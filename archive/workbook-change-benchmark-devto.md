# A benchmark for reviewing spreadsheet changes, not just editing them

Spreadsheet tools are increasingly good at writing a formula or producing a
finished workbook. The harder operational question comes afterward: a workbook
changed—what changed, which other formulas can it reach, should it block a
review, and what could the tool not determine?

[Workbook Change Assurance Benchmark (WCAB)](https://github.com/SybilGambleyyu/workbook-change-benchmark)
is a small, open way to make those claims testable. Version 0.20.0 contains
35 deterministic scenarios: 34 baseline/candidate workbook pairs and one
two-workbook portfolio. Together they declare 37 observable facts, a benchmark
review disposition, and—where appropriate—a static dependency-impact lower
bound. The workbook files are generated from source, not copied from a
financial model, email archive, or other sensitive corpus.

Version 0.20.0 includes a deterministic, one-row-per-case `manifest.jsonl`
catalogue. It carries the truth contract alongside exact relative paths, byte
counts, and SHA-256 digests for every baseline and candidate workbook, so an
evaluator can identify precisely which fixtures it consumed. The same release
is mirrored as a [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).
It retains the schema-version-3 truth contract, including an Excel Table
scope-expansion case: `=SUM(SalesLedger[Amount])` stays unchanged while the
stored Table range grows from `A1:D4` to `A1:D5`. [Microsoft documents](https://support.microsoft.com/en-us/excel/using-structured-references-with-excel-tables)
that structured references adjust when a Table gains or loses data. Schema v3
also covers a direct-to-`INDIRECT` change. Version 0.5.0 adds scoreable
requirements to disclose both that boundary and an unchanged `INDIRECT` or
`OFFSET` formula whose selector changes.

Those selector cases are the important addition: formula text remains stable,
but an input changes either the address text consumed by `INDIRECT` or the
column displacement consumed by `OFFSET`. The workbook can therefore select a
different effective target even when a formula-text diff says nothing changed.

Version 0.6.0 adds a different unchanged-cell risk: an external-data
connection starts refreshing when the workbook opens. Excel documents a
[Refresh data when opening the file](https://support.microsoft.com/en-us/excel/connection-properties)
setting for connections. The paired fixture leaves every worksheet cell and
formula unchanged and changes only the relationship-backed connection's
`refreshOnLoad` attribute from false to true. Its endpoint is a non-routable
`example.invalid` URL; WCAB never opens it, requests credentials, refreshes
data, or claims a calculated result.

Version 0.7.0 adds another unchanged-formula risk: a legacy Ctrl+Shift+Enter
(CSE) array changes into a dynamic array. [Excel distinguishes](https://support.microsoft.com/en-US/Excel/dynamic-array-formulas-vs-legacy-cse-array-formulas)
fixed CSE output ranges from dynamic arrays that can resize. The paired
fixture holds `=LEN(Inputs!A1:A3)` and its currently stored `B1:B3` range
constant, then adds the raw OOXML metadata binding for `Model!B1`.
WCAB validates that stored mode change but never calculates the formula,
predicts a future spill extent, finds blockers, or claims client compatibility.

Version 0.8.0 adds a separate unchanged-formula risk: an external-workbook
link can switch from never updating to always updating at workbook open.
[Excel's workbook-link guidance](https://support.microsoft.com/en-us/excel/manage-workbook-links)
describes those startup choices, while the [Open XML workbook-properties
reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.workbookproperties?view=openxml-3.0.1)
identifies `updateLinks` as the stored open-time control. The new pair preserves
`='[WCABSource.xlsx]Inputs'!$B$2` and its local downstream formula but changes
only `workbookPr/@updateLinks` from `never` to `always`. The source workbook is
synthetic and absent; WCAB never opens it, tests trust or authentication,
retrieves a value, or claims recalculation succeeded.

Version 0.9.0 adds a direct circular formula whose stored iteration control is
enabled without changing the formula or its local downstream consumer.
[Excel's circular-reference guidance](https://support.microsoft.com/en-US/Excel/remove-or-allow-a-circular-reference-in-excel)
explains that iterative calculation can intentionally allow circular references,
and the [Open XML calculation-properties reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.calculationproperties?view=openxml-3.0.1)
defines `iterate`, `iterateCount`, and `iterateDelta`. The new pair preserves
`=(B2+Inputs!$B$2)/2` and changes only `calcPr/@iterate` from false to true;
both workbooks store 100 iterations and a 0.001 delta. WCAB reads those stored
controls but never calculates the circular model, asserts convergence, predicts
an iteration count, or reports a terminal value.

Version 0.10.0 adds a different unchanged-cell risk: precision as displayed
can be enabled while the stored input, number format, and formulas still match.
[Excel's calculation guidance](https://support.microsoft.com/en-US/Excel/change-formula-recalculation-iteration-or-precision-in-excel)
says that calculating with displayed values permanently changes stored values,
and its [rounding-precision guidance](https://support.microsoft.com/en-us/excel/set-rounding-precision)
warns of cumulative effects. The [Open XML calculation-properties
reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.calculationproperties?view=openxml-3.0.1)
defines the corresponding `fullPrecision` control. The pair preserves the raw
`Inputs!B2=10.005` value, its `0.00` format, `=Inputs!$B$2*2`, and the local
consumer, then changes only `calcPr/@fullPrecision` from true to false. WCAB
reads package metadata and stored cells only: it never opens or saves Excel,
calculates a formula, asserts that a value rounded, predicts a result, or claims
a particular client applies the setting.

Version 0.11.0 adds a saved-result boundary that formula text alone cannot
cover. Microsoft's [SpreadsheetML formula guidance](https://learn.microsoft.com/en-us/office/open-xml/spreadsheet/working-with-formulas)
stores a formula expression in `<f>` and the result saved from its last
calculation in neighboring `<v>`. The pair retains `Inputs!B2=10`,
`Model!B2`'s `=Inputs!$B$2*2` expression, calculation properties, and the
local `Dashboard!B4` consumer, while changing only the raw numeric `<v>` from
`20` to `25`. WCAB does not calculate the formula, say either saved result is
current, stale, tampered, or correct, or claim what a client will display after
opening.

Version 0.12.0 adds a workbook-wide serial-date-system control change with no
cell edit. Excel documents 1900 and 1904 date systems with a 1,462-day
difference for the same stored serial in its [date-system guidance](https://support.microsoft.com/en-us/office/date-systems-in-excel-e7fe7167-48a9-4b96-bb53-5612a800b487).
The pair preserves raw `Inputs!B2=45292`, its `yyyy-mm-dd` format, and local
formulas while only `workbookPr/@date1904` changes from false to true;
`dateCompatibility=true` remains explicit. WCAB reads raw OOXML, styles, and
formula text only. It does not calculate a formula, convert a serial, predict a
displayed date, or claim Excel-client behavior.

Version 0.13.0 adds an active worksheet AutoFilter criterion change without a
cell edit. [Excel's filter guidance](https://support.microsoft.com/en-us/excel/get-started/filter-data-in-a-range-or-table-in-excel)
explains that filters show matching data and hide the rest, and that the
filtered subset can be copied, charted, or printed. Its
[`SUBTOTAL` documentation](https://support.microsoft.com/en-us/excel/functions/subtotal-function)
states that filter-excluded rows are always excluded. The pair changes the
sole column-0 list value in `Report!A1:B5` from `North` to `South`, while
`Report!D2=SUBTOTAL(109,B2:B5)` and `Dashboard!B4=Report!$D$2` remain fixed.
The raw validator proves that stored transition, stable formulas and direct
dependency edge, and the report-worksheet-only package difference. It does not
apply a filter, calculate the subtotal, infer visible rows, or claim what an
Excel client displays, copies, charts, or prints.

Version 0.14.0 adds a relationship-backed PivotTable cache refresh-on-open
control without a cell edit. [Excel's PivotTable refresh guidance](https://support.microsoft.com/en-us/excel/refresh-pivottable-data)
includes refreshing data when a workbook opens, and the Open XML
[`PivotCacheDefinition` reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.pivotcachedefinition?view=openxml-3.0.1)
defines `refreshOnLoad`. The pair binds a local `Source!A1:B5` cache through a
PivotTable at `Report!A1:B2` and a direct `Dashboard!B4=Report!$B$2` consumer.
Every source cell, cache record, stored report cell, and formula stays fixed;
only `pivotCacheDefinition/@refreshOnLoad` moves from false to true. WCAB reads
the raw relationship-backed package. It does not open Excel, refresh a cache,
calculate or render a PivotTable, infer a result, or claim that a client honors
the request.

Version 0.15.0 adds a DrawingML chart-series source-reference case without a
worksheet-cell edit. [Excel's series guidance](https://support.microsoft.com/en-US/Excel/rename-a-data-series)
allows a series to use a different source range, while the Open XML
[`NumberReference` reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.drawing.charts.numberreference?view=openxml-3.0.1)
models that binding. The pair keeps `Dashboard!D2`, the title `'Source'!B1`,
the category range `'Source'!$A$2:$A$4`, and every worksheet cell fixed, while
its raw numeric-series source moves from `'Source'!$B$2:$B$4` to
`'Source'!$C$2:$C$4`. The validator follows the worksheet-to-drawing-to-chart
relationship chain and proves that only `xl/charts/chart1.xml` changes. It
does not calculate, refresh, render, infer a visible difference, or claim
client behavior.

Version 0.16.0 adds a relationship-backed PivotTable value-field aggregation
case without a cell edit. [Excel's PivotTable layout guidance](https://support.microsoft.com/en-US/Excel/design-the-layout-and-format-of-a-pivottable)
describes changing a field's Value settings, while the Open XML
[`DataField.Subtotal` reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.datafield.subtotal?view=openxml-3.0.1)
identifies the stored data-consolidate function. The pair retains its local
`Source!A1:B5` cache binding, all cache records, `Report!A1:B2` location,
stored `Report!B2` display cell, and `Dashboard!B4=Report!$B$2` formula; only
the one `dataFields/dataField/@subtotal` changes from `sum` to `average`.
The validator proves the cache/PivotTable relationship graph and that only the
PivotTable definition part changes. It does not refresh, calculate, or render
a PivotTable, infer a changed display value, or claim client behavior.

Version 0.17.0 adds a relationship-backed PivotTable Slicer-selection case
without a cell edit. [Excel's PivotTable filtering guidance](https://support.microsoft.com/en-us/excel/get-started/filter-data-in-a-pivottable)
describes Slicers as controls that filter PivotTables and convey filtering
state. The Office Open XML [Slicer Cache Part specification](https://learn.microsoft.com/en-us/openspecs/office_standards/MS-XLSX/e7eda20c-c65e-45ed-9540-de59c4a07b7d)
stores cache-item indices with `x` and selected items with `s=1`. The pair
retains its local `Source!A1:B5` cache, `Report!A1:B2` PivotTable, stored
`Report!B2` display cell, and `Dashboard!B4=Report!$B$2` formula; only the
selected `Region` item moves from index 0 (`North`) to index 1 (`South`). The
validator follows the workbook-to-Slicer-cache-to-PivotCache/PivotTable graph
and proves that only `xl/slicerCaches/slicerCache1.xml` changes. This fixture
has no visual Slicer or drawing: it does not apply a filter, refresh, calculate,
or render a PivotTable, infer a changed result, or claim client behavior.

Version 0.18.0 adds a connection-only Power Query M filter case without a
worksheet edit. [Power Query's overview](https://support.microsoft.com/en-us/excel/about-power-query-in-excel)
explains that transformations are stored as M, and its [query-management
guidance](https://support.microsoft.com/en-us/excel/manage-queries-power-query)
allows a query to be connection-only. The pair keeps a local
`Source!A1:B5` `SourceData` Table, every worksheet cell, metadata, permission
control, and calculation property fixed while its stored
`Table.SelectRows` `Region` literal moves from `North` to `South` inside
`customXml/item1.xml`. The validator follows the package-root custom-XML
relationship and a bounded generated Data Mashup envelope. It does not execute
M, apply the filter, refresh a query, materialize output, calculate a workbook,
infer returned rows, or claim client behavior.

Version 0.19.0 adds a Scenario Manager alternate-input case without a worksheet
edit. [Excel’s Scenario Manager guidance](https://support.microsoft.com/en-us/excel/switch-between-various-sets-of-values-by-using-scenarios)
describes scenarios as saved sets of values for changing cells. The pair keeps
`Inputs!B2=0.1`, `Inputs!B3=125`, `Inputs!D2=B2*B3`, and
`Dashboard!B4=Inputs!$D$2` fixed. In the selected locked `WCAB downside`
scenario, only the raw stored `Inputs!B2` value moves from `0.08` to `0.16`.
The scenario remains stored rather than shown or applied. The validator proves
the exact scenario metadata and that only `xl/worksheets/sheet1.xml` differs;
it does not show or apply a scenario, calculate a formula, create a scenario
summary, infer a result, or claim Excel-client behavior.

Version 0.20.0 adds a one-variable What-If Data Table input-reference case
without a formula edit. [Excel's Data Table guidance](https://support.microsoft.com/en-us/excel/calculate-multiple-results-by-using-a-data-table)
distinguishes one- and two-variable tables and their row or column input cells.
The Open XML [`CellFormula` reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.cellformula?view=openxml-3.0.1)
defines the `dataTable` master formula with its output range, input references,
and orientation controls. The pair keeps the column-oriented
`Sensitivity!D3` master's `D3:D5` output range, recalculation request, input
grid, ordinary formulas, calculation properties, and saved table results fixed
while only raw `f/@r1` moves from `B2` to `B3`. The validator proves that the
Sensitivity worksheet is the sole changed package member and that both possible
input cells retain ordinary static paths to the model and dashboard. It does
not substitute inputs, calculate a table or workbook, infer output values,
resolve a circular dependency, or claim Excel-client behavior.

Version 0.19.0 retains the tool-neutral normalized observation protocol.
An adapter can declare a case analyzed, unsupported, or errored; the scorer then
reports expected-fact recall, coverage-disclosure recall, analyzed coverage,
and agreement with the benchmark's reference review convention. WCAB's facts are deliberately
targeted rather than exhaustive, so an unrecognized observation stays visible
for review instead of being labeled a false positive. Unsupported analysis is
visible too—it cannot become a pass.

Version 0.20.0 retains that protocol and adds a one-variable What-If Data
Table input-reference fact, so a tool can distinguish a stored table control
change from a calculated sensitivity result.

## A gap between existing benchmarks

Existing resources answer important adjacent questions:

- [Modified EUSES](https://spreadsheets.sai.tugraz.at/index.php/corpora-for-benchmarking/euses/)
  tests injected formula faults.
- [VEnron](https://researchportal.hkust.edu.hk/en/publications/venron-a-versioned-spreadsheet-corpus-and-related-evolution-analy/)
  recovers version history from business spreadsheets.
- [SpreadsheetBench](https://github.com/RUCKBReasoning/SpreadsheetBench)
  evaluates workbook-manipulation tasks.
- Recent [formula-repair work](https://www.microsoft.com/en-us/research/publication/benchmark-dataset-generation-and-evaluation-for-excel-formula-repair-with-llms/)
  evaluates runtime-error repairs.

WCAB focuses on a different boundary: reviewing a candidate version against an
approved one. Its contract is explicit change facts, a stated
accept/review/block convention, static impact that should not be missed, and
visible unsupported coverage instead of a silent pass.

## Cases that distinguish text changes from semantic risk

The scenarios cover formula-to-value replacement, wrong-period
reference drift, input propagation, external formula references, named-range
redirection, copied-formula interruption, mismatched `SUMIFS` ranges, removed
input validation, conditional-formatting removal, hidden-sheet visibility,
formula-cell unlocking, incomplete manual calculation, direct static cycles,
3-D formula scope expansion, an Excel Table scope expansion with unchanged
structured-reference text, an introduced `INDIRECT` reference, unchanged
`INDIRECT` and `OFFSET` formulas whose selectors change, structural formula
rewrites, a connection refresh-on-open control, an external-workbook link
update-on-open policy, a local PivotTable-cache refresh-on-open control, a
local PivotTable value field whose aggregate changes from Sum to Average while
its source, cache, and stored report cells remain fixed, a local PivotTable
Slicer cache whose selected Region item changes while its source, cache, and
stored report cells remain fixed, a connection-only Power Query M definition
whose local-table filter literal changes while its source and controls remain
fixed, a stored Scenario Manager alternate input whose raw value changes while
visible worksheet values and formulas stay fixed, a one-variable What-If Data
Table whose raw input reference changes while its output range and ordinary
formulas stay fixed, a dashboard chart
whose numeric-series source changes while cells and its other bindings remain fixed, an
unchanged circular formula whose iterative
calculation becomes enabled, an unchanged precision-sensitive input and formula
whose calculation switches to precision as displayed, a saved formula result
that changes without a formula or input edit, a workbook serial-date-system
control change without a cell edit, an active AutoFilter criterion change with
stable `SUBTOTAL` and downstream formulas, an unchanged array formula whose
mode changes from legacy CSE to dynamic, and a cross-workbook dependency.

That combination is deliberate. A column insertion can rewrite many formulas
while retaining declared logical inputs. Conversely, inserting a tab inside
`SUM(Jan:Mar!B5)` can change a formula's scope while its text remains unchanged.
Neither a raw text diff nor a “no formula changed” signal is enough for a
reliable review workflow.

## Truth with stated limits

Each case contains `truth.json`, with facts such as `formula_to_value`,
`sheet_visibility_changed`, and `three_d_scope_changed`. The `must_reach`
section declares downstream formula locations that a conservative local A1
dependency walk must reach. It does not claim formula evaluation, complete
Excel semantics, dynamic-reference resolution, or numerical correctness.

The project ships a validator that reads the generated workbooks and verifies
the truth contract. It also canonicalizes OOXML ZIP member order and timestamps
so regeneration is byte-for-byte reproducible. Version 0.20.0 passed 122 tests
locally under Python 3.13 and in
[hosted CI](https://github.com/SybilGambleyyu/workbook-change-benchmark/actions/runs/30768076919)
under Python 3.10 and 3.13; fresh
Python 3.13 wheel and source-distribution installations reproduced the
catalogue byte-for-byte.

An optional local FormulaFence adapter shows one concrete integration without
making its report schema normative. FormulaFence 0.220.0 recovered all 36
currently mappable facts, all three scoreable dynamic-reference coverage
declarations, and five targeted lint rules. The driver declarations require
both its `value_changed` record and candidate `dynamic_reference_cells` profile
feature, rather than an invented target value. For the connection fact, it
requires the exact connection ID and `refresh_on_load` false-to-true transition
behind `FF023`. For the external-link policy fact, it requires exactly
`update_links: never → always` while the other workbook-wide refresh controls
retain their defaults, rather than accepting a generic settings diff. For the
iteration fact, it requires exactly `iterate: false → true` while the stored
100-iteration / 0.001-delta bounds and all other calculation controls remain
unchanged behind `FF009`. For the precision-as-displayed fact, it requires
exactly `fullPrecision: true → false` while the other stored calculation
controls remain unchanged behind `FF009`. For the saved-result fact, it requires
FormulaFence's matching `formula_cached_result_changed` record and `FF042`,
with exactly one unexplained material cache change; the tool deliberately
redacts raw cache values and the formula-cell location. For the date-system
fact, it requires `date1904: false → true`, explicit
`dateCompatibility=true`, zero unrecognized controls, and `FF117`. For the
active-filter fact, it requires the matching redacted
`filter_visibility_controls_changed` record and `FF036`; WCAB's raw validator
independently establishes the `North → South` values and stable formulas. For
the PivotCache fact, it requires `pivot_cache_refresh_controls_changed` and
`FF023`, with only `refresh_on_load: false → true` in FormulaFence's redacted
cache profile; WCAB independently verifies the source and PivotTable bindings.
For the PivotTable aggregation fact, it requires FormulaFence's exact redacted
`pivot_table_definitions_changed` profile and `FF031`; FormulaFence does not
expose the selected aggregate, source labels, or a rendered result, so WCAB
independently verifies the local graph, stored cells, and `sum → average`
declaration.
For the PivotTable Slicer fact, it requires FormulaFence's exact redacted
`slicer_timeline_cache_definitions_changed` profile and `FF032`; FormulaFence
does not expose the Slicer name, selected item/value, or a rendered report, so
WCAB independently verifies the local graph and stored `North → South`
selection.
For the Power Query fact, it requires FormulaFence's exact redacted
`power_query_changed` profile and `FF024`; FormulaFence does not expose M
source, local-table values, or a query result, so WCAB independently verifies
the package-root binding, local source, connection-only controls, and stored
`North → South` literal.
For the Scenario Manager fact, it requires FormulaFence's exact redacted
`scenario_manager_changed` profile and `FF035`; FormulaFence does not expose
the scenario name, input cells, values, comment, or user, so WCAB independently
verifies the selected locked scenario and the raw `0.08 → 0.16` stored value.
For the What-If Data Table fact, it requires FormulaFence's exact redacted
one-variable `what_if_data_tables_changed` profile and `FF034`; FormulaFence
does not expose the output range, local input references, or calculated table
values, so WCAB independently verifies the generated `D3:D5` master, raw
`B2 → B3` `r1` transition, stable surrounding controls, and worksheet-only
package change.
For the chart fact, it requires FormulaFence's exact one-chart redacted
`chart_definitions_changed` profile and `FF030`; WCAB independently verifies
the title, category, and numeric-series source references.
For the array fact, it requires the exact legacy-CSE-to-dynamic mode transition and
stored output range
behind `FF018`. Its normalized export reports those facts
without inventing review decisions, so policy agreement remains explicitly
unset. The structural rewrite is intentionally left unmapped: it documents
intent, but does not pretend that a small fixture proves generic Excel semantic
equivalence.

## Try it

```bash
git clone https://github.com/SybilGambleyyu/workbook-change-benchmark.git
cd workbook-change-benchmark
python -m venv .venv
.venv/bin/python -m pip install -e '.[dev]'
wcab validate --fixtures fixtures
wcab manifest --fixtures fixtures
wcab observation-template --fixtures fixtures --output observations.json
wcab score --fixtures fixtures --observations observations.json
pytest
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/workbook-change-benchmark.html)
for the schema, validation record, and release links. WCAB is MIT-licensed and
available on [GitHub](https://github.com/SybilGambleyyu/workbook-change-benchmark),
the [v0.20.0 release](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.20.0),
and the [dataset mirror](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).
