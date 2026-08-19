# Playbook 90 — Open-sourcing (Tier 1 → Tier 2)

Run this before flipping any repo public, and before submitting to any store or
marketplace. The audit found two public repos with no license and one with a
frozen agent-prompt README — this playbook exists so that stops happening.

## 1. License

No LICENSE file means all-rights-reserved regardless of visibility — strangers
can read but not legally use. Add `templates/base/LICENSE.MIT.tmpl` (fill
`{{YEAR}}`/`{{COPYRIGHT_HOLDER}}`), set the matching `license` field in
package.json / pyproject.toml. If it must stay proprietary, say so explicitly in
the README instead.

## 2. README rewrite — for strangers

The Tier 1 README is a map for you and your agents. A public README must answer,
in order: what is this, why would I use it, how do I install and run it, what are
the outputs. Kill anything that only made sense mid-project (handoff prompts,
"paste this into the agent" blocks, stale bundle references). Keep the honest
framing.

## 3. PII and secrets sweep

Run [../checklists/pre-publish-pii-sweep.md](../checklists/pre-publish-pii-sweep.md)
in full — including against git *history*, not just the working tree. If history
contains a secret, rotate the secret; if it contains PII, decide between history
rewrite and accepting the exposure *before* the repo goes public, not after.

## 4. Repo furniture

- Issue + PR templates from `templates/github/`.
- CI badge only if CI exists (it should — Tier 1 requirement).
- Prune branches: everything merged gets deleted; anything unmerged gets a
  decision (finish, or record why it's parked in STATUS.md).
- `git log --oneline | head -30` — would you sign every subject line? Squash-land
  anything embarrassing *before* first publish; you can't after.

## 5. Store/marketplace submissions (extensions, packages)

Beyond the repo itself: bump the version in the manifest, write and host a privacy
policy if the thing touches user data, prepare listing assets (screenshots at the
required sizes, icons), and expect the first review round-trip to take days —
plan releases around it, and keep a `PUBLISHING.md` runbook in the repo recording
what the reviewer flagged so the next release doesn't repeat it.

## 6. After flipping public

- GitHub → Settings → General → check **Template repository** if others should be
  able to instantiate it.
- Add topics and the one-liner to the GitHub About box (it's the search surface).
- Public repos get free unlimited standard-runner CI minutes — a reason to make
  heavy data jobs public-by-design in a dedicated repo.
