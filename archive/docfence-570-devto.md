---
title: A Relationship Transform belongs in the package manifest
published: true
description: DocFence 0.57 requires every OPC Relationship Transform to have its manifest, selector, canonicalization, and relationships-part context.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-570.html
---

# A Relationship Transform belongs in the package manifest

OPC allows only three XMLDSIG transform algorithms in a package signature, but
the Relationship Transform is not interchangeable with canonicalization. It
has a defined input: a relationships part selected from a package manifest.

[DocFence 0.57.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.57.0)
now enforces that context everywhere in a recognized XML signature before its
bounded static coverage audit begins.

## A permitted URI still needs a home

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.8.2 gives the [Relationship Transform](https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Digital_topic_ID0EHROM.html)
a local grammar. In DocFence, every occurrence must satisfy these stored-package
constraints:

~~~text
ds:Manifest
  ds:Reference URI="/...rels?ContentType=application/vnd.openxmlformats-package.relationships+xml"
    ds:Transforms
      opc Relationship Transform with a direct relationship selector
      immediate XML Canonicalization transform
~~~

The reference URI must declare a <code>.rels</code> part using OPC's exact
relationships content type. The transform must contain at least one direct
<code>opc:RelationshipReference</code> or
<code>opc:RelationshipsGroupReference</code>, and the next transform must be
XML Canonicalization, with or without comments. A recognized signature may name
a declared relationships part with the Relationship Transform only once.

## Coverage cannot downgrade malformed context

Before 0.57, the transform-algorithm allowlist correctly blocked unknown
algorithms but still allowed a permitted Relationship Transform in a
same-document <code>SignedInfo</code> Reference that was not a manifest
relationship declaration. It could remain an inventoryable signature because
the coverage audit intentionally follows only one package-specific object. Now
that stray transform makes the recognized signature malformed immediately.

The same boundary rejects a selectorless transform, missing or misordered
canonicalization, a transform whose reference names an ordinary Word part, a
wrong relationships content type, and duplicate transforms for the same
declared relationships part. These are syntax and placement checks; they do not
become merely unsupported coverage counts.

## Still not a transform engine

DocFence does not resolve a declared target for this boundary, interpret
selector values, execute a transform, canonicalize XML, recompute a digest,
verify a signature, validate certificates, establish trust, or predict Office
behavior. Its later static audit can resolve a small declared subset for
coverage, while public reports keep paths, selectors, algorithms, URIs, values,
and document contents private.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite includes a fully declared fixture with an extra
<code>SignedInfo</code> Relationship Transform, missing selector and
canonicalization variants, wrong-content-type and ordinary-Word-part variants,
and duplicate declarations. The standard declared-coverage fixture remains
accepted.

Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 22 XML
signature parts are present and 21 parse successfully. All 38 Relationship
Transforms meet this boundary, and public profiles are byte-identical to 0.56.
Main and tagged CI passed on Python 3.11 and 3.13. Two independent tagged
builds were byte-identical, and the public wheel and source distribution were
downloaded anonymously and byte-compared with that build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.57.0/docfence-0.57.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.57 release note](https://sybilgambleyyu.github.io/posts/docfence-570.html)
for the exact policy, threat-model, and validation boundaries.
