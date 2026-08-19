# Checklist: pre-publish PII & secrets sweep

Run from the repo root before any repo goes public. Every command is re-runnable;
a clean sweep is silence. Sweep the working tree first, then history.

## 1. Emails, names, contact info

```sh
grep -rniE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' . --exclude-dir=.git --exclude-dir=node_modules
grep -rniE '\+?1?[ .-]?\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4}' . --exclude-dir=.git --exclude-dir=node_modules
```

Then grep for your own real name, and names of colleagues, clients, professors,
recruiters. Public handle is fine; legal names are a choice, not a default.

## 2. Absolute paths that leak a username

```sh
grep -rnE '(/Users/|/home/|C:\\\\Users\\\\)[A-Za-z0-9_.-]+' . --exclude-dir=.git --exclude-dir=node_modules
```

## 3. Secret shapes

```sh
grep -rnE 'sk-[A-Za-z0-9]|sk-ant-|ghp_[A-Za-z0-9]|gho_[A-Za-z0-9]|github_pat_|AKIA[0-9A-Z]{16}|-----BEGIN|xox[baprs]-|eyJ[A-Za-z0-9_-]{20,}\.' . --exclude-dir=.git --exclude-dir=node_modules
grep -rniE '(password|passwd|secret|token|api_?key)[ ]*[=:][ ]*[^ {$<]' . --exclude-dir=.git --exclude-dir=node_modules
```

Expect hits on variable NAMES (`.env.example`, docs) — verify each has no value
after the `=`. Any real value found: **rotate the credential**; deleting the line
is not enough.

## 4. Internal infrastructure

```sh
grep -rnE '\b(10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)\b' . --exclude-dir=.git --exclude-dir=node_modules
grep -rniE '\.(internal|corp|local|intranet)\b|vpn\.' . --exclude-dir=.git --exclude-dir=node_modules
```

Also grep for employer domains, internal project codenames, and ticket IDs
(`[A-Z]{2,}-[0-9]+` — expect false positives like `SHA-256`, `KI-1`; judge each).

## 5. Cross-repo leakage

Grep for the names of your *private* repos and unreleased products. A public repo
that name-drops a private one leaks its existence and purpose.

## 6. Git history (the working tree is not enough)

```sh
git log --all -p | grep -nE 'AKIA[0-9A-Z]{16}|ghp_|sk-ant-|-----BEGIN' 
git log --format='%an %ae' | sort -u   # committer identities that will go public
```

A secret in history: rotate it, then decide on history rewrite vs accepting
exposure — before publishing. Committer emails: GitHub's noreply address is the
private option.

## 7. Files that shouldn't ship

```sh
git ls-files | grep -iE '\.(env|pem|key|p12|sqlite|db)$|settings\.local|\.DS_Store'
git ls-files --others --exclude-standard   # untracked strays about to be added
```
