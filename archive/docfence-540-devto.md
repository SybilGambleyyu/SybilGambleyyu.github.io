---
title: XPath is forbidden everywhere in an OPC signature
published: true
description: DocFence 0.54 rejects XMLDSIG XPath elements anywhere in a recognized OPC package signature.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-540.html
---

# XPath is forbidden everywhere in an OPC signature

XMLDSIG permits transform parameters that a generic signature processor may
interpret. OPC is more restrictive: its package-signature rules say that the
XMLDSIG XPath element must not be present. That is a rule about the stored
Signature as a whole, not only the small declaration chain used to report
package coverage.

[DocFence 0.54.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.54.0)
now rejects XMLDSIG XPath elements anywhere in a recognized OPC package
signature.

## A global grammar boundary

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.18 prohibits the XMLDSIG <code>XPath</code> element. The rule does not
ask a package inspector to parse the expression, choose a context, or apply a
transform:

~~~xml
<ds:Transform Algorithm="…">
  <ds:XPath>…</ds:XPath>
</ds:Transform>
~~~

DocFence 0.54 therefore scans every XMLDSIG <code>ds:XPath</code> element in a
recognized package Signature before inventory or static declaration coverage. It
rejects the signature shape closed whether the element is in a coverage
reference, an application object, or another stored Signature subtree.

## Coverage is not the whole grammar

DocFence 0.49 already withheld coverage when an XPath parameter appeared in the
bounded package-object binding or manifest-reference chain. That was useful,
but a <code>SignedInfo</code> element can contain another same-document
Reference outside that chain.

The regression starts with a fully declared synthetic package and adds only one
same-document Reference with a standard canonicalization transform and an XPath
parameter. Version 0.53 accepted that package and still reported complete
declared coverage; 0.54 rejects it structurally. Neither result recalculates a
digest or asserts that the synthetic signature is cryptographically valid.

## No XPath runs

This is a stored-markup check, not an XPath engine. DocFence does not parse or
evaluate XPath, resolve namespaces, canonicalize XML, execute transforms,
recompute a digest, verify XMLDSIG, inspect certificates, establish trust, or
predict an Office client. The public report continues to withhold expressions,
reference URIs, selectors, paths, digest material, and document contents.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite now covers XPath in the package-object binding, a manifest
relationship transform, a manifest part transform, and an additional
non-coverage <code>SignedInfo</code> Reference. Across the 29 DOCX fixtures in
the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 22 XML
signature parts are present, 21 parse successfully, and none contain an XPath
element. Every aggregate profile is byte-identical to 0.53.

Main and tagged CI passed. Fresh wheel and source-distribution installations
accept the compatible SHA-1 probe while rejecting both the already-forbidden
MD5 probe and the new XPath probe. The public release downloads were
byte-compared with the reproducible tagged build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.54.0/docfence-0.54.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.54 release note](https://sybilgambleyyu.github.io/posts/docfence-540.html)
for the exact policy, threat-model, and validation boundaries.
