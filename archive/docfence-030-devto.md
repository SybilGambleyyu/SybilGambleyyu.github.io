Word documents can carry material that is neither ordinary paragraph text nor a
visible comment: embedded OLE objects, packaged documents, ActiveX controls,
and alternative-format imports. A normal text diff can simply step around those
boundaries. For a controlled handoff or CI gate, “we did not inspect it” is not
a useful result.

[DocFence 0.3.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.3.0)
makes those package surfaces review-visible without turning a review tool into
an Office runtime. It records bounded, privacy-safe evidence that a document
contains embedded or imported content, then gives a policy author a choice:
prohibit it outright, or permit an approved baseline and fail a later mutation.

## Two distinct package surfaces

The embedded-object inventory recognizes standard OLE, package, control, and
ActiveX control-binary relationship types. It also covers payloads stored in the
conventional `word/embeddings/` and `word/activeX/` folders. Reports expose only
aggregate relationship and part counts; relationship targets, part paths,
payload bytes, and fingerprints remain private.

OOXML alternative-format import is separate. A Word `w:altChunk` anchor marks
where imported content belongs, and it is supposed to reference an internal
`aFChunk` relationship. DocFence inventories both the relationship/payload layer
and direct anchors. An encountered anchor must name a matching internal standard
relationship whose target safely resolves to a stored package member. Otherwise,
the parser fails closed.

That is intentionally not a rendering or safety verdict. DocFence never fetches
an external target, decodes a payload, imports HTML, opens an embedded file,
executes a control, or claims to know what Word would render. Microsoft calls
[embedded files and objects](https://support.microsoft.com/en-us/excel/embedded-files-or-objects-found)
an inspectable hidden-data surface, and the Open XML SDK documents the
relationship contract for [`w:altChunk`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.altchunk?view=openxml-3.0.1).
The useful statement is about stored review state, not an invented malware or
rendering conclusion.

## “None” or “no change” are different policies

A publishing or clean-handoff boundary can prohibit either category in the
candidate:

```yaml
rules:
  require_no_embedded_objects: true
  require_no_alternative_format_imports: true
```

Those candidate-state gates are `DFP015` and `DFP016`.

An approved template may already contain a payload. For that case, the new
comparison gates preserve the baseline but reject a later mutation:

```yaml
rules:
  no_embedded_object_payload_changes: true
  no_alternative_format_import_changes: true
```

Those are `DFP017` and `DFP018`. Relationship IDs are normalized before
comparison, so an ID renumbering alone does not create churn. A second
`w:altChunk` anchor is still visible even if it reuses an unchanged import
relationship.

## Release evidence

The release adds regression coverage for a conventional ActiveX relationship
chain, OLE/package and alternative-format payload changes, malformed and
duplicate `w:altChunk` anchors, policy output, redaction, and relationship-ID
stability. Sensitive markers placed in visible text and each added payload
surface are checked against JSON, Markdown, and SARIF output.

The wheel and source archive were independently built twice from the release
commit with the same `SOURCE_DATE_EPOCH`; both pairs were byte-identical. The
GitHub release includes those artifacts and a SHA-256 manifest, and its
downloaded wheel was installed into a fresh environment for a final smoke test.

The complete release note, source links, policy scope, and installation command
are on the [canonical site](https://sybilgambleyyu.github.io/posts/docfence-030.html).
