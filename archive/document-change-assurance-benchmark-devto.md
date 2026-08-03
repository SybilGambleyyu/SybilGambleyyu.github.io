# A benchmark for reviewing Word changes, not just comparing text

A Word document can retain ordinary text while its stored review surface
changes. A direct hyperlink can point somewhere new. A `HYPERLINK` or
`INCLUDETEXT` field can retain its displayed result while its private
instruction changes. Hidden text, revision markup, editing restrictions,
content-control mappings, custom XML, and opaque macro or OLE payloads sit
outside a normal prose diff.

[Document Change Assurance Benchmark (DCAB)](https://github.com/SybilGambleyyu/document-change-benchmark)
is a narrow, reproducible way to test whether a static review tool notices
those changes without exposing document material. Version 0.1.0 contains 12
deterministic baseline/candidate `.docx` and `.docm` pairs, target-free truth,
a structural validator, a tool-neutral observation protocol, and a scorer.
It is not a Word renderer, macro evaluator, field updater, or runtime-security
verdict.

## One stored boundary at a time

Every pair keeps the same package-member set and the same sequence of stored
Word text nodes. Only declared ZIP members differ. The initial cases cover:

- direct Word hyperlink target changes and markup addition;
- `HYPERLINK` and `INCLUDETEXT` field-source retargeting;
- direct `w:vanish` and `w:ins` markup;
- Track Changes and read-only document-protection settings;
- content-control binding XPath and custom-XML payload changes; and
- inert VBA-project and embedded-OLE payload boundaries.

Microsoft documents relationship-backed
[`w:hyperlink`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.hyperlink?view=openxml-3.0.1),
[content controls bound to custom XML](https://learn.microsoft.com/en-us/visualstudio/vsto/content-controls?view=visualstudio),
[`w:vanish`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.vanish?view=openxml-3.0.1),
[`w:ins`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.insertedrun?view=openxml-3.0.1),
and [`w:documentProtection`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.documentprotection?view=openxml-3.0.1).

## Target-free truth

DCAB’s public oracle names a bounded fact such as `field_target_changed` or
`hidden_text_run_added`; it never discloses targets, field instructions, XPath
values, relationship IDs, payload bytes, or payload digests. All URI-like
fixture values use `example.invalid`, and macro/OLE members are inert markers.

The validator checks deterministic source bytes, ZIP integrity, local OPC and
WordprocessingML structure, stable stored text, and exact changed-member
boundaries. It never opens Word, resolves a target, updates a field, parses an
opaque payload, activates OLE, or executes code.

## A score that stays explicit about limits

Tools can use any internal schema. An adapter reports analyzed, unsupported, or
errored cases; exact public facts; and an optional `allow`, `review`, or
`block` reference disposition. DCAB reports fact recall, analysis coverage,
policy agreement, and complete cases. Extra observations remain visible as
unrecognized evidence rather than being labeled false positives by a partial
oracle.

An optional [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps public aggregate evidence into that contract and completes the
full 12-case DCAB run. That is an integration check, not a universal policy or
a claim that stored declarations execute.

## Compatibility is not runtime behavior

DCAB opens every `.docx` fixture through `python-docx` and every `.docx`/
`.docm` package through its lower-level OPC reader. Hosted CI repeats the
package, source-distribution, and wheel checks on Python 3.11–3.13 and runs a
separate released-DocFence integration job. This is package-level
interoperability evidence, not a claim about Word, LibreOffice, macro hosts,
OLE servers, field-update behavior, rendering, or security outcomes.

```bash
python -m pip install \
  https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.1.0/document_change_benchmark-0.1.0-py3-none-any.whl

dcab validate
dcab observation-template --output observations.json
dcab score --observations observations.json --output score.json
```

The corpus is also mirrored as a public [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark).
The canonical article is https://sybilgambleyyu.github.io/posts/document-change-assurance-benchmark.html.
