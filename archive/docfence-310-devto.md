---
title: A stored template-style update request is a review boundary
published: true
description: DocFence 0.31 makes Word's stored template-style-update-on-open setting reviewable without loading a template or predicting client behavior.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-310.html
---

# A stored template-style update request is a review boundary

A Word package can retain an attached-template relationship while separately
storing a request to update styles from that template when a document opens.
Those are different review facts: retargeting a template is not the same as
enabling a stored template-style-update request, and neither tells a static
scanner what a particular client will do.

[DocFence 0.31.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.31.0)
adds a private-by-default inventory for direct `w:linkStyles` settings. It
makes that narrow configuration boundary reviewable in CI without resolving a
relationship, loading a template, or exposing sensitive package material.

## A direct request beside a separate relationship

Microsoft documents
[`LinkStyles`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.linkstyles?view=openxml-3.0.1)
as the setting for automatically updating document styles from an attached
template when a document opens. That direct Settings leaf is distinct from the
attached-template relationship itself.

```text
word/settings.xml
  w:attachedTemplate r:id="…"       separate relationship anchor
  w:linkStyles w:val="true"         stored enabled request

The scanner reads the request; it does not resolve the relationship.
```

DocFence accepts strict `CT_OnOff` leaves in Transitional and Strict Word
namespaces. An omitted `w:val` is enabled; supported enabled and disabled
spellings normalize together. Duplicate, malformed, or ambiguous leaves are
rejected rather than guessed about.

The feature reads stored package bytes only. It never opens Word, resolves,
retrieves, or loads a template, propagates a style, follows a target, evaluates
a field, runs a macro, or claims runtime behavior.

## Aggregate evidence can protect the boundary

Public JSON, Markdown, and SARIF expose only:

- `template_style_update_on_open_enabled_setting_count`
- `template_style_update_on_open_disabled_setting_count`

Settings paths, raw XML, relationship targets, and private fingerprints stay
private. A candidate-state rule can reject enabled requests:

```yaml
rules:
  require_no_template_style_updates_on_open: true
```

That emits `DFP075`. A baseline-protection rule catches material transitions:

```yaml
rules:
  no_template_style_update_on_open_changes: true
```

That emits `DFP076`. The policies do not classify a template as safe or unsafe;
they make an exact stored review boundary visible.

## Evidence, not template execution

The 58-test release suite covers direct and Strict forms, malformed-leaf
rejection, equivalent-spelling stability, privacy, policy behavior, and all
public output formats. Hosted CI passed for the release commit and tag, and
fresh wheel and source-archive installs passed smoke checks.

[DCAB 0.21.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.21.0)
adds a matching deterministic pair: it fixes the attached-template anchor,
relationship, and synthetic target while moving only `w:linkStyles` from
`false` to `true`. Its optional adapter consumes aggregate evidence only.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.31.0/docfence-0.31.0-py3-none-any.whl
docfence profile candidate.docx --format markdown
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-310.html)
for the full policy and evidence contract.
