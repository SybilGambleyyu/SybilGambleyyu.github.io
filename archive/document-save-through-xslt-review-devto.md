---
title: A Word document can change its XML-save transform without changing its text
published: true
description: DCAB 0.18.0 adds a deterministic Word XML-save XSLT transform-target change case for static package review.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-save-through-xslt-review.html
---

# A Word document can change its XML-save transform without changing its text

Ordinary text diffs cannot explain every consequential WordprocessingML change.
A document can keep every stored text node and its entire Settings XML fixed
while changing the external transform configured for a single-XML save.

[Document Change Assurance Benchmark 0.18.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.18.0)
adds its twenty-ninth deterministic pair:
`external.save_through_xslt_target_retargeted`.

Both packages preserve their member set, stored `w:t` values, explicit enabled
setting, transform anchor, relationship ID, and all Settings XML. Only
`word/_rels/settings.xml.rels` changes, where a synthetic external transform
target is retargeted.

## The complete static topology matters

Microsoft documents [`SaveThroughXslt`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.savethroughxslt?view=openxml-3.0.1)
as a custom XSL transform used when a document is saved as a single XML file.
[`UseXsltWhenSaving`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.usexsltwhensaving?view=openxml-3.0.1)
controls whether it is applied. The OOXML [Document Settings relationship
contract](https://ooxml.info/docs/11/11.9/) defines the associated `transform`
relationship as external.

```text
word/settings.xml                         fixed on both sides
  w:useXSLTWhenSaving true               fixed enabled state
  w:saveThroughXslt r:id                 fixed transform anchor

word/_rels/settings.xml.rels             only changed package member
  transform relationship / target         synthetic target retargeted
```

The fixture models configuration, not execution. It does not include a
transform payload, fetch or parse one, save a document through one, open Word,
or claim emitted XML or client behavior.

## A target-free oracle and a real consumer

The public truth names only `save_through_xslt_target_changed`, an external
binding class, a generic XML-transform relationship category, and the Word
Settings source. It excludes both targets, the relationship ID, relationship
path, and local solution identifiers. URI-like fixture values use the reserved
`example.invalid` domain.

The optional [DocFence 0.28.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.28.0)
adapter reaches a strict 29/29 score from aggregate evidence:
`external_relationships_changed`, `save_through_xslt_inventory_changed`, one
enabled setting, one anchor, one external transform relationship, and no local
solution identifier. It never consumes a target, ID, path, or private
fingerprint.

Hosted CI passed on Python 3.11–3.13 for the main commit and release tag. The
standard `python-docx` reader opens all 56 `.docx` fixtures and its OPC reader
opens all 58 packages. Clean wheel/source-distribution installs validate the
bundled corpus, and the public [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
mirror was byte-verified against the generated tree.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.18.0/document_change_benchmark-0.18.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

DCAB keeps fixture schema version 1: this is one new static-review fact, not a
transform engine, Word emulator, renderer, or universal policy claim. Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-save-through-xslt-review.html)
for the exact package and privacy contract.
