---
title: A PDF signature ByteRange must exclude its own Contents
published: true
description: PDFFence 1.22 adds PFP014 for exact historical PDF signature Contents boundaries.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-122.html
---

# A PDF signature ByteRange must exclude its own Contents

An older PDF signature is not automatically stale evidence. After a later
incremental update, its `/ByteRange` should normally stop at the revision that
introduced it. But an old endpoint alone is not enough: the range should omit
exactly that signature's own `/Contents` value.

[PDFFence 1.22.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.22.0)
adds PFP014, `require_contents_bound_own_revision_signature_coverage`, to
make that stored-layout boundary reviewable without treating it as signature
validation.

The [PDF 2.0 signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html)
describe a multi-signature ByteRange as ending at the `%%EOF` that terminates
the incremental update adding that signature dictionary, with a possible
optional EOL. [RFC 3778](https://datatracker.ietf.org/doc/html/rfc3778#section-5)
describes the conventional two-pair range around the excluded signature value,
whose `/Contents` is normally hexadecimal.

## The new review gate

PFP014 requires every semantic signature dictionary with `/ByteRange` to have
all three pieces of bounded static evidence:

- a well-formed direct two-pair range beginning at byte zero;
- one excluded span that matches its direct hexadecimal `/Contents` token
  exactly; and
- a final endpoint at the footer of that same signature's revision.

~~~yaml
version: 1
rules:
  require_contents_bound_own_revision_signature_coverage: true
~~~

PDFFence only evaluates catalog-reachable AcroForm and catalog `/Perms`
signature roots. It follows a confirmed `/Prev`-linked xref chain and uses
bounded raw and footer scans. Unavailable, ambiguous, malformed, indirect,
compressed, or over-limit evidence fails closed. Reports contain aggregate
counts only, never offsets, object references, revision boundaries, delimiter
positions, signature bytes, digests, certificates, transforms, or trust data.

This is intentionally distinct from PFP011 (current-file exact Contents
coverage) and PFP013 (own-revision endpoint coverage). A correctly bounded
older signature can pass PFP014 after a later incremental update. The new diff
event appears only when the existing generic coverage and own-revision
aggregates are stable, avoiding duplicate signals for changes already owned by
PFP011 or PFP013.

## A focused 159th benchmark pair

[PDFCAB 1.22.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.22.0)
adds a pair where both signatures are historically stale relative to a later
update but still reach their own signing-revision footers. The baseline's gap
is exactly direct `/Contents`; the candidate starts the same gap one byte
earlier. Only the historical Contents event and PFP014 are expected. Held
PDFFence 1.21 reports changed bytes alone, proving the pair exercises the new
boundary.

PDFFence passed 256 tests and Ruff; PDFCAB passed 89 tests and Ruff. The public
score is 159/159, builds are reproducible, and clean wheel/source-archive
installs passed on Python 3.12 and 3.13. A pyHanko exercise also confirmed the
stored layout for both an older signature after an update and a two-signature
file.

This does not validate a digest, `/Contents`, certificate, transform,
permission, or trust decision, and it does not decide whether an update is
authentic, permitted, safe, or malicious.

Read the canonical [PDFFence 1.22 release note](https://sybilgambleyyu.github.io/posts/pdffence-122.html)
for the supported boundary, validation record, and release links.
