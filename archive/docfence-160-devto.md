# A hidden Word variable is only half the story

The previous DocFence release made Word’s hidden document-variable store
review-visible. That answers whether a package retains automation state. It
does not answer the next practical question: does the document retain a stored
field that can turn one of those hidden values into visible text?

Word’s [Variable object documentation](https://learn.microsoft.com/en-us/office/vba/api/word.variable)
describes document variables as persisted document or template state, normally
invisible until an appropriate `DOCVARIABLE` field is inserted. The field is the
bridge between a hidden key/value store and a document result. CI and handoff
review need evidence of that bridge without copying a field argument or
variable name into a build log.

[DocFence 0.16.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.16.0)
adds that evidence as a separate, privacy-safe inventory.

## Field presence is not field evaluation

A `DOCVARIABLE` field can be stored as a compact `w:fldSimple` instruction or
as a complex begin/instruction/separate/end sequence. Complex instructions may
be split across runs, retained in tracked-deletion markup, or nested inside
another field expression. A visible result can also be stale, and a field can
consult an attached template outside the package.

DocFence reads only complete stored field-code instructions. It never opens
Word, updates a field, runs a macro, resolves an attached template, or uses a
result to infer a variable value. It records complete simple and complex
instructions across supported Word stories, with current and deleted field-code
variants retained separately.

## The default formatting switch matters

A bare-word parser misses normal Word-authored fields. Microsoft’s
[field-formatting guidance](https://support.microsoft.com/en-gb/office/format-field-results-baa61f5a-5636-4f11-ab4f-6c36ae43508c)
says Word adds `\* MERGEFORMAT` by default when inserting a field through its
dialog. The switch controls presentation; it does not replace the leading
variable argument.

DocFence conservatively recognizes a leading plain token or complete quoted
argument even with trailing Word switch material. Nested or compound
expressions stay nonliteral instead of being interpreted. That handles normal
Word field storage without turning a CI scanner into a field evaluator.

## Safe counts, not field contents

Reports expose only aggregate reference/story, literal/nonliteral, and
exact-literal same-scope storage-association counts. A same-scope association
means a stored literal argument exactly matches a validated `w:docVar` in the
same main or glossary package document scope.

It is not runtime resolution: a matching name does not prove Word will display
a value, and an unmatched literal may be supplied by an attached template.
Field instructions, literal arguments, variable names/values, and paths remain
private.

## Two policy choices

For a handoff that should contain no stored document-variable field references:

```yaml
rules:
  require_no_word_document_variable_fields: true
```

This produces `DFP045` for every complete stored `DOCVARIABLE` reference. For
a governed template that intentionally includes the field codes:

```yaml
rules:
  no_word_document_variable_field_changes: true
```

`DFP046` protects the private field-reference inventory from a later mutation.
Use the 0.15 document-variable storage rules alongside these when the
`w:docVars` state itself is also part of the handoff boundary.

## Release evidence

The 0.16 suite has 41 tests covering simple/complex encodings, quotes, the
default formatting switch, nested and compound expressions, revision variants,
headers, Strict Word XML, main-versus-glossary scope, policy/SARIF output, and
redaction.

The released wheel also profiled LibreOffice’s public
[`tdf150542.docx` regression fixture](https://github.com/LibreOffice/core/blob/2553d132a7e95170568cb99920a7264fe5c8081d/sw/qa/extras/ooxmlexport/data/tdf150542.docx).
It reports one stored `DOCVARIABLE` reference with one literal same-scope
association alongside a three-variable Settings store, while preserving the
actual names and values as private material. The fixture uses the common
`\* MERGEFORMAT` pattern.

Hosted CI passed on Python 3.11 and 3.13. The wheel and source archive were
independently rebuilt from the release commit and matched byte-for-byte; fresh
release downloads passed the published SHA-256 manifest and package checks.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.16.0/docfence-0.16.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-160.html)
has the detailed evidence, policy reference, and threat-model links.
