---
title: A declaration has an attribute boundary
published: true
description: DocFence 0.62 stops unknown XMLDSIG Reference and DigestMethod attributes from receiving static package-signature coverage credit.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-620.html
---

# A declaration has an attribute boundary

Signature coverage is only as useful as the declaration that supports it.
[DocFence 0.62.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.62.0)
tightens one small but consequential boundary in its static OPC
package-signature audit: a <code>Reference</code> or <code>DigestMethod</code>
with undeclared attributes cannot silently receive coverage credit.

## Three attributes on the reference; one on the digest method

XMLDSIG Core's <code>ReferenceType</code> declares <code>Id</code>,
<code>URI</code>, and <code>Type</code>. Its <code>DigestMethodType</code>
declares <code>Algorithm</code>. In the one bounded binding-and-manifest chain
that DocFence uses for declared package coverage, 0.62 now applies those direct
attribute surfaces:

~~~xml
<ds:Reference Id="idWordPart" URI="/word/document.xml?ContentType=..." Type="...">
  <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
  <ds:DigestValue>...</ds:DigestValue>
</ds:Reference>
~~~

<code>Id</code>, <code>URI</code>, and <code>Type</code> remain valid on the
bounded <code>Reference</code>; an <code>Algorithm</code> remains valid on its
direct <code>DigestMethod</code>. An extra attribute is outside the stored
declaration grammar that this coverage audit understands.

## Malformed declarations now fail closed at the right level

An unknown attribute on the <code>SignedInfo</code> reference that binds the
package object leaves that signature without declared package coverage. An
unknown attribute on a manifest reference is retained only as aggregate
unsupported evidence; it covers neither a Word part nor a relationship.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

This does not become general XMLDSIG schema validation. DocFence does not
validate method-parameter child markup, base64 lexical content, digest values,
signature values, certificates, cryptography, or trust. It does not execute a
transform or predict an Office client's effective coverage.

## Evidence and use

The 72-test suite includes valid <code>Reference/@Id</code> and
<code>Reference/@Type</code> cases, plus unknown <code>Reference</code> and
<code>DigestMethod</code> attributes on both the package-object binding and
ordinary manifest paths.

The public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security) provide 29 DOCX
fixtures: 21 XML signature parts parse successfully, with 222 XMLDSIG
references (<code>URI</code> alone 161 times; <code>Type</code> plus
<code>URI</code> 61 times) and 243 <code>DigestMethod</code> elements carrying
only <code>Algorithm</code>. All captured corpus outcomes, including two
expected parser failures, match 0.61 byte-for-byte.

Two independent epoch-fixed builds were byte-identical. SHA-256: wheel
<code>3667fa38e0596ba177805417003dfdeec6fadee408c5eca8f81f3707191cadc5</code>;
source distribution
<code>a5f0645f614520a5723c37938bf694dc76bfb3ee312ed2b6de68924b0cce67c3</code>.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.62.0/docfence-0.62.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.62 release note](https://sybilgambleyyu.github.io/posts/docfence-620.html)
for the exact policy, threat-model, and validation boundaries.
