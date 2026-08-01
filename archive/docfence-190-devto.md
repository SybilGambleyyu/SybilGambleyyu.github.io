# One Word image link can be two stored markers

“This image has a hyperlink” sounds like one fact. In a Word OOXML package, it
can be more than one stored action marker. That matters in CI: a package
relationship is not enough evidence, and a visible-link count is not the same
thing as the markup stored in the file.

[DocFence 0.19.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.19.0)
adds a privacy-safe inventory for direct DrawingML `a:hlinkClick`,
`a:hlinkHover`, and `a:hlinkMouseOver` markers inside supported Word stories.

## A real image has two click markers

LibreOffice’s public
[`tdf78657_picture_hyperlink.docx` regression fixture](https://github.com/LibreOffice/core/blob/100f43ab871bedda6b427645cbfc2c8083da98b5/sw/qa/extras/ooxmlexport/data/tdf78657_picture_hyperlink.docx)
is identified by its commit as a Microsoft Word 2016 test file. Its one image
hyperlink relationship is referenced by two stored `a:hlinkClick` elements:
one on WordprocessingDrawing’s `wp:docPr`, and another on the picture’s
non-visual properties.

That does *not* mean a user sees two links. It means the package contains two
action markers. A review tool should preserve that stored evidence rather than
silently deduplicating it into a rendered-link guess. One marker can be changed
or removed while the other remains; that package-level change is precisely what
a controlled review needs to see.

## Count the stored action, keep its material private

The inventory reports only aggregate marker/story counts; click/hover/mouse-over
kinds; external/internal/unsupported relationship classes; missing-`r:id`
markers; and the presence of `action` and `invalidUrl` attributes. A package
relationship does not count unless a direct marker references it.

Targets, invalid URLs, action strings, tooltips, frame names, history settings,
relationship IDs, story paths, and fingerprints remain private. The private
signature catches a same-count target or attribute rewrite while a
relationship-ID renumbering with identical resolved semantics remains quiet.

The OOXML [`a:hlinkClick` definition](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_hlinkClick_topic_ID0ENF2KB.html)
documents the relationship target and action-related attributes; its
[hover counterpart](https://c-rex.net/samples/ooxml/e1/part4/OOXML_P4_DOCX_hlinkHover_topic_ID0EF62IB.html)
and the Open XML SDK’s
[mouse-over contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.drawing.hyperlinkonmouseover?view=openxml-3.0.1)
complete the family. DocFence records direct stored elements in supported Word
stories, but does not select a Markup Compatibility branch, resolve a target,
associate markers with a rendered object, validate a URL, or execute an action.

## Two policy choices

For a handoff that must carry no stored DrawingML action markup:

```yaml
rules:
  require_no_word_drawing_hyperlinks: true
```

This produces `DFP051`. For a governed template that intentionally retains
image or shape actions:

```yaml
rules:
  no_word_drawing_hyperlink_changes: true
```

`DFP052` protects the private marker baseline. These rules complement the
generic relationship gate, direct `w:hyperlink` markup gate, and `HYPERLINK`
field gate because each represents different stored evidence.

## Release evidence

The 0.19 suite has 45 tests. It covers click, hover, and mouse-over kinds;
relationship modes/type mismatch; missing IDs; action and invalid-URL attribute
presence; body/header and Strict encodings; orphaned-relationship exclusion;
same-count target/action mutations; relationship-ID renumbering; policy/SARIF
output; and redaction.

The released wheel profiles the public Word 2016 image fixture and reports two
click markers and two external relationship-backed marker references without
emitting its target. Hosted Python 3.11/3.13 CI, reproducible builds, fresh
release-download checksums, package checks, and an isolated-wheel fixture smoke
test all passed.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.19.0/docfence-0.19.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-190.html)
has the detailed evidence, policy reference, and threat-model links.
