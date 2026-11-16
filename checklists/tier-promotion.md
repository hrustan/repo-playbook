<!-- proposed: not currently in my repos -->
# Checklist: tier promotion (spike → project)

Promote when ANY of these fires — the audit's spikes that outgrew Tier 0 without
promoting ended up with untested critical paths and READMEs frozen mid-handoff:

- [ ] A second working session is planned.
- [ ] A second contributor (human or agent) will touch it.
- [ ] The first non-obvious decision got made (and is currently recorded nowhere).
- [ ] Someone asked "what's the status of X?" and the answer lived in your head.

## Promotion steps (thirty minutes)

- [ ] Re-run `scripts/bootstrap.sh` on the repo with `--tier 1`: it adds the new
      files and appends the map to the existing README without overwriting
      anything.
- [ ] Fill AGENTS.md (the boundary rule, the gate command), STATUS.md (what is
      in flight and what is next), ROADMAP.md (gates AND kill criteria).
- [ ] `docs/adr/`: the template and index arrive with the re-run. Backfill only
      a decision that meets the bar in that index (costly to reverse, a real
      alternative rejected). Usually that is none or one; the rest are already
      recorded by the commits that made them.
- [ ] Stack tooling from `templates/stacks/<stack>/`; tests for anything whose
      output you act on.
- [ ] CI gate (`ci-node.yml` / `ci-python.yml`) the same day tests exist.
- [ ] `.env.example` if any secret has appeared.
- [ ] Branch discipline starts now: `feat/<slug>`, PR, merge, delete.
