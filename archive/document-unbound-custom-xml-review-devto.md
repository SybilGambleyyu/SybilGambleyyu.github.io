---
title: Stored but unbound: custom XML is a document review surface
published: true
description: DCAB 0.23 adds a deterministic unbound custom-XML payload boundary for static Word package review tools.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/document-unbound-custom-xml-review.html
---

# Stored but unbound: custom XML is a document review surface

A document-review benchmark should not require a visible content control before
it can test a stored custom-XML change. A package can carry a conventional
custom-XML store without a mapping, and a static reviewer should be able to
account for that storage boundary without inventing client-runtime behavior.

[Document Change Assurance Benchmark 0.23.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.23.0)
adds its thirty-fourth deterministic pair:
<code>review.unbound_custom_xml_payload_changed</code>. The pair changes only
a synthetic custom-XML payload. It is deliberately not a data-binding case.

## One opaque boundary, stable package topology

Microsoft’s [Custom XML parts overview](https://learn.microsoft.com/en-us/visualstudio/vsto/custom-xml-parts-overview)
describes embedded custom XML parts as package data that Office solutions can
create or modify while a document is open or closed. That makes stored presence
independently reviewable; it does not establish that a particular document view
will surface the data.

~~~text
customXml/item1.xml            only changed member
customXml/itemProps1.xml       byte-identical
customXml/_rels/item1.xml.rels byte-identical
word/document.xml              byte-identical
w:dataBinding                  absent on both sides
~~~

Both files retain the same package-member set, conventional custom-XML
data/properties topology, relationships, and sequence of stored
<code>w:t</code> values. The builder changes only inert synthetic XML bytes in
<code>customXml/item1.xml</code>. It does not parse that payload as application
data, resolve a target, open Word, render a document, update a control, or
claim that Word displays, uses, or removes it.

## A target-free truth envelope

The public truth says only that the pair represents an unbound custom-XML
payload boundary:

~~~json
{
  "kind": "unbound_custom_xml_payload_changed"
}
~~~

It omits payload values, XML nodes, namespaces, identifiers, and any meaning
assigned to the stored data. Structural validation checks the single-member
boundary, absence of a <code>w:dataBinding</code> marker, unchanged
relationship and properties parts, stable stored text, ZIP and XML validity,
independent reader compatibility, and deterministic regeneration.

## A released consumer, still a tool-neutral corpus

The optional [DocFence 0.33.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.33.0)
adapter reaches a strict 34/34 score with public aggregate evidence only. For
this pair it requires a generic custom-XML change, an unchanged two-part
custom-XML inventory, and zero data bindings. It never receives the XML
payload or a private fingerprint.

Hosted CI passed on Python 3.11, 3.12, and 3.13, including a fresh
public-DocFence adapter installation. Fresh wheel and source-distribution
installs validate the bundled 34-case corpus. The public
[Hugging Face dataset mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was atomically synchronized after release, and its complete project-file
inventory and the new pair’s hashes were compared with the tagged source.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.23.0/document_change_benchmark-0.23.0-py3-none-any.whl
dcab validate
dcab docfence-observations --executable docfence --output observations
dcab score --observations observations --strict
~~~

Fixture schema version 1 remains stable: this is one exact static-review fact,
not a custom-XML classifier, document scrubber, Word client, renderer, or
promise about application behavior. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/document-unbound-custom-xml-review.html)
for the full fixture and validation contract.
