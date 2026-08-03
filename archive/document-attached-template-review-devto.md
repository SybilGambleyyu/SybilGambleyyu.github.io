# A template target can change without changing Word text

A Word document can retain the same visible text, the same settings anchor, and
the same relationship ID while changing which external template that anchor
names. That is a useful review boundary: a static tool should make the
retargeting visible without fetching or opening a template.

[Document Change Assurance Benchmark 0.2.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.2.0)
adds its thirteenth deterministic paired package:
`external.attached_template_target_retargeted`. The pair holds every package
member and every stored `w:t` sequence steady. Only
`word/_rels/settings.xml.rels` changes, while `w:attachedTemplate` remains
anchored in `word/settings.xml`.

## Inspect the relationship; do not resolve it

Microsoft’s [Office Open XML notes for attached templates](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/7713efa6-b1ff-4cbd-9339-5bf9018433ac)
say Word determines the template path through the `attachedTemplate`
relationship. DCAB represents that as an external package relationship, but its
builder, validator, scorer, and reference adapter never follow the target or
open a document client.

All package targets are synthetic `example.invalid` values. The public truth
does not reveal targets, relationship IDs, or relationship paths. It declares a
single target-free fact:
`external_document_dependency_target_changed`, with an attached-template
dependency and external binding.

## A reproducible static boundary

The generator emits the settings relationship part only when an attached
template is present. Its independent validator verifies the anchor,
relationship type, external target mode, deterministic package bytes, stable
member set, and the exact one-member pair boundary. The standard `python-docx`
reader opens every `.docx` fixture, while its lower-level OPC reader opens all
26 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps public aggregate evidence—an external-relationship change and an
external-document-dependency inventory change—without consuming private
targets or signatures.

DCAB 0.2.0 keeps fixture schema version 1 because the truth and observation
envelopes are unchanged; it extends the corpus from 12 to 13 cases. It does not
claim a client runtime outcome, template safety, rendering equivalence, or one
universal policy.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-attached-template-review.html)
for the full static boundary and install command.
