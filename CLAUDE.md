# CLAUDE.md — using this repo

This repo is a **source of templates**, not a project. Nothing in `templates/` runs
here; placeholders like `{{PROJECT_NAME}}` are intentional and must never be
"fixed" in place.

## When asked to start a new project from this playbook

1. Read [playbooks/00-new-project.md](playbooks/00-new-project.md) and pick the tier
   (0 spike / 1 project / 2 public) with the user. Default to the *lowest* tier that
   fits — do not give a spike Tier 1 ceremony.
2. Copy files with `scripts/bootstrap.sh` (preferred — it fills placeholders and
   never overwrites without `--force`), or by hand for a one-off file. Pass the
   script the chosen tier as `--tier`, since it defaults to Tier 1. For Tier 1+,
   decide the kind (research or product) and the stack (python, typescript, or
   none) before copying; they are independent. Every repo gets the shared
   AGENTS.md, and `--kind research` appends the research rules to it.
3. If copying by hand, fill every `{{...}}` placeholder; the full list is in the
   README. Grep for `{{` afterward to confirm none remain.
4. For Tier 1+, delete any AGENTS.md template sections that don't apply. A lean
   AGENTS.md an agent actually reads beats a complete one nobody does.

## When asked to modify this repo

- Templates stay **short**; explanation and rationale belong in `playbooks/`.
- Anything added that wasn't observed in a real repo gets an inline
  `<!-- proposed: not currently in my repos -->` marker and a row in the README's
  "Proposed additions" section.
- Every new template, checklist, or playbook gets an entry in the README template
  index **in the same commit**.
- Templates must stay valid as-is: YAML and TOML must parse, shell must pass
  shellcheck, markdown links must resolve.
- Never put a real secret, email, or absolute path in any file here. Run
  [checklists/pre-publish-pii-sweep.md](checklists/pre-publish-pii-sweep.md) before
  any push that adds content.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`) for all commits.
