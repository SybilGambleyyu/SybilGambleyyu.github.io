---
title: A signature declaration needs one home
published: true
description: DocFence 0.46 requires OPC's one package-specific XMLDSIG object and SignedInfo binding before static package coverage is credited.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-460.html
---

# A signature declaration needs one home

An OPC package signature can contain several XMLDSIG objects, but only one is
the package-specific object. A static coverage audit should not select any
reachable Manifest and call the result package coverage. It needs to establish
that the declaration is the one OPC structure intended to describe package
content.

[DocFence 0.46.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.46.0)
now treats that topology as a prerequisite for bounded static
package-signature coverage.

**Correction, August 4, 2026:** 0.46 established the required package-object
and binding topology, but it did not yet validate the required OPC
<code>idSignatureTime</code> property inside that object.
[DocFence 0.47](https://sybilgambleyyu.github.io/posts/docfence-470.html)
closes that separate declaration gap by requiring the fixed property ID,
target, SignatureTime child shape, and Format/Value lexical agreement before
coverage is credited.

## One special object, one binding

OPC fixes the package-specific object identifier to <code>idPackageObject</code>.
Its [package-specific Object rule](https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Package_Specific_topic_ID0EWFEK.html)
requires the Manifest and SignatureProperties pair, while its
[SignedInfo rule](https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_SignedInfo_topic_ID0ECHBK.html)
requires exactly one reference to that object.

~~~text
ds:Signature
  ├─ ds:SignedInfo
  │    └─ one Reference URI="#idPackageObject"
  └─ ds:Object Id="idPackageObject"
       ├─ ds:Manifest
       └─ ds:SignatureProperties
~~~

DocFence requires exactly that direct topology before any Manifest declaration
can cover a bounded Word part or relationship:

- one direct object whose only attribute is <code>Id="idPackageObject"</code>;
- exactly one direct <code>ds:Manifest</code>, followed by one direct
  <code>ds:SignatureProperties</code>;
- exactly one direct <code>SignedInfo</code> Reference whose local fragment is
  <code>#idPackageObject</code>.

A nonstandard identifier, missing or extra child, duplicate package object, or
duplicate binding leaves coverage unavailable. Other application-specific
objects are not a substitute for the package-specific carrier.

## Structure first, coverage second

Once the topology qualifies, DocFence resolves only that one Manifest under its
existing narrow rules: exact part URI/content-type matches, bounded
relationship transforms, canonicalization ordering, XMLDSIG digest-child
shape, and exact relationship selectors. It no longer unions declarations from
arbitrary objects.

That makes a failed structure easy to reason about: it is a signature without
declared package coverage, not a partly successful declaration with a few
references attached. Public output remains aggregate-only, so it does not
reveal a part path, URI, selector, digest, certificate, or private semantic
fingerprint.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

The corresponding findings, DFP092 and DFP093, are bounded review controls.
They do not state that a signature is cryptographically valid or trusted.

## This is not XMLDSIG validation

The gate reads only the binding Reference's direct URI fragment. It does not
parse or validate that Reference's digest or transforms, recompute manifest
digests, execute transforms, verify a signature, inspect a certificate,
establish trust, or predict an Office client decision.

That distinction is the point. A static review tool should make the declaration
it understands dependable without pretending to perform the cryptographic or
client-side work it does not perform.

## A matching public benchmark correction

The boundary uncovered a fixture-quality issue in the package-signature pairs
of the Document Change Assurance Benchmark.
[DCAB 0.32.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.32.0)
normalizes those non-cryptographic XMLDSIG-shaped carriers to
<code>idPackageObject</code>. It retains all 42 cases, public facts, fixture
schema, Word text, and review expectations; only private carrier topology
changes. The independent fixture verifier pins the standard identifier rather
than sharing the builder's choice.

The full corpus is public on
[Hugging Face](https://huggingface.co/datasets/SybilGambleyyu/document-change-benchmark).

## Evidence and use

The DocFence suite covers missing SignatureProperties, a nonstandard object ID,
an extra child, duplicate objects, duplicate bindings, and the previous
transform/digest-shape cases. All 67 tests passed, and the complete DCAB
adapter passed against a fresh DocFence wheel.

A fresh wheel and source-distribution installation also retained complete
bounded coverage for a signed baseline from the public
[OOXML Signature Security artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security).
The published content-injection, universal-signature-forgery,
duplicate-document, and evil-type attacker variants each exposed an uncovered
or unavailable declaration boundary. This is a stored-structure compatibility
smoke test, not a trust or safety verdict.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.46.0/docfence-0.46.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.46 release note](https://sybilgambleyyu.github.io/posts/docfence-460.html)
for the policy, threat-model, validation, and reproducibility links.
