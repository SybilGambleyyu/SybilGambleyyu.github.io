# A legacy shape link can change without changing Word text

A Word document can carry a direct link on a legacy drawing shape rather than
in ordinary hyperlink text or an OOXML relationship. The shape destination can
change while every stored <code>w:t</code> node remains unchanged. That is
stored review evidence, not proof of what a renderer displayed or what a user
click would do.

[Document Change Assurance Benchmark 0.11.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.11.0)
adds its twenty-second deterministic paired package:
<code>interaction.vml_shape_hyperlink_target_retargeted</code>. Both packages
retain their members, Word text, direct VML rectangle, shape ID, styling, and
target frame. Only <code>word/document.xml</code> changes: its direct
<code>href</code> moves between two synthetic <code>example.invalid</code>
destinations.

## Legacy markup is still stored review evidence

Microsoft’s Open XML API describes a VML
[`v:shape` `href`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.vml.shape?view=openxml-3.0.1)
as a hyperlink target. Microsoft’s [Word OOXML guidance](https://learn.microsoft.com/en-us/office/dev/add-ins/word/create-better-add-ins-for-word-with-office-open-xml)
explains that Word 2007 continued to use VML for shapes and text boxes, while
later documents can retain VML fallback markup.

The pair is deliberately narrower than navigation behavior. Its compact
<code>w:pict</code>/<code>v:rect</code> marker has no relationship target,
embedded payload, macro, or field evaluation. DCAB does not resolve the URL,
load a browser, select a drawing branch, simulate a click, open Word, or assert
that a client will follow the link.

## One direct href boundary

The independent verifier checks the VML rectangle, fixed shape ID, target
frame, styling, direct <code>href</code>, deterministic bytes, stable members,
unchanged Word text, and the one-member boundary. Standard
<code>python-docx</code> opens all 42 <code>.docx</code> fixtures, and its
lower-level OPC reader opens all 44 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter reports aggregate <code>word_vml_hyperlink_inventory_changed</code>
evidence. Both sides retain one marker in one story, one concrete shape, no
groups or shape templates, and one target-frame attribute. It detects the
private fingerprint transition without exposing the destination, shape ID, or
target-frame value.

DCAB 0.11.0 retains fixture schema version 1 and extends the corpus from 21 to
22 cases. It publishes a narrow static-review fact, not a visual-rendering,
navigation, deployment, identity, or security-policy claim.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-vml-shape-review.html)
for the full boundary and install command.
