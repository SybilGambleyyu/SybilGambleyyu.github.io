# A Word editable range can carry an editor identity

A Word document can be broadly read-only yet leave selected text, a table
column, or another region editable. That exception can be useful in a review
template or controlled form. It can also preserve a named person’s e-mail
address, alias, or domain identity inside the OOXML package. A clean-looking
document handoff therefore needs to ask two separate questions: does the
package retain an editable-range exception, and does a report reveal the
identity stored with it?

Microsoft’s [protected-document guidance](https://support.microsoft.com/en-us/word/allow-changes-to-parts-of-a-protected-word-document)
describes this workflow directly: a protected document can allow everyone or
selected individuals to edit a chosen region, with e-mail addresses recommended
when authentication is used. The [Open XML SDK’s `w:permStart`
contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.permstart?view=openxml-3.0.1)
gives the stored representation; its paired
[`w:permEnd`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.permend?view=openxml-3.0.1)
marker closes the range.

[DocFence 0.14.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.14.0)
makes that package state review-visible without printing editor identifiers,
marker IDs, or exact editable content.

## What the package can retain

A `w:permStart` marker stores the beginning of an editable range. Its `w:ed`
attribute can hold an individual editor value; `w:edGrp` can hold a predefined
application group such as `everyone`, `editors`, or `owners`. The corresponding
`w:permEnd` shares the range ID. A start marker can also carry `w:colFirst` or
`w:colLast` for a table-column selection.

These markers are useful only in the broader behavior of a Word client and its
document-protection configuration. They are not a live identity directory, a
proof that an editor is authenticated, or evidence that anyone can presently
edit the file. Microsoft’s [implementation notes](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/25f91d19-68a2-4190-8611-2d804a821d10)
also record that, when both individual and group attributes are stored, Word
gives the individual attribute precedence.

## Counts in reports; identities stay private

DocFence scans supported body, header, footer, footnote, endnote, comment, and
glossary stories in Transitional or Strict OOXML. It validates recognized marker
leaves, required IDs, standard attributes, known group values, column-selector
syntax, custom-XML placement values, and unambiguous IDs within a story.

Profile JSON, Markdown, and SARIF expose only aggregate start/end,
paired/unpaired, individual-editor, predefined-group, table-column-selector,
and custom-XML-placement counts. They do not expose the `w:ed` value, a marker
ID, an exact table column, a story path, or a fingerprint. The complete marker
shape is privately fingerprinted, so a same-count identity rewrite still
appears as a review-relevant inventory change without putting an identity in CI
output.

An unmatched boundary is still counted as stored review state. It is not
presented as an effective permission. This matters because a malformed or
residual marker can still carry sensitive metadata even when Word does not
honor it as an editable region.

## Two policy choices

For a handoff that must carry no stored editable-range permission markup:

```yaml
rules:
  require_no_word_permission_ranges: true
```

This produces `DFP041` whenever a recognized start or end marker is present,
including an unmatched boundary. For a template that intentionally preserves
known editable regions:

```yaml
rules:
  no_word_permission_range_changes: true
```

`DFP042` compares the private inventory against the approved baseline. It
detects a changed editor value or marker shape even when the safe public counts
did not change.

## What this deliberately does not do

DocFence does not authenticate a person, resolve a group, calculate the exact
editable text or cells, emulate client precedence, determine whether Word will
honor a marker, or decide whether a document is secure. It does not turn a
stored editable-range exception into an authorization claim. The inventory is a
bounded package-review signal for CI and handoff workflows.

## Release evidence

The 0.14 suite has 37 tests. It covers aggregate categories, same-count
editor-identity changes, JSON/Markdown/SARIF redaction, policy findings,
body/header discovery, Strict OOXML, unmatched boundaries, and malformed
leaves, IDs, attributes, groups, columns, placement values, and duplicate
boundaries. It passed Python 3.11 and 3.13 CI, Ruff, and compilation checks.

The wheel and source archive were independently rebuilt from the release commit
and matched byte-for-byte. A clean installed wheel profiled a standard-shaped
range-permission package with paired individual and group markers, plus
independent Open XML SDK Strict and ordinary Word fixtures to confirm the
zero-state path. The release artifact download was then verified against its
SHA-256 manifest.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.14.0/docfence-0.14.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-140.html)
has the detailed evidence, policy reference, and threat-model links.
