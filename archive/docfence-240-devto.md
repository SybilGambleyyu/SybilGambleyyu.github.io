# The linked Word object hiding in a legacy VML shape

A Word document can store a linked spreadsheet, chart, or other OLE object as
a shape-backed piece of legacy XML instead of an ordinary Word field. A generic
embedded-object count tells a reviewer that OLE material exists, but it does
not distinguish a static embed from the direct stored marker for a source-backed
link.

[DocFence 0.24.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.24.0)
adds a privacy-safe inventory for the narrow direct surface:
`o:OLEObject Type="Link"` in a supported Word story. It is stored-package
evidence for document CI, not Word automation, a source resolver, or a network
monitor.

## Why a direct markup boundary matters

Microsoft’s [linked-versus-embedded-object guidance](https://support.microsoft.com/en-US/Word/linked-objects-and-embedded-objects)
explains the review distinction: linked data remains in its source and can
change when the source changes, while an embed is a static copy in the Word
file. The Open XML SDK’s [`o:OLEObject` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.vml.office.oleobject?view=openxml-3.0.1)
and the ECMA-376 [`OLEObject` definition](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_OLEObject_topic_ID0EXGUXB.html)
identify the direct Office VML element and its `Type`, optional `r:id`, and
`UpdateMode` attributes.

This is not theoretical legacy residue. A public [Excel-linked Word XML
fragment](https://stackoverflow.com/questions/60565712/insert-ole-object-into-ms-word-document-and-keep-the-underlying-format-wmf-intac)
uses `Type="Link"` and `UpdateMode="Always"`. Another public [Word shape
fragment](https://forum.aspose.com/t/cannot-found-includepicture-field-type-via-doc-range-fields/277035)
uses `UpdateMode="OnCall"` and is explicitly described as a linked OLE object,
not a conventional `LINK` field.

## What DocFence records

DocFence scans every direct `o:OLEObject` whose unqualified `Type` is `Link`
in supported Word stories. It retains duplicates and markers in Markup
Compatibility branches as separate stored evidence.

When the marker has `r:id`, the scanner recognizes the standard OLE-object
relationship and classifies its stored target mode as external or internal.
The OOXML [Embedded Object Part contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Embedded_topic_ID0EA5BO.html)
permits both. Another resolved type or mode stays visible as unsupported
evidence. A marker without `r:id` remains its own class because the schema
permits it. `UpdateMode="Always"` is aggregated as a stored automatic-update
marker; all other or missing values are nonautomatic-or-unspecified.

That is deliberately not a claim about runtime behavior. DocFence does not
select a Markup Compatibility branch, associate a marker with a rendered
shape, retrieve a source, update or activate an OLE object, or predict what
Word will do.

`Type="Embed"`, `w:objectLink`, VML image data, VML shape links, DrawingML
linked pictures, and broad embedded OLE/package/control totals stay separate.
An unreferenced OLE relationship alone creates no linked-OLE marker count.

## Private semantics and review gates

Public JSON, Markdown, and SARIF expose only aggregate marker/story,
update-mode, and relationship-classification counts. Sources, monikers,
program IDs, shape and object IDs, relationship targets and IDs, field codes,
VML markup, and story paths stay private.

The private signature fingerprints the full direct marker and normalizes a
relationship ID to its stored relationship semantics. A same-count source,
program, field-code, update-mode, or target rewrite remains review-visible;
an ID-only renumbering with unchanged semantics stays quiet.

```yaml
rules:
  require_no_word_vml_linked_ole_objects: true
```

That candidate gate emits `DFP061`. For a known-approved baseline:

```yaml
rules:
  no_word_vml_linked_ole_object_changes: true
```

`DFP062` detects a material private-inventory change.

The release passed a 50-test suite, hosted Python 3.11/3.13 CI on the commit
and tag, deterministic tagged builds, checksum verification, and a fresh
public-wheel smoke test. The full contract, source, and reproducibility record
are in the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-240.html).
