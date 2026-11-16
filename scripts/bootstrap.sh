#!/usr/bin/env bash
# bootstrap.sh — copy a playbook tier, kind, and stack into a target directory
# and fill the placeholders. Dependencies: bash 3.2+, coreutils, git.
#
# Idempotent: an existing file is never overwritten unless --force is given,
# and shared files (.gitignore, README.md, AGENTS.md) are appended to at most
# once. That makes it safe to run on top of a repo an upstream scaffolder
# created, and to re-run with a higher --tier to promote a repo.
# --dry-run shows the plan.
set -euo pipefail
# bash >= 5.2 expands "&" in the replacement of ${var//pat/repl} to the matched
# text, which mangles a name like "R&D Tool". Quoting the replacement avoids
# that but inserts literal quotes on bash 3.2 (macOS), so switch the option off
# where it exists instead.
shopt -u patsub_replacement 2>/dev/null || true

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
  --kind KIND          product | research (default: product). research appends
                       the research rules to AGENTS.md and adds docs/research/
  --stack STACK        python | typescript | none (default: none). Use none for
                       a docs-only repo, or when an upstream scaffolder already
                       created the code and its tooling
  --check-cmd CMD      the command that runs this repo's full gate, written
                       into AGENTS.md (default: "make check" for python,
                       "pnpm check" for typescript, the docs gate for none)
  --github-user USER   GitHub handle; only used as the default for --holder
                       (default: git config github.user, else empty)
  --holder NAME        {{COPYRIGHT_HOLDER}} (default: same as --github-user)
  --dry-run            print what would happen; write nothing
  --force              overwrite existing files
  -h, --help           this help

Kind and stack are independent: any kind works with any stack.
Older spellings still work: --agents for --kind, --stack docs for --stack none.
EOF
}

PLAYBOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$PLAYBOOK_DIR/templates"

TARGET="" NAME="" SLUG="" ONE_LINER="TODO: one-liner"
TIER="1" STACK="none" KIND="product" CHECK_CMD="" GITHUB_USER="" HOLDER=""
DRY_RUN=0 FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)        TARGET="$2"; shift 2 ;;
    --name)          NAME="$2"; shift 2 ;;
    --slug)          SLUG="$2"; shift 2 ;;
    --one-liner)     ONE_LINER="$2"; shift 2 ;;
    --tier)          TIER="$2"; shift 2 ;;
    --stack)         STACK="$2"; shift 2 ;;
    --kind|--agents) KIND="$2"; shift 2 ;;
    --check-cmd)     CHECK_CMD="$2"; shift 2 ;;
    --github-user)   GITHUB_USER="$2"; shift 2 ;;
    --holder)        HOLDER="$2"; shift 2 ;;
    --dry-run)       DRY_RUN=1; shift ;;
    --force)         FORCE=1; shift ;;
    -h|--help)       usage; exit 0 ;;
    *) echo "error: unknown flag: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ -n "$TARGET" ] || { echo "error: --target is required" >&2; exit 2; }
[ -n "$NAME" ]   || { echo "error: --name is required" >&2; exit 2; }
[ "$STACK" != "docs" ] || STACK="none"
case "$TIER"  in 0|1|2) ;; *) echo "error: --tier must be 0, 1, or 2" >&2; exit 2 ;; esac
case "$STACK" in python|typescript|none) ;; *) echo "error: --stack must be python, typescript, or none" >&2; exit 2 ;; esac
case "$KIND"  in research|product) ;; *) echo "error: --kind must be research or product" >&2; exit 2 ;; esac

if [ -z "$SLUG" ]; then
  SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  SLUG="${SLUG#-}"; SLUG="${SLUG%-}"
fi
if [ -z "$CHECK_CMD" ]; then
  case "$STACK" in
    python)     CHECK_CMD="make check" ;;
    typescript) CHECK_CMD="pnpm check" ;;
    none)       CHECK_CMD="bash scripts/check-docs.sh" ;;
  esac
fi
if [ -z "$GITHUB_USER" ]; then
  GITHUB_USER="$(git config --get github.user 2>/dev/null || true)"
fi
[ -n "$HOLDER" ] || HOLDER="$GITHUB_USER"
YEAR="$(date +%Y)"
# Python package names cannot contain hyphens or start with a digit.
PKG="${SLUG//-/_}"
case "$PKG" in [0-9]*) PKG="_$PKG" ;; esac

