---
title: A canonicalization method has a boundary
published: true
description: DocFence 0.51 accepts only OPC’s two permitted SignedInfo canonicalization methods before recognizing a package XML signature.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-510.html
---

# A canonicalization method has a boundary

A structure-only package-signature audit still has to distinguish a declared
OPC signature from generic XMLDSIG-shaped markup. In <code>SignedInfo</code>,
OPC makes that distinction explicit: the canonicalization method has exactly
two permitted Algorithm URIs. Counting the element without reading that
declaration makes the boundary looser than the package format itself.

[DocFence 0.51.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.51.0)
now accepts only those two methods before recognizing a package XML signature.

## OPC permits two methods

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.5 says that packages shall use only XML Canonicalization or XML
Canonicalization with Comments. Their Algorithm values are:

~~~text
http://www.w3.org/TR/2001/REC-xml-c14n-20010315
http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments
~~~

That is deliberately different from the neighboring SignatureMethod guidance,
which uses recommendations and permits other algorithms. A parser can enforce
this exact package-format requirement without pretending to decide
cryptographic strength, signature validity, or trust.

## What 0.51 changes

A recognized package XML signature must now contain one direct
<code>SignedInfo/CanonicalizationMethod</code> whose <code>Algorithm</code> is
exactly one of those two URIs. A missing attribute or another URI fails the
recognized XML-signature shape closed. Both standard C14N and the
comments-preserving form remain accepted.

This happens before the bounded declaration-coverage inventory. It prevents
generic or malformed XMLDSIG markup from being reported as an OPC package
signature in the first place; it does not turn DFP092 or DFP093 into a
cryptographic policy.

## No canonicalization is performed

DocFence reads the stored Algorithm URI only. It does not execute
canonicalization, evaluate transforms, decode or recompute a digest, validate a
SignatureMethod, verify XMLDSIG, inspect certificates, establish trust, or
predict what an Office client will accept. Algorithm values, reference URIs,
selectors, paths, digest material, and document contents stay out of public
reports.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

Those remain bounded stored-declaration gates, not a substitute for a verifier
and a trust policy.

## Evidence and use

The 69-test suite now covers ordinary C14N, C14N with comments, a missing
Algorithm attribute, and an unsupported Algorithm. The public [OOXML Signature
Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security) contain
22 XML signature parts: all 21 parseable declarations use standard C14N, while
the remaining attacker part is empty and already fails XML parsing.

Aggregate DocFence profiles for all 29 DOCX fixtures are identical between 0.50
and 0.51. Main and tagged CI passed, and an isolated wheel accepts both
permitted methods while rejecting a targeted unsupported mutation. The public
wheel and source archive were then byte-compared with the reproducible release
build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.51.0/docfence-0.51.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.51 release note](https://sybilgambleyyu.github.io/posts/docfence-510.html)
for the exact policy, threat-model, and validation boundaries.
