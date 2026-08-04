---
title: A timestamp declaration needs its shape
published: true
description: DocFence 0.47 requires the exact OPC idSignatureTime declaration before static package-signature coverage is credited.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-470.html
---

# A timestamp declaration needs its shape

An OPC package signature carries a claimed signing time in a fixed place. A
static review tool that relies on the package-specific Object for coverage
declarations should not credit that Object when its required time property is
malformed, unrelated, or internally inconsistent.

[DocFence 0.47.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.47.0)
now treats that timestamp-property shape as a prerequisite for bounded static
package-signature coverage.

## One fixed property

The current [ECMA-376 Part 2](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
requires a SignatureProperty below the OPC-specific Object to use the fixed
<code>idSignatureTime</code> ID, target either nothing or the root Signature
ID, and contain a SignatureTime element with no other elements. Its official
[schema bundle](https://ecma-international.org/wp-content/uploads/ECMA-376-2_5th_edition_december_2021.zip)
defines that SignatureTime as an ordered Format/Value pair.

~~~text
ds:Object Id="idPackageObject"
  └─ ds:SignatureProperties
       └─ ds:SignatureProperty
            Id="idSignatureTime"
            Target="" or "#<root Signature Id>"
            └─ opc:SignatureTime
                 ├─ opc:Format
                 └─ opc:Value
~~~

DocFence accepts static coverage only after that direct shape holds:

- exactly one timestamp property;
- only its required <code>Id</code> and <code>Target</code> attributes;
- an empty Target or an exact fragment to the root Signature ID;
- one attribute-free SignatureTime child, with attribute-free Format then Value
  leaves;
- one of OPC's six schema precision formats, with a Value that matches it.

## A structural gate, not a trust verdict

Missing, duplicate, misidentified, mis-targeted, attribute-bearing, malformed,
or format/value-mismatched time properties leave declaration coverage
unavailable. DocFence does not combine a few Manifest references after the
carrier fails.

It also does not say the claimed time is accurate, verify a timestamp
authority, recompute a digest, execute a transform, verify XMLDSIG, inspect a
certificate, establish trust, or predict an Office client.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

DFP092 and DFP093 remain bounded review controls, not statements that a
signature is valid or trusted.

## Evidence and use

The 68-test suite covers all six accepted timestamp formats and the permitted
empty Target form, alongside malformed timestamp-property IDs, targets,
attributes, children, formats, and values. DCAB's full adapter suite also
passed against a fresh DocFence wheel.

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
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.47.0/docfence-0.47.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.47 release note](https://sybilgambleyyu.github.io/posts/docfence-470.html)
for the exact policy, threat-model, and validation boundaries.
