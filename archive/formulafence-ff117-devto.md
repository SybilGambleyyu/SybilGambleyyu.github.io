# A date system change is a workbook-wide change

A workbook can keep every stored numeric cell and every formula exactly the
same while changing how date serials are interpreted. That is easy to miss in a
cell-by-cell review, and costly to discover after a report shifts by years.

[FormulaFence 0.220.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.220.0)
adds `FF117`, a high-severity finding for a normalized change to the workbook's
serial-date controls. It watches `workbookPr/@date1904` and
`workbookPr/@dateCompatibility` directly in raw OOXML, before ordinary readers
turn a date-formatted number into an application value.

## Watch the control, not a guessed outcome

Microsoft's [WorkbookProperties documentation](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.workbookproperties?view=openxml-3.0.1)
defines the controls: `date1904` selects the 1900 or 1904 compatibility base,
while `dateCompatibility` determines whether that compatibility base is in use.
The documented defaults matter: omitted `date1904` is false and omitted
`dateCompatibility` is true. FormulaFence normalizes those defaults, so an
omitted declaration and an explicit documented default do not make CI noisy.

The rule is observational. It does not calculate formulas, convert serials to
dates, predict a client display, or claim that a saved result is current. It
reports the stored control transition so a reviewer can decide what it means for
the workbook's actual consumers.

## A policy boundary people can read

Profiles and `FF117` details expose only normalized Boolean state, whether
`dateCompatibility` was explicitly declared, and an unrecognized-control count.
Invalid, duplicate, or unreadable metadata becomes an explicit coverage warning
rather than a guessed epoch.

To block the change in CI:

```yaml
version: 1
rules:
  no_workbook_date_system_changes: true
```

That turns the observed `FF117` into `FFP117`.

## Evidence before the claim

The release fixture keeps a raw numeric serial, date number format, ordinary
formula consumer, and downstream dashboard consumer fixed. Only
`xl/workbook.xml` changes: `date1904` moves from false to true while
`dateCompatibility` remains true. Separate cases prove that documented default
spelling stays quiet, a compatibility-mode change is detected independently,
and malformed controls remain visibly unassessed.

FormulaFence 0.220.0 passed 1,589 tests, hosted CI, package metadata checks,
and fresh wheel/source-distribution installs. Read the [canonical release note](https://sybilgambleyyu.github.io/posts/formulafence-ff117.html)
for the full boundary, validation record, and install command. FormulaFence is
MIT-licensed and available on [GitHub](https://github.com/SybilGambleyyu/formulafence).
