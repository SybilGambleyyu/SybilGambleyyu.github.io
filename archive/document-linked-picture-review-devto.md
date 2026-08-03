# A linked picture target can change without changing Word text

A Word document can keep every stored text node, every DrawingML picture
marker, and every relationship ID fixed while changing the target of a linked
picture. That is a stored review boundary a text diff misses, but a static
reviewer can expose without downloading an image.

[Document Change Assurance Benchmark 0.3.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.3.0)
adds its fourteenth deterministic pair:
`external.drawing_linked_picture_target_retargeted`. Both sides contain the
same `a:blip r:link` marker and package members. Only
`word/_rels/document.xml.rels` changes, retargeting a standard external image
relationship.

## Recognize the marker; do not retrieve the image

Microsoft’s [Open XML documentation for `Blip.Link`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.drawing.blip.link?view=openxml-3.0.1)
describes `r:link` as a linked-picture reference for an image outside the file.
DCAB models that relationship-backed marker, but never resolves a target, opens
a document client, renders an image, or claims that any Office client will load
it.

The package target is synthetic `example.invalid` data. Its public truth names
only `drawing_linked_picture_target_changed`, with an external binding and
image relationship category. It excludes the target, relationship ID,
relationship path, and presentation metadata.

## A deterministic static boundary

The fixture uses a compact DrawingML inline picture with `a:blip r:link` and no
image payload member. The candidate changes only the relationship target. An
independent verifier checks the marker, absence of `r:embed`, standard image
relationship type, external target mode, deterministic bytes, stable member
set, and exact pair boundary.

The standard `python-docx` reader opens all 26 `.docx` fixtures, and its
lower-level OPC reader opens all 28 packages. The optional local
[DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps public aggregate external-relationship and linked-picture-inventory
evidence without consuming targets or private signatures.

DCAB 0.3.0 keeps fixture schema version 1 because the public envelopes are
unchanged; it extends the corpus from 13 to 14 cases. It does not claim image
safety, a network request, a renderer result, client behavior, or one universal
policy.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-linked-picture-review.html)
for the full boundary and install command.
