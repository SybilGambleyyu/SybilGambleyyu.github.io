# A Word file can assemble itself from outside the package

An external relationship is not one thing. A hyperlink is usually just a
destination for a reader. But Word can also keep an attached template, a
master-document subdocument, or a frameset source outside the package. Those
are document dependencies: stored references that can shape, supplement, or
substitute what a user works with.

[DocFence 0.7.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.7.0)
makes that distinction review-visible without turning a CI report into a path or
URL leak. It reports six aggregate counts only: anchors and relationships for
attached templates, subdocuments, and frame sources. Targets, relationship IDs,
part paths, frame names, and fingerprints stay private.

## Three standardized paths beyond the package

OOXML defines a [Document Template](https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Document_topic_ID0E1IDK.html)
relationship from a Word Settings part. The settings markup contains
`w:attachedTemplate`; the relationship supplies the external location.
[Microsoft’s implementation notes](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/7713efa6-b1ff-4cbd-9339-5bf9018433ac)
say Word obtains the template path by evaluating that relationship ID.

A master document has a different contract. Its main document can hold
`w:subDoc` anchors that point to externally located subdocuments. OOXML describes
this as a way to work with a document as separately editable pieces—useful for a
book organized as chapters, but important to make explicit at a controlled
handoff.

Framesets add a third path. A linked Web Settings part can contain frames whose
`w:sourceFileName` points to external WordprocessingML packages. These formats
are uncommon today, but an uncommon standardized external assembly mechanism is
exactly the kind of state that should not disappear into a generic relationship
counter.

## Strict where the format is strict

DocFence recognizes conventional and Strict OOXML relationship forms. It
discovers Settings and Web Settings parts from either the main or glossary
document, while keeping Word’s conventional `word/settings.xml` location as a
compatibility fallback.

For each recognized dependency family, the direct anchor must name the expected
relationship type with `TargetMode="External"`. A malformed relationship or
anchor fails closed instead of becoming an ambiguous diff. A recognized external
relationship is still counted when no current anchor references it: stale state
still carries a target worth reviewing.

This is stored-state evidence, not an Office runtime. DocFence does not retrieve
a template, open a subdocument, resolve a frameset, render external content,
authenticate to a target, or determine whether a target is benign. That matters
especially for templates: [MITRE ATT&CK T1221](https://attack.mitre.org/techniques/T1221/)
documents template injection as an abuse of document template references.

## Choose “none” or “no change”

A clean-handoff policy can reject all recognized external document dependency
state:

```yaml
rules:
  require_no_external_document_dependencies: true
```

This emits `DFP025` whenever one of the six counts is nonzero. For an approved
template workflow that intentionally retains a dependency, compare against a
controlled baseline instead:

```yaml
rules:
  no_external_document_dependency_changes: true
```

This emits `DFP026` when the private dependency inventory changes.
Relationship-ID rewrites alone remain quiet. For a Web Settings part that carries
frame dependency state, DocFence fingerprints the full part privately, so an
otherwise easy-to-miss source or layout change is still review-visible without
printing it.

## Evidence, not a network monitor

The release tests conventional and Strict OOXML, glossary-linked settings,
attached-template, subdocument, and frame-source anchors, residual
relationships with no anchor, target changes, relationship-ID renumbering,
malformed type and target-mode state, policy findings, JSON/Markdown/SARIF
output, and redaction markers.

I also reconstructed and profiled the unpacked DOCX representation in the
open-source [XJTU thesis Office template](https://github.com/obster-y/XJTU-thesis-Office/tree/master/%E6%A8%A1%E6%9D%BF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E-docx).
DocFence reports one attached-template anchor and one attached-template
relationship without reproducing its target.

The wheel and source archive were independently rebuilt twice from the release
commit with `SOURCE_DATE_EPOCH`; both artifact pairs were byte-identical. The
public release contains the wheel, source archive, and SHA-256 manifest. I
downloaded those assets, verified the checksums, installed the wheel in a fresh
environment, and repeated the external-package profile.

Install the release:

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.7.0/docfence-0.7.0-py3-none-any.whl
```

The [full canonical note](https://sybilgambleyyu.github.io/posts/docfence-070.html)
has the policy and threat-model links. DocFence is MIT-licensed and available on
[GitHub](https://github.com/SybilGambleyyu/docfence).
