# The anchors behind Word's embedded controls

“This Word package contains ActiveX parts” and “this document has a direct
control anchor” are different review facts. A relationship or payload count can
show persistence material, but it cannot say where a document records the
markup representing an embedded control. A direct marker is not proof that a
client has a control installed, will load its data, or will permit active
content.

[DocFence 0.26.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.26.0)
adds a narrow, privacy-safe inventory for direct WordprocessingML
`w:control` children of `w:object` or `w:pict`. It gives document CI a stable
stored-markup review signal without uploading package material or forecasting
Word behavior.

## A deliberately narrow XML boundary

The Open XML SDK’s [`w:control` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.control?view=openxml-3.0.1)
documents the two parent forms: embedded under `w:object` and floating under
`w:pict`. The ISO 29500 [schema definitions](https://github.com/dolanmiu/docx/blob/309b972e107b8cc12c65027d5161b7045e404b6c/ooxml-schemas/ISO-IEC29500-4_2016/wml.xsd#L1146-L1199)
show that `r:id` is optional and both containers permit a control child.

DocFence records every matching direct child in its supported Word stories.
Duplicates and Markup Compatibility branches remain separate stored evidence;
an arbitrary `w:control` elsewhere does not enter this inventory.

When an anchor supplies `r:id`, DocFence recognizes the standard control
relationship and classifies its stored target mode. The OOXML [Embedded Control
Persistence Part contract](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Embedded_topic_ID0EQDBO.html)
requires an internal target. Thus internal standard relationships, stored but
nonconforming external standard relationships, unsupported relationships, and
anchors without an ID remain separately reviewable. None says that a control is
available, enabled, safe, or loaded by Word.

## Package totals and anchors answer different questions

The new boundary is complementary to DocFence’s generic embedded-object
inventory. It does not absorb arbitrary `w:control` markup, `w:objectLink`,
`w:objectEmbed`, VML markup, fields, or ActiveX-control-binary relationships.
Generic evidence can be orphaned from an anchor, while a direct marker can omit
its relationship ID.

The difference appears in docx4j’s public
[`LegacyForms.docx`](https://github.com/plutext/docx4j/blob/74ea74323a33d92769fdbd3e6d5fe730bbfd8ffb/docx4j-core-tests/src/test/resources/LegacyForms.docx)
fixture. The installed release reports five direct anchors, all main-document
`w:object` anchors with internal standard relationships. The broad package
inventory reports ten recognized control relationships and ten control parts.
Neither number replaces the other.

## Private by design; enforceable in CI

Reports disclose only aggregate anchor, story, parent, and relationship-class
counts. Control names, shape identifiers, relationship IDs and targets, XML,
story paths, and fingerprints stay private. Same-count marker or target changes
remain review-visible privately; relationship-ID-only renumbering stays quiet.

```yaml
rules:
  require_no_word_embedded_controls: true
```

This candidate gate emits `DFP065`. For an intentional baseline:

```yaml
rules:
  no_word_embedded_control_changes: true
```

`DFP066` detects a material private-inventory change. The rules complement the
broader embedded-object gate rather than replacing it.

## Evidence without a runtime claim

The 52-test release suite covers direct-parent scope, relationship classes,
optional IDs, duplicates, Word stories, Strict and Transitional namespaces,
orphan/unparented exclusion, semantic changes, privacy, and every report
format. Hosted Python 3.11/3.13 CI passed for the commit and tag; independently
rebuilt tagged artifacts matched byte-for-byte; fresh public downloads verified
by checksum and an isolated installed wheel profiled the real fixture.

The coverage limit matters: one of 141 docx4j Word packages was positive, while
503 readable Open XML SDK candidate packages had no direct marker. That is not
a prevalence or interoperability claim. DocFence does not resolve, instantiate,
load, activate, render, or execute controls; it does not establish that Word
will select a branch, allow active content, or honor a marker.

The complete contract, source links, exact evidence, and release assets are in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-260.html).
