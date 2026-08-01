# A Word comment can retain a hidden review graph

A visible comment count is not the whole review surface in a current Word file.
Modern comments can retain people records, thread and resolution state, durable
comment identifiers, and reactions in separate OOXML package parts. That leaves
a practical handoff question: does a document carry review metadata that an
ordinary comment scan does not describe?

[DocFence 0.9.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.9.0)
adds a bounded, privacy-safe answer. It inventories the modern-comment
`people`, `commentsExtended`, `commentsIds`, and `commentsExtensible` parts and
reports aggregate counts only. Names, contact providers, user IDs, paragraph
and durable IDs, dates, thread associations, reaction details, paths, XML, and
fingerprints remain private inside the local comparison.

## A separate OOXML review surface

Microsoft's [modern-comments overview](https://support.microsoft.com/en-us/word/using-modern-comments-in-word)
describes an active conversation model with replies and resolved comments. The
corresponding OOXML contracts define a [people part](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-docx/f461e6b7-7a35-4bc4-8153-b60f5d925539),
a [thread/extension part](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-docx/31f689cd-4192-4c2d-8d2f-202b1f8f20e9),
a [comment-ID part](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-docx/22977b5a-5bb5-4f27-b7a1-c6d216c2bb94),
and an [extensible-comment part](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-docx/62c16828-8131-4d1f-99f8-afd7560a1c78).
Microsoft's [reaction extension example](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oreactxml/24d7d1f3-568d-4df9-89ef-42867776d742)
illustrates why this is more than a count of comment text: review metadata can
carry user and time information.

DocFence finds these parts through standard content types, relationship types,
or conventional Word paths. It validates each recognized root and rejects a
recognized metadata relationship that is external or does not resolve to a
stored part. It supports both the established Office 15 `2010/11`
people/thread vocabulary and the current `2012` vocabulary, because real
template packages still contain the former.

## Counts in reports, private comparison underneath

A profile can say that a candidate has two person records, six thread-extension
records, one resolved comment, or three reaction users. It cannot reveal who
they are, which comment they belong to, or where they reside in the ZIP package.

The private comparison signature retains sensitive material so a same-count
identifier or reaction change remains review-visible. OOXML relationship-ID
renumbering alone stays quiet. That makes the evidence practical in CI without
turning CI output into a new copy of reviewer data.

This is deliberately stored-state evidence, not a Word runtime. DocFence does
not render a comment, resolve a person, synchronize an account, decide whether
a notification will fire, interpret unknown extension payloads, or alter
comment state. A nonzero count means the package stores that class of metadata;
it does not prove that a particular Word client will show it or that an account
is live.

## Choose a clean handoff or a protected baseline

For a release that must not retain modern-comment review state:

```yaml
rules:
  require_no_modern_comment_metadata: true
```

`DFP029` fails when any modern-comment count is nonzero. For a controlled
template that intentionally retains approved review state, freeze a baseline:

```yaml
rules:
  no_modern_comment_metadata_changes: true
```

`DFP030` fails when the private inventory changes, even if public counts match.
The ordinary comments-story count remains separate, so a team can describe the
review rule it actually needs.

## Templates, evidence, and the release

DocFence 0.9 also adds bounded `.dotx` and `.dotm` template scanning beside
`.docx` and `.docm`. Templates are often where a review workflow begins and
where residual metadata lasts the longest, so the same policy boundary is useful
before a document is instantiated.

The regression suite covers all four metadata parts; content-type,
relationship, and unlinked conventional-path discovery; legacy and current
vocabularies; malformed roots; rejected external relationships; templates;
same-count metadata changes; policy findings; SARIF; and report redaction. The
final wheel was installed outside its source tree and profiled against an Office
15 Open XML SDK template and an independent modern-comment template.

The wheel and source archive were rebuilt twice from the release commit and
matched byte-for-byte. The [public release](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.9.0)
contains both artifacts and SHA-256 checksums.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.9.0/docfence-0.9.0-py3-none-any.whl

docfence profile review-template.dotx --format markdown
docfence check approved.dotx candidate.dotx --policy docfence.yml --format sarif --output docfence.sarif
```

The complete scope and limits are in the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-090.html).
