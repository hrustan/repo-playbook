# repo-playbook

Reusable conventions, templates, and runbooks for starting a new repository —
extracted from an audit of my real repos, not from best practices in the abstract.
Every template here is something I have actually shipped at least once; the handful
of net-new items are listed under [Proposed additions](#proposed-additions).

The goal: any agent (human or AI) opening a repo built from this playbook can pick
up the full context — current progress, blockers, open decisions, research, plans —
from a handful of predictable files, in one read.

## How to use it

Two ways, interchangeable:

1. **GitHub template repo** — click *Use this template*, then delete the tiers you
   don't need and fill the placeholders.
2. **Bootstrap script** — copy a tier + stack into a target directory:

   ```sh
   scripts/bootstrap.sh --target ../my-project --name "My Project" \
     --one-liner "What it does in one sentence" --tier 1 --kind product --stack python
   ```

   Supports `--dry-run` (show what would happen) and `--force` (overwrite existing
   files; without it, existing files are always left alone). Run with `--help` for
   all flags.

Start with [playbooks/00-new-project.md](playbooks/00-new-project.md) — it walks the
day-zero steps in order and tells you which tier you need.

## Tiers

Ceremony scales with maturity. Don't give a spike the furniture of a product.

| Tier | For | Gets |
|------|-----|------|
| **0 — spike** | throwaway experiments, one-shot tools, flat script repos | `README.md`, minimal `.gitignore`, `LICENSE`. Nothing else. Trunk-only. |
| **1 — project** | anything getting a second session of work or a first real decision | Tier 0 + `AGENTS.md`, `STATUS.md`, `ROADMAP.md`, `docs/adr/`, `.env.example`, stack tooling, tests, CI gate |
| **2 — public** | anything a stranger will read | Tier 1 + README rewritten for strangers, PII sweep, issue/PR templates, pruned branches |

Promotion triggers are in [checklists/tier-promotion.md](checklists/tier-promotion.md).

## The doc system (the part that matters)

One rule, learned from real use and explained in
[playbooks/01-doc-system.md](playbooks/01-doc-system.md):

> Files an agent reads every session are small snapshots, edited in place. Git
> is the log. Anything allowed to grow is read only on demand.

Four root files with strict, non-overlapping roles:

> **README = map · ROADMAP = forward plan · STATUS = snapshot of now · AGENTS = the rules.**

- README never carries state. It indexes doc trees and living docs; dated notes
  and ADRs are indexed inside their own tree.
- STATUS.md is four short sections with a 60-line limit. Agents fix what is no
  longer true and never append. History is `git log`.
- ROADMAP.md is forward-only: a finished phase is deleted.
- `scripts/check-docs.sh` enforces the limits in CI and in the local gate, so
  the rule does not depend on an agent choosing to follow it.
- ADRs are rare and need the owner's approval. A decision gets one only when it
  is costly to reverse and a real alternative was rejected; everything else is
  recorded by the commit that made it. Agents propose, they do not write one
  unprompted. An accepted ADR is superseded, never edited.
- Perishable numbers live only in dated docs; living docs never carry a count or
  dollar figure unless tagged `as of YYYY-MM-DD`.

## Template index

| Path | What it is |
|------|-----------|
| [templates/base/README.md.tmpl](templates/base/README.md.tmpl) | README every repo gets: name, one-liner, quickstart |
| [templates/base/README.tier1.md.tmpl](templates/base/README.tier1.md.tmpl) | Map block appended to the README at Tier 1 (start-here links, doc index) |
| [templates/base/AGENTS.md.tmpl](templates/base/AGENTS.md.tmpl) | Agent rules every repo gets (session loop, Definition of Done) |
| [templates/base/AGENTS.research.md.tmpl](templates/base/AGENTS.research.md.tmpl) | Research rules appended to AGENTS.md (mission, pre-registered gates, data hygiene) |
| [templates/base/CLAUDE.md.tmpl](templates/base/CLAUDE.md.tmpl) | Two-line shim for tools that only read CLAUDE.md |
| [templates/base/STATUS.md.tmpl](templates/base/STATUS.md.tmpl) | Snapshot of now: in flight, next, needs owner, watch out |
| [templates/base/ROADMAP.md.tmpl](templates/base/ROADMAP.md.tmpl) | Forward-only gated phases, each with a kill criterion |
| [templates/base/gitignore.base](templates/base/gitignore.base) | Commented, policy-citing ignore skeleton |
| [templates/base/env.example.tmpl](templates/base/env.example.tmpl) | Names-only env file with per-variable exposure notes |
| [templates/base/LICENSE.MIT.tmpl](templates/base/LICENSE.MIT.tmpl) | MIT license |
| [templates/docs/adr/0000-template.md](templates/docs/adr/0000-template.md) | ADR template, with an approval line and rejected alternatives |
| [templates/docs/adr/README.md](templates/docs/adr/README.md) | ADR index, the bar a decision must clear, and the owner gate |
| [templates/docs/research/0000-template.md](templates/docs/research/0000-template.md) | Numbered research note |
| [templates/docs/research/README.md](templates/docs/research/README.md) | Research-note index, and what goes in research/ vs adr/ |
| [templates/docs/runbook.md.tmpl](templates/docs/runbook.md.tmpl) | Operator runbook, TL;DR first |
| [templates/docs/known-issues.md.tmpl](templates/docs/known-issues.md.tmpl) | KI-coded register of open issues |
| [templates/scripts/check-docs.sh](templates/scripts/check-docs.sh) | Docs gate: size limits on the files agents read every session, and no stray root docs |
| [templates/github/workflows/ci-node.yml](templates/github/workflows/ci-node.yml) | Node/pnpm quality gate |
| [templates/github/workflows/ci-python.yml](templates/github/workflows/ci-python.yml) | Python quality gate |
| [templates/github/workflows/ci-docs.yml](templates/github/workflows/ci-docs.yml) | Docs gate only, for repos with no code stack |
| [templates/github/workflows/scheduled-job.yml](templates/github/workflows/scheduled-job.yml) | Cron job skeleton with header-comment runbook |
| [templates/github/ISSUE_TEMPLATE/task.md](templates/github/ISSUE_TEMPLATE/task.md) | Phase-task issue template |
| [templates/github/PULL_REQUEST_TEMPLATE.md](templates/github/PULL_REQUEST_TEMPLATE.md) | PR template mirroring the AGENTS.md Definition of Done |
| [templates/stacks/python/](templates/stacks/python/) | pyproject, uv-driven Makefile, package seed, guardrail smoke test, gitignore |
| [templates/stacks/typescript/](templates/stacks/typescript/) | strict tsconfig, flat ESLint, vitest config, package scripts, seed source and smoke test, gitignore |
| [checklists/](checklists/) | new-repo, tier-promotion, pre-publish PII sweep, archive-repo |
| [playbooks/](playbooks/) | The long-form how-and-why for each stack |

## Placeholders

Every `.tmpl` file uses these; `scripts/bootstrap.sh` fills them all.

| Placeholder | Meaning | Example |
|-------------|---------|---------|
| `{{PROJECT_NAME}}` | Human-readable name | `My Project` |
| `{{PROJECT_SLUG}}` | kebab-case repo/package name | `my-project` |
| `{{PROJECT_PKG}}` | snake_case Python package name, derived from the slug | `my_project` |
| `{{ONE_LINER}}` | One-sentence description | `Watches X and reports Y.` |
| `{{CHECK_CMD}}` | The command that runs the repo's full gate | `make check` |
| `{{YEAR}}` | Current year | `2026` |
| `{{COPYRIGHT_HOLDER}}` | Name on the LICENSE line | your name or handle |

## Proposed additions

Items marked `<!-- proposed: not currently in my repos -->` were not observed in the
audited repos; they fill gaps the audit surfaced. Adopt or delete deliberately:

- `templates/base/CLAUDE.md.tmpl` — shim so CLAUDE.md-only tools find AGENTS.md
- `templates/github/workflows/ci-python.yml` — the Python CI gate none of my Python repos had
- `checklists/tier-promotion.md` — explicit spike→project triggers
- `templates/scripts/check-docs.sh` and `templates/github/workflows/ci-docs.yml` —
  the docs gate, added after STATUS.md and ADR counts grew without limit in real use
- the `uv` workflow (`uv sync`, `uv run`, committed `uv.lock`) in the Python stack and [playbooks/10-python-research.md](playbooks/10-python-research.md)

## License

MIT — see [LICENSE](LICENSE).
