# A DDE source can change without changing Word text

A Word field can retain its stored result text while its instruction changes.
That matters when the instruction identifies source material outside the
package: a text-only review sees the same result, while static package review
can make the stored source boundary visible without evaluating the field.

[Document Change Assurance Benchmark 0.7.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.7.0)
adds its eighteenth deterministic pair:
<code>external.dde_field_source_retargeted</code>. Both sides retain the same
complete <code>w:fldSimple</code> shape, field result, application token, item
token, package-member set, and stored <code>w:t</code> sequence. Only
<code>word/document.xml</code> changes, and only in the private source-file
argument.

## Review a stored instruction; do not process it

Microsoft’s [Word field specification for DDE](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/a2c3a25a-1dba-40da-be7a-47cf63c78d55)
defines separate application, source-file, and source-item arguments. DCAB
fixes the synthetic application and item arguments and changes only a
synthetic local-style source-file argument.

Microsoft’s [DDE security advisory](https://learn.microsoft.com/en-us/security-updates/securityadvisories/2017/4053440)
documents Office controls for processing DDE fields. That supports treating the
stored instruction as a review surface, but DCAB is not a client-behavior or
exploit test. Its builder, verifier, scorer, and adapter do not resolve a
source, update a field, open Word, start an application, or invoke DDE.

## A deterministic field-instruction boundary

The independent verifier checks the fixed field shape and instruction
components, deterministic package bytes, stable members, unchanged stored
Word text, and the one-member boundary. <code>python-docx</code> opens all 34
<code>.docx</code> fixtures, and its lower-level OPC reader opens all 36
packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps aggregate external-field evidence while the DDE-field count
remains one. It does not consume source strings or private signatures.

DCAB 0.7.0 retains fixture schema version 1 and extends the corpus from 17 to
18 cases. It does not claim a source exists, is safe, is reachable, was
processed, or will be used by a client.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-dde-review.html)
for the full boundary and install command.
