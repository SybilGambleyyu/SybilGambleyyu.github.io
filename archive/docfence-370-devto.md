---
title: A Word save setting can change the handoff contract
published: true
description: DocFence 0.37 makes direct Word form-data-only-save configuration review-visible without reading a form value or simulating a save.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-370.html
---

# A Word save setting can change the handoff contract

A document can keep the same text while carrying a stored request that changes
the meaning of a later save. That is a useful handoff fact. It is not proof
that a form was exported, that a field was evaluated, or that a particular
client will do anything.

[DocFence 0.37.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.37.0)
adds a local, aggregate-only inventory for direct Word Settings
<code>w:saveFormsData</code> declarations.

## Stored configuration, not an export claim

The Open XML SDK documents
[SaveFormsData](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.saveformsdata?view=openxml-3.0.1)
as a direct Settings declaration for saving form-field content only. Office
documentation differs in how it describes the delimiter, so this release
deliberately stays at the stored configuration boundary.

DocFence validates one direct leaf per discovered Settings part, canonicalizes
standard on/off spellings, and reports only enabled and explicitly disabled
counts. It does not find or evaluate a form field, read a value, open Word,
save a document, emit a record, infer a delimiter, or predict client behavior.

~~~yaml
rules:
  require_no_save_forms_data: true
~~~

That candidate-state gate emits DFP086. A controlled template can protect an
approved state instead:

~~~yaml
rules:
  no_save_forms_data_changes: true
~~~

DFP087 catches a material private inventory change.

## A paired static-review case

[DCAB 0.27.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.27.0)
adds its 38th deterministic WordprocessingML pair. It fixes a complete legacy
FORMTEXT carrier, package membership, and stored Word text while changing only
the direct <code>w:saveFormsData</code> value in <code>word/settings.xml</code>
from false to true. The pair is static package evidence, not a test of a
generated export.

Tagged CI passed. Fresh release artifacts validated the bundled 38-case corpus,
the public downloads matched the tagged build hashes, and the public
[Hugging Face mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was checked against the generated fixture hash.

The full contract, policy choices, and install instructions are in the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-370.html).
