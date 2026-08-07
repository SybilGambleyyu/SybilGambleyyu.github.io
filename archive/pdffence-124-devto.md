---
title: A PDF's terminal footer is a review boundary
published: true
description: PDFFence 1.24 adds PFP015, a fail-closed terminal PDF revision-footer policy for signed, unsigned, and encrypted PDFs.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-124.html
---

# A PDF's terminal footer is a review boundary

A parser accepting a PDF is not the same as a review system having positive structural evidence about it. A parser can tolerate raw bytes after a final `%%EOF` marker; those bytes are not automatically a valid PDF revision.

[PDFFence 1.24.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.24.0) adds PFP015, `require_terminal_revision_footer`: a privacy-safe, fail-closed policy for that condition. It is stored-layout review evidence, not PDF conformance or signature validation.

## Three redacted states

The [PDF 2.0 syntax errata](https://pdf-issues.pdfa.org/32000-2-2020/clause07.html) describe the last line of a file as `%%EOF`. PDFFence follows a confirmed `/Prev`-linked cross-reference chain and maps one bounded, unambiguous footer for each linked revision. It reports only:

- `terminal`: the map is established and the final linked footer ends the physical source apart from its optional EOL;
- `nonterminal`: the map is established, but bytes follow that footer; or
- `unavailable`: the bounded map cannot be established.

The new `revision_terminal_footer_changed` event carries only those labels—never an offset, footer location, object reference, source bytes, or hash.

## Separate from PFP006

PFP015 does not reject ordinary incremental history. A valid linked later update can have several revisions and still be terminal. Conversely, a one-revision PDF can have unlinked trailing bytes. That is why PFP015 is separate from `require_single_revision` (PFP006).

~~~yaml
version: 1
rules:
  require_terminal_revision_footer: true
~~~

The check is independent of signatures and uses structural information available before an encrypted PDF is left uninspected; it never decrypts the source.

## Signature evidence remains narrower

The [PDF 2.0 signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html) describe a signature ByteRange ending at the footer of the update that added its signature dictionary. Existing PFP013 and PFP014 positive evidence consumes the same terminal footer map. PFP015 now makes that prerequisite independently visible for unsigned PDFs too.

An older correctly bounded signature can pass after a valid later incremental update. An arbitrary tail after the final linked footer cannot keep earning own-revision credit merely because a tolerant parser accepts it.

## A 161-pair public contract

[PDFCAB 1.24.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.24.0) adds an unsigned terminal-footer control. Its baseline is a normal one-revision PDF; only the candidate appends unlinked bytes after its final footer. Both revision counts stay confirmed at one, so the expected result is `revision_terminal_footer_changed`, stored-byte evidence, and PFP015—not PFP006.

The existing semantic-signature tail control now expects that general event alongside its own-revision coverage event, while keeping PFP013 as its focused policy contract.

PDFFence passed 264 tests, Ruff, and bytecode compilation; PDFCAB passed 91 tests and Ruff. The public process-bound score is 161/161. Both distributions built reproducibly, passed Twine checks, and passed fresh wheel installs on Python 3.12 and 3.13 plus a Python 3.12 source-archive install. Re-downloaded GitHub release wheels also scored 161/161 in a fresh Python 3.13 environment.

PFP015 does not authenticate a revision, validate a signature or digest, inspect `/Contents`, validate certificates, trust, transforms, permissions, or PDF conformance, or predict viewer behavior. It does not decide whether an update is authorized, safe, or malicious.

Read the canonical [PDFFence 1.24 release note](https://sybilgambleyyu.github.io/posts/pdffence-124.html) for the supported boundary, validation record, and release links.
