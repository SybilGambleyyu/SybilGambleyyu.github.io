# A worksheet control can retarget a macro without a cell changing

A spreadsheet can keep every ordinary cell, formula, and saved calculation
stable while a clickable worksheet control changes which macro it names. That
is a review boundary a cell diff can miss. The useful claim is deliberately
small: a stored assignment moved; it is not a claim that a macro ran.

Microsoft's [Excel guidance for assigning a macro to a control
button](https://support.microsoft.com/en-us/excel/assign-a-macro-to-a-form-or-a-control-button)
documents macro assignments for Form and ActiveX controls. [Workbook Change
Assurance Benchmark 0.44.1](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.44.1)
adds a deterministic, relationship-bound Form-control case for this review
surface. [FormulaFence 0.225.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.225.0)
provides the corresponding critical control-change evidence.

## One stored declaration, not a cell change

The generated pair holds its worksheet control declaration, control-properties
part, relationship, content type, ordinary Controls!B2=12 input,
Controls!D2=B2*C2 formula, direct Dashboard!B4=Controls!$D$2 consumer, and
calculation properties fixed. The sole package difference is one private inline
macro-assignment attribute in xl/worksheets/sheet1.xml.

The fixture contains no VBA project or macro payload. It tests whether a review
system notices an altered stored dispatch declaration, not whether it can run
or inspect executable code.

## Useful evidence without a disclosure channel

WCAB's raw validator proves the exact local relationship shape and private
assignment transition. Its public truth contains only structural counts and
safe package-member boundaries, excluding the control name, shape identifier,
macro names, relationship identifier, and raw XML.

The optional adapter accepts the case only when FormulaFence emits its exact
critical worksheet_embedded_controls_changed record and FF029 finding with a
redacted one-control profile. A generic worksheet difference is not enough,
and macro or control identities are not required in the report.

## What this does not establish

This is not proof that a macro exists, resolves, is enabled, runs, or produces
a result. WCAB and FormulaFence do not load a control, inspect or execute VBA,
invoke an Office client, authenticate a user, or evaluate permissions. The
bounded claim is that a review-relevant stored declaration changed while its
ordinary spreadsheet context did not.

WCAB 0.44.1 contains 61 validated cases and 63 observable facts. It corrects
three stale score-test totals in 0.44.0; the fixture corpus and adapter
contract are unchanged. Its 294-test suite, package checks, fresh wheel/source
installations, and strict
FormulaFence 0.225.0 adapter run passed. FormulaFence maps all 62 supported
facts and all three coverage expectations; one intentionally structural formula
rewrite remains unmapped. The synchronized dataset is available on [Hugging
Face](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).

The full canonical note, including commands and release links, is at
https://sybilgambleyyu.github.io/posts/worksheet-control-macro-assignment-review.html.
