---
title: A signature revision footer must be the PDF's terminal footer
published: true
description: PDFFence 1.23 makes historical PDF signature ByteRange evidence fail closed when raw bytes follow the final linked footer.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-123.html
---

# A signature revision footer must be the PDF's terminal footer

A historical PDF signature is not automatically stale after a later incremental update: its `/ByteRange` should normally stop at the `%%EOF` that closed its own revision. But that footer must itself be terminal. A tolerant parser ignoring arbitrary bytes after it is not evidence of a valid later PDF revision.

[PDFFence 1.23.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.23.0) hardens existing PFP013 and PFP014 static signature-boundary evidence around that condition. It remains a review aid, not a signature validator.

The [PDF 2.0 syntax errata](https://pdf-issues.pdfa.org/32000-2-2020/clause07.html) say the last line of a file contains `%%EOF`, while the [signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html) describe a multiple-signature ByteRange as ending at the footer of the incremental update that adds its signature dictionary, with a possible optional EOL. A valid later incremental update has linked cross-reference data and a terminal footer; unlinked raw tail bytes do not.

## The tightened positive evidence

PDFFence follows a confirmed `/Prev`-linked xref chain for catalog-reachable AcroForm and catalog `/Perms` signature roots. It identifies one bounded, unambiguous footer per linked revision, then requires the final linked footer to be at the physical end of the source (apart from its optional EOL) before a signature receives own-revision credit.

This preserves normal history: an older correctly bounded signature can pass after a valid later update. It fails closed for unavailable, ambiguous, malformed, over-limit, or unlinked-tail evidence. PFP013 remains the rule for a well-formed ByteRange ending at its own revision; PFP014 additionally requires the conventional two-pair range to omit exactly its own direct hexadecimal `/Contents` token.

~~~yaml
version: 1
rules:
  require_signature_byte_range_own_revision_coverage: true
  require_contents_bound_own_revision_signature_coverage: true
~~~

Reports retain aggregate counts and generic findings only—never offsets, object references, revision boundaries, footer locations, ranges, signature bytes, digests, certificates, transforms, or trust decisions.

## A focused terminal-footer control

[PDFCAB 1.23.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.23.0) adds the 160th deterministic pair. Both sides begin with a semantic signature and a valid later incremental update, making each ByteRange historically bounded but not current-file coverage. The candidate alone appends unlinked bytes after the final PDF footer.

Only `signature_own_revision_coverage_inventory_changed`, PFP013, and stored byte evidence are expected. PFP014 has no redundant separate event because the own-revision endpoint prerequisite changed. The held 1.22 release reports stored bytes alone for this pair.

PDFFence passed 260 tests, Ruff, and bytecode compilation; PDFCAB passed 90 tests and Ruff. The public CLI score is 160/160. Both distributions built reproducibly, passed Twine checks, and passed fresh wheel installs on Python 3.12 and 3.13 plus a Python 3.12 source-archive install. Re-downloaded GitHub release wheels also scored 160/160 in a fresh Python 3.13 environment.

This does not validate a digest, `/Contents`, certificate, transform, permission, or trust decision, and it does not decide whether an update is authentic, permitted, safe, or malicious.

Read the canonical [PDFFence 1.23 release note](https://sybilgambleyyu.github.io/posts/pdffence-123.html) for the supported boundary, validation record, and release links.
