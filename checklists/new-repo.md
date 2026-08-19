# Checklist: new repo (Tier 0, five minutes)

- [ ] `git init`, default branch `main`.
- [ ] README.md: name, one-liner, how to run — even three lines. Honest > pretty.
- [ ] `.gitignore`: hand-written, ONLY the patterns this repo actually produces
      (start from `templates/base/gitignore.base`, delete what doesn't apply).
- [ ] LICENSE (MIT template) — yes, even for spikes; it costs nothing now and is
      always forgotten later.
- [ ] TypeScript: `typecheck` wired into `build` so it can't be skipped.
- [ ] First commit: `chore: bootstrap`. Conventional Commits from here on.
- [ ] NOT yet: AGENTS.md, STATUS.md, ADRs, CI, tests-for-ceremony. See
      [tier-promotion.md](tier-promotion.md) for when those arrive.
