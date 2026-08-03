# Imported content can change without changing Word text

A Word package can keep all stored text, an import anchor, and its relationship
ID fixed while changing alternate content that a client may later import. That
is a package change a text diff cannot see, but a static reviewer can report it
without attempting the import.

[Document Change Assurance Benchmark 0.5.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.5.0)
adds its sixteenth deterministic pair:
`import.alternative_format_html_payload_changed`. Both sides retain a fixed
`w:altChunk r:id` anchor, an internal `afChunk` relationship, every package
member, and every stored `w:t` sequence. Only `word/afchunk1.html` changes.

## Inspect the payload; do not import it

Microsoft’s [Open XML documentation for `AltChunk`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.altchunk?view=openxml-3.0.1)
describes the anchor as a location for alternate content to be imported through
an internal `afChunk` relationship. DCAB uses a compact inert HTML marker, but
its builder, validator, scorer, and adapter never parse HTML, import content,
launch Word, or claim what a client will render.

The public truth names only `alternative_format_import_payload_changed`, with
an HTML payload kind and the Word altChunk source. It excludes payload bytes,
content, relationship IDs, relationship paths, and any client-generated
WordprocessingML.

## A deterministic internal boundary

The generator emits the standard internal relationship and HTML content-type
override only when a payload is present. An independent verifier checks the
anchor, relationship type, internal mode, payload member, deterministic bytes,
stable package members, unchanged stored text, and exact one-member boundary.
The standard `python-docx` reader opens all 30 `.docx` fixtures, and its
lower-level OPC reader opens all 32 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps public alternative-format import inventory evidence while anchor,
relationship, and payload-part counts remain one. It does not consume payload
content or private signatures.

DCAB 0.5.0 keeps fixture schema version 1 because the public envelopes are
unchanged; it extends the corpus from 15 to 16 cases. It does not claim imported
HTML is safe, processed, renderer-equivalent, or handled by a client.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-altchunk-review.html)
for the full boundary and install command.
