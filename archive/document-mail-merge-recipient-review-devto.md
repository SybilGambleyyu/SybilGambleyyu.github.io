---
title: A mail-merge recipient-selection state can change while the source stays fixed
published: true
description: DCAB 0.17.0 makes a stored mail-merge recipient inclusion-state change reproducible without retrieving data or performing a merge.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-mail-merge-recipient-review.html
---

# A mail-merge recipient-selection state can change while the source stays fixed

[Document Change Assurance Benchmark 0.17.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.17.0) adds a twenty-eighth deterministic pair for a narrow but meaningful review boundary: a mail-merge recipient can move from excluded to included while the source, the recipient record, and the rest of the package topology stay fixed.

The new case is `review.mail_merge_recipient_active_state_changed`. Both packages keep their members, stored `w:t` values, mail-merge source, settings markup, relationships, recipient-data content type, and recipient-record hash. Only `word/recipientData.xml` changes: its explicit stored inclusion state moves from `false` to `true`.

## The source and selection are different facts

Microsoft’s [Mail Merge Recipient Data Part contract](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/af3dc913-8c08-4843-ab40-495a92170b96) specifies a recipient-data part related internally from Document Settings, with a `w:recipients` root and no relationships of its own. Its [`w:active` definition](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/7bbd9fb1-6181-481d-b29c-63842301455d) says that a false value excludes the corresponding external record from a merge.

```text
word/settings.xml
  w:mailMerge
    w:dataSource               fixed source anchor
    w:odso / w:recipientData   fixed internal selection anchor

word/_rels/settings.xml.rels
  mailMergeSource relationship fixed
  recipientData relationship   fixed, internal

word/recipientData.xml
  w:recipients / w:recipientData
    w:active false -> true     the only changed state
```

The case includes that complete topology instead of changing a loose setting. It also avoids two misleading shortcuts: Microsoft’s compatibility notes say Word [does not use the `w:src` ODSO element](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/205f8efd-0c52-4f1b-8849-1204e86379e4), and that documents containing [`w:headerSource` fail to open](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/6dce24e5-6a19-4a67-98fb-d2f301658523).

## Static evidence, no merge execution

The source is synthetic and uses `example.invalid`. DCAB never retrieves or parses it, identifies a real recipient, computes a record hash, connects to a provider, performs a merge, opens Word, or claims how a client presents recipient selection. Its public oracle names only `mail_merge_recipient_active_state_changed`; it omits the source target, recipient hash, inclusion value, relationship IDs, and part paths.

The optional [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0) adapter reaches a strict 28/28 score from target-free aggregate evidence: `mail_merge_inventory_changed`, one mail-merge configuration, one data-source relationship, no header-source relationship, and one internally related recipient-data part. It does not publish stored source or recipient data.

Hosted CI passed on Python 3.11–3.13 for both the main commit and release tag. Clean wheel/source-distribution installs, release artifacts, and the public [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark) mirror validate the 28-case corpus.

```bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.17.0/document_change_benchmark-0.17.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations.json
dcab score --observations observations.json --strict
```

DCAB 0.17.0 retains fixture schema version 1. It adds one stored recipient-selection review boundary—not a data connector, merge engine, client runtime, renderer, or universal security-policy claim.

The canonical version of this article is [A mail-merge recipient-selection state can change while the source stays fixed](https://sybilgambleyyu.github.io/posts/document-mail-merge-recipient-review.html).
