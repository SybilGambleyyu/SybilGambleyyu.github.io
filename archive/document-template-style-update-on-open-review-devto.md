---
title: A stored template-style update request deserves review
published: true
description: DCAB 0.21 makes a stored Word template-style-update-on-open transition reproducible without loading a template or opening Word.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-template-style-update-on-open-review.html
---

# A stored template-style update request deserves review

A WordprocessingML package can change a stored template-style-update request
while the attached template, its Settings relationship, its synthetic target,
the package-member set, and stored text remain fixed. That is different from
retargeting a template, and it can be reviewed without loading the template or
running a Word client.

[Document Change Assurance Benchmark 0.21.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.21.0)
adds its thirty-second deterministic pair:
`review.template_style_update_on_open_enabled`. The baseline stores
`w:linkStyles w:val="false"`; the candidate stores
`w:linkStyles w:val="true"`. Only `word/settings.xml` changes.

## Fixed template topology, one direct-leaf change

Microsoft documents
[`LinkStyles`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.linkstyles?view=openxml-3.0.1)
as the WordprocessingML setting for automatically updating document styles from
an attached template when a document opens. DCAB models the stored setting and
the fixed surrounding topology, not a claim that a client will act on it.

```text
word/settings.xml                         only changed package member
  w:attachedTemplate r:id="rId…"          fixed direct anchor
  w:linkStyles w:val="false"              baseline direct leaf
  w:linkStyles w:val="true"               candidate direct leaf

word/_rels/settings.xml.rels              byte-identical on both sides
  rId… → synthetic external template       fixed relationship and target
```

The pair retains the same package members and `w:t` sequence. Construction and
validation never resolve, retrieve, or load the template; open Word; propagate
styles; or claim a runtime effect.

## A public fact without target disclosure

The target-free oracle publishes only this narrow fact:

```json
{
  "dependency": "attached_template",
  "kind": "template_style_update_on_open_enabled",
  "source": "word_settings"
}
```

It excludes targets, relationship IDs, raw Settings serialization, document
content outside fixed synthetic text, and private fingerprints. Structural
validation checks the exact leaf, one-member boundary, byte-identical Settings
relationships, stable template topology, unchanged text, and deterministic
regeneration.

## A released consumer, still a tool-neutral benchmark

The optional [DocFence 0.31.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.31.0)
adapter reaches a strict 32/32 score from aggregate evidence: the inventory
change, an enabled count from zero to one, a disabled count from one to zero,
and stable attached-template anchor and relationship counts. It does not
consume a target, relationship ID, path, raw value, or fingerprint.

Hosted CI passed on Python 3.11–3.13 for the release commit and tag. Clean wheel
and source-archive installs validate the bundled 32-case corpus, and the
published Hugging Face mirror was byte-compared and validated after download.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.21.0/document_change_benchmark-0.21.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

Fixture schema version 1 is unchanged: this is one exact static-review fact,
not a template loader, style resolver, document client, renderer, source
retriever, or universal policy claim. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/document-template-style-update-on-open-review.html)
for the full contract.
