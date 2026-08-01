# The Word picture hyperlink hiding in legacy VML

One legacy Word VML image-data element can carry two distinct relationship
attributes. Collapsing them into a generic external-relationship count loses
the context a reviewer needs.

[DocFence 0.23.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.23.0)
adds a privacy-safe inventory for the direct legacy
`v:imagedata/@r:href` marker in supported Word stories. It is stored-package
evidence for CI review, not a renderer, link resolver, or network monitor.

## Image data is not the hyperlink-target attribute

The Open XML SDK's
[`ImageData` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.vml.imagedata?view=openxml-3.0.1)
calls `r:id` the explicit relationship to image data and `r:href` the explicit
relationship to a hyperlink target. Those are separate stored surfaces from a
VML shape `href`, a `w:hyperlink` element, a `HYPERLINK` field, a DrawingML
link, and a generic relationship total.

A public [Word XML fragment](https://stackoverflow.com/questions/52124509/read-images-from-docx-file-with-python-docx)
shows the exact legacy form: `v:imagedata r:id="…" r:href="…"`.

## Preserve the strange cases instead of guessing

DocFence scans direct `v:imagedata/@r:href` markers in supported stories. A
resolved standard hyperlink relationship is classified from its stored target
mode as external or internal. Any other resolved relationship type or mode
remains visible as unsupported evidence.

That last class is important. A public
[document-processing report](https://forum.aspose.com/t/corrupted-targetmode-attribute-value-in-relationship-tag/22502)
shows an `r:href` marker tied to an external standard image relationship. The
marker is real stored data, but the relationship is not silently treated as a
conventional hyperlink and does not establish what a client will do.

The boundary excludes image-data `r:id`, `r:pict`, raw `src`, and `o:relid`.
They are distinct legacy surfaces rather than alternate hyperlink markers.

## Private semantics, concrete policy gates

Public output contains only aggregate marker/story and external/internal/
unsupported relationship-classification counts. Targets, IDs, VML markup,
story paths, and fingerprints remain private. Same-count target changes remain
review-visible in the private signature; unchanged-semantics ID renumbering and
rewrites of excluded attributes do not create this inventory's churn.

```yaml
rules:
  require_no_word_vml_image_hyperlinks: true
```

This emits `DFP059` for a candidate containing the direct marker. For an
approved controlled baseline:

```yaml
rules:
  no_word_vml_image_hyperlink_changes: true
```

`DFP060` protects the private marker inventory.

## Evidence and limits

The 49-test release suite covers external/internal standard hyperlink and
unsupported relationship classes, duplicate markers, body/header stories,
Strict namespaces, unavailable relationship failure, excluded attributes,
same-count target changes, ID stability, redaction, and policy/SARIF output.
The release combines controlled package validation with the public real XML
fragment; it does not present that fragment as a downloadable whole-package
fixture.

DocFence does not select a Markup Compatibility branch, associate a marker with
a rendered picture, resolve, retrieve, follow, validate, evaluate, render, or
execute a target. It does not establish that a client will honor a relationship
or that a target is safe or reachable.

Read the full release note, exact policy contract, and threat-model limits in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-230.html).
