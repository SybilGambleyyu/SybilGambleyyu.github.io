---
title: A relationship selector cannot float free
published: true
description: DocFence 0.58 requires OPC relationship selectors to be direct, schema-shaped children of a Relationship Transform.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-580.html
---

# A relationship selector cannot float free

A Relationship Transform has to live in a package manifest, but its selector
elements have rules of their own. They identify the relationships that the
transform selects.

[DocFence 0.58.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.58.0)
makes that selector shape a global recognized-signature boundary, rather than
allowing malformed selectors to be reduced to an aggregate coverage result.

## Selectors belong directly inside the transform

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§§10.5.9–10.5.10 say that <code>opc:RelationshipReference</code> and
<code>opc:RelationshipsGroupReference</code> occur only as children of a
Relationship Transform. The accompanying OPC schema gives each a single
required attribute and simple content:

~~~text
ds:Transform Algorithm=".../RelationshipTransform"
  opc:RelationshipReference SourceId="rId..."

or

ds:Transform Algorithm=".../RelationshipTransform"
  opc:RelationshipsGroupReference SourceType="relationship-type-URI"
~~~

DocFence now requires the selector to be a direct child of that transform. A
<code>RelationshipReference</code> must have exactly <code>SourceId</code>; a
<code>RelationshipsGroupReference</code> must have exactly
<code>SourceType</code>; neither can contain child XML. A standalone selector,
a selector under another transform, a missing, wrong, or extra attribute, or
nested markup makes the recognized package signature malformed.

## Shape first, value later

DocFence does not interpret a selector value, require it to identify a stored
relationship at the global boundary, execute a transform, canonicalize XML,
recompute a digest, verify XMLDSIG, or make a trust decision. The bounded
static coverage audit still reports a well-shaped selector that cannot cover a
stored relationship as unresolved or unsupported evidence.

That distinction closes an important ambiguity from 0.57: malformed selectors
could be accepted as a recognized signature and only contribute an unsupported
coverage count. In 0.58, their syntax cannot quietly remain in a signature
merely because the audit does not use that declaration.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite covers standalone selectors, missing, wrong, and extra
attributes, nested markup, a wrong selector kind, and a standards-shaped
positive selector. A present but empty selector value is also tested as the
intentional narrower case: it remains a coverage concern, not a selector-shape
error.

Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 21 XML
signature parts parse successfully. Their 38 Relationship Transforms contain
106 direct selectors with the expected parent, attribute, and child-free shape;
public profiles are byte-identical to 0.57. Main and tagged CI passed on Python
3.11 and 3.13. Two independent tagged builds were byte-identical, and anonymous
downloads of the published wheel and source distribution were byte-compared with
that build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.58.0/docfence-0.58.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.58 release note](https://sybilgambleyyu.github.io/posts/docfence-580.html)
for the exact policy, threat-model, and validation boundaries.
