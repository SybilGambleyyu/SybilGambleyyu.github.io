---
title: A current signature boundary must bound the signature contents
published: true
description: PDFFence 1.19 adds a static gate that checks whether a current signature ByteRange gap exactly matches direct Contents.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-119.html
---

# A current signature boundary must bound the signature contents

A PDF signature's `/ByteRange` normally leaves one gap for the signature value
in `/Contents`. PDFFence 1.18 made a useful static question review-visible: does
a semantic signature range reach the current physical file end? But an
EOF-reaching range alone does not establish what its omitted span represents.

[PDFFence 1.19.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.19.0)
adds an opt-in structural review gate for the missing connection.

## The narrower evidence

The new aggregate count is positive only for a semantic signature root when:

- its `/ByteRange` has exactly two pairs and reaches current EOF;
- the sole omitted gap exactly spans a direct hexadecimal `/Contents` token;
- that token is found in an xref-addressable direct signature dictionary by a
  bounded raw lexical scan.

PDFFence establishes a signature root only through a catalog-reachable AcroForm
signature field, including inherited `/FT`, or catalog `/Perms` DocMDP, UR, or
UR3. A private `/PieceInfo` lookalike is not signature evidence.

## PFP011: require a Contents-bound current range

The opt-in `require_contents_bound_current_signature_coverage` rule (`PFP011`)
fails only when an inspected PDF has semantic signature roots but none has that
positive Contents-bound current-file evidence. Unsigned PDFs pass.

~~~yaml
version: 1
rules:
  require_contents_bound_current_signature_coverage: true
~~~

PFP011 complements PFP009 and PFP010. PFP009 asks whether current-file
coverage fell. PFP010 asks whether any current-file boundary exists now. PFP011
asks whether one of those current boundaries has an omitted gap exactly bound
to direct `/Contents`.

## A control that preserves EOF coverage

[PDF Change Assurance Benchmark
1.19.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.19.0)
adds a deterministic pair where both semantic ByteRanges remain well-formed and
reach EOF. The candidate widens its gap by one byte before direct `/Contents`.
The generic coverage inventory changes and PFP011 fires; PFP009 and PFP010
correctly remain quiet.

The scan is intentionally conservative: default limits are 1 MiB per
dictionary and 16 MiB per source. Unavailable, indirect, malformed, or
over-limit objects do not earn positive evidence.

This is not signature validation. The [PDF 2.0 signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html)
and the [PDF Association advisory](https://pdfa.org/recently-identified-pdf-digital-signature-vulnerabilities/)
motivate explicit review while making its limits clear. PDFFence does not
calculate a digest, validate `/Contents`, certificates, trust chains,
transforms, or permissions, or decide whether an update is valid, permitted,
safe, or malicious. It emits no delimiter positions or signature bytes.

PDFFence passed 245 tests and Ruff; PDFCAB passed 86 tests and Ruff. The source
candidates scored all 156 pairs. Both packages built reproducibly and passed
Twine checks; clean Python 3.12/3.13 wheel installs and a Python 3.12
source-archive install passed dependency checks, fixture verification, and the
complete score.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.19.0/pdffence-1.19.0-py3-none-any.whl

pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.19 release note](https://sybilgambleyyu.github.io/posts/pdffence-119.html)
for the precise static-review boundary and validation record.
