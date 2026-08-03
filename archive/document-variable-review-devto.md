# A document variable can change without changing Word text

A Word document can persist a named document-variable value separately from
the text stored in its body. A field can refer to that variable while retaining
the same stored field result. A text-only comparison can therefore miss the
state change, while package-level review can report it without trying to
evaluate a field.

[Document Change Assurance Benchmark 0.8.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.8.0)
adds its nineteenth deterministic paired package:
<code>binding.document_variable_value_changed</code>. Both sides retain the
same <code>DOCVARIABLE</code> field reference, stored field result, variable
name, package-member set, and stored <code>w:t</code> sequence. Only
<code>word/settings.xml</code> changes, in the persisted value of one
synthetic document variable.

## Stored state, not field execution

The Open XML [document-variables element](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.documentvariables?view=openxml-3.0.1)
belongs in document settings and persists a collection of name/value pairs. Its
[document-variable child](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.documentvariable?view=openxml-3.0.1)
carries an individual name and value. Microsoft’s [Word Variable documentation](https://learn.microsoft.com/en-us/office/vba/api/word.variable)
describes the document-stored data and its matching <code>DOCVARIABLE</code>
field use.

DCAB fixes a synthetic variable name, field instruction, and stored result,
then changes only the synthetic <code>w:docVars/w:docVar</code> value. Its
builder, verifier, scorer, and adapter do not update a field, open Word, load a
macro, start an application, or claim what any client will display. This is a
static-review case, not a rendering or automation test.

## A deterministic settings boundary

The independent verifier checks the exact variable container, name/value
shape, field instruction, deterministic package bytes, stable members,
unchanged stored Word text, and the one-member pair boundary. Standard
<code>python-docx</code> opens all 36 <code>.docx</code> fixtures, and its
lower-level OPC reader opens all 38 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps aggregate <code>word_document_variable_inventory_changed</code>
evidence. It additionally checks that there is still one stored variable and
one literal variable-field reference matching the stored name. It uses only
counts and structural matching, never the variable name or value.

DCAB 0.8.0 retains fixture schema version 1 and extends the corpus from 18 to
19 cases. It does not claim a value is safe, sensitive, active, evaluated,
synchronized with a field result, or visible in a particular client.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-variable-review.html)
for the full boundary and install command.
