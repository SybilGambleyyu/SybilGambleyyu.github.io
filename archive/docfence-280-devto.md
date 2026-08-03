---
title: A Word save transform is a review boundary
published: true
description: DocFence 0.28 makes Word's stored XSLT-on-single-XML-save configuration reviewable without fetching or executing a transform.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-280.html
---

# A Word save transform is a review boundary

A Word document can carry instructions for what to do when it is saved as a
single XML file. That stored configuration can change while the document text
and visible page remain unchanged. It belongs in a package review, but it does
not turn a review tool into an XSLT host.

[DocFence 0.28.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.28.0)
adds a private-by-default inventory for the narrow configuration family:
`w:useXSLTWhenSaving`, `w:saveThroughXslt`, the standard external `transform`
relationship, and an optional local solution identifier.

## The stored setting is meaningful

Microsoft documents [`SaveThroughXslt`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.savethroughxslt?view=openxml-3.0.1)
as a custom XSL transform used when saving a document as a single XML file.
[`UseXsltWhenSaving`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.usexsltwhensaving?view=openxml-3.0.1)
controls whether the transform is applied, and the OOXML
[Document Settings relationship contract](https://ooxml.info/docs/11/11.9/)
specifies the corresponding `transform` relationship as external.

```text
word/settings.xml
  w:useXSLTWhenSaving     explicit enabled or disabled setting
  w:saveThroughXslt       transform anchor (relationship or local solution ID)

word/_rels/settings.xml.rels
  transform relationship  external stored target
```

DocFence inventories only this stored topology. It does not open Word, invoke a
save, fetch a target, parse a transform, execute it, or predict the XML a
client would emit.

## Reports stay useful without exposing the configuration

Public JSON, Markdown, and SARIF contain only five aggregate counts: enabled
settings, disabled settings, transform anchors, standard transform
relationships, and local solution identifiers. Targets, relationship IDs,
solution values, Settings-part paths, and private fingerprints remain local.

That still detects material rewrites. A same-count target or solution-ID change
changes the private semantic inventory; a relationship-ID renumbering with the
same semantics does not create noise. Orphaned standard transform relationships
remain review-visible as stored evidence.

```yaml
rules:
  require_no_save_through_xslt: true
```

The candidate-state gate emits `DFP069`. A baseline gate is available when a
known configuration is intentionally retained:

```yaml
rules:
  no_save_through_xslt_changes: true
```

`DFP070` reports a material private-inventory transition. Neither rule calls a
transform safe or unsafe; it makes the configuration visible in reviewable
policy.

## Evidence, not execution

The 54-test release suite covers enabled/disabled state, external transform
relationships, local-solution-only anchors, orphan relationships, Strict and
Transitional forms, malformed input rejection, same-count rewrites,
relationship-ID stability, privacy redaction, and JSON/Markdown/SARIF output.
Hosted CI passed for the release commit and tag; fresh wheel and source archive
installs passed the smoke checks.

[DCAB 0.18.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.18.0)
adds a matching deterministic benchmark case. The adapter maps its target-free
aggregate evidence without reading a target, relationship ID, path, or private
fingerprint.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.28.0/docfence-0.28.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-280.html)
for the complete evidence contract, policy details, and limits.
