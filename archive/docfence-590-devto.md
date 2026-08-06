---
title: A relationship match is not case-sensitive
published: true
description: DocFence 0.59 makes static OPC relationship-signature coverage follow ASCII-case-insensitive selector matching.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-590.html
---

# A relationship match is not case-sensitive

A relationship selector's placement and attributes are syntax. Once that syntax
is valid, the OPC Relationships Transform defines exactly which stored
relationships the selector chooses.

[ECMA-376 Open Packaging
Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.6 says that matching is ASCII case-insensitive.
[DocFence 0.59.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.59.0)
now applies that rule in its bounded static coverage audit.

## Selection is an algorithm, not a string lookup

Consider a stored relationship and a well-shaped selector:

~~~xml
<Relationship Id="rIdStyles"
  Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
  Target="styles.xml"/>

<opc:RelationshipReference SourceId="RIDSTYLES"/>
~~~

Those ID values differ only in ASCII letter case, so the transform selects the
relationship. The same rule applies to a
<code>RelationshipsGroupReference/@SourceType</code> and a stored relationship
<code>Type</code>. If several stored IDs differ only in ASCII case, every
matching relationship is selected.

Earlier coverage resolution used exact string equality. A standards-shaped
declaration with a case-only difference could therefore look unresolved or
uncovered even though the OPC transform would select it.

## A deliberately narrow correction

0.59 folds only ASCII <code>A</code>–<code>Z</code> when comparing selector
values with stored relationship IDs and types. It does not apply broad Unicode
normalization, rewrite package content, widen the selector syntax accepted in
0.58, execute a transform, canonicalize XML, recompute a digest, verify XMLDSIG,
or make a trust decision.

The global boundary remains strict: selectors must be direct, child-free
children of a Relationship Transform with exactly their required attribute.
The change occurs only after that syntax passes, when DocFence reports bounded
declared package-signature coverage.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 70-test suite now covers case-insensitive <code>SourceId</code> matching,
case-insensitive <code>SourceType</code> matching, and a selector that must
select multiple case-colliding IDs.

Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 21 XML
signature parts parse successfully. Their 38 Relationship Transforms contain
106 direct selectors; none has a case-only stored match or a folded-ID
collision, so their public profiles remain identical to 0.58. Main and tagged
CI passed. Two independent epoch-fixed builds were byte-identical, and anonymous
downloads of the published wheel and source distribution matched those artifacts
byte-for-byte.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.59.0/docfence-0.59.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.59 release note](https://sybilgambleyyu.github.io/posts/docfence-590.html)
for the exact policy, threat-model, and validation boundaries.
