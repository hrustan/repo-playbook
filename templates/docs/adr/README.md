# Architecture Decision Records

The few decisions that are costly to reverse, and why they were made. A healthy
project has a handful. Read the index; open a file only when its row is relevant
to what you are changing.

| ADR | Decision, in one line | Status |
|-----|-----------------------|--------|
| | | |

## When a decision gets an ADR

Only when all three hold:

1. It is costly to reverse: a data model, a public interface, a vendor or
   platform, a security posture.
2. A real alternative was considered and rejected.
3. A future reader would likely reopen it without the reasoning.

Not an ADR: a library that is easy to swap, naming, file layout, how a bug was
fixed, anything a test or lint rule already enforces, anything the commit body
explains well enough. The commit that made those decisions is their record.

## Who writes one

The owner decides. An agent that thinks a decision meets the bar adds one line
under "Needs owner" in `STATUS.md`. It writes the ADR only after the owner says
yes, and does not treat the decision as made until then.

## Writing one

1. Copy [0000-template.md](0000-template.md) to `NNNN-kebab-title.md`, using the
   next unused number. Numbers are never reused.
2. Keep it to about a page. The docs gate fails past 80 lines.
3. Add its row to the index above, stating the decision itself, so the index
   alone answers most questions.
4. If the decision changes how every session must work, propose a one-line rule
   for `AGENTS.md` as well. The ADR is the why; AGENTS.md is the what.

An accepted ADR is not edited. To change a decision, write a new ADR that
supersedes it, mark the old file and its row "Superseded by NNNN", and link both
ways.
