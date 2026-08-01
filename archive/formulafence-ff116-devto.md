# When a saved Excel spill error looks like #VALUE!

Dynamic-array formulas make a worksheet more expressive, but their saved result
is still historical evidence. A workbook can retain Excel's last result while a
future recalculation produces something different.

[FormulaFence 0.218.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.218.0)
adds `FF116`: a high-severity CI finding for a saved dynamic-array spill outcome
whose complete SpreadsheetML marker is present.

The distinction matters because compatible writers can store that outcome as a
typed saved value error rather than a literal `#SPILL!` string. String matching
would be unreliable and too broad.

## A complete stored marker

`FF116` requires one formula cell to have a typed saved error, array-formula
state, dynamic-array cell metadata, a value-metadata binding, and the canonical
metadata relationship and content-type declarations. Microsoft's
[SpreadsheetML metadata specification](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-xlsx/3dd44d53-847b-402f-a8c7-41a85024caf7)
defines that package machinery.

The rule does not calculate a formula, resolve an obstruction, infer a spill
range, expose a formula or cached value, or claim that the error remains
current. It reports a location plus `saved_formula_result` as the evidence
scope. A complete `FF116` finding suppresses the generic saved-value-error
finding at the same location, avoiding duplicate CI noise.

## Evidence that works in CI

FormulaFence keeps formula text, cached values, sheet names, external links,
metadata indices, and workbook inputs out of JSON, Markdown, and SARIF output.

A privacy-preserving replay over 5,458 accessible workbook artifacts found 63
complete markers across three workbooks. The aggregate-only replay produced
`FF116` without duplicate generic saved-value findings or rich-data warnings.
The release passed 1,551 tests, hosted CI's test and action-contract jobs,
package metadata checks, byte-identical wheel and source-distribution builds,
and clean-install CLI checks.

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/formulafence-ff116.html)
for the exact boundary, limitations, and install command. FormulaFence is
MIT-licensed and available on [GitHub](https://github.com/SybilGambleyyu/formulafence).
