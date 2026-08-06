---
title: An allowed transform cannot hide an XPath
published: true
description: DocFence 0.49 rejects XMLDSIG XPath parameters hidden in transforms before granting bounded OPC package-signature coverage.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-490.html
---

# An allowed transform cannot hide an XPath

A transform URI can look compatible while its stored parameter markup says
otherwise. XMLDSIG's generic <code>Transform</code> schema allows an XPath
parameter, but OPC explicitly disallows the <code>ds:XPath</code> element. A
bounded package-signature coverage audit should not give that declaration
authority merely because the outer algorithm name is canonicalization.

[DocFence 0.49.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.49.0)
now rejects that forbidden parameter throughout its bounded declaration chain.

**Correction, August 6, 2026:** 0.49 closes the XPath-parameter gap, but it did
not yet apply OPC's explicit <code>DigestMethod</code> MD5 prohibition to the
declaration chain. [DocFence 0.50](https://sybilgambleyyu.github.io/posts/docfence-500.html)
closes that separate digest-method boundary without turning SHA-1 guidance into
a broader cryptographic policy.

## OPC narrows a generic XMLDSIG surface

The [ECMA-376 Open Packaging Conventions standard](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
limits package-signature transforms to its canonicalization forms and its
Relationships transform. Its XPath rule is direct: XPath filtering is not
allowed in an OPC signature. XMLDSIG nevertheless defines
<code>ds:Transform</code> as a generic parameter carrier, so a superficially
ordinary canonicalization transform can contain a nested XPath element.

~~~text
ds:Transform Algorithm="OPC C14N"
  └─ ds:XPath true()
~~~

Checking only the outer Algorithm would credit the transform without noticing
that its nested content crosses the OPC boundary.

## One narrow rejection rule, three coverage paths

DocFence rejects a <code>ds:XPath</code> element anywhere inside a transform
that participates in its bounded declaration chain: the SignedInfo Reference
that binds <code>idPackageObject</code>, an ordinary package-part Reference in
the bound Manifest, or either transform in a relationship declaration.

A malformed binding leaves declaration coverage unavailable. A manifest
reference carrying XPath remains aggregate unsupported: it cannot lend coverage
to a Word part, and a relationship transform cannot lend even partial coverage
to an otherwise valid selector. Public output retains only aggregate coverage
and unsupported-reference counts; XPath content, selectors, URIs, paths, and
digest material remain private.

## Rejecting syntax is not executing it

This is a stored-structure check. DocFence does not parse or evaluate an XPath
expression, execute a transform, recompute a digest, verify XMLDSIG, inspect a
certificate, establish trust, or predict an Office client. It merely refuses
to turn a declaration with an OPC-forbidden element into an assurance signal.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

DFP092 and DFP093 remain gates over bounded stored declarations, not claims
that a signature is valid or trusted.

## Evidence and use

The 69-test suite covers XPath-bearing binding, part, and relationship
transforms. It proves that a valid relationship selector next to an XPath
parameter receives no partial coverage, while no-transform and both permitted
canonicalization forms remain accepted. DCAB's complete reference adapter
passed against a fresh DocFence wheel.

A scan of the public [OOXML Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security)
found no XPath element in their 22 XML signature parts. Fresh wheel and
source-distribution installations retained complete bounded coverage for a
signed baseline; the published content-injection, universal-signature-forgery,
duplicate-document, and evil-type variants retained their expected uncovered
or unavailable surfaces. This is a stored-structure compatibility smoke test,
never a safety or trust verdict.

Main and tagged CI passed. Source and wheel artifacts were verified against
fresh installations, and public GitHub release downloads were byte-compared to
the verified artifacts.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.49.0/docfence-0.49.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.49 release note](https://sybilgambleyyu.github.io/posts/docfence-490.html)
for the exact policy, threat-model, and validation boundaries.
