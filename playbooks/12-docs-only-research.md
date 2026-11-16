# Playbook 12 — Docs-only research repo

For thinking-in-git: idea engines, domain research hubs, decision scaffolds for a
project that doesn't have code yet. Git is the database; markdown is the runtime;
the agent file is the program.

## Shape

```
AGENTS.md      # the rules — an agent reads this, then STATUS, then acts
README.md      # map + doc index (every new doc gets a row, same commit)
STATUS.md      # open/resolved decisions, live state, changelog
ROADMAP.md     # gated phases with kill criteria, freely rewritten
docs/          # partitioned by KIND, not topic:
  adr/         #   immutable decisions
  research/    #   dated or numbered snapshots (never rewritten)
  reference/   #   living lookups (APIs, codes, schemas)
  write-ups/   #   synthesis pieces
scripts/       # optional: stdlib-only pullers; raw output to git-ignored data/
```

## The rules that make it work

- **Role separation**: README = map · ROADMAP = forward plan · STATUS = decision
  log · AGENTS = rules. Decisions get *logged* in STATUS and *executed* via
  ROADMAP — don't blend the two.
- **Snapshots are immutable.** A superseded research doc gets a one-line banner
  pointing at the newer one; it is never rewritten.
- **Perishable numbers only in dated docs** — a living doc carrying an untagged
  count or dollar figure is a bug.
- **Kill gates, pre-registered.** Every phase states what would kill it before the
  phase starts, plus standing kill conditions that apply at any phase. An honest
  "this died at gate 1" is a success.
- **A resources rule**: one file (`docs/resources.md` or `reference/`) is the
  single source of truth for links; citing a link in a write-up without indexing
  it there is a miss.
- If scripts appear: stdlib-preferred, dependency-light, raw output to git-ignored
  `data/`, findings committed as dated docs. This is a research hub, not a
  product — resist the promotion until [tier promotion](../checklists/tier-promotion.md)
  genuinely triggers.

## Templates to use

`base/AGENTS.md.tmpl` plus `base/AGENTS.research.md.tmpl` (delete the code
sections if there is no code), `base/STATUS.md.tmpl`, `base/ROADMAP.md.tmpl`, `docs/adr/*`,
`docs/research/*`. Skip stacks and tests entirely. CI is one job, the docs gate
(`ci-docs.yml` running `scripts/check-docs.sh`).
