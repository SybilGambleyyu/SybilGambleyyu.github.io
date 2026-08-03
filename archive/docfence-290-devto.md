---
title: A Word schema association is a review boundary
published: true
description: DocFence 0.29 makes Word's stored attached-custom-XML-schema associations reviewable without resolving or validating a schema.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-290.html
---

# A Word schema association is a review boundary

A Word document can retain a stored association between custom XML markup and a
schema target namespace. That association can change while document text and
the rest of the package remain stable. It belongs in package review, but it
does not turn a static reviewer into a schema resolver, loader, or validator.

[DocFence 0.29.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.29.0)
adds a private-by-default inventory for direct `w:attachedSchema` elements in
Word Settings parts. It provides a durable CI signal for that narrow stored
state without exposing namespace identifiers in public output.

## The stored association is meaningful; validation is separate

Microsoft identifies
[`AttachedSchema`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.attachedschema?view=openxml-3.0.1)
as an attached custom XML schema. Word exposes a related
[`AttachToDocument`](https://learn.microsoft.com/en-us/office/vba/api/word.xmlnamespace.attachtodocument)
operation, while its XML APIs expose validation separately. That makes the
stored element important to review, but it does not prove a schema is
available, valid, loaded, or applied in a particular environment.

```text
word/settings.xml
  w:attachedSchema w:val="target namespace"   one or more direct entries

No relationship target is required for this stored association.
```

DocFence accepts the standard `CT_String` leaf shape in Transitional and Strict
Word namespaces: exactly one Word-namespace `w:val` attribute, no children, and
no nonblank text. It inventories only stored topology. It never locates,
resolves, retrieves, loads, or validates a schema; opens Word; or predicts
client behavior.

## Aggregate evidence can still detect a rewrite

Public JSON, Markdown, and SARIF expose just one count:
`attached_custom_xml_schema_count`. Namespace identifiers, Settings-part paths,
and private fingerprints stay local. A same-count namespace rewrite still
changes the private semantic inventory and appears in a diff.

```yaml
rules:
  require_no_attached_custom_xml_schemas: true
```

That candidate-state gate emits `DFP071`. A known, intentional association can
instead be protected as a baseline:

```yaml
rules:
  no_attached_custom_xml_schema_changes: true
```

`DFP072` flags a material private-inventory transition. These rules do not call
a schema safe or unsafe; they make the stored configuration reviewable in a
policy people can inspect.

## Evidence, not schema execution

The 55-test release suite covers Strict and Transitional forms, multiple
associations, malformed leaf rejection, same-count rewrites, privacy redaction,
policy behavior, and JSON/Markdown/SARIF output. Hosted CI passed for the
release commit and tag; fresh wheel and source archive installs passed the
smoke checks.

[DCAB 0.19.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.19.0)
adds a matching deterministic case. Its adapter consumes aggregate evidence
only—never a namespace, Settings path, or private fingerprint.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.29.0/docfence-0.29.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-290.html)
for the complete evidence contract, policy details, and limits.
