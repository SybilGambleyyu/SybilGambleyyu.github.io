---
title: A PDF action key needs a path, not just a name
published: true
description: PDFFence 1.15 distinguishes semantic PDF action roots from private and archival action-looking dictionary fields.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-115.html
---

# A PDF action key needs a path, not just a name

A key called `/A` is not enough to make a PDF dictionary executable. Nor is
`/AA`, `/NA`, or `/PA`. The owner and route through the document determine the
key's meaning.

[PDFFence 1.15.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.15.0)
now makes that route part of its private active-content evidence.

## The same name can mean different things

A navigation node's `/NA` and `/PA` actions are meaningful only in a page's
`/PresSteps` navigation structure. A Link annotation's `/PA`, by contrast, is
an archived Web Capture URI rather than an action trigger. Private application
data can also contain action-shaped dictionaries under any of those names.

That is why a generic object walk cannot decide behavior from local shape
alone. It must establish a standard document path first; the distinction comes
from the [PDF 1.7 reference](https://opensource.adobe.com/dc-acrobat-sdk-docs/standards/pdfstandards/pdf/PDF32000_2008.pdf)'s
separate presentation-navigation and Link-annotation definitions.

## What 1.15 recognizes

PDFFence performs bounded semantic traversal from catalog document-open and
additional actions, catalog JavaScript name-tree values, the real catalog page
tree and its annotations, AcroForm fields and widgets, outline items, and page
presentation-step navigation nodes. Its positional `/Next` handling starts only
after one of those roots has been established.

The result is deliberately selective. A private `PieceInfo` payload shaped like
a Link action remains visible as a stored-byte change, but it does not produce
`active_content_payload_changed` or `PFP001`. A URI rewrite at a supported
page, Link, field, outline, or navigation-node action root remains reviewable
even when public action inventory stays fixed.

## Five negatives and six positives

[PDF Change Assurance Benchmark
1.15.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.15.0)
now contains 150 deterministic pairs. Five passive controls cover four private
`PieceInfo` trigger lookalikes—`/A`, `/AA`, `/NA`, and `/PA`—and a real Link
annotation's archival `/PA`. They require only `stored_pdf_bytes_changed`.

Six matching positive controls place a URI action at a real page
additional-action, Link direct-action, field additional-action, outline action,
or navigation-node next/previous path. PDFFence 1.15.0 scores 150/150. The
released 1.14.0 wheel scores 145/150, adding active-content evidence to exactly
the five passive controls.

PDFFence passed 221 tests and Ruff; PDFCAB passed 80 tests and Ruff. Two
fixed-timestamp builds of each package were byte-for-byte reproducible, passed
Twine metadata checks, and were exercised by clean Python 3.12/3.13 wheel
installs plus a Python 3.12 source-archive install.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.15.0/pdffence-1.15.0-py3-none-any.whl

pdffence init pdffence.yml
pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.15 release note](https://sybilgambleyyu.github.io/posts/pdffence-115.html)
for the complete validation record and the exact static-review boundary.
