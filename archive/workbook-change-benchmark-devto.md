# A benchmark for reviewing spreadsheet changes, not just editing them

Spreadsheet tools are increasingly good at writing a formula or producing a
finished workbook. The harder operational question comes afterward: a workbook
changed—what changed, which other formulas can it reach, should it block a
review, and what could the tool not determine?

[Workbook Change Assurance Benchmark (WCAB)](https://github.com/SybilGambleyyu/workbook-change-benchmark)
is a small, open way to make those claims testable. Version 0.3.0 contains
17 deterministic scenarios: 16 baseline/candidate workbook pairs and one
two-workbook portfolio. Each scenario supplies machine-readable truth about an
observable change, a benchmark review disposition, and—where appropriate—a
static dependency-impact lower bound. The workbook files are generated from
source, not copied from a financial model, email archive, or other sensitive
corpus.

Version 0.3.0 includes a deterministic, one-row-per-case `manifest.jsonl`
catalogue. It carries the truth contract alongside exact relative paths, byte
counts, and SHA-256 digests for every baseline and candidate workbook, so an
evaluator can identify precisely which fixtures it consumed. The same release
is mirrored as a [Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).
It also upgrades the truth contract to schema version 2 with an Excel Table
scope-expansion case: `=SUM(SalesLedger[Amount])` stays unchanged while the
stored Table range grows from `A1:D4` to `A1:D5`. [Microsoft documents](https://support.microsoft.com/en-us/excel/using-structured-references-with-excel-tables)
that structured references adjust when a Table gains or loses data.

Version 0.3.0 also adds a tool-neutral normalized observation protocol. An
adapter can declare a case analyzed, unsupported, or errored; the scorer then
reports expected-fact recall, analyzed coverage, and agreement with the
benchmark's reference review convention. WCAB's facts are deliberately
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
structured-reference text, structural formula rewrites, and a cross-workbook
dependency.

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
so regeneration is byte-for-byte reproducible. Version 0.3.0 passed 18 tests
and validated fixtures under Python 3.10 and 3.13; a fresh Python 3.12 wheel
installation reproduced the catalogue byte-for-byte.

An optional local FormulaFence adapter shows one concrete integration without
making its report schema normative. FormulaFence 0.219.0 recovered all 18
currently mappable facts and five targeted lint rules. Its normalized export
reports those facts without inventing review decisions, so policy agreement
remains explicitly unset. The structural rewrite is intentionally left
unmapped: it documents intent, but does not pretend that a small fixture proves
generic Excel semantic equivalence.

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
the [v0.3.0 release](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.3.0),
and the [dataset mirror](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).
