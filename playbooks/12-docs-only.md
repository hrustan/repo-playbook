# Playbook 12 — No code stack (docs-only)

For `--stack none` used as thinking-in-git: idea engines, domain research hubs,
decision scaffolds for a project that doesn't have code yet. Git is the
database; markdown is the runtime; the agent file is the program.

`--stack none` has a second use, a repo whose code an upstream scaffolder
created. That case is covered in [00-new-project.md](00-new-project.md).

## Shape

```
AGENTS.md      # the rules — an agent reads this, then STATUS, then acts
README.md      # map: one row per doc tree or living doc
STATUS.md      # a snapshot: now, next, needs owner, watch out (60-line limit)
ROADMAP.md     # gated phases with kill criteria, forward-only
docs/          # partitioned by KIND, not topic:
  adr/         #   the few costly-to-reverse decisions, owner-approved
  research/    #   dated or numbered snapshots (never rewritten), own index
  reference/   #   living lookups (APIs, codes, schemas)
  write-ups/   #   synthesis pieces
scripts/       # check-docs.sh; optionally stdlib-only pullers writing to data/
```

## The rules that make it work

- **Role separation**: README = map · ROADMAP = forward plan · STATUS = snapshot
  of now · AGENTS = rules. A docs-only repo is where STATUS.md bloats fastest,
  because every session's output is prose; the snapshot rule and the docs gate
  in [01-doc-system.md](01-doc-system.md) matter most here.
- **New prose goes into a doc tree, not into a root file.** A session's findings
  are a note under `docs/research/` with a row in that tree's index. They are
  never a new section in STATUS.md or a new markdown file at the root.
- **A resources rule**: one file (`docs/resources.md` or `reference/`) is the
  single source of truth for links; citing a link in a write-up without indexing
  it there is a miss.
- If scripts appear: stdlib-preferred, dependency-light, raw output to git-ignored
  `data/`, findings committed as dated docs. This is a research hub, not a
  product — resist the promotion until [tier promotion](../checklists/tier-promotion.md)
  genuinely triggers.

Most docs-only repos are research repos; bootstrap with `--kind research` and
read [20-research.md](20-research.md) for gates, snapshots, and perishable
numbers.

## Templates to use

`base/AGENTS.md.tmpl` (delete the code sections if there is no code), plus
`base/AGENTS.research.md.tmpl` for a research repo; `base/STATUS.md.tmpl`,
`base/ROADMAP.md.tmpl`, `docs/adr/*`, `docs/research/*`. Skip stacks and tests
entirely. CI is one job, the docs gate (`ci-docs.yml` running
`scripts/check-docs.sh`).
