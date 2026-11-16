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

## 2. Pick the kind and the stack

Two independent choices. Any kind works with any stack.

| | What it decides | Playbook |
|---|---|---|
| **Kind: product** (default) | the shared rules: session loop, Definition of Done, boundaries | — |
| **Kind: research** | adds pre-registered gates, kill criteria, data hygiene, `docs/research/` | [20-research.md](20-research.md) |
| **Stack: python** | uv, ruff, pytest, Makefile, CI | [10-python.md](10-python.md) |
| **Stack: typescript** | pnpm, strict tsconfig, ESLint, vitest, CI | [11-typescript.md](11-typescript.md) |
| **Stack: none** (default) | no tooling: a docs-only repo, or code an upstream scaffolder made | [12-docs-only.md](12-docs-only.md) |

There is deliberately no flavor per framework or target (web app, browser
extension, CLI). Run the framework's own scaffolder, then bootstrap on top with
`--stack none`; [11-typescript.md](11-typescript.md) walks it. A new stack or
kind is added here only after two real repos needed the same files.

## 3. Bootstrap

```sh
path/to/repo-playbook/scripts/bootstrap.sh \
  --target ../new-project --name "New Project" \
  --one-liner "What it does." --tier 1 --kind product --stack python
```

The script never overwrites a file without `--force`, and it appends to
`.gitignore`, `README.md`, and `AGENTS.md` at most once, so it is safe to run on
top of a repo a scaffolder created and to re-run with a higher `--tier` to
promote a repo.

If the playbook has been idle for a couple of months, run its CI by hand first
(Actions → CI → Run workflow). It bootstraps every kind × stack and runs the
result's gate, so it tells you whether a pinned version has gone stale. GitHub
pauses the weekly run after 60 days without activity.

Or copy files by hand and fill every `{{...}}` placeholder (grep for `{{` after).

## 4. Tier 1 setup, in order

1. **AGENTS.md** — one shared file; research repos get the research rules
   appended (`--kind research`, or paste `AGENTS.research.md.tmpl` at the end
   by hand). Fill the project-specific slots: the one boundary/firewall rule, and
   (research) the pre-registered gate. Delete sections that don't apply; lean
   beats complete.
2. **STATUS.md** — fill "Now" and "Next". It is a snapshot with a 60-line limit,
   never a log; see [01-doc-system.md](01-doc-system.md).
3. **ROADMAP.md** — phases with gates AND kill criteria, written before the work.
4. **docs/adr/** — starts with only the index and the template, and is meant to
   stay nearly empty. An ADR is for a decision that is costly to reverse, and
   each one needs your approval; see [01-doc-system.md](01-doc-system.md).
5. **Stack files** — from `templates/stacks/<stack>/`. Install once and commit
   the lockfile (`uv.lock` or `pnpm-lock.yaml`); CI installs frozen and fails
   without it.
6. **.env.example** — only if there are secrets. Names only, per-variable comment.
7. **CI** — bootstrap copies the matching workflow. Confirm the gate is green
   locally first (`make check`, `pnpm check`, or `bash scripts/check-docs.sh`).
8. First commit: `chore: bootstrap from repo-playbook`, then Conventional Commits
   from there on.

## 5. The standing rules (all tiers)

- README is a map, never state. Current state lives in STATUS.md only; history
  lives in git only.
- Every new doc tree or living doc gets a README row in the same commit. Dated
  notes and ADRs are indexed in their own tree's README.
- On GitHub, set squash-merge's default commit message to "Pull request title
  and description" (Settings → General → Pull Requests). The commit body is the
  project's history, and a PR description that never reaches git is lost to it.
- Trunk-only for Tier 0. Tier 1+: branch `feat/<kebab-slug>` (or
  `phase-N/<slug>`), PR, merge, delete the branch.
- Enforcement is CI plus the PR checklist — not git hooks. CI includes the docs
  gate, `scripts/check-docs.sh`, at every tier from 1 up. Claude Code sessions
  also get it after every edit, through the hook in `.claude/settings.json`.
