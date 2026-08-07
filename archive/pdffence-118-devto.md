---
title: A regression gate cannot see an already stale signature boundary
published: true
description: PDFFence 1.18 adds a static review gate for semantic PDF signatures with no ByteRange reaching the current file end.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-118.html
---

# A regression gate cannot see an already stale signature boundary

PDFFence 1.17 could make one important condition review-visible: a semantic
PDF signature's `/ByteRange` reached the file end before a comparison and does
not now. That is a regression question. But review workflows often start after
history has accumulated. If both sides already have a range behind their
current physical file end, a regression-only rule correctly sees no new drop.

[PDFFence 1.18.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.18.0)
adds the complementary static gate.

## A baseline cannot answer every review question

The narrow question is: if a PDF has a standard semantic signature root, is
there at least one corresponding well-formed ByteRange that reaches the current
stored file end?

PDFFence establishes a signature root only through a catalog-reachable AcroForm
signature field, including inherited `/FT`, or catalog `/Perms` DocMDP, UR, or
UR3. A private `/PieceInfo` dictionary that resembles `/Type /Sig` does not
become signature evidence merely because of local key names.

## PFP010: require a current boundary when signatures exist

The opt-in `require_current_file_signature_coverage` rule (`PFP010`) fails only
when an inspected PDF has semantic signature roots and none of their ByteRanges
reaches the current physical file end. Unsigned PDFs pass; this does not demand
that every document be signed.

PFP010 complements `no_signature_coverage_regressions` (`PFP009`): PFP009 asks
whether current coverage fell, while PFP010 asks whether any current coverage
exists now. The latter gives a generic review gate for a document received
without a known-good predecessor.

~~~yaml
version: 1
rules:
  require_current_file_signature_coverage: true
~~~

## A control with no coverage delta

[PDF Change Assurance Benchmark
1.18.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.18.0)
adds a pair where the baseline already has a field-root range before current
EOF. The candidate appends a second distinct incremental revision, yet aggregate
coverage counts remain zero. The expected public changes are only the revision
chain and stored bytes. PFP009 has no new regression to report; PFP010 is the
single policy result.

The [PDF 2.0 signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html)
and the [PDF Association advisory](https://pdfa.org/recently-identified-pdf-digital-signature-vulnerabilities/)
explain why byte-range boundaries deserve explicit review—and why they cannot
replace signature validation.

PFP010 can flag a later update that a conforming validator may consider
acceptable. PDFFence does not locate or validate `/Contents`, calculate a
signed digest, validate a certificate or trust chain, inspect transforms or
permissions, or decide whether an update is valid, permitted, safe, or
malicious. It reports fixed aggregate counts and generic findings only.

PDFFence passed 235 tests and Ruff; PDFCAB passed 85 tests and Ruff. The source
candidate scored all 155 pairs. Both packages built reproducibly and passed
Twine checks; clean Python 3.12/3.13 wheel installs and a Python 3.12
source-archive install passed dependency checks, fixture verification, and the
complete score.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.18.0/pdffence-1.18.0-py3-none-any.whl

pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.18 release note](https://sybilgambleyyu.github.io/posts/pdffence-118.html)
for the precise static-review boundary and validation record.
