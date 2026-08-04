---
title: A package thumbnail is a review boundary—not a preview claim
published: true
description: DocFence 0.34 and DCAB 0.24 make relationship-bound OPC package thumbnail payload changes reviewable without decoding or rendering an image.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/package-thumbnail-review.html
---

# A package thumbnail is a review boundary—not a preview claim

A thumbnail image stored in an OOXML package is neither ordinary Word text nor
a document-rendering instruction. It is still a relationship-bound package
part. A handoff review can need to know that this stored boundary changed
without extracting the image, guessing what it depicts, or promising that any
client will show it.

[DocFence 0.34.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.34.0)
records that narrow boundary, and [DCAB 0.24.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.24.0)
supplies a reproducible pair for it. Both releases are static-analysis work:
they do not decode an image, render a document, open Word, or claim preview
behavior in Word, Explorer, or another client.

## Why a filename is not enough

The OOXML [Thumbnail Part contract](https://ooxml.info/docs/15/15.2/15.2.16/)
defines an image reached through a thumbnail relationship from the package or a
part. The relationship is internal, each source can have at most one thumbnail
relationship, and the thumbnail part cannot carry relationships of its own.
The Open XML SDK exposes the same surface through
[`AddThumbnailPart`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.packaging.wordprocessingdocument.addthumbnailpart?view=openxml-2.20.0).

~~~text
_rels/.rels                 root relationship material
  └─ metadata/thumbnail ──> docProps/thumbnail.png
[Content_Types].xml         image/png declaration
docProps/thumbnail.png      opaque stored bytes
~~~

DocFence accepts only the exact standard thumbnail relationship in Transitional
or Strict OOXML, from the package or a stored part. The target must be
internal, stored, image-typed, and relationship-free; malformed recognized
topology fails closed. A member merely named `thumbnail.png` without the
standard relationship remains generic package residue.

## Review evidence without an image side channel

Public reports expose only `thumbnail_relationship_count` and
`thumbnail_part_count`. Image bytes, content types, relationship sources and
targets, and part paths stay inside a private digest. A same-count image
rewrite remains visible as `package_thumbnail_inventory_changed` without
turning CI output into a copy of package metadata or image material.

~~~yaml
rules:
  require_no_package_thumbnails: true
  no_package_thumbnail_changes: true
~~~

`require_no_package_thumbnails` is a candidate-state gate for a clean handoff.
`no_package_thumbnail_changes` compares an approved baseline with a candidate
that may intentionally retain a thumbnail. The resulting findings are
`DFP080` and `DFP081`; neither includes image pixels or relationship details.

## A deterministic, target-free benchmark pair

DCAB 0.24 adds its thirty-fifth pair:
`review.package_thumbnail_payload_changed`. Baseline and candidate preserve one
standard root thumbnail relationship, the `image/png` content-type declaration,
their package-member set, and every stored `w:t` value. Only a fully synthetic
1×1 PNG payload changes.

~~~text
_rels/.rels                 byte-identical
[Content_Types].xml         byte-identical
word/document.xml           byte-identical
docProps/thumbnail.png      the sole changed package member
~~~

The public truth names only `package_thumbnail_payload_changed`. It omits the
relation source and target, part path, content type, image bytes, and
fingerprints. The verifier regenerates the package byte-for-byte and checks the
relationship and member boundary without decoding or rendering the stored PNG.

## Evidence and use

The release also profiles the public Open XML SDK
[AcademicLetter Word template](https://github.com/dotnet/Open-XML-SDK/blob/main/test/DocumentFormat.OpenXml.Tests.Assets/assets/TestDataStorage/v2FxTestFiles/wordprocessing/O12%20templates/AcademicLetter_TP10067035.dotx)
as a package-compatibility smoke test. It reports one thumbnail relationship
and one thumbnail part; it does not inspect pixels or assert client display.

DCAB’s optional adapter strictly scores 35/35 cases from DocFence 0.34’s public
aggregate evidence. Its Python 3.11–3.13 CI matrix passed, fresh wheel and
source-distribution installs validate the bundled corpus, and the public
[Hugging Face mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was atomically synchronized and compared against the released files.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.34.0/docfence-0.34.0-py3-none-any.whl
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.24.0/document_change_benchmark-0.24.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
dcab validate
~~~

The [canonical release note](https://sybilgambleyyu.github.io/posts/package-thumbnail-review.html)
has the full evidence contract, policy links, and validation details. A package
thumbnail is stored evidence worth reviewing when policy says it is—not a
rendering result and not a claim about what a user will see.
