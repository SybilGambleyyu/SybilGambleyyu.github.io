# A Word link can exist outside its relationship graph

Most Word-link review starts with package relationships. That is useful, but
incomplete. Word can store a `HYPERLINK` field code whose destination sits
directly in the field instruction, with no corresponding relationship target to
inspect.

That matters in CI and controlled handoffs. A document can gain a direct web,
file, or bookmark destination without adding the package record a
relationship-only check expects. The evidence a reviewer needs is that the
field exists and changed—not its destination copied into a build log.

[DocFence 0.17.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.17.0)
adds a separate, privacy-safe inventory for these stored field references.

## A field code is not a relationship

Microsoft’s current [Word field guidance](https://learn.microsoft.com/en-us/office/dev/add-ins/word/fields-guidance)
describes a Hyperlink field as a link to a location in the document or an
external location. The OOXML [`HYPERLINK` field definition](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_HYPERLINKHYPERLINK_topic_ID0EFYG1.html)
goes further: the primary field argument identifies a bookmark or URL, while
`\l` identifies a location in the current file.

A literal primary argument is therefore not enough to call a field external. It
can be a URL, a file location, or a bookmark. DocFence does not guess. It
reports only three lexical cases: a literal leading destination, a literal
`\l` internal-location-only target, or a dynamic/unparseable field code.

Destinations, bookmarks, ScreenTips, frame targets, field instructions, and
story paths never appear in a report. DocFence does not resolve, retrieve,
follow, evaluate, or render a link.

## Stored code, not displayed results

Word can store a field as a compact `w:fldSimple` instruction or a complex
begin/instruction/separate/end sequence. Complex instructions may be split
across runs, retained in tracked-deletion markup, or contain nested fields. A
displayed result can be stale, so DocFence scans only complete stored simple
instructions and complete complex pre-separator instructions across supported
stories. Current and deleted variants remain separately review-visible; loose,
post-separator, and unclosed instructions do not count.

## Two policy choices

For a handoff that must contain no stored `HYPERLINK` field references:

```yaml
rules:
  require_no_word_hyperlink_fields: true
```

This produces `DFP047`. For a governed template that intentionally retains the
fields:

```yaml
rules:
  no_word_hyperlink_field_changes: true
```

`DFP048` protects the private inventory from later mutation. These rules
complement relationship and external-source-field policies rather than
redefining them.

## Release evidence

The 0.17 suite has 43 tests covering simple/split complex fields, quoted and
plain arguments, `\l` locations, trailing switches, nested/dynamic and compound
expressions, revision variants, headers, Strict Word XML, same-count changes,
policy/SARIF output, and redaction.

The released wheel also profiles the public
[`doc.docx` attachment](https://github.com/jgm/pandoc/files/13645632/doc.docx)
from [Pandoc issue #9246](https://github.com/jgm/pandoc/issues/9246). It has a
complete complex `HYPERLINK \l` field in a real Word document. DocFence reports
one literal internal-location-only reference without emitting its bookmark or
result text.

Hosted CI passed on Python 3.11 and 3.13. The wheel and source archive were
rebuilt independently from the release commit and matched byte-for-byte; fresh
release downloads passed the published SHA-256 manifest and package checks.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.17.0/docfence-0.17.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-170.html)
has the detailed evidence, policy reference, and threat-model links.
