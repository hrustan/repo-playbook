# Sanitization report

Sweep run 2026-08-19 over everything generated in this repo, before deleting the
audit working files. Re-run any command below from the repo root to verify.
"Shipped files" = everything except `.audit/` and `PROPOSAL.md`, which were
deleted at the end of this phase (they existed only as working artifacts and
referenced private repo names, a real name, and absolute home-directory paths by
design of the audit).

## Commands run

```sh
# 1. emails and phone numbers
grep -rniE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' . --exclude-dir=.git
# 2. absolute paths leaking a username
grep -rnE '(/Users/|/home/|C:\\\\Users)[A-Za-z0-9_.-]+' . --exclude-dir=.git
# 3. secret shapes
grep -rnE 'sk-ant-|ghp_[A-Za-z0-9]|gho_[A-Za-z0-9]|github_pat_|AKIA[0-9A-Z]{16}|-----BEGIN|xox[baprs]-' . --exclude-dir=.git
# 4. real names — substitute your own full name, first name, and nicknames
grep -rniE '<first-name>|<last-name>|<nickname>' . --exclude-dir=.git
# 5. private repo and product names — substitute the actual private names
#    (this file intentionally does not list them; that would be the leak)
grep -rniE '\b(<private-repo-1>|<private-repo-2>|...)\b' . --exclude-dir=.git
# 6. private IPs / internal hostnames
grep -rnE '\b(10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+)\b' . --exclude-dir=.git
```

## Findings and dispositions

| # | Match | Location | Disposition |
|---|-------|----------|-------------|
| 1 | emails | none in shipped files (none in `.audit/` either) | clean |
| 2 | `/Users/<name>/...` paths | `.audit/inventory.md` only | **removed** — file deleted with `.audit/` |
| 3 | secret shapes | none anywhere (the patterns in `checklists/pre-publish-pii-sweep.md` are the grep regexes themselves, not values) | clean |
| 4 | `hrustan` | `LICENSE:3`, `README.md` placeholder-example row, `templates/github/workflows/scheduled-job.yml` (edgar-fetch URL) | **kept** — public GitHub handle, on the keep-list; LICENSE holder chosen deliberately |
| 4 | owner's real name and nickname | `.audit/inventory.md`, `PROPOSAL.md` only | **removed** — both files deleted |
| 5 | private repo names (all 10 audited) | `.audit/inventory.md`, `PROPOSAL.md` only; zero in shipped files | **removed** — both files deleted; the names are deliberately not repeated in this report |
| 5 | `edgar-fetch` URL | `templates/github/workflows/scheduled-job.yml` | **kept** — already-public repo, cited intentionally as the reference implementation of the data-repo escalation pattern |
| 6 | private IPs / internal hosts | none | clean |

Also verified: no ticket-ID-shaped strings (`[A-Z]{2,}-[0-9]+`) beyond the
template's own `KI-1`/`ADR-NNNN`/`P?-T?` conventions; no colleague/client/
recruiter/professor names anywhere; no content from repos struck at Checkpoint A
(none were struck); this directory has no git history yet, so nothing lurks in
old commits.

## Deleted at the end of this phase

- `.audit/` (raw audit inventory)
- `PROPOSAL.md` (synthesis document, per Checkpoint B decision)

`{{COPYRIGHT_HOLDER}}` remains a placeholder in `templates/base/LICENSE.MIT.tmpl`;
this repo's own `LICENSE` uses the handle `hrustan` per Checkpoint B decision.

The same sweep logic, generalized for reuse on any repo, lives in
[checklists/pre-publish-pii-sweep.md](checklists/pre-publish-pii-sweep.md) —
including the git-history checks that were unnecessary here.