escape_quoted() { # escape_quoted VALUE — make VALUE safe inside a JSON/TOML "string"
  local v="$1"
  v="${v//\\/\\\\}"
  v="${v//\"/\\\"}"
  printf '%s' "$v"
}

WROTE=0 SKIPPED=0 LEFT_ALONE=""

fill() { # fill SRC DEST — print SRC with placeholders filled, escaped for DEST's type
  local src="$1" content name="$NAME" one_liner="$ONE_LINER" holder="$HOLDER"
  case "$2" in
    *.json|*.toml) # free-text values land inside quoted strings in these files
      name="$(escape_quoted "$NAME")"
      one_liner="$(escape_quoted "$ONE_LINER")"
      holder="$(escape_quoted "$HOLDER")"
      ;;
  esac
  # The "proposed" marker is a note to the playbook's maintainer. It means
  # nothing in a generated repo, so it does not travel.
  content="$(grep -vxE '(# )?<!-- proposed: not currently in my repos -->' "$src" || true)"
  content="${content//\{\{PROJECT_NAME\}\}/$name}"
  content="${content//\{\{PROJECT_SLUG\}\}/$SLUG}"
  content="${content//\{\{PROJECT_PKG\}\}/$PKG}"
  content="${content//\{\{ONE_LINER\}\}/$one_liner}"
  content="${content//\{\{CHECK_CMD\}\}/$CHECK_CMD}"
  content="${content//\{\{YEAR\}\}/$YEAR}"
  content="${content//\{\{COPYRIGHT_HOLDER\}\}/$holder}"
  printf '%s\n' "$content"
}

render() { # render SRC DEST — write a whole file; honor dry-run/force/idempotence
  local src="$1" dest="$TARGET/$2"
  if [ -e "$dest" ] && [ "$FORCE" -ne 1 ]; then
    echo "skip   $2 (exists; use --force to overwrite)"
    SKIPPED=$((SKIPPED + 1))
    LEFT_ALONE="$LEFT_ALONE $2"
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would  $2"
  else
    mkdir -p "$(dirname "$dest")"
    fill "$src" "$2" > "$dest"
    echo "write  $2"
  fi
  WROTE=$((WROTE + 1))
}

append_block() { # append_block SRC DEST — append SRC to DEST once; SRC's first line is the marker
  local src="$1" dest="$TARGET/$2" marker
  marker="$(head -n 1 "$src")"
  if [ -e "$dest" ] && grep -qxF -- "$marker" "$dest"; then
    echo "skip   $2 append (\"$marker\" already present)"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would  append \"$marker\" block to $2"
  else
    mkdir -p "$(dirname "$dest")"
    if [ -s "$dest" ]; then echo "" >> "$dest"; fi
    fill "$src" "$2" >> "$dest"
    echo "write  $2 (\"$marker\" block appended)"
  fi
  WROTE=$((WROTE + 1))
}

echo "bootstrap: '$NAME' ($SLUG) -> $TARGET  [tier $TIER, kind $KIND, stack $STACK]"
[ "$DRY_RUN" -eq 1 ] && echo "-- dry run: nothing will be written --"
[ "$DRY_RUN" -eq 1 ] || mkdir -p "$TARGET"

# Tier 0 — every repo. The gitignore is appended, not rendered, so the secrets
# block still lands when a scaffolder has already written a .gitignore.
render       "$TEMPLATES/base/README.md.tmpl"    "README.md"
append_block "$TEMPLATES/base/gitignore.base"    ".gitignore"
render       "$TEMPLATES/base/LICENSE.MIT.tmpl"  "LICENSE"

