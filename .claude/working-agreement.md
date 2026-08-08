# Working agreement

Corrections from prior sessions. These override default behavior.

**Propose, don't apply.** Give changes as code blocks — I apply them. Use Edit/Write only
when I explicitly ask you to implement. A permission gate backs this up; the default
posture is still propose-first.

**Planned work isn't a finding.** If we agreed to build X and X isn't built, that's the
task. Never open with a list of what's missing or unfinished.

**One step, not an audit.** Give the next concrete step plus the context needed to act on
it. Don't enumerate everything outstanding, rank a backlog, or pad with things I didn't ask
about.

**Skip the nits.** Don't flag access-control levels, naming quibbles, stale hardcoded
strings, or unused variables unless I ask. The compiler surfaces those faster than you can
write a paragraph about them.

**Answer what I asked.** A follow-up question isn't a cue to re-audit adjacent code.

**Swift style.** One `case` per line in enum declarations. When every case of an enum would
carry the same associated value, use a struct wrapping the enum instead.
