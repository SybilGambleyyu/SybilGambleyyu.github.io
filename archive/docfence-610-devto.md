---
title: A content type is not case-sensitive
published: true
description: DocFence 0.61 matches OPC manifest ContentType values case-insensitively in its bounded signature-coverage audit.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-610.html
---

# A content type is not case-sensitive

An OPC package-signature manifest identifies a stored part with a local URI and
a <code>ContentType</code> query value. The part name is exact; the query value
is a media type.

[DocFence 0.61.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.61.0)
now keeps that distinction in its bounded declaration-coverage audit.

## The value after <code>ContentType=</code> is a media type

A declaration can look like this:

~~~xml
<ds:Reference URI="/word/styles.xml?ContentType=APPLICATION/XML">
  ...
</ds:Reference>
~~~

[ECMA-376 Open Packaging
Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.7.3 defines the value after <code>ContentType=</code> as the
case-insensitive media type of the target part. <code>APPLICATION/XML</code>
and <code>application/xml</code> therefore name the same type.

Earlier DocFence releases used exact string equality here, so a
standards-shaped declaration with only an ASCII case difference could look
unresolved.

## One rule, three bounded paths

0.61 folds only ASCII <code>A</code>–<code>Z</code> when it compares a manifest
ContentType value. It applies that rule to ordinary part references,
relationship-part references, and the global local-context check that validates
an OPC Relationship Transform. The local URI grammar, the
<code>ContentType</code> query key, and stored part names remain exact.

This is not a new MIME parser or a broader signature validator. DocFence does
not strip parameters, normalize arbitrary Unicode, rewrite a package, execute a
transform, canonicalize XML, recompute a digest, verify XMLDSIG, validate a
certificate, or make a trust decision. It corrects the one comparison that
determines whether its static declaration inventory can credit a
standards-shaped reference.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 71-test suite includes a case-varied ordinary-part media type and a
case-varied relationship-part media type. The latter exercises both the
manifest resolver and the Relationship Transform local-context boundary. A
genuinely different relationship content type remains rejected.

Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 21 XML
signature parts parse successfully. They contain 152 package-manifest
references; 133 are resolvable and all 133 already use the exact stored
ContentType spelling. No corpus profile changes from 0.60. Main and tagged CI
passed, and the independent [Document Change Assurance
Benchmark](https://github.com/SybilGambleyyu/document-change-benchmark) adapter
passed against the tagged wheel.

Two independent epoch-fixed builds were byte-identical. Public downloads of the
published wheel and source distribution matched those artifacts byte-for-byte.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.61.0/docfence-0.61.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.61 release note](https://sybilgambleyyu.github.io/posts/docfence-610.html)
for the exact policy, threat-model, and validation boundaries.
