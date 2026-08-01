# A Word file can remember a value you cannot see

A Word document can look clean, contain no comment or visible field result, and
still retain arbitrary name/value state in its Settings part. That state is
useful for templates and automation, but a handoff reviewer has a reasonable
question: did the file keep a hidden value that should not cross this boundary?

Word’s [Variable object documentation](https://learn.microsoft.com/en-us/office/vba/api/word.variable)
is unusually direct: document variables are stored with a document or template
to preserve macro settings between sessions, and they are invisible unless an
appropriate `DOCVARIABLE` field is inserted. The [Open XML SDK’s `w:docVar`
contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.documentvariable?view=openxml-3.0.1)
describes the package representation as persisted arbitrary customer data in
name/value pairs.

[DocFence 0.15.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.15.0)
makes that stored state review-visible without copying a variable name or value
into CI output.

## The hidden store is in Settings

A direct `w:docVars` container in a Word Settings part can hold one or more
`w:docVar` leaves. Each leaf has a stored `w:name` and `w:val`. The visible
document body need not reveal either string. A matching `DOCVARIABLE` field can
later display a value, and a macro can read or update it, but those are separate
client behaviors—not proof that a stored value is harmless or unused.

This is distinct from custom document properties and custom XML. The ISO/IEC
29500 material surfaced by the SDK calls document variables a legacy-compatible
mechanism, yet legacy-compatible state still matters in a governed template or
document handoff. A clean review needs to see that the store exists without
turning the report into a copy of it.

## Counts in reports; names and values stay private

DocFence discovers Settings through the conventional `word/settings.xml` path
and through Transitional or Strict relationships from main and glossary
documents. It recognizes direct `w:docVars` containers and direct `w:docVar`
leaves, validates their Word-namespace shape, required attributes, SDK length
limits, and the one-container-per-Settings-part cardinality.

Profile JSON, Markdown, and SARIF expose only aggregate container, variable,
and empty-value counts. They do not emit a variable name, value, Settings-part
path, or fingerprint. The entire recognized container remains inside a private
digest, so a same-count rewrite of a name or value still becomes a
review-relevant inventory change without disclosing either string.

The OOXML schema permits an empty stored value, although ordinary Word
automation does not set one. DocFence counts it rather than guessing at author
intent or silently discarding it.

## Two policy choices

For a handoff that must carry no stored document-variable state:

```yaml
rules:
  require_no_word_document_variables: true
```

This produces `DFP043` whenever a recognized `w:docVars` container is present,
including an empty container. For a template that intentionally retains known
variables:

```yaml
rules:
  no_word_document_variable_changes: true
```

`DFP044` compares the private inventory against the approved baseline. It
detects a changed name or value even when the safe public counts are unchanged.

## What this deliberately does not do

DocFence does not evaluate `DOCVARIABLE` fields, run macros, resolve a variable
name, determine whether a Word client will display a value, or decide what a
value means. It does not claim that a stored variable will be used, that a
template is attached, or that a document is safe. The inventory is bounded
evidence about persisted package state for CI and handoff workflows.

## Release evidence

The 0.15 suite has 39 tests. It covers aggregate categories, same-count
name/value changes, JSON/Markdown/SARIF redaction, policy findings,
conventional/Strict/glossary-linked Settings discovery, empty values, UTF-16
boundary handling, and malformed containers, leaves, attributes, lengths, text,
and relationships. Hosted CI passed on Python 3.11 and 3.13.

The wheel and source archive were independently rebuilt from the release commit
and matched byte-for-byte. A fresh virtual environment installed the wheel from
`site-packages`, profiled a standard-shaped document-variable package without
exposing sentinel values, and preserved the zero-state result on a public Open
XML SDK Word fixture. Fresh release downloads then passed the published
SHA-256 manifest and package checks.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.15.0/docfence-0.15.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-150.html)
has the detailed evidence, policy reference, and threat-model links.
