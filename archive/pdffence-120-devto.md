---
title: A signature ByteRange cannot hide an indirect signature value
published: true
description: PDFFence 1.20 adds a static gate for indirect top-level values in ByteRange signature dictionaries.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-120.html
---

# A signature ByteRange cannot hide an indirect signature value

A signature `/ByteRange` describes a byte-level digest scope, but its
surrounding dictionary still has an object-layout requirement. The [PDF 2.0
signature errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html)
require direct signature-dictionary values when a byte-range digest is present.
A general PDF parser can resolve an indirect reference for the caller, hiding
that stored distinction during review.

[PDFFence 1.20.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.20.0)
adds aggregate direct-value evidence and an opt-in review rule, PFP012. It is
static object-layout evidence, not signature validation.

## The stored distinction matters

A direct text string and an indirect reference to a text string can resolve to
the same application-level value. In a ByteRange signature dictionary, they are
not the same stored representation. PDFFence asks only whether every
top-level dictionary value is direct. It does not recursively constrain nested
containers or expose a key name, object reference, or value.

The scope is semantic signature roots only: catalog-reachable AcroForm
signature fields, including inherited `/FT`, and catalog `/Perms` DocMDP, UR,
or UR3 entries. A private `/PieceInfo` lookalike is not signature evidence.

## PFP012: require direct ByteRange signature values

`require_direct_byte_range_signature_values` fails when either inspected PDF
has a semantic signature dictionary with `/ByteRange` and an indirect
top-level value. Unsigned PDFs and semantic signature dictionaries without
`/ByteRange` pass. The rule does not depend on an EOF-reaching boundary or an
exact `/Contents` gap.

~~~yaml
version: 1
rules:
  require_direct_byte_range_signature_values: true
~~~

PFP009 detects a current-file coverage regression. PFP010 requires a current
boundary. PFP011 requires a current boundary whose omitted span is exactly
direct `/Contents`. PFP012 is independent: it checks the directness of the
ByteRange signature dictionary's own top-level values.

## A boundary-preserving control

[PDFCAB 1.20.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.20.0)
adds a pair where both sides keep a well-formed, current-file ByteRange with a
gap exactly matching direct hexadecimal `/Contents`. The candidate alone makes
one top-level signature value indirect while the same target remains
independently catalog-reachable.

Only `signature_direct_value_inventory_changed` and PFP012 are expected;
PFP009 through PFP011 remain quiet. PDFFence 1.19 reports stored bytes alone
on this pair, so the fixture proves the new boundary is doing work.

PDFFence records aggregate counts only. It does not emit object references,
values, offsets, signature bytes, digests, certificates, transforms,
permissions, or trust decisions. It does not calculate a digest, validate
`/Contents`, validate a certificate chain, or decide whether an update is
authentic, permitted, safe, or malicious.

PDFFence passed 248 tests and Ruff; PDFCAB passed 87 tests and Ruff. The final
sources scored all 157 benchmark pairs through the public process boundary and
built reproducibly. Clean Python 3.12/3.13 wheel installs and a Python 3.12
source-archive install each passed dependency checks, fixture verification, and
the complete installed score.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.20.0/pdffence-1.20.0-py3-none-any.whl

pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.20 release note](https://sybilgambleyyu.github.io/posts/pdffence-120.html)
for the precise static-review boundary and validation record.
