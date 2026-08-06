---
title: A signature has an order
published: true
description: DocFence 0.60 validates the direct XMLDSIG Signature and SignedInfo child sequences in recognized OPC signatures.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-600.html
---

# A signature has an order

An XML package signature is not a bag of familiar element names. Its core
grammar fixes the direct order of the elements that give a signature its
meaning.

[DocFence 0.60.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.60.0)
makes that order part of the recognized OPC signature boundary before it
records package-signature or declared-coverage evidence.

## The direct grammar matters

[ECMA-376 Open Packaging
Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.1 requires a Digital Signature XML Signature part to be schema-valid
against the XMLDSIG and OPC signature schemas. The XMLDSIG core schema begins a
signature with this direct sequence:

~~~text
ds:Signature
  ds:SignedInfo
  ds:SignatureValue
  ds:KeyInfo?       # optional
  ds:Object*        # zero or more
~~~

Its <code>SignedInfo</code> child has an equally fixed sequence:

~~~text
ds:SignedInfo
  ds:CanonicalizationMethod
  ds:SignatureMethod
  ds:Reference+
~~~

Before 0.60, DocFence counted the required elements but did not insist on their
direct sequence. A reordered or stray element could retain a recognizable-looking
inventory even though it was not the XMLDSIG structure that OPC requires.

## A bounded grammar check

DocFence now requires those two direct sequences. At this boundary
<code>SignedInfo</code> and <code>SignatureValue</code> may carry only their
optional <code>Id</code> attribute; <code>SignatureValue</code> cannot contain
child XML; and <code>SignatureMethod/@Algorithm</code> must be present and
nonblank.

This is intentionally smaller than full schema validation. DocFence does not
validate base64 lexical content, method parameters, <code>KeyInfo</code> or
application-defined <code>Object</code> payloads, reference digests, XMLDSIG
cryptography, certificates, revocation, signer identity, or trust. It checks
the stored grammar needed before a bounded inventory can say that it recognized
a signature part.

~~~yaml
version: 1
rules:
  require_no_package_digital_signatures: true
  no_package_digital_signature_changes: true
~~~

## Evidence and use

The 70-test suite covers a missing <code>SignatureMethod/@Algorithm</code>,
reordering and unexpected direct <code>Signature</code> and
<code>SignedInfo</code> children, nested and extra-attribute
<code>SignatureValue</code> markup, plus permitted <code>Id</code> attributes.

Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), all 21
parseable XML signature roots use these sequences; their public profiles remain
identical to 0.59. Main and tagged CI passed. Two independent epoch-fixed builds
were byte-identical, and anonymous downloads of the published wheel and source
distribution matched those artifacts byte-for-byte.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.60.0/docfence-0.60.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.60 release note](https://sybilgambleyyu.github.io/posts/docfence-600.html)
for the exact policy, threat-model, and validation boundaries.
