---
title: A lock declaration is not an effective lock
published: true
description: DocFence 0.39 inventories direct Word content-control lock declarations as static review evidence without claiming client-side enforcement.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-390.html
---

# A lock declaration is not an effective lock

A Word content control can carry a direct stored lock declaration. It is useful
handoff evidence: it says what the package declares. It does not prove that a
particular client will enforce it, or that a missing declaration has a single
effective meaning.

[DocFence 0.39.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.39.0)
adds a local, aggregate-only inventory for direct
<code>w:sdtPr/w:lock</code> markup across supported Word stories. Public reports
contain no control text, tags, IDs, XML paths, or raw values.

## Five static categories

The Open XML SDK defines the direct
[lock element](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.lock?view=openxml-3.0.1)
and its four
[schema values](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.lockingvalues?view=openxml-3.0.1):
<code>unlocked</code>, <code>sdtLocked</code>, <code>contentLocked</code>, and
<code>sdtContentLocked</code>.

DocFence reports those four explicit states separately from controls with no
direct declaration. It does not silently interpret absence as <code>unlocked</code>:
omission has control-type-specific behavior. Equal-count reassignment still
produces <code>content_control_lock_inventory_changed</code>, using only private
local references to retain the signal.

~~~yaml
rules:
  require_content_control_locks: true
~~~

That candidate-state gate emits DFP090 when a discovered control has no direct
declaration or is explicitly <code>unlocked</code>. A controlled template can
protect the approved aggregate inventory instead:

~~~yaml
rules:
  no_content_control_lock_changes: true
~~~

DFP091 catches a material transition. Neither rule applies a lock, opens Word,
authenticates an editor, or predicts client behavior.

## A deterministic paired case

[DCAB 0.29.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.29.0)
adds its 40th pair. It holds the package-member set, content-control ID, tag,
and stored text fixed while changing only direct <code>w:lock/@w:val</code> from
<code>unlocked</code> to <code>sdtContentLocked</code>. Its independent validator
checks that exact static boundary; the optional adapter consumes only
DocFence's public aggregate transition.

Tagged CI passed, the full 40/40 adapter score reached complete fact and
reference-policy agreement, release downloads matched fresh tagged builds, and
the public [Hugging Face dataset mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was checked against the 40-entry manifest and new fixture bytes.

The full contract, policy choices, and install instructions are in the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-390.html).
