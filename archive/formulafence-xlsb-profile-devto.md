# A safer way to inventory Excel Binary Workbooks

Excel Binary Workbook files (`.xlsb`) are useful for large models, but they are
not a small variation of `.xlsx`: formulas are BIFF12 reverse-polish token
streams and workbook state is binary records inside a ZIP package. Rendering an
unknown token as plausible formula text would create a misleading review result.

[FormulaFence 0.219.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.219.0)
adds `formulafence profile workbook.xlsb`, a deliberately narrow inventory
path—not general XLSB support.

## A visible capability boundary

The profile reader applies a fail-closed ZIP preflight, then reads only the
workbook catalog, its relationship part, optional shared strings, and selected
worksheet binary parts. It validates BIFF12 framing, bounds resource use, and
does not evaluate formulas, macros, or external targets.

FormulaFence reconstructs only a verified formula-token subset: ordinary
references and areas, literals, operators, selected functions, names, and
verified internal 3-D forms. An unrecognised construct is an explicit
formula-text coverage gap, not an invented formula.

The output declares `xlsb_core_profile` scope and its token-coverage status.
It also marks out-of-scope counts as unassessed. `lint`, `diff`, `check`, and
`portfolio` continue to reject `.xlsb`, and the public analysis APIs reject a
narrowed profile snapshot too.

## Data-minimising output

The XLSB profile withholds cell values, formula text, defined-name labels, and
definition bodies. It keeps aggregate counts and coverage evidence instead, so
a review artifact does not become another copy of a model's sensitive logic.

The implementation was replayed against 18 public XLSB fixtures from calamine
and Apache POI: 15 current ZIP packages loaded, with 12 complete token-coverage
results and three explicit coverage gaps. Two protected/non-ZIP samples failed
archive preflight, and an older Excel 2007 Beta 2 fixture was declined instead
of being guessed through an incompatible layout. Focused tests plus
deterministic malformed-input sweeps cover 30,000 cases without an unexpected
implementation exception.

Read the [canonical release note](https://sybilgambleyyu.github.io/posts/formulafence-xlsb-profile.html)
for the exact boundary, validation record, and install command. FormulaFence is
MIT-licensed and available on [GitHub](https://github.com/SybilGambleyyu/formulafence).
