# Checklist: archiving a repo

A dead repo that says so is an asset; one that trails off mid-thought is a trap
for the next reader (including future you and your agents).

- [ ] Final STATUS.md entry: what was concluded, what was abandoned and why, and
      the verdict if there was a gate. Date it.
- [ ] README banner at the top: `> **Archived YYYY-MM-DD.** <one-line outcome.
      Successor repo, if any.>`
- [ ] Close the loop on open decisions: each one gets resolved, moved to the
      successor, or explicitly marked "died with the repo".
- [ ] Delete every merged branch; note any unmerged branch's fate in STATUS.md.
- [ ] Rotate any credentials the repo's CI or .env ever held.
- [ ] GitHub → Settings → Archive repository (makes it read-only and labels it).
