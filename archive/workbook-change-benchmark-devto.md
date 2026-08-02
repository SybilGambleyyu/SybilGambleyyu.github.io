# A benchmark for reviewing spreadsheet changes, not just editing them

Spreadsheet tools are increasingly good at writing a formula or producing a
finished workbook. The harder operational question comes afterward: a workbook
changed—what changed, which other formulas can it reach, should it block a
review, and what could the tool not determine?

[Workbook Change Assurance Benchmark (WCAB)](https://github.com/SybilGambleyyu/workbook-change-benchmark)
is a small, open way to make those claims testable. Version 0.9.0 contains
24 deterministic scenarios: 23 baseline/candidate workbook pairs and one
two-workbook portfolio. Each scenario supplies machine-readable truth about an
observable change, a benchmark review disposition, and—where appropriate—a
static dependency-impact lower bound. The workbook files are generated from
source, not copied from a financial model, email archive, or other sensitive
corpus.

Version 0.9.0 includes a deterministic, one-row-per-case `manifest.jsonl`
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

Version 0.9.0 retains the tool-neutral normalized observation protocol.
An adapter can declare a case analyzed, unsupported, or errored; the scorer then
reports expected-fact recall, coverage-disclosure recall, analyzed coverage,
and agreement with the benchmark's reference review convention. WCAB's facts are deliberately
targeted rather than exhaustive, so an unrecognized observation stays visible
for review instead of being labeled a false positive. Unsupported analysis is
visible too—it cannot become a pass.

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
update-on-open policy, an unchanged circular formula whose iterative
calculation becomes enabled, an unchanged array formula whose mode changes from
legacy CSE to dynamic, and a cross-workbook dependency.

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
so regeneration is byte-for-byte reproducible. Version 0.9.0 passed 43 tests
locally under Python 3.12 and 3.13, while hosted CI passed under Python 3.10
and 3.13; a fresh Python 3.12 wheel installation reproduced the catalogue
byte-for-byte.

An optional local FormulaFence adapter shows one concrete integration without
making its report schema normative. FormulaFence 0.219.0 recovered all 25
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
unchanged behind `FF009`. For the
array fact, it requires the exact legacy-CSE-to-dynamic mode transition and
stored output range behind `FF018`. Its normalized export reports those facts
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
the [v0.9.0 release](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.9.0),
and the [dataset mirror](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).
