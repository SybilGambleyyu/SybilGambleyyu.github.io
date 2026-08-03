---
title: A Word control can change while its XML anchor stays fixed
published: true
description: DCAB 0.16.0 makes an opaque ActiveX persistence rewrite reproducible without parsing or instantiating a control.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-activex-persistence-review.html
---

# A Word control can change while its XML anchor stays fixed

[Document Change Assurance Benchmark 0.16.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.16.0) adds a twenty-seventh deterministic pair for a narrow but important review boundary: an ActiveX control’s opaque persistence binary can change while its visible Word anchor and surrounding XML topology stay fixed.

The new case is `embedded.activex_control_persistence_payload_changed`. Both packages keep their member set, stored Word text, `w:object`/`w:control` anchor, ActiveX XML persistence part, content types, and internal relationships. Only `word/activeX/activeX1.bin` changes.

## The chain is part of the fact

Microsoft’s [`w:control` reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.control?view=openxml-3.0.1) describes the embedded-control anchor under a Word `w:object`. Its [`ax:ocx` contract](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/48c99072-6cf7-4e69-84b1-3bea64f0ee3a) defines the class/persistence metadata and binary relationship reference. The [Embedded Control Persistence Binary Data contract](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/81974a0b-05c0-4c46-b3b6-c96d0b3d3799) specifies the internal `activeXControlBinary` target.

```text
word/document.xml
  w:object / w:control
    -> internal control relationship
    -> ActiveX persistence XML
    -> internal persistence-binary relationship
    -> activeX1.bin (the only changed member)
```

A reviewer needs to associate both relationships, not merely notice a binary part. DCAB fixes that entire topology and changes only inert synthetic marker bytes.

## Static evidence, no activation

The payload is deliberately not a loadable control stream. DCAB never parses it, opens Word, loads or instantiates a control, renders a placeholder, invokes a client/server, authenticates, or claims runtime behavior. It is a static package-review test, not an execution or compatibility test.

The optional [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0) adapter recognizes the transition from target-free aggregate evidence: `embedded_object_inventory_changed` plus stable two-part/two-relationship control topology and one internal Word anchor. It reaches a strict 27/27 score without exposing the control name, class ID, persistence metadata, relationship IDs, paths, payload bytes, or private fingerprints.

Hosted CI passed on Python 3.11–3.13. Fresh wheel and source-distribution installs, public GitHub release downloads, and a fresh [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark) snapshot all validate the 27-case corpus.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.16.0/document_change_benchmark-0.16.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

DCAB 0.16.0 retains fixture schema version 1. It adds one opaque-persistence review boundary—not a control loader, runtime analyzer, document renderer, or universal security-policy claim.

The canonical version of this article is [A Word control can change while its XML anchor stays fixed](https://sybilgambleyyu.github.io/posts/document-activex-persistence-review.html).
