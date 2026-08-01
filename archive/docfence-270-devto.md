# The marker behind Word's embedded OLE objects

An embedded-object relationship or payload says useful things about package
material, but it does not say whether a Word story stores the legacy Office VML
marker that identifies an embedded OLE object. A marker is not proof that Word
will open, activate, render, or trust that object either.

[DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adds a privacy-safe inventory for direct Office VML `o:OLEObject` markers with
`Type="Embed"`. It gives document CI a stable
stored-markup signal without uploading package material or predicting client
behavior.

## A marker with a deliberately narrow scope

The Open XML SDK's [`o:OLEObject` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.vml.office.oleobject?view=openxml-3.0.1)
and the ECMA-376 [`OLEObject` definition](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_OLEObject_topic_ID0EXGUXB.html)
define the direct Office VML element, its optional `r:id`, type, and metadata.
The contract permits several parent forms, so DocFence follows the direct stored
marker in supported Word stories rather than assigning it a rendered-object
position. Duplicates and Markup Compatibility branches remain distinct stored
evidence.

The inventory is separate from VML `Type="Link"`, WordprocessingML
`w:objectEmbed` and `w:objectLink`, VML image and shape links, fields, and
generic embedded OLE/package/control relationship and payload totals.

## Relationship evidence that stays private

When an `r:id` exists, DocFence classifies a standard OLE-object relationship
by stored internal or external target mode. Another resolved type or mode is
reviewable as unsupported evidence; a marker without the optional ID has its
own class. The OOXML [Embedded Object Part contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Embedded_topic_ID0EA5BO.html)
permits the conventional relationship with either stored mode.

Reports contain only aggregate marker/story and relationship-classification
counts. Program, shape, object, relationship, target, update, field-code, XML,
story-path, and fingerprint values stay private. The complete direct marker is
privately fingerprinted: same-count program, update, field-code, or target
rewrites are visible while an unchanged-semantics relationship-ID renumbering
is quiet. `UpdateMode` remains private because the standard describes it for
the Link form, not as embedded-object behavior.

```yaml
rules:
  require_no_word_vml_embedded_ole_objects: true
```

This candidate gate emits `DFP067`. For a controlled baseline:

```yaml
rules:
  no_word_vml_embedded_ole_object_changes: true
```

`DFP068` detects a material private-inventory change. Both gates complement the
generic embedded-object boundary rather than replacing it.

## Evidence without a runtime claim

The installed release profiles the Open XML SDK public
[`ole.docx` fixture](https://github.com/dotnet/Open-XML-SDK/blob/cd2b359ef824737edb93f1c6157c19551aae1e52/test/DocumentFormat.OpenXml.Tests.Assets/assets/TestDataStorage/v2FxTestFiles/wordprocessing/ole/ole.docx)
as one direct marker with an internal standard OLE relationship and payload. It
reports the same aggregate contract for five public
[docx4j OLE fixtures](https://github.com/plutext/docx4j/tree/74ea74323a33d92769fdbd3e6d5fe730bbfd8ffb/docx4j-core-tests/src/test/resources/OLE).

A pinned scan found direct markers in 22 of 503 readable Open XML SDK package
candidates (two of 505 produced read errors) and five of 141 docx4j Word
packages. Those public test assets establish real stored-package coverage, not
prevalence, payload safety, or runtime interoperability.

The 53-test release suite, hosted Python 3.11/3.13 CI, byte-identical tag
rebuild, public checksum verification, and fresh-wheel smoke test all passed.
DocFence does not select a Markup Compatibility branch, retrieve a target, open
or activate an OLE object, decode a payload, render it, or execute it.

The complete contract, source links, exact evidence, and release assets are in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-270.html).
