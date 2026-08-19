<!-- proposed: not currently in my repos -->
# Checklist: tier promotion (spike → project)

Promote when ANY of these fires — the audit's spikes that outgrew Tier 0 without
promoting ended up with untested critical paths and READMEs frozen mid-handoff:

- [ ] A second working session is planned.
- [ ] A second contributor (human or agent) will touch it.
- [ ] The first non-obvious decision got made (and is currently recorded nowhere).
- [ ] Someone asked "what's the status of X?" and the answer lived in your head.

## Promotion steps (thirty minutes)

- [ ] Add AGENTS.md (one flavor), STATUS.md (real phase board + first changelog
      entry), ROADMAP.md (gates AND kill criteria).
- [ ] `docs/adr/`: copy the template + index; backfill the decisions already made
      as ADR-0002+ — from memory, dated today, honestly marked as backfilled.
- [ ] Stack tooling from `templates/stacks/<stack>/`; tests for anything whose
      output you act on.
- [ ] CI gate (`ci-node.yml` / `ci-python.yml`) the same day tests exist.
- [ ] `.env.example` if any secret has appeared.
- [ ] Branch discipline starts now: `feat/<slug>`, PR, merge, delete.