# Tier 1 — projects
if [ "$TIER" -ge 1 ]; then
  append_block "$TEMPLATES/base/README.tier1.md.tmpl" "README.md"
  render "$TEMPLATES/base/AGENTS.md.tmpl"         "AGENTS.md"
  if [ "$KIND" = "research" ]; then
    append_block "$TEMPLATES/base/AGENTS.research.md.tmpl" "AGENTS.md"
    render "$TEMPLATES/docs/research/0000-template.md" "docs/research/0000-template.md"
    render "$TEMPLATES/docs/research/README.md"        "docs/research/README.md"
  fi
  render "$TEMPLATES/base/CLAUDE.md.tmpl"         "CLAUDE.md"
  render "$TEMPLATES/base/STATUS.md.tmpl"         "STATUS.md"
  render "$TEMPLATES/base/ROADMAP.md.tmpl"        "ROADMAP.md"
  render "$TEMPLATES/docs/adr/0000-template.md"   "docs/adr/0000-template.md"
  render "$TEMPLATES/docs/adr/0001-record-architecture-decisions.md" \
                                                  "docs/adr/0001-record-architecture-decisions.md"
  render "$TEMPLATES/docs/adr/README.md"          "docs/adr/README.md"
  render "$TEMPLATES/scripts/check-docs.sh"       "scripts/check-docs.sh"
  case "$STACK" in
    python)
      render "$TEMPLATES/stacks/python/pyproject.toml.tmpl"       "pyproject.toml"
      render "$TEMPLATES/stacks/python/Makefile.tmpl"             "Makefile"
      render "$TEMPLATES/stacks/python/src/__init__.py"           "src/$PKG/__init__.py"
      render "$TEMPLATES/stacks/python/tests/test_smoke.py.tmpl"  "tests/test_smoke.py"
      render "$TEMPLATES/base/env.example.tmpl"                   ".env.example"
      render "$TEMPLATES/github/workflows/ci-python.yml"          ".github/workflows/ci.yml"
      append_block "$TEMPLATES/stacks/python/gitignore.python"    ".gitignore"
      ;;
    typescript)
      render "$TEMPLATES/stacks/typescript/package.json.tmpl" "package.json"
      render "$TEMPLATES/stacks/typescript/tsconfig.json"     "tsconfig.json"
      render "$TEMPLATES/stacks/typescript/eslint.config.js"  "eslint.config.js"
      render "$TEMPLATES/stacks/typescript/vitest.config.ts"  "vitest.config.ts"
      render "$TEMPLATES/stacks/typescript/src/index.ts"      "src/index.ts"
      render "$TEMPLATES/stacks/typescript/tests/smoke.test.ts" "tests/smoke.test.ts"
      render "$TEMPLATES/base/env.example.tmpl"               ".env.example"
      render "$TEMPLATES/github/workflows/ci-node.yml"        ".github/workflows/ci.yml"
      append_block "$TEMPLATES/stacks/typescript/gitignore.node" ".gitignore"
      ;;
    none)
      render "$TEMPLATES/github/workflows/ci-docs.yml"        ".github/workflows/ci.yml"
      ;;
  esac
fi

# Tier 2 — public repos
if [ "$TIER" -ge 2 ]; then
  render "$TEMPLATES/github/PULL_REQUEST_TEMPLATE.md"  ".github/PULL_REQUEST_TEMPLATE.md"
  render "$TEMPLATES/github/ISSUE_TEMPLATE/task.md"    ".github/ISSUE_TEMPLATE/task.md"
fi

echo "done: $WROTE written/planned, $SKIPPED skipped."
if [ "$DRY_RUN" -eq 0 ]; then
  if [ -n "$LEFT_ALONE" ] && [ "$WROTE" -gt 0 ]; then
    echo "left alone because they already existed — merge by hand if they came from"
    echo "a scaffolder rather than from this playbook:$LEFT_ALONE"
  fi
  echo "next: fill the remaining TODO slots, then:"
  echo "      cd $TARGET && git init"
  if [ "$TIER" -ge 1 ] && [ "$STACK" = "typescript" ]; then
    echo "      pnpm install && pnpm check   # writes pnpm-lock.yaml; commit it, CI installs frozen"
  elif [ "$TIER" -ge 1 ] && [ "$STACK" = "python" ]; then
    echo "      uv sync && make check        # writes uv.lock; commit it, CI installs with --locked"
  fi
  echo "      git add -A && git commit -m 'chore: bootstrap from repo-playbook'"
  if [ "$TIER" -ge 1 ]; then
    echo "opt-in templates, copied by hand when needed: docs/runbook.md.tmpl,"
    echo "      docs/known-issues.md.tmpl, github/workflows/scheduled-job.yml"
  fi
  if [ -z "$HOLDER" ]; then
    echo "note: {{COPYRIGHT_HOLDER}} was empty — fill the blank in LICENSE."
  fi
fi
