# An editable range can change without changing Word text

A Word document can store an editable-range marker around text and associate
that marker with an individual editor. The covered text can remain exactly the
same while the stored editor assignment changes. Text-only review sees no
change, while package-level review can report the marker without pretending to
know whether an identity is actually authorized.

[Document Change Assurance Benchmark 0.9.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.9.0)
adds its twentieth deterministic paired package:
<code>review.permission_range_editor_changed</code>. Both sides retain one
paired <code>w:permStart</code>/<code>w:permEnd</code> boundary, numeric marker
ID, covered stored text, package-member set, and stored <code>w:t</code>
sequence. Only <code>word/document.xml</code> changes, in one synthetic
<code>w:ed</code> editor assignment.

## Stored markers, not effective access

Microsoft’s [Open XML documentation for `w:permStart`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.permstart?view=openxml-3.0.1)
describes a range-permission start marker paired to a later end marker by a
shared ID. The matching [`w:permEnd` contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.permend?view=openxml-3.0.1)
describes the reverse pairing requirement. The standard permits the compact
paragraph-level marker shape used in this pair.

DCAB fixes one boundary, numeric ID, and synthetic covered run, then changes
only a synthetic individual-editor attribute. It does not enable document
protection, authenticate an editor, resolve a group, calculate editable cells,
open Word, start an application, or claim that an Office client will honor the
marker. This is a stored-markup review case, not an access-control or
client-behavior test.

## A deterministic permission-markup boundary

The independent verifier checks marker attributes, order and pairing, the
covered run, deterministic package bytes, stable members, unchanged Word text,
and the one-member pair boundary. Standard <code>python-docx</code> opens all
38 <code>.docx</code> fixtures, and its lower-level OPC reader opens all 40
packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps aggregate <code>word_permission_range_inventory_changed</code>
evidence. It verifies that both sides retain one story, start, end, paired
range, and individual-editor assignment, with no group, table-column selector,
or unmatched marker. It uses counts and private local signatures only; it does
not expose the marker ID or editor value.

DCAB 0.9.0 retains fixture schema version 1 and extends the corpus from 19 to
20 cases. It does not claim an editor is authenticated, allowed to edit,
active, known to a client, or protected by a particular policy.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-permission-range-review.html)
for the full boundary and install command.
