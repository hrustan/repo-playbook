# Playbook 01 — The doc system

Why the root docs are shaped the way they are, and what keeps them that way.

## What went wrong

The first version of this playbook called STATUS.md "the decision log and live
state" and told agents to add a changelog entry every session. They did. In
real repos the file grew to hundreds of kilobytes and more, and it was read at
the start of every session.

The cause was not a careless agent. Every instruction said *add*, none said
*remove*, and nothing set a size. The wording around ADRs had the same flaw and
the same result; see "Recording decisions" below.

## The rule

> Files an agent reads every session are small snapshots, edited in place. Git
> is the log. Anything allowed to grow is read only on demand, and is never
> indexed from a file that is read every session.

| Class | Files | How it is kept | Limit |
|---|---|---|---|
| Read every session | `AGENTS.md`, `STATUS.md` | fix what is no longer true; never append | 200 lines; 60 lines and 6 KB |
| Read when relevant | `ROADMAP.md`, `docs/known-issues.md`, the index in each `docs/*/README.md` | one line per item; pruned when done | 150 lines; 100 lines |
| Read on demand | ADR files, research notes, `git log` | may grow; never read by default | 80 lines per ADR |

A line in a file that is read every session is paid for on every task, whether
it is relevant or not, so those files get a limit. A research note that is
opened twice a year can be as long as it needs to be. The 200 for AGENTS.md is
the Claude Code docs' own target for an instruction file; a research repo's
AGENTS.md starts at roughly two thirds of it.

## STATUS.md

Four sections — Now, Next, Needs owner, Watch out — and nothing else.

- **No changelog, no "done" list, no resolved-decisions list.** What happened
  is `git log`.
- **No "last updated" line.** Git has the date, and a date field is a standing
  reason to touch the file every session.
- **Edited only when a line stops being true.** "Update STATUS.md in every PR"
  was the append reflex. A change that leaves the snapshot accurate leaves the
  file alone.
- **"Needs owner" is drained only by the owner**, so it has an overflow rule:
  when it is full, an agent raises the new item in its commit body and never
  deletes an unanswered one to make room.
- **ROADMAP.md owns phases and gates.** STATUS.md does not repeat them, and
  ROADMAP.md is forward-only: a finished phase is deleted.

## Where history goes

The commit body. It says what was done and what was deferred, which is what the
changelog used to hold. Two consequences:

- PR descriptions are not in git. On GitHub, set squash-merge's default commit
  message to "Pull request title and description" so the description survives
  as the commit body.
- `git log --oneline -15` is step one of every session, next to reading
  STATUS.md.

## Recording decisions

The first version said "record any non-trivial decision as a new ADR", backed by
a Definition-of-Done checkbox, a PR-template checkbox, and a meta-ADR that
called the writing tax "the point". "Non-trivial" was never defined, so to an
agent almost every decision qualified, and a checkbox is satisfied by producing
a file. Some repos collected hundreds.

Now a decision takes the cheapest record that works:

1. the commit body, which is the default;
2. a `// why:` comment at the site;
3. a rule in AGENTS.md, proposed to the owner;
4. an ADR, only when it is costly to reverse, a real alternative was rejected,
   and a future reader would reopen it without the reasoning.

Three things hold the line:

- **The owner approves every ADR.** An agent adds a one-line proposal under
  "Needs owner" and never writes one unprompted. A decision that is costly to
  reverse is the owner's to make anyway.
- **No checkbox asks for one.** Nothing in the Definition of Done or the PR
  template can be satisfied by creating an ADR.
- **ADR files are never read by default.** The index in `docs/adr/README.md`
  states each decision in one line, and a rule every session must follow is
  promoted into AGENTS.md. The ADR itself is only the why.

Supersede-don't-edit stays. With the gate the count stays small, and a research
repo needs the trail when a pre-registered gate moves.

## Enforcement

A rule that depends on an agent choosing to follow it is a request. The limits
above are enforced by `scripts/check-docs.sh`, which every Tier 1+ repo gets:

- It fails when a file is over its limit.
- It fails when a markdown file it does not expect appears at the repo root.
  That is where a trimmed log tends to come back, as `NOTES.md` or
  `HANDOFF.md`.
- Its message says what to do: delete what is stale, do not move it to another
  file, and do not raise the limit.

It runs in CI for every stack, including docs-only repos, and in the local gate
(`make check`, `pnpm check`). Raising a limit or allowing another root doc is
the owner's decision, made by editing the script.

## The Claude Code layer

Everything above works for any agent. Claude Code gets one extra file,
`.claude/settings.json`, committed so every session on every machine has it:

- **A hook that runs the docs gate after every edit.** CI catches an oversized
  STATUS.md at PR time; the hook reports it to the agent in the session that
  caused it, when the fix is cheapest. It exits 2 on failure, which is what
  sends the message to Claude and not only to the transcript.
- **Ask rules** on `docs/adr/`, `AGENTS.md`, `scripts/check-docs.sh`, and the
  settings file itself. Writing an ADR, changing the rules, or raising a limit
  prompts the owner, including in auto mode. That click is the approval the ADR
  gate asks for. In an unattended run nobody can answer the prompt, so there the
  AGENTS.md wording and CI are what hold.
- **Deny rules** on reading `.env` files, with `.env.example` carved back out.

`CLAUDE.md` is the single line `@AGENTS.md`. When a repo has both files, Claude
Code reads only CLAUDE.md, and a CLAUDE.md that tells Claude in prose to go and
read AGENTS.md leaves it to the model to open the file. The import loads it
every session.

STATUS.md is deliberately not imported. An import is expanded in full at launch
and sent with every request, so an oversized file would cost its whole size on
every turn. Read on demand, it is capped by the Read tool, and the session loop
in AGENTS.md already says to read it first. For the same reason, never write an
`@` path to STATUS.md or to anything under `docs/` in AGENTS.md or CLAUDE.md:
outside backticks, that is an import.

When AGENTS.md nears its limit, or after a major model release, run `/doctor`,
which trims what Claude can derive from the code, and `/doctor prompt-audit`,
which flags stale and contradictory instructions.

Sources, as of 2026-11: the Claude Code docs on
[memory and CLAUDE.md](https://code.claude.com/docs/en/memory),
[hooks](https://code.claude.com/docs/en/hooks),
[permissions](https://code.claude.com/docs/en/permissions), and
[best practices](https://code.claude.com/docs/en/best-practices).

## When a limit is hit

Delete. The usual candidates, in order: finished items still listed under Now,
gotchas that no longer apply, a Next list longer than one session's work, and
AGENTS.md rules that a test or lint rule now enforces. If everything left is
still true and still needed, the limit is wrong for this repo, and the owner
raises it.
