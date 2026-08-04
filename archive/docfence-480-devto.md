---
title: A package binding needs a real Reference
published: true
description: DocFence 0.48 requires XMLDSIG’s exact Reference shape before a SignedInfo binding can lend static OPC package coverage.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-480.html
---

# A package binding needs a real Reference

A local URI such as <code>#idPackageObject</code> names an OPC package-specific
Object, but the URI alone is not an XMLDSIG Reference. The SignedInfo
declaration that claims to bind the Object also has a required child order and
transform boundary.

[DocFence 0.48.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.48.0)
requires that stored Reference shape before it credits bounded static
package-signature coverage.

## A URI is only the start

The [XMLDSIG Reference schema](https://www.w3.org/TR/xmldsig-core/#sec-Reference)
defines optional Transforms followed by DigestMethod and DigestValue. OPC
restricts package-signature transforms to canonicalization and its Relationships
transform; the latter has defined input only under a Manifest. A Reference to
the package Object can therefore have no transform, or a direct nonempty list
of OPC's two XML Canonicalization forms.

~~~text
ds:SignedInfo
  └─ ds:Reference URI="#idPackageObject"
       ├─ optional ds:Transforms
       │    └─ ds:Transform Algorithm="OPC C14N"
       ├─ ds:DigestMethod Algorithm="…"
       └─ ds:DigestValue (plain, nonempty)
~~~

DocFence requires the direct child order. DigestMethod needs a nonblank
Algorithm; DigestValue must be direct, attribute-free, child-free, and
nonempty. A present transform list must be direct, nonempty, and use only
normal or comment-preserving XML Canonicalization.

## Strict syntax, not XMLDSIG validation

Unknown, relationship, empty, or duplicate transform lists—and missing,
reordered, malformed, nested, extra, or text-bearing digest children—leave
static declaration coverage unavailable.

DocFence does not decode or recompute a digest, execute a transform, verify a
signature, inspect a certificate, establish trust, or predict an Office
client. It checks only the small stored shape necessary for the bounded
coverage declaration it reports.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

DFP092 and DFP093 remain review gates over declared scope, not claims that a
signature is valid or trusted.

## Evidence and use

The 69-test suite accepts a binding with no transform and both permitted
canonicalization forms. It rejects unsupported, relationship, empty, and
duplicate transform lists plus missing, misordered, malformed, nested, extra,
and text-bearing digest children. DCAB's complete reference adapter passed
against a fresh DocFence wheel.

A fresh wheel and source-distribution installation retained complete bounded
coverage for a signed baseline in the public
[OOXML Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security).
The published content-injection, universal-signature-forgery,
duplicate-document, and evil-type variants still exposed uncovered or
unavailable declaration surfaces. This is a stored-structure compatibility
smoke test, never a safety or trust verdict.

Main and tagged CI passed. Source and wheel artifacts were built twice under
the commit timestamp and matched byte-for-byte; public GitHub release downloads
were byte-compared to those verified builds.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.48.0/docfence-0.48.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.48 release note](https://sybilgambleyyu.github.io/posts/docfence-480.html)
for the exact policy, threat-model, and validation boundaries.
