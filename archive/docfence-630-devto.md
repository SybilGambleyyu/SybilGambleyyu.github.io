---
title: A transform has an attribute boundary
published: true
description: DocFence 0.63 rejects undeclared XMLDSIG Transforms and Transform attributes anywhere in a recognized OPC package signature.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-630.html
---

# A transform has an attribute boundary

XMLDSIG transform markup has a compact direct attribute grammar.
[DocFence 0.63.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.63.0)
now enforces it anywhere in a recognized OPC package signature, before its
bounded static coverage audit can treat any declaration as evidence.

## The container has none; the transform has one

XMLDSIG Core's <code>TransformsType</code> declares no attributes. Its
<code>TransformType</code> declares one required attribute:
<code>Algorithm</code>.

~~~xml
<ds:Transforms>
  <ds:Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
</ds:Transforms>
~~~

In 0.63, an attribute-bearing <code>ds:Transforms</code>, or a
<code>ds:Transform</code> with a missing, wrong, or extra attribute, closes the
recognized signature shape. This complements OPC's transform-algorithm
restriction.

## Global structural evidence, not a coverage loophole

The rule applies to every transform in a recognized signature—not only one in
the package-object binding or selected manifest. An extra attribute on an
otherwise unrelated <code>SignedInfo</code> reference cannot remain invisible
while another manifest receives coverage credit. The same is true for a
transform on a Word-manifest reference.

This is not a general transform engine. DocFence does not validate arbitrary
transform parameters or child markup, execute a transform, canonicalize XML,
recompute a digest, verify XMLDSIG, validate certificates, or decide trust.

## Evidence and use

The 73-test suite covers attribute-bearing <code>Transforms</code> and
<code>Transform</code> markup on both a non-coverage <code>SignedInfo</code>
reference and a Word-manifest path.

Across the 29 DOCX files in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 63
<code>Transforms</code> containers are attribute-free and all 101
<code>Transform</code> elements carry only <code>Algorithm</code>. Every
captured corpus outcome matches 0.62 byte-for-byte.

Two independent epoch-fixed builds were byte-identical. SHA-256: wheel
<code>8e32d8430a3cb26ca31962d68a23a145ada0ed1f2aca89f148bc76ca4572ff9e</code>;
source distribution
<code>58874ca4548ba0aeca4b8797c587d7cf3cc598a71b4761ac42c5e107510f56b4</code>.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.63.0/docfence-0.63.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.63 release note](https://sybilgambleyyu.github.io/posts/docfence-630.html)
for the exact policy, threat-model, and validation boundaries.
