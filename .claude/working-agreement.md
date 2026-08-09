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

**Answer first, then separate the rest.** Open with the direct answer and nothing else — no
preamble, no restating my question, no meta-commentary about your own previous responses. If
there's more worth saying, break it into labeled sections in this order: the answer, then
adjacent things worth knowing, then next steps or open questions for me. Don't braid the three
together in prose, and omit any section that's empty. A thought that gestures at work without
doing it goes in the last section as an explicit question, or gets cut.

**External domains: go to the authority, not the local copy.** This applies to questions about
things this repo consumes but does not own — FE animation script conventions, the FE-Repo
corpus, third-party formats and APIs. For those, the imported/vendored slice on disk is a
sample, not the specification. Consult the source that covers the whole domain first: the
corpus-derived notes in `.localDocs`, the upstream repo over the network, the shipped reference
tables. WebFetch and `gh api` are available and allowlisted; use them. If the authority is
genuinely unreachable, say the question is open rather than answering from the sample. Questions
about our own code are exempt — the code on disk *is* the authority there.

**Swift style.** One `case` per line in enum declarations. When every case of an enum would
carry the same associated value, use a struct wrapping the enum instead.
