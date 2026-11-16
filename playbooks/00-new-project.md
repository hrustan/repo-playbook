# Playbook 00 — New project, day zero

The steps in order. Total time: five minutes for a spike, thirty for a project.

## 1. Pick the tier

- **Tier 0 (spike)** — you might throw this away. Also the right shape for flat
  single-purpose tools: a handful of modules at the repo root, a README that is the
  entire doc surface (a table of what it does, worked invocations, output shapes,
  and a one-line extension rule), and no ceremony. Browser-extension experiments
  and CI-matrix data pullers live here happily forever.
- **Tier 1 (project)** — it will get a second session of work, a second
  contributor (human or agent), or a first non-obvious decision.
- **Tier 2 (public)** — a stranger will read it. Do Tier 1 first, then
  [90-open-sourcing.md](90-open-sourcing.md).

When unsure, start at Tier 0 and promote — see
[../checklists/tier-promotion.md](../checklists/tier-promotion.md). Never start a
spike at Tier 1; unfilled ceremony rots and trains you to ignore it.

## 2. Bootstrap

```sh
path/to/repo-playbook/scripts/bootstrap.sh \
  --target ../new-project --name "New Project" \
  --one-liner "What it does." --tier 1 --kind product --stack python
```

Kind (`product` or `research`) and stack (`python`, `typescript`, or `none`) are
independent choices. The script never overwrites a file without `--force`, and
it appends to `.gitignore`, `README.md`, and `AGENTS.md` at most once, so it is
safe to run on top of a repo a scaffolder created and to re-run with a higher
`--tier` to promote a repo.

Or copy files by hand and fill every `{{...}}` placeholder (grep for `{{` after).

## 3. Tier 1 setup, in order

1. **AGENTS.md** — one shared file; research repos get the research rules
   appended (`--kind research`, or paste `AGENTS.research.md.tmpl` at the end
   by hand). Fill the project-specific slots: the one boundary/firewall rule, and
   (research) the pre-registered gate. Delete sections that don't apply; lean
   beats complete.
2. **STATUS.md** — write the real phase board and the first changelog entry.
3. **ROADMAP.md** — phases with gates AND kill criteria, written before the work.
4. **docs/adr/** — ADR-0001 is included; your first real decision is ADR-0002.
   Often that's the stack choice.
5. **Stack files** — from `templates/stacks/<stack>/`. Append the stack gitignore
   to the base one.
6. **.env.example** — only if there are secrets. Names only, per-variable comment.
7. **CI** — copy the matching `ci-*.yml` into `.github/workflows/`. Do this the
   same day tests exist; a green suite nothing enforces is how repos drift.
8. First commit: `chore: bootstrap from repo-playbook`, then Conventional Commits
   from there on.

## 4. The standing rules (all tiers)

- README is a map, never state. State lives in STATUS.md only.
- Every new doc gets a README doc-index row in the same commit.
- Trunk-only for Tier 0. Tier 1+: branch `feat/<kebab-slug>` (or
  `phase-N/<slug>`), PR, merge, delete the branch.
- Enforcement is CI plus the PR checklist — not git hooks.
