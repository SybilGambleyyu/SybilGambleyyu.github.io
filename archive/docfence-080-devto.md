# A Word field can quietly consult the outside world

A field result can look like ordinary document text while its stored instruction
says something materially different: query a database, include another
document, pull a picture, retain an OLE link, refer to a document used by an
index, or exchange data with another application. A generic field count cannot
distinguish a harmless date from one of those outside-facing instructions.

[DocFence 0.8.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.8.0)
adds a deliberately bounded, privacy-safe inventory for that difference. It
recognizes `DATABASE`, legacy `DATA`, `DDE`, `DDEAUTO`,
`INCLUDE`/`INCLUDETEXT`, `INCLUDEPICTURE`/`IMPORT`, `LINK`, and `RD` fields,
then reports only category counts. Field instructions, source paths, connection
strings, queries, application names, item references, and private fingerprints
do not enter JSON, Markdown, or SARIF.

## Why the field encoding matters

OOXML stores a simple field in `w:fldSimple/@w:instr`. A [complex field](https://ooxml.info/docs/17/17.16/17.16.2/) is a
begin/separate/end sequence whose pre-separator instruction may be split across
multiple `w:instrText` runs and may contain nested fields. DocFence reconstructs
that local instruction state, classifies only its initial field keyword, hashes
the full instruction privately, and discards the source-bearing value before
public output is created.

Tracked revisions add a subtle failure mode. Word can preserve a deleted field
code in [`w:delInstrText`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.deletedfieldcode?view=openxml-3.0.1) beside a current `w:instrText` code. Concatenating them
creates an invented field and can hide a historic external reference. DocFence
assembles current and deleted variants separately, including moved-from and
moved-to field-code ranges. A revised field can therefore contribute evidence
for both stored forms without disclosing either instruction.

## Evidence, not execution

The field name is a review signal, not a runtime verdict. DocFence does not
parse field arguments, run a database query, start DDE, open an OLE object,
locate an included file, retrieve content, or decide whether Word would update a
field. It does not claim to inventory every Word expression that can display a
URL. The boundary is deliberately limited to stored evidence for named field
families.

For a clean handoff, reject all recognized external-source field instructions:

```yaml
rules:
  require_no_external_fields: true
```

That emits `DFP027` when any category count is nonzero. For an approved template
with known fields, freeze a controlled baseline instead:

```yaml
rules:
  no_external_field_changes: true
```

This emits `DFP028` if the private inventory changes. Run fragmentation alone
stays quiet; a changed stored source does not.

## Release evidence

The release covers all eight field categories, simple and complex encodings,
split, nested, resultless, Strict, header-story, revision, moved-field,
non-field-text, unclosed-field, policy, SARIF, and redaction cases. The final
wheel also profiled Apache POI’s independent
[FieldCodes.docx](https://github.com/apache/poi/blob/trunk/test-data/document/FieldCodes.docx)
and [FldSimple.docx](https://github.com/apache/poi/blob/trunk/test-data/document/FldSimple.docx)
fixtures without a false external-source count.

The wheel and source archive were built independently twice with the same
`SOURCE_DATE_EPOCH` and matched byte-for-byte. The public release includes a
wheel, source archive, and SHA-256 manifest; I downloaded the published assets,
verified the checksums, installed the wheel in a fresh environment, and reran
the fixture profile.

Install it with:

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.8.0/docfence-0.8.0-py3-none-any.whl
```

The complete explanation, sources, policy scope, and limits are on the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-080.html).
