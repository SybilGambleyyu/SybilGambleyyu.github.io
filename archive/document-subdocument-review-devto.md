# A subdocument target can change without changing Word text

A Word master document can keep all stored text, its `w:subDoc` anchor, and its
relationship ID fixed while changing which separate subdocument it names. A text
diff cannot make that dependency retarget visible, but a static reviewer can
record it without opening or merging either document.

[Document Change Assurance Benchmark 0.4.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.4.0)
adds its fifteenth deterministic pair:
`external.subdocument_target_retargeted`. Both sides preserve every package
member, every `w:t` sequence, and a fixed `w:subDoc r:id` marker. Only
`word/_rels/document.xml.rels` changes, retargeting the standard external
subdocument relationship.

## Inspect the dependency; do not open it

Microsoft’s [Open XML documentation for `SubDocumentReference`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.subdocumentreference?view=openxml-3.0.1)
defines `w:subDoc` as an anchor for a subdocument location. Its corresponding
OOXML relationship is an external master-document dependency. DCAB records that
stored relationship boundary only: its builder, validator, scorer, and adapter
never retrieve a target, launch Word, or merge subdocument content.

All package targets are synthetic `example.invalid` values. The public truth
declares only `external_document_dependency_target_changed` with the
`subdocument` dependency subtype. It excludes targets, relationship IDs,
relationship paths, and subdocument content.

## A deterministic package boundary

The generator renders the anchor directly in the main document body and keeps a
standard external `subDocument` relationship. An independent verifier checks
those requirements, deterministic package bytes, stable package members,
unchanged stored text, and the exact one-member pair boundary. The standard
`python-docx` reader opens all 28 `.docx` fixtures, and its lower-level OPC
reader opens all 30 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps public aggregate external-relationship and external-document-
dependency inventory evidence without consuming targets or private signatures.

DCAB 0.4.0 keeps fixture schema version 1 because the public envelopes are
unchanged; it extends the corpus from 14 to 15 cases. It does not claim that a
subdocument exists, is safe, will be loaded, or will render a particular way.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-subdocument-review.html)
for the full boundary and install command.
