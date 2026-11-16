# Playbook 20 — Research kind

For `--kind research`, on any stack: repos whose product is a *verdict*.
Validate a hypothesis, measure a system, kill ideas cheaply. The defining
features are pre-registered gates, snapshots that are never rewritten, and data
hygiene. Tooling is in the stack playbooks ([10-python.md](10-python.md),
[11-typescript.md](11-typescript.md), [12-docs-only.md](12-docs-only.md)).

## Gates

- **Kill gates, pre-registered.** Every phase states what would kill it before
  the phase starts, plus standing kill conditions that apply at any phase. An
  honest "this died at gate 1" is a success.
- **A gate does not move after results exist.** Moving one needs the owner's
  sign-off, recorded as an ADR. This is the one routine source of ADRs in a
  research repo, and it is rare by design.
- **Enforce it where a test can.** If results files exist, a test asserts the
  registration fields were committed first.

## Docs

- `docs/research/` holds numbered, dated notes with their own index. Nothing in
  it is read by default; an agent opens a note when the index row is relevant.
- **Snapshots are immutable.** A superseded note gets a one-line banner pointing
  at the newer one; it is never rewritten.
- **Perishable numbers only in dated docs.** A living doc carrying an untagged
  count or dollar figure is a bug; tag it `as of YYYY-MM-DD` or move it to a note.
- Optionally `experiments/NNNN_name/` with a pre-registration → results →
  verdict triad, where the verdict file is *not created* until the gate is
  earned, and `docs/runbooks/` for operator procedures.
- The README opens with an honest-framing section: what this is, what it is not,
  and the expected outcome distribution ("most ideas here will die; that is the
  point"). Optional house style some of my repos enforce: no em dashes in
  committed prose — adopt per-repo if you want it, it is not a default.

## Data hygiene

- `/data/` at the repo root, git-ignored **root-anchored** (leading slash) so a
  source package like `src/<package>/data/` stays tracked. `*.parquet` ignored
  globally.
- Commit *findings*, not dumps: a dated `docs/research/` note with counts and a
  few representative records; the bulk JSON/parquet stays local or in CI
  artifacts.
- Scheduled captures that must persist go to an **orphan `data` branch**
  (append-only, bot-committed) or to workflow artifacts with short retention —
  never to `main`.
- When a pull outgrows one machine, split it into a dedicated data repo (see the
  escalation note in `templates/github/workflows/scheduled-job.yml`).
