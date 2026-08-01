A Word content control can look like ordinary text while retaining an XML mapping
that tells Word where the value belongs—or where it should come from. That is a
separate review boundary at a controlled handoff: visible wording and stored
data/view state are not necessarily the same thing.

[DocFence 0.6.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.6.0)
makes that state review-visible as bounded, local evidence. It inventories
standard content-control XML mappings, storage-ID state, associated custom XML
parts when the package establishes the association, and identifiers that cannot
be matched. It never puts XPath expressions, namespace-prefix mappings, storage
IDs, part names, or XML values into JSON, Markdown, or SARIF output.

## A content control is not always its own source of truth

The Open XML SDK describes
[`w:dataBinding`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.databinding?view=openxml-3.0.1)
as the information that maps a structured document tag to an XML element in a
custom XML data part. When Word finds the mapped element, its stored value can
replace the control's current run content.

Word's [XMLMapping model](https://learn.microsoft.com/en-us/office/vba/api/word.xmlmapping)
describes the same connection as a link between content-control text and XML in
the document data store. That is useful for templates and generated documents;
it also means an approved visible view can retain behavior and data state a
handoff should explicitly account for.

## Evidence without pretending to be Word

DocFence recognizes direct `w:sdtPr/w:dataBinding` declarations in the Word
document stories it already reviews. For a nonempty `w:storeItemID`, it safely
associates the binding with a custom XML data part only through the package's
internal `customXmlProps` relationship and its `ds:datastoreItem` identifier.
It accepts conventional and Strict OOXML relationship forms, as well as the
properties-root spellings used by real Word packages.

The public inventory has only five counts:

- Mappings.
- Mappings with a storage ID.
- Mappings without a storage ID.
- Referenced custom XML data parts.
- Unmatched storage IDs.

An unmatched nonempty ID is explicit review evidence, not a guessed target. A
mapping without a storage ID is still counted, but Word may search custom XML
parts with its XPath; DocFence deliberately does not guess which part it would
select.

Recognized properties relationships used for association must be internal and
point to a valid storage-properties root. A malformed contract fails closed.
DocFence does not evaluate XPath, update a control, render the document, or
interpret the XML payload.

## “None” and “no change” are different policies

A clean-handoff policy can prohibit all recognized stored mappings in the
candidate:

```yaml
rules:
  require_no_data_bindings: true
```

This emits `DFP023`.

An approved template can legitimately retain mappings. In that case, preserve
the known baseline and reject a later mutation:

```yaml
rules:
  no_data_binding_changes: true
```

This emits `DFP024` when the private inventory differs. For an identified
storage ID, the comparison includes the paired custom XML data and properties
payloads privately, so a bound-data mutation is visible without being
disclosed. Use `no_custom_xml_changes` as well when every custom XML mutation
must block the handoff.

## Release evidence and limits

The release tests conventional and Strict OOXML, Word-compatible properties-root
vocabulary, unscoped mappings, unmatched IDs, multiple controls that map to one
part, mapped-data mutations, relationship-ID renumbering, malformed properties
roots and target modes, policy findings, SARIF, and redaction.

I also profiled an independent
[OOXML Reference Corpus data-binding package](https://loadfix.github.io/ooxml-reference-corpus/case/docx__custom-xml-part.html).
It reports one content control, one mapping, one referenced custom XML part, and
no unmatched ID without reproducing the document or XML material.

The wheel and source archive were independently rebuilt twice from the release
commit with the same `SOURCE_DATE_EPOCH`; both artifact pairs were byte-identical.
The public release includes a wheel, source archive, and SHA-256 manifest. I
downloaded those assets, verified their checksums, installed the wheel in a
fresh environment, and repeated the external-package profile.

DocFence is stored-state evidence, not a Word renderer, XPath evaluator,
template engine, or malware verdict. The full installation command, policy
contract, and source links are on the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-060.html).
