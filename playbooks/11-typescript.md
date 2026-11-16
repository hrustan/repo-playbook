# Playbook 11 — TypeScript stack

The tooling for `--stack typescript`: a plain TypeScript package with lint,
typecheck, and tests wired. For a framework project, see "Targets" below.

## Stack

- **pnpm**, pinned once via `"packageManager"` in package.json — CI and
  `pnpm/action-setup` both read it (single source of truth; never pin a second
  copy in the workflow). Node works the same way: the floor lives in
  `engines.node` and CI reads it with `node-version-file`. The gitignore bans `package-lock.json` and `yarn.lock`
  outright: two lockfiles in one repo is how the audit's worst dependency state
  happened.
- **TypeScript strict** plus `noUncheckedIndexedAccess` — the single flag that
  most changed real code quality across the audited repos. No `any` without a
  `// why:` comment; ESLint warns (not errors) so the comment, not the linter, is
  the gate.
- **ESLint flat config** via `defineConfig`, non-type-checked presets (fast,
  CI-friendly). No Prettier by default; add it only if a formatter fight
  actually occurs. TypeScript is pinned to 6.x until typescript-eslint supports
  the native 7.x compiler; the config file says so where the pin bites.
- TypeScript 6 no longer loads every `@types/*` package by default. Code that
  uses Node globals needs `@types/node` and `"types": ["node"]` in tsconfig.
- **Vitest.** Single app → one `tests/` dir; monorepo → per-package `tests/`
  dirs with one root vitest config including `packages/**` and `apps/**`.
- Scripts: `lint`, `typecheck`, `test`, and a `check` aggregate that chains all
  three — the local mirror of CI.
- CI: `templates/github/workflows/ci-node.yml` from day one of having tests.

## Targets: web app, worker, browser extension, CLI

None of these is templated here, on purpose. A framework's scaffolder is always
current and a copy frozen in this repo is not, so:

1. Run the upstream scaffolder (`pnpm create vite`, `pnpm create next-app`,
   `pnpm create cloudflare`, the extension framework's own, …).
2. Layer the playbook on top:
   `bootstrap.sh --stack none --check-cmd "pnpm check" …`. It adds the docs,
   the docs gate, and the Claude Code settings, appends the secrets block to
   the scaffolder's `.gitignore`, and lists the files it left alone.
3. Port the opinions that matter by hand from `templates/stacks/typescript/`:
   `noUncheckedIndexedAccess`, the `check` script that chains lint, typecheck,
   test, and `check-docs`, and the CI workflow.

What each target adds beyond that is small enough to state here:

- **Web app** — client-exposed env variables carry the framework prefix and
  server-only keys never do (see "Config").
- **Worker** — side effects live in the worker entry; keep the logic in pure
  modules so tests need no runtime.
- **Browser extension** — store review is slow and repeats its objections; keep
  `docs/publishing.md` current ([90-open-sourcing.md](90-open-sourcing.md) §5).

A target earns a template of its own only after two real repos needed the same
files.

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
- Keep README's quickstart honest; current state goes to STATUS.md and history
  to git.
