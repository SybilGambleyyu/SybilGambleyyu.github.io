---
title: A future-save privacy request is a review boundary
published: true
description: DocFence 0.32 makes Word's stored personal-information-removal-on-save request reviewable without inspecting personal data or predicting a client save.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-320.html
---

# A future-save privacy request is a review boundary

A Word document can store a request that a capable host remove authors’
personal information on a later save. That request is worth reviewing, but it
is not proof that the package currently has no personal information, that a
client will act on it, or that a particular definition of personal information
applies.

[DocFence 0.32.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.32.0)
adds a private-by-default inventory for direct
`w:removePersonalInformation` Settings leaves. It makes the stored request
reviewable in CI without identifying authors, inspecting document properties,
removing data, saving a document, or opening a Word client.

## One direct leaf, one future-save request

Microsoft documents
[`RemovePersonalInformation`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.removepersonalinformation?view=openxml-3.0.1)
as the direct setting under which hosting applications remove document authors’
personal information when saving. The contract also leaves the definition and
extent of that information undefined. DocFence therefore records only the
stored leaf.

```text
word/settings.xml
  w:removePersonalInformation w:val="true"   stored request for a later save

The scanner records this leaf. It does not inspect or alter the package.
```

DocFence accepts one strict `CT_OnOff` leaf per discovered Settings part in
Transitional and Strict Word namespaces. An omitted `w:val` is enabled;
supported enabled and disabled spellings normalize together. Duplicate,
malformed, or ambiguous leaves are rejected rather than guessed about.

The scanner reads stored package bytes only. It never opens or saves Word,
identifies authors, parses document-property values for personal information,
rewrites properties, removes comments or revisions, follows a relationship,
evaluates a field, runs a macro, or claims a host will honor the request.

## Aggregate evidence can protect a precise boundary

Public JSON, Markdown, and SARIF expose only:

- `personal_information_removal_on_save_enabled_setting_count`
- `personal_information_removal_on_save_disabled_setting_count`

Settings paths, raw XML, and private fingerprints stay local. The positive
candidate-state gate checks for a stored request only:

```yaml
rules:
  require_personal_information_removal_on_save: true
```

That emits `DFP077` when no enabled request is stored. It is not a
current-package cleanliness test. A baseline-protection rule catches a
material transition:

```yaml
rules:
  no_personal_information_removal_on_save_changes: true
```

That emits `DFP078`. Neither rule claims a client will remove any data.

## A matching reproducible pair

[DCAB 0.22.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.22.0)
adds a matching deterministic pair: it changes only
`w:removePersonalInformation` from explicit `false` to `true`; package members
and stored text stay fixed. Its optional adapter reaches a strict 33/33 score
from public aggregate evidence only.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.32.0/docfence-0.32.0-py3-none-any.whl
docfence profile candidate.docx --format markdown
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-320.html)
for the full policy and evidence contract.
