# The external picture link your Word review misses

An external-relationship total is a useful warning, but it cannot tell a
reviewer whether an external target is an image source, a hyperlink, an
attached template, or an unused relationship. Word has a direct DrawingML
marker for linked pictures: `a:blip` with `r:link`. It can be present while
the usual hyperlink inventories are empty.

[DocFence 0.21.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.21.0)
adds a privacy-safe inventory for that exact stored boundary: direct DrawingML
linked-picture markers in supported Word stories.

## A linked-picture marker is not an embedded-picture marker

The Open XML SDK documents
[`a:blip/@r:link`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.drawing.blip.link?view=openxml-3.0.1)
as a linked-picture reference for an image that does not reside in the file.
That is distinct from `r:embed`, which refers to an image stored locally in the
package. ECMA-376’s [Image Part
contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Image_topic_ID0EGXDO.html)
allows a standard image relationship to use internal or external target mode.

DocFence scans each direct `a:blip/@r:link` marker in supported Word stories.
It reports only aggregate marker/story counts and whether the resolved backing
relationship is a standard image relationship with stored external mode,
stored internal mode, or an unsupported relationship. A standalone image
relationship and an `r:embed`-only image do not become linked-picture counts.

Targets, relationship IDs, surrounding drawing markup, story paths, and
fingerprints remain private. Same-count target or direct-markup changes remain
visible; an ID-only renumbering with unchanged semantics remains quiet.

## Policies for a clean handoff or governed baseline

```yaml
rules:
  require_no_word_drawing_linked_pictures: true
```

This produces `DFP055`. A controlled template can instead use:

```yaml
rules:
  no_word_drawing_linked_picture_changes: true
```

`DFP056` protects the private marker baseline. These rules complement the
generic external-relationship gate rather than replace it: they add the direct
DrawingML context that a total alone cannot show.

## Evidence and an explicit limit

The 47-test release suite covers external/internal/unsupported relationship
classes, dual `r:link`/`r:embed` markup, embedded-only exclusion, body/header
stories, Strict OOXML, orphan exclusion, same-count target/markup changes,
renumbering stability, policy/SARIF output, and redaction.

It also profiles a real public Word package from pea-sys’s
[`abspath2relpath-docx` investigation](https://github.com/pea-sys/shell-experiments/blob/91386d4de9e499a21bbb2e54743eb63a63727bfb/powershell/survey/abspath2relpath-docx/survey/abs/1.docx).
At the pinned commit, it has two direct `a:blip/@r:link` markers backed by two
external image relationships. DocFence reports those two markers without
emitting paths or IDs. The downloaded fixture SHA-256 is
`8554932d5de0f1c81dbdcbf7b480c17f9008abca18c66a7f03b2e881cfe5147b`.

This is stored-package evidence only. DocFence does not choose a Markup
Compatibility branch, retrieve or resolve an image, update a link, render a
picture, or claim that Word will load or honor a target.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.21.0/docfence-0.21.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the full release note, exact policy contract, and threat-model limits in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-210.html).
