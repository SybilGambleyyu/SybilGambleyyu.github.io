---
title: A signature reference cannot leave its document
published: true
description: DocFence 0.52 rejects non-local SignedInfo Reference URIs before recognizing an OPC package XML signature.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-520.html
---

# A signature reference cannot leave its document

Generic XMLDSIG can describe detached signatures over other resources. OPC
package signatures cannot use that flexibility inside <code>SignedInfo</code>:
every Reference there must point only within the same <code>Signature</code>
element. A parser that inventories package signatures should establish that
location boundary before reporting generic XMLDSIG markup as OPC evidence.

[DocFence 0.52.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.52.0)
now fails non-local SignedInfo references closed.

## Same document means an explicit URI form

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.7.2 requires <code>SignedInfo</code> References to reference elements
only in the same Signature. XMLDSIG defines its same-document URI forms as
either an empty URI or a URI beginning with a fragment:

~~~xml
<Reference URI="">…</Reference>
<Reference URI="#idPackageObject">…</Reference>
~~~

Those forms identify the XML document that contains the Signature or an element
in it. In contrast, a missing URI leaves object identity to application
context, and a package-relative or absolute URI names something outside that
XML Signature document.

## What 0.52 rejects

Every direct <code>SignedInfo/Reference</code> must now carry either the
explicit empty URI or a nonempty local fragment beginning with <code>#</code>.
An omitted URI, a package path such as <code>/word/document.xml</code>, or an
absolute URI fails the recognized XML-signature shape closed.

This happens before package-signature inventory and static declaration coverage.
It prevents a foreign detached-signature model from borrowing OPC-looking
relationships and content types; it does not change the meaning of a valid
coverage declaration or turn DFP092 and DFP093 into signature verification.

## No URI is followed

DocFence does not dereference a URI, resolve a fragment or XPointer, perform
canonicalization, evaluate transforms, recompute a digest, verify XMLDSIG,
inspect certificates, establish trust, or predict an Office client. The rule
classifies only stored URI location syntax. Public reports withhold reference
URIs, selectors, paths, digest material, and document contents.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite covers both accepted forms—an empty URI and a local
fragment—plus missing, package-relative, and absolute URIs. The public [OOXML
Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security)
contain 29 DOCX fixtures. Compared with 0.51, exactly one profile changes: a
published universal-signature-forgery attacker package has eight ODF-style
package-file References in <code>SignedInfo</code> and now fails structurally
rather than being inventoried as an OPC signature. The other 28 profiles are
unchanged.

Main and tagged CI passed. Fresh wheel and source-distribution installations
accept a valid signed OPC baseline and reject that real foreign-reference
fixture. The public GitHub release downloads were byte-compared with the
reproducible build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.52.0/docfence-0.52.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.52 release note](https://sybilgambleyyu.github.io/posts/docfence-520.html)
for the exact policy, threat-model, and validation boundaries.
