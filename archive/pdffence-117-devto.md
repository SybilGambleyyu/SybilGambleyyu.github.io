---
title: A signature range needs a current file boundary
published: true
description: PDFFence 1.17 distinguishes semantic PDF signature roots from lookalikes and records whether ByteRange reaches the current stored file end.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-117.html
---

# A signature range needs a current file boundary

A PDF can contain a signature dictionary while its stored `/ByteRange` ends
before the physical end of the file being reviewed. A later incremental update
can leave the original range structurally intact and append another revision.
That is useful review evidence, but it is not a verdict about signature
validity, trust, or whether the update is allowed.

[PDFFence 1.17.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.17.0)
makes that narrow boundary review-visible without becoming a signature
validator.

## A signature needs a document owner too

PDFFence does not count every reachable `/Type /Sig` dictionary. It establishes
a signature root only through a catalog-reachable AcroForm signature field,
including inherited `/FT`, or through catalog `/Perms` DocMDP, UR, or UR3. A
private producer value below `/PieceInfo` can still change generic stored-byte
or reachability evidence, but it cannot manufacture signature inventory
evidence simply by looking like a signature.

## Current-file boundary, not validation

For those semantic roots, PDFFence publishes only aggregate counts: signature
dictionaries, ByteRange presence, well-formed layouts, and ByteRanges whose
final endpoint reaches the current physical file end. A layout must use direct
integer pairs, start at byte zero, have non-negative offsets and positive
lengths, remain ordered and in bounds, and reach current EOF to count in the
last category. Offsets, `/Contents`, certificate material, digests,
transforms, and trust results are not exposed or computed.

The [PDF 2.0 signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html)
describe the ByteRange boundary expected for a signature's incremental
revision. The [PDF Association advisory](https://pdfa.org/recently-identified-pdf-digital-signature-vulnerabilities/)
also explains why this static check cannot replace a conforming signature
validator.

## A narrow regression gate

The opt-in `no_signature_coverage_regressions` rule (`PFP009`) fails only when
the aggregate count of semantic ByteRanges reaching the current file end drops.
The new PDFCAB control starts with a valid field-root range at EOF, then appends
a valid incremental update that leaves it behind. Signature structure stays
fixed; coverage evidence changes and PFP009 appears.

[PDF Change Assurance Benchmark
1.17.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.17.0)
also adds the inverse control: a private PieceInfo signature-shaped dictionary
with no standard owner must produce only reachability and stored-byte evidence.
PDFFence 1.17 scores all 154 pairs. The released 1.16 wheel misses the first
coverage event and falsely reports a signature-structure change for the second
control.

PDFFence passed 233 tests and Ruff; PDFCAB passed 84 tests and Ruff. Two
fixed-timestamp builds of both packages were byte-for-byte reproducible and
passed Twine checks. Clean Python 3.12/3.13 wheel installs and a clean Python
3.12 source-archive install passed dependency checks, fixture verification, and
the full score.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.17.0/pdffence-1.17.0-py3-none-any.whl

pdffence init pdffence.yml
pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.17 release note](https://sybilgambleyyu.github.io/posts/pdffence-117.html)
for the exact static-review boundary and validation record.
