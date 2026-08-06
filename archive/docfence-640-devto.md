---
title: A method has an attribute boundary
published: true
description: DocFence 0.64 rejects undeclared XMLDSIG CanonicalizationMethod and SignatureMethod attributes in recognized OPC package signatures.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-640.html
---

# A method has an attribute boundary

XMLDSIG's two direct SignedInfo method declarations each have one required
attribute: <code>Algorithm</code>. [DocFence
0.64.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.64.0)
now enforces that small attribute grammar before treating a recognized OPC
package signature as structurally valid.

## Parameters are children, not attributes

XMLDSIG's [CanonicalizationMethodType](https://www.w3.org/TR/xmldsig-core/#sec-CanonicalizationMethod)
and [SignatureMethodType](https://www.w3.org/TR/xmldsig-core/#sec-SignatureMethod)
require <code>Algorithm</code> and declare no other attributes. Their schemas
do permit parameter elements, so DocFence keeps that distinction explicit:

~~~xml
<ds:CanonicalizationMethod
    Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315">
  <method:Parameter xmlns:method="urn:example"/>
</ds:CanonicalizationMethod>

<ds:SignatureMethod
    Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256">
  <method:Parameter xmlns:method="urn:example"/>
</ds:SignatureMethod>
~~~

In 0.64, an extra or missing attribute closes the recognized signature shape.
Parameter child markup remains outside this bounded check; DocFence does not
parse a parameter, execute canonicalization, recompute a digest, or verify
XMLDSIG.

## A small rule at the right boundary

The check belongs where DocFence already requires the fixed direct
<code>SignedInfo</code> order: <code>CanonicalizationMethod</code>,
<code>SignatureMethod</code>, then one or more references. The
canonicalization URI must still be one of OPC's two permitted forms, and the
signature-method URI must still be nonblank. This prevents unrecognized method
attributes from being treated as ordinary metadata without turning DocFence
into a general XMLDSIG validator.

## Evidence and use

The 73-test suite now rejects an extra attribute on either method while
accepting schema-permitted parameter children. Across the 29 DOCX files in the
public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), all 21
parseable signature parts use only <code>Algorithm</code> on both method kinds.
Every captured profile outcome matches 0.63 byte-for-byte.

Two independent epoch-fixed builds were byte-identical. SHA-256: wheel
<code>b5ae20ee7164ce323a77776d42d8568e71b1b7ea7a0d31694e84bb6cb7b7ad42</code>;
source distribution
<code>a4a23e70d3e0ee419ebedfc57f3f4b447f72e55541bcd61f841480db1ba1a8ba</code>.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.64.0/docfence-0.64.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.64 release note](https://sybilgambleyyu.github.io/posts/docfence-640.html)
for the exact policy, threat-model, and validation boundaries.
