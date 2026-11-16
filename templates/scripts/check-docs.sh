#!/usr/bin/env bash
# <!-- proposed: not currently in my repos -->
# check-docs.sh — keep the docs that agents read small.
#
# Files read every session are snapshots with a size limit; history lives in
# git. This fails when one outgrows its limit, or when a new markdown file
# appears at the repo root, which is where logs like NOTES.md or HANDOFF.md
# tend to start. Run it from anywhere: `bash scripts/check-docs.sh`. CI runs
# it, and so does the Claude Code hook in .claude/settings.json.
#
# Raising a limit or adding a root doc is the owner's decision.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# file:max-lines — a file that does not exist is skipped.
LIMITS="
AGENTS.md:200
STATUS.md:60
ROADMAP.md:150
docs/known-issues.md:100
"
STATUS_MAX_BYTES=6000 # a few very long lines cost as much as many short ones
ADR_MAX_LINES=80      # about a page; anything longer is a design doc
# Markdown files allowed at the repo root. Everything else belongs under docs/.
ROOT_DOCS="README.md AGENTS.md CLAUDE.md CLAUDE.local.md STATUS.md ROADMAP.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md"

fail=0

count() { wc "$1" < "$2" | tr -d '[:space:]'; }

over() { # over FILE ACTUAL LIMIT UNIT
  echo "check-docs: $1 is $2 $4; the limit is $3." >&2
  fail=1
}

for entry in $LIMITS; do
  file="${entry%%:*}"
  max="${entry##*:}"
  [ -f "$file" ] || continue
  lines="$(count -l "$file")"
  [ "$lines" -le "$max" ] || over "$file" "$lines" "$max" lines
done

if [ -f STATUS.md ]; then
  bytes="$(count -c STATUS.md)"
  [ "$bytes" -le "$STATUS_MAX_BYTES" ] || over STATUS.md "$bytes" "$STATUS_MAX_BYTES" bytes
fi

for file in docs/adr/[0-9]*.md; do
  [ -f "$file" ] || continue
  lines="$(count -l "$file")"
  [ "$lines" -le "$ADR_MAX_LINES" ] || over "$file" "$lines" "$ADR_MAX_LINES" lines
done

for file in *.md; do
  [ -f "$file" ] || continue
  case " $ROOT_DOCS " in
    *" $file "*) ;;
    *)
      echo "check-docs: $file is not an expected markdown file at the repo root." >&2
      fail=1
      ;;
  esac
done

if [ "$fail" -ne 0 ]; then
  cat >&2 <<'EOF'

How to fix:
- Over a limit: delete lines that are no longer true or no longer needed. Do
  not move them to another file. What happened is in `git log`.
- Unexpected root file: durable docs go under docs/. Session notes and logs do
  not go in the repo at all; put what you did in the commit body.
- The limits and the root list live in scripts/check-docs.sh. Changing them is
  the owner's decision: ask, do not edit.
EOF
  exit 1
fi
echo "check-docs: ok"
