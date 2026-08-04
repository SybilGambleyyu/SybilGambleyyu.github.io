---
title: A future-save privacy request deserves review
published: true
description: DCAB 0.22 makes a stored Word personal-information-removal-on-save transition reproducible without identifying authors or opening Word.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-personal-information-removal-on-save-review.html
---

# A future-save privacy request deserves review

A direct Word Settings leaf can change while every package member except the
Settings XML and every stored text value remain fixed. That is a narrow static
review fact, but it does not prove anything about the current privacy state of
the document or a future editor save.

[Document Change Assurance Benchmark 0.22.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.22.0)
adds its thirty-third deterministic pair:
`review.personal_information_removal_on_save_enabled`. The baseline stores
`w:removePersonalInformation w:val="false"`; the candidate stores
`w:removePersonalInformation w:val="true"`. Only `word/settings.xml` changes.

## One settings boundary, no personal data payload

Microsoft documents
[`RemovePersonalInformation`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.removepersonalinformation?view=openxml-3.0.1)
as a direct `CT_OnOff` setting under which a hosting application removes
document authors’ personal information when saving. The standard does not
define the extent of personal information. DCAB models only the stored request,
not an author, property, or save result.

```text
word/settings.xml                         only changed package member
  w:removePersonalInformation w:val="false"  baseline direct leaf
  w:removePersonalInformation w:val="true"   candidate direct leaf

word/_rels/settings.xml.rels              absent on both sides
word/document.xml                         byte-identical stored text
```

The pair keeps the same package-member set and stored `w:t` sequence.
Construction and validation do not identify an author, inspect or rewrite
document properties, remove information, save a document, open Word, or claim
that a host will do so.

## A public fact without privacy disclosure

The target-free oracle publishes only this narrow fact:

```json
{
  "kind": "personal_information_removal_on_save_enabled",
  "source": "word_settings"
}
```

It excludes raw Settings serialization, author identity, document-property
content, comments, revisions, document content outside fixed synthetic text,
and private fingerprints. Structural validation checks the exact leaf,
one-member boundary, absent Settings relationships, unchanged text, reader
compatibility, and deterministic regeneration.

## A released consumer, still tool-neutral

The optional [DocFence 0.32.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.32.0)
adapter reaches a strict 33/33 score using only public aggregate evidence:
`personal_information_removal_on_save_inventory_changed`, plus enabled and
disabled count transitions. It never consumes raw XML, author data, or a
private fingerprint.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.22.0/document_change_benchmark-0.22.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/document-personal-information-removal-on-save-review.html)
for the full fixture and validation contract.
