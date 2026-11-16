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
     --one-liner "What it does in one sentence" --tier 1 --stack python
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

Four root files with strict, non-overlapping roles:

> **README = map · ROADMAP = forward plan · STATUS = decision log & live state · AGENTS = the rules.**

- README never carries state. It is an index; every new doc gets a row in it **in
  the same commit** that creates the doc.
- STATUS.md opens with `Last updated:` and ends with a changelog. Agents read it
  first and update it before ending a session. This is the load-bearing file.
- ADRs are immutable. To change a decision, write a new ADR that supersedes the old
  one and link both ways.
- Perishable numbers live only in dated docs; living docs never carry a count or
  dollar figure unless tagged `as of YYYY-MM-DD`.

## Template index

| Path | What it is |
|------|-----------|
| [templates/base/README.md.tmpl](templates/base/README.md.tmpl) | Map-style README with doc index |
| [templates/base/AGENTS.research.md.tmpl](templates/base/AGENTS.research.md.tmpl) | Agent rules — research flavor (validation gates, kill criteria) |
| [templates/base/AGENTS.product.md.tmpl](templates/base/AGENTS.product.md.tmpl) | Agent rules — product flavor (session loop, Definition of Done) |
| [templates/base/CLAUDE.md.tmpl](templates/base/CLAUDE.md.tmpl) | Two-line shim for tools that only read CLAUDE.md |
| [templates/base/STATUS.md.tmpl](templates/base/STATUS.md.tmpl) | Live state: phase board, open decisions, handoff notes, changelog |
| [templates/base/ROADMAP.md.tmpl](templates/base/ROADMAP.md.tmpl) | Gated phases, each with a kill criterion |
| [templates/base/gitignore.base](templates/base/gitignore.base) | Commented, policy-citing ignore skeleton |
| [templates/base/env.example.tmpl](templates/base/env.example.tmpl) | Names-only env file with per-variable exposure notes |
| [templates/base/LICENSE.MIT.tmpl](templates/base/LICENSE.MIT.tmpl) | MIT license |
| [templates/docs/adr/0000-template.md](templates/docs/adr/0000-template.md) | ADR template (immutable-decision format) |
| [templates/docs/adr/0001-record-architecture-decisions.md](templates/docs/adr/0001-record-architecture-decisions.md) | Meta-ADR adopting the ADR practice |
| [templates/docs/adr/README.md](templates/docs/adr/README.md) | ADR index convention |
| [templates/docs/research/0000-template.md](templates/docs/research/0000-template.md) | Numbered research note |
| [templates/docs/research/README.md](templates/docs/research/README.md) | What goes in research/ vs adr/ |
| [templates/docs/runbook.md.tmpl](templates/docs/runbook.md.tmpl) | Operator runbook, TL;DR first |
| [templates/docs/known-issues.md.tmpl](templates/docs/known-issues.md.tmpl) | KI-coded known-issues register |
| [templates/github/workflows/ci-node.yml](templates/github/workflows/ci-node.yml) | Node/pnpm quality gate |
| [templates/github/workflows/ci-python.yml](templates/github/workflows/ci-python.yml) | Python quality gate |
| [templates/github/workflows/scheduled-job.yml](templates/github/workflows/scheduled-job.yml) | Cron job skeleton with header-comment runbook |
| [templates/github/ISSUE_TEMPLATE/task.md](templates/github/ISSUE_TEMPLATE/task.md) | Phase-task issue template |
| [templates/github/PULL_REQUEST_TEMPLATE.md](templates/github/PULL_REQUEST_TEMPLATE.md) | PR template mirroring the AGENTS.md Definition of Done |
| [templates/stacks/python/](templates/stacks/python/) | pyproject, venv-pinned Makefile, guardrail smoke test, gitignore |
| [templates/stacks/typescript/](templates/stacks/typescript/) | strict tsconfig, flat ESLint, vitest config, package scripts, gitignore |
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
| `{{YEAR}}` | Current year | `2026` |
| `{{COPYRIGHT_HOLDER}}` | Name on the LICENSE line | your name or handle |

## Proposed additions

Items marked `<!-- proposed: not currently in my repos -->` were not observed in the
audited repos; they fill gaps the audit surfaced. Adopt or delete deliberately:

- `templates/base/CLAUDE.md.tmpl` — shim so CLAUDE.md-only tools find AGENTS.md
- `templates/docs/adr/0001-record-architecture-decisions.md` — meta-ADR
- `templates/github/workflows/ci-python.yml` — the Python CI gate none of my Python repos had
- `checklists/tier-promotion.md` — explicit spike→project triggers
- the `uv` lockfile note in [playbooks/10-python-research.md](playbooks/10-python-research.md)

## License

MIT — see [LICENSE](LICENSE).
