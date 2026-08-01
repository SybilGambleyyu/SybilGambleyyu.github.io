Word review workflows can account for visible paragraphs, comments, tracked
changes, and embedded files while treating document properties as an unhelpful
generic package mutation. For a controlled handoff, that is the wrong boundary.
Core, extended, and custom properties can carry authoring and workflow
metadata; Microsoft’s [Document Inspector](https://support.microsoft.com/en-us/office/collab-files/remove-hidden-data-and-personal-information-by-inspecting-documents-presentations-or-workbooks)
puts document properties and personal information in its own review category.

[DocFence 0.4.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.4.0)
makes that category review-visible as bounded, local evidence. It records
aggregate state for Word’s core, extended, and custom property parts without
placing property names, values, paths, relationship targets, or fingerprints
into JSON, Markdown, or SARIF output.

## Three property families, deliberately separate

Word conventionally stores the property families in `docProps/core.xml`,
`docProps/app.xml`, and `docProps/custom.xml`. Core properties can include
fields such as creator and title; extended properties may describe the
application, template, or document statistics; custom properties are
user-defined definitions. Microsoft’s [property guide](https://support.microsoft.com/en-us/office/view-or-change-the-properties-for-an-office-file-21d604c2-481e-4379-8e54-1dd4622c6b75)
also distinguishes built-in from custom properties and notes that some
information is maintained automatically.

DocFence recognizes the package relationships and conventional stored paths,
then validates each property XML root before counting. It supports Transitional
OOXML and canonical Strict variants. Public profiles contain only property-part
counts, populated core and extended property counts, and custom-property
definition counts. A custom-property definition remains counted even when its
value is empty.

That makes a change to a timestamp, application/version field, template
reference, or custom definition review-visible instead of losing it in an
opaque-parts bucket. It does not label metadata personal, confidential,
intentional, safe, or malicious. The result is evidence about stored state;
the reviewer decides what it means.

## Candidate-state and baseline-state policies

A clean-handoff policy can prohibit custom property definitions in the
candidate:

```yaml
rules:
  require_no_custom_document_properties: true
```

This emits `DFP020` and exposes only the custom part and definition counts.

Some approved templates need retained metadata but must not drift after review.
For that case, use the comparison gate:

```yaml
rules:
  no_document_property_changes: true
```

This emits `DFP019` if the private property inventory changes, with only
before/after aggregate counts in the finding. It is deliberately sensitive:
ordinary resaves can update automatic metadata. The appropriate workflow is a
controlled baseline, not an assumption that every metadata change is bad.

## Release evidence

The release covers conventional relationship-backed packages, canonical
physical property paths without relationships, Strict variants, malformed
roots, value-only changes, custom definitions, policy findings, relationship-ID
renumbering, and output redaction. Distinct markers placed in property names and
values are verified not to appear in public output.

The wheel and source archive were independently built twice from the release
commit with the same `SOURCE_DATE_EPOCH`; both artifact pairs were
byte-identical. The public GitHub release includes a wheel, source archive, and
SHA-256 manifest. I downloaded those assets, verified their checksums, installed
the wheel into a fresh environment, and ran a self-diff smoke test.

The complete release note, source links, policy contract, and installation
command are on the [canonical site](https://sybilgambleyyu.github.io/posts/docfence-040.html).
