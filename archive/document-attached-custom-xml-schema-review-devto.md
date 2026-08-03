---
title: A one-line Word setting can change a custom XML schema association
published: true
description: DCAB 0.19 makes a stored attached custom XML schema namespace rewrite reproducible without resolving or validating a schema.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-attached-custom-xml-schema-review.html
---

# A one-line Word setting can change a custom XML schema association

A consequential WordprocessingML change need not alter text, a relationship
target, or a visible page. A document can retain one direct `w:attachedSchema`
entry in Settings while changing its target namespace. A text-oriented review
has little reason to surface that stored association; a package-review tool
should be able to state it precisely.

[Document Change Assurance Benchmark 0.19.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.19.0)
adds its thirtieth deterministic pair:
`binding.attached_custom_xml_schema_namespace_changed`.

The baseline and candidate preserve their member set, stored text sequence, and
schema-association count. Only `word/settings.xml` changes, where one synthetic
namespace value is replaced.

## A valid leaf, an intentionally narrow boundary

Microsoft documents
[`AttachedSchema`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.attachedschema?view=openxml-3.0.1)
as an attached custom XML schema. The OOXML definition places the
`w:attachedSchema` `CT_String` leaf directly in document Settings. The fixture
models exactly that stored structure: one direct element, one `w:val`
attribute, no child markup or text, and no Settings relationship part.

```text
word/settings.xml                         only changed package member
  w:attachedSchema w:val="namespace"     one valid direct leaf on each side

word/_rels/settings.xml.rels              absent on both sides
```

The case is not a schema-validation experiment. It has no schema payload; does
not locate, retrieve, resolve, or load a schema; does not validate custom XML;
and does not open Word or claim host behavior. The synthetic values use the
reserved `example.invalid` domain.

## Public truth without publishing the namespace

The target-free oracle reports only:

```json
{
  "binding": "custom_xml_schema",
  "kind": "attached_custom_xml_schema_namespace_changed",
  "source": "word_settings"
}
```

It excludes both namespace identifiers, Settings-part paths, relationship
information, and private fingerprints. Structural validation independently
checks exact leaf shape, the one-member boundary, absence of a Settings
relationship part, stable package topology, unchanged stored text, deterministic
regeneration, and the absence of namespace material from public truth.

## A released consumer without a value leak

The optional [DocFence 0.29.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.29.0)
adapter reaches a strict 30/30 score from two aggregate observations:
`attached_custom_xml_schema_inventory_changed` and a fixed
`attached_custom_xml_schema_count` of one. It never consumes a namespace,
Settings path, or private fingerprint.

Hosted CI passed for the release commit and tag. Clean wheel and source archive
installs validate the bundled 30-case corpus. The public
[Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
mirror was byte-verified against the generated tree and validated directly
after download.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.19.0/document_change_benchmark-0.19.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

DCAB keeps fixture schema version 1: this is one exact static-review fact, not
a schema resolver, document client, renderer, validator, or universal policy
claim. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/document-attached-custom-xml-schema-review.html)
for the complete package and privacy contract.
