---
title: MD5 cannot hide outside the coverage chain
published: true
description: DocFence 0.53 rejects OPC's forbidden MD5 declaration anywhere in a recognized package XML signature.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-530.html
---

# MD5 cannot hide outside the coverage chain

Package-signature coverage answers a bounded question: which required package
declarations are named by a particular signature object. A prohibited
cryptographic declaration is a broader structural question. If an XML Signature
stored in an OPC package declares MD5 anywhere, placing it on an
application-object reference must not make the declaration disappear from the
package-signature boundary.

[DocFence 0.53.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.53.0)
now rejects OPC's forbidden MD5 declaration anywhere in a recognized package
XML signature.

## One hard prohibition, read at its actual scope

[ECMA-376 Open Packaging Conventions](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
§10.5.11 draws an intentional distinction: SHA-256, SHA-384, and SHA-512
<em>should</em> be used; SHA-1 <em>should not</em> be used; the exact
XMLDSIG-More MD5 algorithm URI <em>shall not</em> be used.

~~~text
http://www.w3.org/2001/04/xmldsig-more#md5
~~~

DocFence 0.53 enforces the last statement as a structural rule. It does not
turn a recommendation about SHA-1 into a rejection rule, and it does not
represent a cryptographic approval of any declaration.

## Coverage is not the whole signature

The earlier static coverage checks inspect the small declaration chain that
binds the package object, manifest, relationships, and content types. A
<code>SignedInfo</code> Reference can also name an application object that is
outside that bounded chain. In a native, publicly available signed DOCX
baseline, replacing the digest algorithm on such an application-object
Reference with MD5 used to leave the coverage result intact. No digest was
recomputed and no signature-validity claim was made; it demonstrated a
parser-scope gap.

Now each stored XMLDSIG <code>DigestMethod</code> in a recognized package
Signature is examined before inventory or coverage reporting. The exact
forbidden MD5 URI fails the signature shape closed wherever it appears: a
coverage reference, a manifest reference, or a non-coverage application-object
reference.

## Deliberately narrow, deliberately static

The rule compares only the stored algorithm identifier. DocFence does not
canonicalize XML, evaluate transforms, recompute a digest, verify XMLDSIG,
inspect certificates, establish trust, or predict an Office client. It also
does not reject SHA-1 under this rule: OPC says SHA-1 <em>should not</em> be
used, whereas it says MD5 <em>shall not</em> be used.

~~~yaml
version: 1
rules:
  require_complete_package_signature_coverage: true
  no_package_signature_coverage_changes: true
~~~

## Evidence and use

The 69-test suite includes a real application-object Reference mutation: its
SHA-1 variant remains structurally accepted, while its MD5 variant is rejected.
Across the 29 DOCX fixtures in the public [OOXML Signature Security
artifacts](https://github.com/RUB-NDS/OOXML_Signature_Security), 243 stored
digest declarations use SHA-256 and none use MD5; every profile is unchanged
from 0.52.

Main and tagged CI passed. Fresh wheel and source-distribution installations
accept the valid baseline and its SHA-1 mutation while rejecting the MD5
mutation. The public release downloads were byte-compared with the
reproducible tagged build.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.53.0/docfence-0.53.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

Read the canonical [DocFence 0.53 release note](https://sybilgambleyyu.github.io/posts/docfence-530.html)
for the exact policy, threat-model, and validation boundaries.
