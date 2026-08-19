#!/usr/bin/env bash
# bootstrap.sh — copy a playbook tier + stack into a target directory and fill
# the placeholders. Dependencies: bash, coreutils, git. Idempotent: existing
# files are never overwritten unless --force is given. --dry-run shows the plan.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh --target DIR --name "Project Name" [options]

Required:
  --target DIR         directory to bootstrap into (created if missing)
  --name NAME          human-readable project name

Options:
  --slug SLUG          kebab-case slug (default: derived from --name)
  --one-liner TEXT     one-sentence description (default: "TODO: one-liner")
  --tier 0|1|2         ceremony tier (default: 1)
  --stack STACK        python | typescript | docs (default: docs)
  --agents FLAVOR      research | product (default: product for typescript,
                       research otherwise)
  --github-user USER   GitHub handle for {{GITHUB_USER}} (default: git config
                       github.user, else empty)
  --holder NAME        {{COPYRIGHT_HOLDER}} (default: same as --github-user)
  --dry-run            print what would happen; write nothing
  --force              overwrite existing files
  -h, --help           this help
EOF
}

PLAYBOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$PLAYBOOK_DIR/templates"

TARGET="" NAME="" SLUG="" ONE_LINER="TODO: one-liner"
TIER="1" STACK="docs" AGENTS="" GITHUB_USER="" HOLDER=""
DRY_RUN=0 FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)      TARGET="$2"; shift 2 ;;
    --name)        NAME="$2"; shift 2 ;;
    --slug)        SLUG="$2"; shift 2 ;;
    --one-liner)   ONE_LINER="$2"; shift 2 ;;
    --tier)        TIER="$2"; shift 2 ;;
    --stack)       STACK="$2"; shift 2 ;;
    --agents)      AGENTS="$2"; shift 2 ;;
    --github-user) GITHUB_USER="$2"; shift 2 ;;
    --holder)      HOLDER="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    --force)       FORCE=1; shift ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "error: unknown flag: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$TARGET" ] || { echo "error: --target is required" >&2; exit 2; }
[ -n "$NAME" ]   || { echo "error: --name is required" >&2; exit 2; }
case "$TIER"  in 0|1|2) ;; *) echo "error: --tier must be 0, 1, or 2" >&2; exit 2 ;; esac
case "$STACK" in python|typescript|docs) ;; *) echo "error: --stack must be python, typescript, or docs" >&2; exit 2 ;; esac

if [ -z "$SLUG" ]; then
  SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  SLUG="${SLUG#-}"; SLUG="${SLUG%-}"
fi
if [ -z "$AGENTS" ]; then
  if [ "$STACK" = "typescript" ]; then AGENTS="product"; else AGENTS="research"; fi
fi
case "$AGENTS" in research|product) ;; *) echo "error: --agents must be research or product" >&2; exit 2 ;; esac
if [ -z "$GITHUB_USER" ]; then
  GITHUB_USER="$(git config --get github.user 2>/dev/null || true)"
fi
[ -n "$HOLDER" ] || HOLDER="$GITHUB_USER"
YEAR="$(date +%Y)"

WROTE=0 SKIPPED=0

render() { # render SRC DEST — fill placeholders, honor dry-run/force/idempotence
  local src="$1" dest="$TARGET/$2" content
  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
    echo "skip   $2 (exists; use --force to overwrite)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  content="$(cat "$src")"
  content="${content//\{\{PROJECT_NAME\}\}/$NAME}"
  content="${content//\{\{PROJECT_SLUG\}\}/$SLUG}"
  content="${content//\{\{ONE_LINER\}\}/$ONE_LINER}"
  content="${content//\{\{YEAR\}\}/$YEAR}"
  content="${content//\{\{GITHUB_USER\}\}/$GITHUB_USER}"
  content="${content//\{\{STACK\}\}/$STACK}"
  content="${content//\{\{COPYRIGHT_HOLDER\}\}/$HOLDER}"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would  $2"
  else
    mkdir -p "$(dirname "$dest")"
    printf '%s\n' "$content" > "$dest"
    echo "write  $2"
  fi
  WROTE=$((WROTE + 1))
}

