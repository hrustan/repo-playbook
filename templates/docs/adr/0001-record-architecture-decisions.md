<!-- proposed: not currently in my repos -->
# ADR-0001: Record architecture decisions

**Status:** Accepted
**Date:** YYYY-MM-DD
**Deciders:** <owner>
**Supersedes / Superseded by:** —

## Context

Decisions made in chat sessions and commit messages evaporate. A future session
(human or agent) needs to know not just what was decided but what was rejected and
why, without re-litigating.

## Decision

Every non-trivial decision gets a numbered, immutable file in this directory,
using [0000-template.md](0000-template.md). Sequential 4-digit numbering, kebab-case
titles, indexed in [README.md](README.md).

## Consequences

- Decisions survive sessions; superseding leaves an audit trail.
- Small writing tax on every real decision — the tax is the point.
