# A spreadsheet can change where its data comes from without changing a cell

A workbook can keep saved imported values, ordinary formulas, and dashboard
output unchanged while a stored external-data connection points somewhere new.
That source declaration lives outside worksheet cells, so a cell-by-cell diff
can miss the change entirely.

[FormulaFence 0.221.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.221.0)
and [WCAB 0.37.0](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.37.0)
make that boundary reviewable without fetching or exposing the source.

## Stored source material is a review surface

Microsoft's [external-connection format documentation](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-xls/69df8d03-b6fd-45cd-a0a0-9b026e50a3d9)
describes connection material such as providers, servers, authentication,
commands, and refresh settings. For web queries, the Open XML
[WebQueryProperties reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.webqueryproperties?view=openxml-3.0.0)
identifies the stored URL and request controls.

That means a workbook can retain every visible cell while changing the stored
place from which it may obtain data. A useful review needs to surface the
retarget. A safe review needs to avoid copying a sensitive URL, connection
string, command, or credential-adjacent value into its report.

## A safe category, not a source leak

FormulaFence 0.221.0 keeps its comprehensive comparison private and adds a
coarse safe category when a stable, uniquely identified connection changes. A
URL-only retarget emits high-severity `FF023` evidence with:

```text
source_configuration_material_changed: true
source_material_change_categories: ["web_query_url"]
```

It does not emit either URL, a connection string, command, parameter, SSO
identifier, or fingerprint. The same mechanism can distinguish request or
configuration material, database material, OLAP/text-import configuration,
files, parameter bindings, and SSO material. When connection IDs are added,
removed, duplicated, or renumbered, it deliberately withholds a category
rather than guessing.

FormulaFence does not open a connection, fetch a URL, authenticate, refresh
data, evaluate a formula, or claim a returned value.

## A deterministic test of the exact claim

[Workbook Change Assurance Benchmark](https://github.com/SybilGambleyyu/workbook-change-benchmark)
0.37.0 adds a relationship-backed fixture whose only raw difference is
`xl/connections.xml` `webPr/@url`, moving between two reserved
`example.invalid` endpoints. The connection ID/type/name, refresh controls,
workbook relationship, content type, saved `ImportedData!B2=100`, and direct
`ImportedData!B2 → Summary!B2 → Dashboard!B4` formula path stay fixed.

WCAB verifies the local package graph, requires `xl/connections.xml` to be the
only changed member, and compares it after removing only that URL. It does not
contact either endpoint. Its optional FormulaFence adapter requires exact
high-severity `external_data_connections_changed` and `FF023` evidence with
the safe `web_query_url` category, while the raw validator independently checks
the endpoint transition that FormulaFence intentionally withholds.

That separation lets a CI artifact be shareable without becoming another copy
of a sensitive source, while still giving reviewers an exact local change to
approve.

FormulaFence 0.221.0 passed 1,591 tests and hosted CI. WCAB 0.37.0 now has 54
cases, 56 facts, 254 passing tests, fresh-install validation, and hosted CI on
Python 3.10 and 3.13. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/external-data-source-review.html)
for the full boundary, installation commands, and validation links.
