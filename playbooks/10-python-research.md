# Playbook 10 — Python research repo

For repos whose product is a *verdict*: validate a hypothesis, measure a system,
kill ideas cheaply. The defining features are pre-registered gates, immutable
decisions, and data hygiene.

## Stack

- `pyproject.toml` + hatchling, src layout (`src/<package>/`, the slug in
  snake_case), floor-pinned deps with a justification comment on anything
  non-obvious. Dev tools live in `[dependency-groups]`, not in an extra.
- <!-- proposed: not currently in my repos --> **uv** owns the environment and
  the lockfile: `uv sync`, `uv run`, and a committed `uv.lock` that CI installs
  with `--locked`. None of the audited repos had a lockfile, which made no build
  reproducible.
- **ruff** for lint + format (`line-length = 100`, `target-version = "py311"`),
  config inline in pyproject. No black, no isort, no pre-commit hooks.
- **pytest**, centralized `tests/`, files named `test_<module>.py` mirroring
  source 1:1.
- **Makefile** whose targets all go through `uv run` — a login shell can default
  to a sibling repo's venv and silently break a bare `python`, and `uv run`
  always uses this repo's `.venv`. `make check` is the local mirror of CI.
  See `templates/stacks/python/Makefile.tmpl`.
- CI: `templates/github/workflows/ci-python.yml`, on the `requires-python` floor
  and the newest release.

## Guardrails as code

The strongest pattern in the audit: every AGENTS.md rule that *can* be a test *is*
a test, and AGENTS.md names the test so no agent can claim ignorance.

- `tests/test_smoke.py` — package imports + an AST-walk import firewall for
  structural boundaries ("execution code never imports research data").
- Rejection fixtures — if the repo can take a dangerous action (place an order,
  send an email), a test feeds it the forbidden inputs and asserts refusal.
- Pre-registration enforcement — if results files exist, a test asserts the
  registration fields were committed first.

Mark these in AGENTS.md: "Do not weaken or skip. If a guardrail test blocks you,
the code is wrong, not the test."

## Data hygiene

- `/data/` at the repo root, git-ignored **root-anchored** (leading slash) so a
  source package like `src/<slug>/data/` stays tracked. `*.parquet` ignored
  globally.
- Commit *findings*, not dumps: a dated `docs/research/` note with counts and a
  few representative records; the bulk JSON/parquet stays local or in CI
  artifacts.
- Scheduled captures that must persist go to an **orphan `data` branch**
  (append-only, bot-committed) or to workflow artifacts with short retention —
  never to `main`.
- When a pull outgrows one machine, split it into a dedicated data repo (see the
  escalation note in `templates/github/workflows/scheduled-job.yml`).

## Docs

Four trees, each with its own `_TEMPLATE` and numbering: `docs/adr/` (immutable
decisions), `docs/research/` (numbered snapshots), `docs/runbooks/` (operator
procedures), and optionally `experiments/NNNN_name/` with a
pre-registration → results → verdict triad, where the verdict file is *not
created* until the gate is earned.

The README opens with an honest-framing section: what this is, what it is not,
and the expected outcome distribution ("most ideas here will die; that is the
point"). Optional house style some of my repos enforce: no em dashes in committed
prose — adopt per-repo if you want it, it is not a default.

## Commit style

Conventional Commits everywhere (`feat:`, `fix:`, `docs:`, `chore:`). Subjects may
still carry the domain payload — `feat: validate spinoff sleeve, verdict RED` —
the prefix and the verdict are not in tension.