append_gitignore() { # append_gitignore SRC MARKER — idempotent append to .gitignore
  local src="$1" marker="$2" dest="$TARGET/.gitignore"
  if [ -e "$dest" ] && grep -qF "$marker" "$dest"; then
    echo "skip   .gitignore append ($marker already present)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would  append $marker block to .gitignore"
  else
    { echo ""; cat "$src"; } >> "$dest"
    echo "write  .gitignore ($marker block appended)"
  fi
  WROTE=$((WROTE + 1))
}

echo "bootstrap: '$NAME' ($SLUG) -> $TARGET  [tier $TIER, stack $STACK, agents $AGENTS]"
[ "$DRY_RUN" -eq 1 ] && echo "-- dry run: nothing will be written --"
[ "$DRY_RUN" -eq 1 ] || mkdir -p "$TARGET"

# Tier 0 — every repo
render "$TEMPLATES/base/README.md.tmpl"    "README.md"
render "$TEMPLATES/base/gitignore.base"    ".gitignore"
render "$TEMPLATES/base/LICENSE.MIT.tmpl"  "LICENSE"

# Tier 1 — projects
if [ "$TIER" -ge 1 ]; then
  render "$TEMPLATES/base/AGENTS.$AGENTS.md.tmpl" "AGENTS.md"
  render "$TEMPLATES/base/CLAUDE.md.tmpl"         "CLAUDE.md"
  render "$TEMPLATES/base/STATUS.md.tmpl"         "STATUS.md"
  render "$TEMPLATES/base/ROADMAP.md.tmpl"        "ROADMAP.md"
  render "$TEMPLATES/docs/adr/0000-template.md"   "docs/adr/0000-template.md"
  render "$TEMPLATES/docs/adr/0001-record-architecture-decisions.md" \
                                                  "docs/adr/0001-record-architecture-decisions.md"
  render "$TEMPLATES/docs/adr/README.md"          "docs/adr/README.md"
  case "$STACK" in
    python)
      render "$TEMPLATES/stacks/python/pyproject.toml.tmpl"       "pyproject.toml"
      render "$TEMPLATES/stacks/python/Makefile.tmpl"             "Makefile"
      render "$TEMPLATES/stacks/python/tests/test_smoke.py.tmpl"  "tests/test_smoke.py"
      render "$TEMPLATES/base/env.example.tmpl"                   ".env.example"
      append_gitignore "$TEMPLATES/stacks/python/gitignore.python" "# Python additions"
      ;;
    typescript)
      render "$TEMPLATES/stacks/typescript/package.json.tmpl" "package.json"
      render "$TEMPLATES/stacks/typescript/tsconfig.json"     "tsconfig.json"
      render "$TEMPLATES/stacks/typescript/eslint.config.js"  "eslint.config.js"
      render "$TEMPLATES/stacks/typescript/vitest.config.ts"  "vitest.config.ts"
      render "$TEMPLATES/base/env.example.tmpl"               ".env.example"
      append_gitignore "$TEMPLATES/stacks/typescript/gitignore.node" "# Node/TypeScript additions"
      ;;
    docs)
      render "$TEMPLATES/docs/research/0000-template.md" "docs/research/0000-template.md"
      render "$TEMPLATES/docs/research/README.md"        "docs/research/README.md"
      ;;
  esac
fi

# Tier 2 — public repos
if [ "$TIER" -ge 2 ]; then
  render "$TEMPLATES/github/PULL_REQUEST_TEMPLATE.md"  ".github/PULL_REQUEST_TEMPLATE.md"
  render "$TEMPLATES/github/ISSUE_TEMPLATE/task.md"    ".github/ISSUE_TEMPLATE/task.md"
  case "$STACK" in
    python)     render "$TEMPLATES/github/workflows/ci-python.yml" ".github/workflows/ci.yml" ;;
    typescript) render "$TEMPLATES/github/workflows/ci-node.yml"   ".github/workflows/ci.yml" ;;
    docs)       ;; # no CI for docs-only repos
  esac
fi

echo "done: $WROTE written/planned, $SKIPPED skipped."
if [ "$DRY_RUN" -eq 0 ]; then
  echo "next: fill remaining TODOs, pick ONE AGENTS.md flavor's optional sections,"
  echo "      then: cd $TARGET && git init && git add -A && git commit -m 'chore: bootstrap from repo-playbook'"
  if [ -z "$GITHUB_USER" ]; then
    echo "note: {{GITHUB_USER}}/{{COPYRIGHT_HOLDER}} were empty — grep for blanks in README/LICENSE."
  fi
fi
