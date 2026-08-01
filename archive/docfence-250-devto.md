# Word's other linked-object marker

WordprocessingML has a linked-object marker that is easy to blur into a broad
OLE or relationship count: `w:objectLink`, a leaf directly under
`w:object`. It is distinct from `w:objectEmbed`, legacy Office VML
`o:OLEObject Type="Link"`, fields, DrawingML linked pictures, VML links, and
generic embedded-object totals.

[DocFence 0.25.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.25.0)
adds a privacy-safe inventory for that narrow direct surface. It is stored
package evidence for document CI, not Word automation, an OLE client, a source
resolver, or a network monitor.

## A direct schema boundary

The Open XML SDK's [`w:objectLink` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.objectlink?view=openxml-3.0.1)
identifies the Office 2007+ leaf and its `w:object` parent. The ISO 29500
[`CT_ObjectLink` definition](https://github.com/dolanmiu/docx/blob/309b972e107b8cc12c65027d5161b7045e404b6c/ooxml-schemas/ISO-IEC29500-4_2016/wml.xsd#L1188-L1228)
requires `r:id` and `w:updateMode`, with the exact stored modes
`always` and `onCall`. The OOXML [Embedded Object Part
contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Embedded_topic_ID0EA5BO.html)
permits a standard OLE-object relationship with an internal or external target.

DocFence counts only direct `w:objectLink` children of `w:object` in
supported Word stories. Duplicates and Markup Compatibility branches remain
separate stored evidence. A loose or unparented marker does not enter this
inventory.

The public projection distinguishes standard external/internal OLE
relationships, unsupported relationships, and direct markers without
`r:id`. It also separates exact `w:updateMode="always"` and
`w:updateMode="onCall"` from unsupported-or-missing modes. This avoids a
dangerous shortcut: the Microsoft API documentation's example displays
`updateMode="user"`, which is not one of the schema's enumerated modes.
DocFence preserves unusual stored state for review instead of treating it as a
normal update behavior.

## Private semantics and policy

JSON, Markdown, and SARIF reports expose counts only. Program and shape
identifiers, relationship IDs and targets, field codes, locking metadata, XML,
and story paths remain private. The full direct marker is privately
fingerprinted, so same-count metadata or target rewrites remain visible while
an ID-only relationship renumbering with unchanged semantics stays quiet.

```yaml
rules:
  require_no_word_object_links: true
```

That candidate gate emits `DFP063`. For an intentionally approved baseline:

```yaml
rules:
  no_word_object_link_changes: true
```

`DFP064` detects a material private-inventory change.

## Evidence without pretending ubiquity

The release passed a 51-test suite, hosted Python 3.11/3.13 CI on the commit
and tag, deterministic tagged builds, checksum verification, and fresh
public-wheel smoke tests for both standard update categories.

Public package coverage is deliberately bounded: 503 readable Open XML SDK
fixture packages (from 505 candidates; two read errors) and all 141 docx4j
`VERSION_17_0_3` Word packages contained no direct marker. That does not mean
the markup does not exist. It means this is a standards-shaped stored-XML
compatibility boundary, not a claim of widespread contemporary Word authoring
or a runtime interoperability guarantee.

DocFence does not resolve, retrieve, open, update, activate, render, or execute
an OLE object, and it does not establish that Word will honor a marker or a
target is safe. The complete contract, exact test evidence, and release assets
are in the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-250.html).
