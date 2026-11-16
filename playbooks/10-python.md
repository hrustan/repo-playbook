# Playbook 10 — Python stack

The tooling for `--stack python`, whatever the repo is for. Research-specific
practice (pre-registered gates, data hygiene, experiment docs) is in
[20-research.md](20-research.md).

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

Mark these in AGENTS.md: "Do not weaken or skip. If a guardrail test blocks you,
the code is wrong, not the test."

## Commit style

Conventional Commits everywhere (`feat:`, `fix:`, `docs:`, `chore:`). Subjects may
still carry the domain payload — `feat: validate spinoff sleeve, verdict RED` —
the prefix and the verdict are not in tension.
