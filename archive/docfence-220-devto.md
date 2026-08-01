# The legacy Word image link a relationship count cannot explain

An external-relationship total tells a reviewer that a Word package stores an
external target. It cannot say whether that target belongs to a picture the
document actually marks for display, a hyperlink, a template, or an unused
relationship. That ambiguity gets sharper in Word’s legacy VML picture markup.

[DocFence 0.22.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.22.0)
adds a privacy-safe inventory for one precise stored boundary: direct legacy
VML `v:imagedata` markers with an explicit `r:id` that resolves to an externally
stored relationship.

## An image-data relationship is not just a relationship total

The Open XML SDK calls
[`v:imagedata/@r:id`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.vml.imagedata.relationshipid?view=openxml-3.0.1)
the explicit relationship to image data. The ID is a pointer from a VML
image-data marker to the story part’s relationship table. ECMA-376’s [Image
Part contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Image_topic_ID0EGXDO.html)
supplies the standard image relationship type and permits a stored external
target mode.

DocFence scans direct `v:imagedata/@r:id` markers in supported Word stories. It
records only markers whose resolved relationship has stored `TargetMode=External`.
A standard image relationship is counted separately from another external
relationship type, which remains reviewable as unsupported stored evidence.

## Count the explicit marker; leave the rest separate

Ordinary embedded VML images with internal relationships are not
external-image markers. Nor are an orphaned image relationship, raw VML `src`,
`r:pict`, `r:href`, or `o:relid`; those are deliberately separate legacy
surfaces, not fallback spellings of this one. Microsoft’s Office compatibility
notes mark raw [VML image-data `src`](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/7e506612-7a40-4d4e-95f4-e1f36173fe14)
as unsupported.

Public reports contain only aggregate marker/story and relationship-classification
counts. Image targets, relationship IDs, source values, VML attributes, story
paths, and fingerprints stay private. A same-count external target rewrite
remains visible in the inventory’s private signature; relationship-ID
renumbering with unchanged semantics and a raw-`src` rewrite do not create this
inventory’s churn.

## Policies for a clean handoff or a governed baseline

```yaml
rules:
  require_no_word_vml_external_images: true
```

This produces `DFP057`. A controlled template can instead use:

```yaml
rules:
  no_word_vml_external_image_changes: true
```

`DFP058` protects the private marker baseline. These rules add direct VML
image-data context to a generic external-relationship gate rather than replace
it.

## Evidence and an explicit limit

The 48-test release suite covers standard and unsupported external
relationship classes, excluded embedded images and attributes, duplicate
markers, body/header stories, Strict namespaces, orphan exclusion, same-count
target changes, raw-`src` quietness, relationship-ID renumbering, policy/SARIF
output, and redaction.

It also profiles the paired real public Word package from pea-sys’s
[`abspath2relpath-docx` investigation](https://github.com/pea-sys/shell-experiments/blob/91386d4de9e499a21bbb2e54743eb63a63727bfb/powershell/survey/abspath2relpath-docx/survey/rel/1.docx).
At the pinned commit, it has two direct `v:imagedata/@r:id` markers backed by
two external standard image relationships. DocFence reports those two markers
without emitting paths or IDs. The downloaded fixture SHA-256 is
`60708e292cd38cb9bee28886e91b2103b7d2ee43e963fa5e1cac4eccaaa71ed6`.

This is stored-package evidence only. DocFence does not choose a Markup
Compatibility branch, retrieve or resolve an image, update a link, render a
picture, or claim that Word will load or honor a target.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.22.0/docfence-0.22.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the full release note, exact policy contract, and threat-model limits in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-220.html).
