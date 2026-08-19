# Playbook 11 — TypeScript app

For products: web apps, workers, extensions past the spike stage.

## Stack

- **pnpm**, pinned once via `"packageManager"` in package.json — CI and
  `pnpm/action-setup` both read it (single source of truth; never pin a second
  copy in the workflow). The gitignore bans `package-lock.json` and `yarn.lock`
  outright: two lockfiles in one repo is how the audit's worst dependency state
  happened.
- **TypeScript strict** plus `noUncheckedIndexedAccess` — the single flag that
  most changed real code quality across the audited repos. No `any` without a
  `// why:` comment; ESLint warns (not errors) so the comment, not the linter, is
  the gate.
- **ESLint 9 flat config**, non-type-checked presets (fast, CI-friendly). No
  Prettier by default; add it only if a formatter fight actually occurs.
- **Vitest.** Single app → one `tests/` dir; monorepo → per-package `tests/`
  dirs with one root vitest config including `packages/**` and `apps/**`.
- Scripts: `lint`, `typecheck`, `test`, and a `check` aggregate that chains all
  three — the local mirror of CI.
- CI: `templates/github/workflows/ci-node.yml` from day one of having tests.

## Monorepo variant

Only when there are genuinely two deployables or a shared library:

- `apps/*` = deployables with side effects (web, worker); `packages/*` = pure
  libraries. **The split is a rule, not a suggestion**: nothing in `packages/*`
  touches network, disk, or env — side effects live in `apps/*`, and tests
  enforce it with committed fixtures and injected clients
  (`createClient(env = process.env)` so tests pass fakes).
- Root-level shared tsconfig (`tsconfig.base.json`, `strict`, `composite`) with
  per-package extends; one root `typecheck` script chains the projects.

## Config

- `.env.example` lists every variable, names only, each with its exposure class
  (public / server-only / one-shot) and where the real value lives. Client-exposed
  variables carry the framework prefix (`NEXT_PUBLIC_*`, `VITE_*`); a server-only
  key must never get that prefix.
- Validate external payloads at the boundary with a schema (zod); read env
  through one accessor or injected parameter, not scattered `process.env`.

## Hygiene

- PR template mirrors the AGENTS.md Definition of Done checkboxes; issue template
  carries the task ID scheme (`[P?-T?]`).
- Delete branches after merge. The audit found a repo with 32 branches, 25 of
  them merged and dead.
- Keep README's quickstart honest; everything stateful goes to STATUS.md.
