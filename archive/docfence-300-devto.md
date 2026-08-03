---
title: A stored Word field-update request is a review boundary
published: true
description: DocFence 0.30 makes Word's stored field-recalculation-on-open setting reviewable without evaluating fields or opening a document client.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-300.html
---

# A stored Word field-update request is a review boundary

A Word document can store a request that its field results be recalculated when
it is opened by an application that supports the setting. That request can
change while visible document text and package topology remain stable. It
belongs in package review, but it does not turn a static reviewer into a field
evaluator or a predictor of client behavior.

[DocFence 0.30.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.30.0)
adds a private-by-default inventory for direct `w:updateFields` settings. It
provides an auditable CI signal for a narrow stored-state boundary without
exposing Settings paths, raw XML, or private fingerprints in public output.

## A stored request, not a field run

Microsoft documents
[`UpdateFieldsOnOpen`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.updatefieldsonopen?view=openxml-3.0.1)
as the WordprocessingML setting for automatically recalculating fields from
field codes when a supporting application opens a document. The direct Settings
leaf matters to review; it does not prove that a particular application will
honor it, identify a source, retrieve data, or change a field result.

```text
word/settings.xml
  w:updateFields w:val="true"    stored enabled request

No relationship target is required for this direct setting.
```

DocFence accepts the strict `CT_OnOff` leaf form in Transitional and Strict
Word namespaces: no child markup or nonblank text, at most one
Word-namespace `w:val` attribute, and a supported on/off spelling. The
omitted value is the enabled form. Malformed and duplicate direct leaves are
rejected rather than guessed about.

It reads the stored setting only. It never opens Word, evaluates a field,
recalculates a result, resolves an instruction, follows a link, accesses a
source, runs a macro, or claims runtime behavior.

## Aggregate evidence can still protect the boundary

Public JSON, Markdown, and SARIF expose two counts:
`field_update_on_open_enabled_setting_count` and
`field_update_on_open_disabled_setting_count`. Settings paths, raw values,
and semantic fingerprints remain private. Equivalent enabled spellings stay
quiet at the inventory layer; an enabled-to-disabled change remains visible as
a private semantic transition.

```yaml
rules:
  require_no_field_updates_on_open: true
```

That candidate-state gate emits `DFP073` only for an enabled setting. A
known, intentional setting can instead be protected as a baseline:

```yaml
rules:
  no_field_update_on_open_changes: true
```

`DFP074` flags a material inventory transition. These rules do not call a
field safe or unsafe; they make a stored configuration boundary reviewable.

## Evidence, not client execution

The 56-test release suite covers absent, implicit, enabled, disabled, and
Strict forms; malformed leaf rejection; equivalent-spelling stability; privacy
redaction; policy behavior; and JSON, Markdown, and SARIF output. Hosted CI
passed for the release commit and tag, and fresh wheel and source archive
installs passed smoke checks.

[DCAB 0.20.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.20.0)
adds the matching deterministic fixture. Its optional DocFence adapter consumes
aggregate evidence only—not a Settings path, raw value, field instruction, or
fingerprint.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.30.0/docfence-0.30.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-300.html)
for the full evidence contract, policy details, and limits.
