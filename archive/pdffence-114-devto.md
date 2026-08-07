---
title: A PDF dictionary is not necessarily an action
published: true
description: PDFFence 1.14 scopes action behavior detection to standard PDF triggers and keeps private PieceInfo rewrites byte-level.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-114.html
---

# A PDF dictionary is not necessarily an action

A dictionary with `/Type /Action`, `/S /URI`, and `/URI` looks like a PDF
action. That shape alone does not establish that a viewer can reach it. It may
instead be application-private document data.

[PDFFence 1.14.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.14.0)
makes that boundary explicit: it tracks action behavior only when the
dictionary is reached through a standard action trigger.

## Shape is not an execution path

The catalog `PieceInfo` entry is intended to carry application-specific piece
data. A producer can place arbitrary private data under a standard `PieceInfo`
record, including a dictionary whose keys happen to resemble an action. That is
different from a document-open action, an annotation or page action, an
additional action, or a continuation in an action `Next` chain.

The generic PDF object walk must still see that private data so a file-byte
rewrite is not invisible. In earlier releases, an eligible behavior field in
such an action-shaped dictionary could enter PDFFence's private active-content
signature merely because of its shape. A change then produced
`active_content_payload_changed` and policy finding `PFP001`, despite no
standard action root reaching it.

## What 1.14 changes

PDFFence now admits type-specific action behavior fields to the active-content
comparison only in a recognized root context. Positional handling of `Next`
action chains remains intact. Changing private `PieceInfo` data still produces
the generic `stored_pdf_bytes_changed` result; it simply does not claim an
active-content behavior rewrite without an execution path.

This is a selectivity correction, not a claim about a particular viewer or an
assertion that private data is harmless. PDFFence does not render PDFs, execute
actions, follow URIs, open attachments, or infer viewer permission decisions.

## Eleven paired controls, not one special case

[PDF Change Assurance Benchmark
1.14.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.14.0)
adds 11 deterministic pairs. Each places an action-shaped dictionary under
catalog `PieceInfo` private data, omits `OpenAction`, and changes one
behavior-bearing field: Thread, URI `IsMap`, Sound, Movie, Hide, Named,
SubmitForm, ResetForm, Rendition, Trans, or RichMediaExecute.

For every pair, the expected semantic result is byte-level only. PDFFence
1.14.0 scores 139/139 across the packaged corpus. The released 1.13.0 wheel
scores 128/139, flagging exactly these 11 controls under its former
shape-based treatment. The same behavior fields still trigger review when they
occur in the supported document-open action path.

The release passed 207 tests and Ruff, while PDFCAB passed 69 tests and Ruff.
Fixed-timestamp wheel and source-archive builds were reproducible and passed
Twine metadata checks. Fresh wheel installs on Python 3.12 and 3.13 plus a
Python 3.12 source-archive install each verified and scored all 139 pairs.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.14.0/pdffence-1.14.0-py3-none-any.whl

pdffence init pdffence.yml
pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.14 release note](https://sybilgambleyyu.github.io/posts/pdffence-114.html)
for the validation record and the boundaries this static review gate does not
claim to cross.
