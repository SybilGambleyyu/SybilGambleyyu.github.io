---
title: Unbound custom XML is still a handoff boundary
published: true
description: DocFence 0.33 adds an aggregate-only candidate gate for conventional Word custom XML package data, including unbound stores.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-330.html
---

# Unbound custom XML is still a handoff boundary

A Word document can carry a conventional custom-XML store even when no visible
content control maps to it. That does not prove a client will display, use, or
remove the data. It does mean the package retains a stored data surface a
handoff policy may need to account for.

[DocFence 0.33.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.33.0)
adds <code>require_no_custom_xml_data</code>, an optional candidate-state gate
for that narrow question. The failure reports an aggregate count only: no XML
values, element names, member paths, or fingerprints leave the local scan.

## Stored package data does not need a visible mapping

Microsoft’s [Custom XML parts overview](https://learn.microsoft.com/en-us/visualstudio/vsto/custom-xml-parts-overview)
describes custom XML parts as package data that Office solutions can create or
modify while a document is open or closed. A content-control binding is one way
a document can refer to a store; it is not a precondition for the store to be
present.

~~~text
customXml/
  item1.xml              conventional stored data
  itemProps1.xml         associated custom-XML properties
  _rels/item1.xml.rels   package relationship material
~~~

DocFence counts conventional data and associated-properties parts under
<code>customXml/</code>; relationship parts remain a separate structural
surface. The scanner does not expose or interpret XML values, classify a
store’s meaning, remove or rewrite anything, or claim what Word will do with
it.

## A clean-candidate gate, not a data classifier

Teams that require a candidate with no conventional custom-XML data or
properties parts can state that boundary directly:

~~~yaml
rules:
  require_no_custom_xml_data: true
~~~

The rule emits <code>DFP079</code> when the candidate contains one or more
counted parts. It needs no approved baseline and does not disclose why the
store exists or what it contains. A baseline-comparison rule is still useful
when a team permits an approved store but wants to catch a payload boundary
change; this candidate gate answers a different handoff question.

Public JSON, Markdown, and SARIF contain only
<code>custom_xml_part_count</code> for this gate. They do not contain the data
payload, XML node names, package member names, targets, paths, or private
semantic fingerprints.

## A reproducible unbound case

[DCAB 0.23.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.23.0)
supplies a matching deterministic pair:
<code>review.unbound_custom_xml_payload_changed</code>. Baseline and candidate
retain the same conventional custom-XML data/properties topology,
relationships, package-member set, and stored Word text. Only the synthetic
<code>customXml/item1.xml</code> payload changes.

~~~text
word/document.xml       byte-identical on both sides
w:dataBinding           absent on both sides
customXml/item1.xml     the sole changed package member
~~~

The public oracle names the boundary without publishing or interpreting its
payload. DCAB’s optional adapter reaches a strict 34/34 score from DocFence’s
public aggregate evidence: a custom-XML change, a stable two-part custom-XML
inventory, and zero data bindings.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.33.0/docfence-0.33.0-py3-none-any.whl
docfence profile candidate.docx --format markdown
~~~

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-330.html)
has the complete evidence contract, policy links, and verification details.
