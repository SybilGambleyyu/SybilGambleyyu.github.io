---
title: A digest method has one hard stop
published: true
description: DocFence 0.50 rejects OPC’s expressly forbidden MD5 DigestMethod URI before granting bounded package-signature declaration coverage.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-500.html
---

# A digest method has one hard stop

Static package-signature coverage is not cryptographic verification, but it
still has to respect the standard's hard syntax boundaries. OPC makes a useful
distinction for <code>DigestMethod</code>: SHA-2 values are recommended, SHA-1
is discouraged, and one URI—MD5—is expressly forbidden. A structure-only
parser should preserve that distinction instead of either overlooking the
prohibition or inventing a new algorithm policy.

[DocFence 0.50.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.50.0)
now rejects the exact MD5 URI from its bounded declared-coverage chain.

## “Shall not” is different from “should not”

The [ECMA-376 Open Packaging Conventions standard](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
says a package-signature digest method should use SHA-256, SHA-384, or SHA-512;
it says SHA-1 should not be used; and it says this MD5 URI must not be used:

~~~text
http://www.w3.org/2001/04/xmldsig-more#md5
~~~

A hard standards prohibition can be enforced as stored syntax. A
recommendation or discouragement is not a license for DocFence to claim that a
signature is unsafe, modern, trusted, or valid. That work belongs to a real
XMLDSIG verifier and its policy.

## One exact URI, throughout the declaration chain

DocFence rejects the MD5 URI in every <code>DigestMethod</code> used by its
bounded coverage chain: the SignedInfo Reference binding
<code>idPackageObject</code>, a normal package-part Reference in the bound
Manifest, or a relationship Reference.

An MD5 binding leaves declaration coverage unavailable. An MD5 manifest
Reference is aggregate unsupported, so it cannot lend coverage to a Word part
or a relationship selector. SHA-1 and other values remain structurally
accepted; that is compatibility with OPC's actual conformance language, not
approval of cryptographic properties.

## No digest is recalculated

The rule examines only the stored Algorithm URI. DocFence does not decode or
recompute digest bytes, perform canonicalization, verify XMLDSIG, inspect
certificates, establish trust, or predict an Office client. Its report keeps
algorithm values, reference URIs, selectors, paths, digest material, and
document contents private.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

DFP092 and DFP093 remain bounded declaration gates, not a cryptographic policy
engine.

## Evidence and use

The 69-test suite exercises MD5 in a package-object binding, an ordinary part
Reference, and a relationship Reference; none receives coverage. It also locks
in structural acceptance of a legacy SHA-1 binding. DCAB's complete reference
adapter passed against a fresh DocFence wheel.

A scan of the public [OOXML Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security)
found 243 <code>DigestMethod</code> declarations, all SHA-256 and none MD5.
Fresh wheel and source-distribution installations retained complete bounded
coverage for signed baselines; the published content-injection,
universal-signature-forgery, duplicate-document, and evil-type variants
retained their expected uncovered or unavailable surfaces. This is a
stored-structure compatibility smoke test, never a safety or trust verdict.

Main and tagged CI passed. Source and wheel artifacts were verified against
fresh installations, and public GitHub release downloads were byte-compared to
the verified artifacts.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.50.0/docfence-0.50.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.50 release note](https://sybilgambleyyu.github.io/posts/docfence-500.html)
for the exact policy, threat-model, and validation boundaries.
