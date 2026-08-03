# A sensitivity label can change without a cell changing

A workbook can keep every worksheet cell, formula, and calculated value stable
while its stored sensitivity-label metadata changes. That is material review
evidence. It is also sensitive evidence: a CI report that prints the label
name, identifiers, action details, site information, or timestamps can turn a
useful control into a metadata leak.

[FormulaFence 0.225.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.225.0)
and [Workbook Change Assurance Benchmark 0.43.0](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.43.0)
establish a narrow boundary for this case: detect a persisted Office metadata
transition, report count-only evidence, and leave policy, access, and
enforcement claims outside the result.

## More than one stored location

Microsoft's [LabelInfo versus Custom Document Properties
specification](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-offcrypto/13939de6-c833-44ab-b213-e0088bf02341)
describes persisted sensitivity-label metadata in custom document properties or
a LabelInfo stream, with policy and the actual storage location affecting how
an implementation reads and writes it. Its [Sensitivity Label Information Part
specification](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/c0599e21-b77f-475e-99e0-bd647f60bcbb)
describes a package-root classification-label relationship to a
docMetadata/LabelInfo.xml part whose root is labelList.

FormulaFence recognizes the bounded, persisted forms that matter for review:
the standard Sensitivity custom property, Microsoft Information Protection
custom properties, and the relationship-backed LabelInfo part. This is package
inspection, not a claim that every representation is an effective label in
every Office or service workflow.

## Redacted, explicit evidence

FormulaFence 0.225.0 emits high-severity
sensitivity_label_metadata_changed evidence with FF118 when that bounded
metadata changes. It carries safe aggregate counts and a material-change
signal, while intentionally withholding label identifiers and names, action and
site identifiers, timestamps, property names and values, XML, relationship IDs,
and relationship targets.

The generic custom-property signal remains available when docProps/custom.xml
changes, but it is not a substitute for the explicit sensitivity-label review
surface. Teams can make the event blocking with the readable
no_sensitivity_label_metadata_changes policy rule.

## A deterministic proof case

WCAB 0.43.0 adds governance.sensitivity_label_metadata_changed, a generated
workbook pair with Controls!B2=12, Controls!D2=B2*C2, and
Dashboard!B4=Controls!$D$2 held fixed. It contains both custom-property and
relationship-backed LabelInfo metadata in standards-form package locations.

The candidate changes exactly one private synthetic MIP custom-property value.
The relationship, LabelInfo part, other custom properties, content types,
calculation properties, formulas, and every other package member remain fixed.
The raw validator proves that one-member boundary; public truth includes only
the high-level transition and safe count profile.

The WCAB adapter accepts this only when FormulaFence emits the exact
high-severity category and FF118 with the expected redacted count profile. It
can therefore reject a tool that sees a generic property change but misses the
specific review boundary, without weakening the reporting redaction contract.

## A small claim on purpose

A stored metadata difference is not proof of effective labeling, policy-service
decisions, encryption, permissions, identity, access, Office-client behavior,
SharePoint or OneDrive enforcement, or successful workflow action. FormulaFence
does not resolve those systems. The result is deliberately smaller: a local
package changed in a review-relevant way.

FormulaFence 0.225.0 passed its 1,602-test local suite, packaging checks, and
fresh-install verification. WCAB 0.43.0 contains 60 validated fixtures and
passed its 287-test local suite, packaging checks, and fresh wheel/source
installs. The benchmark dataset mirror is on
[Hugging Face](https://huggingface.co/datasets/SybilGambleyyu/workbook-change-benchmark).

The full canonical note, including install commands and release links, is at
https://sybilgambleyyu.github.io/posts/sensitivity-label-metadata-review.html.
