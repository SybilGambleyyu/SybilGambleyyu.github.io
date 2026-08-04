---
title: A thumbnail request is not a thumbnail
published: true
description: DocFence 0.38 makes direct Word preview-thumbnail-on-save configuration review-visible without treating it as proof that an image exists.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/docfence-380.html
---

# A thumbnail request is not a thumbnail

A Word document can store an instruction asking a supporting application to
make a preview thumbnail on a later save. That is useful handoff evidence. It
is not proof that an image exists now, that a client will make one, or that an
existing image depicts the document.

[DocFence 0.38.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.38.0)
adds a local, aggregate-only inventory for direct Word Settings
<code>w:savePreviewPicture</code> declarations.

## A stored request, separate from an image

The Open XML SDK documents
[SavePreviewPicture](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.savepreviewpicture?view=openxml-3.0.1)
as a request for a supporting application to generate a first-page thumbnail on
save. Its contract also leaves applications free to choose a thumbnail when the
setting is omitted. The direct declaration is therefore configuration evidence,
not an image-inspection result.

DocFence reports only enabled and explicitly disabled setting counts. It is
separate from the existing OPC package-thumbnail inventory, which recognizes a
stored image only through the standard relationship and content-type boundary.
Neither inventory decodes or renders an image.

~~~yaml
rules:
  require_no_save_preview_picture: true
~~~

That candidate-state gate emits DFP088. A controlled template can protect an
approved state instead:

~~~yaml
rules:
  no_save_preview_picture_changes: true
~~~

DFP089 catches a material private inventory change. Neither rule proves a
thumbnail is absent, creates one, opens Word, saves a document, or predicts
client behavior.

## A paired static-review case

[DCAB 0.28.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.28.0)
adds its 39th deterministic WordprocessingML pair. It fixes every package
member and stored Word text while changing only the direct
<code>w:savePreviewPicture</code> value in <code>word/settings.xml</code> from
false to true. Neither package has a thumbnail relationship or thumbnail image
part.

Tagged CI passed, including the adapter installed from the DocFence tag. Fresh
release artifacts detected the transition and validated the bundled 39-case
corpus; public downloads matched fresh tagged builds; and the public
[Hugging Face mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was checked against the generated fixture hash.

The full contract, policy choices, and install instructions are in the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-380.html).
