# A benchmark for reviewing spreadsheet changes, not just editing them

Spreadsheet tools are increasingly good at writing a formula or producing a
finished workbook. The harder operational question comes afterward: a workbook
changed—what changed, which other formulas can it reach, should it block a
review, and what could the tool not determine?

[Workbook Change Assurance Benchmark (WCAB)](https://github.com/SybilGambleyyu/workbook-change-benchmark)
is a small, open way to make those claims testable. Its first release contains
16 deterministic scenarios: 15 baseline/candidate workbook pairs and one
two-workbook portfolio. Each scenario supplies machine-readable truth about an
observable change, a benchmark review disposition, and—where appropriate—a
static dependency-impact lower bound. The workbook files are generated from
source, not copied from a financial model, email archive, or other sensitive
corpus.

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

The initial scenarios cover formula-to-value replacement, wrong-period
reference drift, input propagation, external formula references, named-range
redirection, copied-formula interruption, mismatched `SUMIFS` ranges, removed
input validation, conditional-formatting removal, hidden-sheet visibility,
formula-cell unlocking, incomplete manual calculation, direct static cycles,
3-D formula scope expansion, structural formula rewrites, and a cross-workbook
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
so regeneration is byte-for-byte reproducible. The first release passed its
tests and validated fixtures under Python 3.10 and 3.13.

An optional local FormulaFence adapter shows one concrete integration without
making its report schema normative. FormulaFence 0.219.0 recovered all 17
currently mappable facts and five targeted lint rules. The structural rewrite
is intentionally left unmapped: it documents intent, but does not pretend that
a small fixture proves generic Excel semantic equivalence.

## Try it

```bash
git clone https://github.com/SybilGambleyyu/workbook-change-benchmark.git
cd workbook-change-benchmark
python -m venv .venv
.venv/bin/python -m pip install -e '.[dev]'
wcab validate --fixtures fixtures
pytest
```

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/workbook-change-benchmark.html)
for the schema, validation record, and release links. WCAB is MIT-licensed and
available on [GitHub](https://github.com/SybilGambleyyu/workbook-change-benchmark).
