---
title: An OPC signature has only three transform algorithms
published: true
description: DocFence 0.56 permits only OPC's three transform algorithms in recognized package XML signatures.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-560.html
---

# An OPC signature has only three transform algorithms

Generic XMLDSIG is extensible: a Reference can describe arbitrary transform
algorithms. OPC deliberately narrows that freedom for package signatures. A
recognized OPC Signature can use its Relationship Transform or either of its two
XML Canonicalization variants. No other XMLDSIG
<code>Transform/@Algorithm</code> belongs in the Signature.

[DocFence 0.56.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.56.0)
now rejects every XMLDSIG <code>ds:Transform</code> in a recognized package
signature whose <code>Algorithm</code> is missing or outside that set.

## One rule for the whole Signature

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.8.1 restricts the transform algorithm set to three values:

~~~text
XML Canonicalization
XML Canonicalization with Comments
OPC Relationship Transform
~~~

The check is global: it applies before the bounded static package-coverage audit
and includes transform lists on References that audit does not otherwise follow.

That distinction matters because the broader [XML Signature Core
specification](https://www.w3.org/TR/xmldsig-core/) describes transforms as
ordered processing steps selected by the signer; OPC is the package-specific
layer that removes the open-ended choice.

## Coverage cannot hide an unsupported transform

The regression starts with a fully declared synthetic package signature and adds
one same-document <code>SignedInfo</code> Reference carrying an unsupported
transform URI. Version 0.55 accepted that package and still reported declared
package coverage. Version 0.56 rejects it structurally. An allowed
canonicalization transform on the same extra Reference remains accepted.

The same rule now rejects an unsupported transform in the package-object binding
or a manifest package-part declaration. Those locations no longer degrade only
to an unsupported coverage count: their containing recognized Signature is
malformed.

## No transform engine

DocFence compares stored element and attribute values only. It does not resolve
or execute a transform, interpret transform parameters, canonicalize XML,
recompute a digest, verify XMLDSIG, validate certificates, establish trust, or
predict an Office client. Its public output continues to withhold signatures,
URIs, selectors, algorithms, digest material, and document contents.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite covers unsupported and missing transform algorithms on
additional <code>SignedInfo</code> References, plus unsupported transforms in
the bounded coverage paths and a positive non-coverage canonicalization case.
Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 22 XML
signature parts are present and 21 parse successfully. They contain 38 OPC
Relationship Transforms and 63 XML Canonicalization Transforms, with no other
transform algorithms. Every aggregate profile is byte-identical to 0.55.

Main and tagged CI passed on Python 3.11 and 3.13. Fresh wheel and
source-distribution installations reject both missing and unsupported transform
algorithms while accepting the permitted canonicalization case. Two independent
tagged builds were byte-identical, and the public release downloads were
byte-compared with that build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.56.0/docfence-0.56.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.56 release note](https://sybilgambleyyu.github.io/posts/docfence-560.html)
for the exact policy, threat-model, and validation boundaries.
