---
title: Markup Compatibility cannot live inside an OPC signature
published: true
description: DocFence 0.55 rejects Markup Compatibility namespace markup inside recognized OPC package signatures.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-550.html
---

# Markup Compatibility cannot live inside an OPC signature

OOXML Markup Compatibility (MCE) is useful in ordinary document markup: it can
retain alternatives for consumers with different feature support. An OPC package
XML signature is a different boundary. The package-signature rules prohibit
MCE-namespace elements and attributes in the Signature itself. A static review
tool should enforce that rule over the whole recognized signature, not mistake
compatibility markup for a normal branch to inventory.

[DocFence 0.55.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.55.0)
rejects any MCE-namespace element or attribute anywhere in a recognized OPC
package XML signature.

## Two scopes, deliberately separate

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.2 applies a namespace-level restriction to a Digital Signature XML
Signature part.

~~~xml
<ds:Signature … mc:Ignorable="w14">
  …
</ds:Signature>

<ds:Signature …>
  …
  <mc:AlternateContent>…</mc:AlternateContent>
</ds:Signature>
~~~

This does not change DocFence's existing MCE inventory. That inventory
deliberately scans stored non-relationship <code>word/*.xml</code> members and
retains branch and compatibility-rule evidence privately while reporting only
aggregate counts. It does not validate MCE conformance, resolve a feature
prefix, choose a branch, preprocess a package, or predict an Office client.

Signature parts do not enter that Word-part inventory. Once an OPC signature is
recognized through its declared package topology and basic XMLDSIG shape, MCE
markup there is malformed signature syntax. The check is structural: it does
not interpret the markup that caused rejection.

## Coverage cannot hide the grammar violation

The regression starts from a fully declared synthetic package signature. It adds
either one MCE attribute on the Signature root or one MCE element in the
Signature subtree. Version 0.54 accepted both fixtures and reported one
signature with complete declared package coverage. Version 0.55 rejects both
with a document-format error.

That comparison matters because static declared coverage is intentionally
narrow. It follows only a bounded package-object and manifest declaration
chain; the OPC signature grammar applies before that audit. A signature cannot
retain disallowed MCE markup merely because the bounded declaration chain is
otherwise complete.

## No branch processing, no trust claim

DocFence does not select or evaluate an <code>AlternateContent</code> branch,
parse compatibility-rule tokens in a signature, canonicalize XML, execute
transforms, recompute a digest, verify XMLDSIG, validate certificates, establish
trust, or predict an Office client's behavior. The public report still withholds
signature markup, identifiers, URIs, algorithms, digest material, and document
contents.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite now includes fully declared signature fixtures for both MCE
attributes and MCE elements. Across the 29 DOCX fixtures in the public [OOXML
Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security),
22 XML signature parts are present, 21 parse successfully, and none contains
an MCE-namespace element or attribute. Every aggregate profile is
byte-identical to 0.54.

Main and tagged CI passed on Python 3.11 and 3.13. Fresh wheel and
source-distribution installations reject both probes. Two independent builds
from the tag were byte-identical, and the public release downloads were
byte-compared with that tagged build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.55.0/docfence-0.55.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.55 release note](https://sybilgambleyyu.github.io/posts/docfence-550.html)
for the exact policy, threat-model, and validation boundaries.
