---
title: A stored Word field-update request deserves review
published: true
description: DCAB 0.20 makes a stored Word field-recalculation-on-open transition reproducible without evaluating fields or opening Word.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-field-recalculation-on-open-review.html
---

# A stored Word field-update request deserves review

A consequential WordprocessingML change need not alter text, a relationship
target, or a visible page. A document can move from a stored disabled
field-recalculation-on-open setting to an enabled one while its member set and
stored text remain fixed. A static package-review tool should be able to name
that transition without pretending to run the document.

[Document Change Assurance Benchmark 0.20.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.20.0)
adds its thirty-first deterministic pair:
`review.field_recalculation_on_open_enabled`. The baseline stores
`w:updateFields w:val="false"`; the candidate stores
`w:updateFields w:val="true"`. Only `word/settings.xml` changes.

## A direct setting, deliberately not a client run

Microsoft documents
[`UpdateFieldsOnOpen`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.updatefieldsonopen?view=openxml-3.0.1)
as the WordprocessingML request to automatically recalculate fields from field
codes when a supporting application opens a document. The benchmark models that
stored direct leaf—not a client run or an assertion that a particular
application will honor it.

```text
word/settings.xml                         only changed package member
  w:updateFields w:val="false"            baseline direct leaf
  w:updateFields w:val="true"             candidate direct leaf

word/_rels/settings.xml.rels              absent on both sides
```

The pair retains its package members and stored `w:t` sequence. It adds no
Settings relationship part, source target, external link, macro, or payload.
It does not open Word, evaluate a field, calculate a result, resolve an
instruction, access a data source, or claim a runtime effect.

## A public fact without setting material

The target-free oracle reports one fact with two stable properties:

```json
{
  "kind": "field_recalculation_on_open_enabled",
  "source": "word_settings"
}
```

It excludes raw Settings XML, paths, relationship information, field
instructions, results, source identifiers, and private fingerprints. Structural
validation checks exact direct-leaf forms, the one-member change boundary,
absence of a Settings relationship part, stable package topology, unchanged
stored text, deterministic regeneration, and the absence of setting material
from public truth.

## A released consumer without a value leak

The optional [DocFence 0.30.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.30.0)
adapter reaches a strict 31/31 score from aggregate observations:
`field_update_on_open_inventory_changed`, an enabled-count transition from
zero to one, and a disabled-count transition from one to zero. It never
consumes a Settings path, raw attribute value, field instruction, or
fingerprint.

Hosted CI passed for the release commit and tag. Clean wheel and source archive
installs validate the bundled 31-case corpus, and a clean combined install
reaches complete DocFence adapter coverage. The public
[Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
mirror was verified against the generated tree and validated after download.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.20.0/document_change_benchmark-0.20.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

DCAB keeps fixture schema version 1: it adds one exact static-review fact, not
a field evaluator, document client, renderer, source resolver, or universal
policy claim. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/document-field-recalculation-on-open-review.html)
for the complete package and privacy contract.
