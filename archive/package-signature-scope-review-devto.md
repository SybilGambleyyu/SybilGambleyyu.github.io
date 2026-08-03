# A package signature can change scope without changing a cell

A workbook can keep every worksheet cell and ordinary formula stable while the
declared scope of a package signature changes. That is material review
evidence, but it is not proof that a signature validates or that a certificate
is trusted.

[FormulaFence 0.224.0](https://github.com/SybilGambleyyu/formulafence/releases/tag/v0.224.0)
and [WCAB 0.42.0](https://github.com/SybilGambleyyu/workbook-change-benchmark/releases/tag/v0.42.0)
make package-signature scope, stored review metadata, and protected-range
descriptor transitions reviewable without exposing material in CI output or
inventing a cryptographic, trust, identity, authorization, or workflow result.

## Two kinds of XMLDSIG reference

The [Open Packaging Conventions specification](https://ecma-international.org/wp-content/uploads/ECMA-376-Part-2-5th-edition.pdf)
defines package relationships and signature parts. The W3C [XML Signature
specification](https://www.w3.org/TR/xmldsig-core/) distinguishes references in
`SignedInfo` from references collected in a `Manifest`.

A `SignedInfo` URI can identify a local signature `Object`; an
`Object/Manifest/Reference` can declare a package part. Those are different
scopes. Treating a local object reference as package coverage would be a false
claim.

## Safe aggregate evidence

FormulaFence 0.224.0 reads the bounded structure and reports aggregate counts
for Manifest references, direct parts, relationship selectors, and direct
workbook, worksheet, VBA-project, and external-data-connection categories.
For a selector-bearing Relationships Transform, it counts declared scope only
when XML C14N immediately follows the transform. When that aggregate changes,
high-severity `FF050` evidence includes:

```text
package_signature_material_changed: true
package_signature_manifest_coverage_changed: true
```

It does not emit a URI, selector, digest, signature value, certificate,
identity, or trust assertion. It does not validate a digest or signature,
process a transform, build a certificate chain, check revocation, apply policy,
or predict a consumer decision.

## A precise benchmark fixture

[Workbook Change Assurance Benchmark](https://github.com/SybilGambleyyu/workbook-change-benchmark)
0.38.0 adds a deterministic pair with a fixed root-to-origin relationship,
origin-to-signature relationship, content types, `SignedInfo` local-object
reference, ordinary `Controls!B10=12` value, and `Controls!D10=B10*C10`
formula. The sole changed archive member is `_xmlsignatures/sig1.xml`: one
`Object/Manifest/Reference/@URI` moves from a direct workbook part to a direct
worksheet part.

The fixture's digest and signature values are deliberately synthetic. WCAB's
raw validator establishes the bounded package shape and the one-member package
boundary; it does not validate cryptography, transforms, certificates, trust,
or a consumer decision.

## Equal safe counts are not scope equality

WCAB 0.39.0 adds a second pair whose Manifest URI stays on the root
relationships part and whose sole Relationships Transform is immediately
followed by XML C14N. Only one `RelationshipReference/@SourceId` moves, from
the root office-document relationship to the root signature-origin
relationship. The graph, cells, formulas, transform sequence, and every archive
member except `_xmlsignatures/sig1.xml` stay fixed.

The redacted aggregate remains exactly equal: one Manifest reference, one
relationship selector, zero direct-part references, one origin, and one XML
signature. FormulaFence must therefore expose the separate
`package_signature_manifest_coverage_changed` signal rather than a count or the
selector itself. The selector identifies a relationship entry, not proof that
its target was signed; neither project executes a transform or makes a
cryptographic or trust claim.

Its FormulaFence adapter requires exact high-severity
`digital_signature_controls_changed` and `FF050` evidence. The direct-part
case requires the category transition; the selector case requires equal
aggregate profiles plus the separate coverage-change flag. WCAB independently
verifies its public synthetic URI or source-ID transition. This lets a
shareable CI report show an important scope change without turning into a
signature-material leak or an invented trust result.

## A resolved comment can move without a cell change

Modern [threaded comments](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-xlsx/66e1875d-c60a-48eb-bf88-41066d45fea8)
are worksheet-associated package state rather than ordinary cell values. WCAB
0.40.0 adds a deterministic pair where one synthetic
top-level thread changes `threadedComment/@done` from `0` to `1`. The only
changed archive member is `xl/threadedComments/threadedComment1.xml`; comment
text, person data, timestamps, cell binding, content types, relationships,
ordinary values, formulas, and calculation properties remain fixed.

FormulaFence emits only high-severity `threaded_comment_controls_changed` /
`FF045` evidence with a redacted `resolved_comment_count` transition of `0` to
`1`. The benchmark's raw validator holds the precise synthetic package check,
without publicizing text, identities, timestamps, cell references, or
relationship IDs. A stored resolved flag does not prove review, approval,
notification, identity, authorization, or workflow completion.

## A revision log can change without a cell change

Legacy shared-workbook revision history persists through headers and revision
logs, as described by Microsoft's [Headers class
reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.headers?view=openxml-3.0.1).
WCAB 0.41.0 adds a deterministic pair with one revision-header part, one
relationship-backed revision-log part, three revision records, and matching
enabled shared-workbook tracking, retention, and history-protection controls.

Only `xl/revisions/revisionLog1.xml` changes. One synthetic historic old value
changes inside that log while the graph, content types, controls,
revision-record shape, ordinary values, formulas, and calculation properties
stay fixed. The public fact deliberately contains only equal safe aggregate
counts; it excludes historic values, locations, author data, timestamps, GUIDs,
and relationship IDs.

FormulaFence exposes this only as high-severity
`shared_workbook_revisions_changed` / `FF062` evidence with equal safe counts
and `revision_log_material_changed: true`. A recorded revision is not proof of
provenance, author identity, conflict resolution, review, approval,
authorization, workflow completion, or Office-client behavior.

## A protected-range descriptor can change without a cell edit

The ISO/IEC SpreadsheetML [protected-range example](https://www.reginfo.gov/public/do/DownloadDocument?objectID=136723002)
places account descriptors in nested `securityDescriptor` children, and the
Open XML SDK's [ProtectedRange reference](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.spreadsheet.protectedrange?view=openxml-3.0.1)
also identifies that child. It is stored review material, not proof that an
application identified, authenticated, authorized, or permitted an editor.

WCAB 0.42.0 adds a compact standards-form pair. Only one nested
`protectedRange/securityDescriptor` text node changes in
`xl/worksheets/sheet1.xml`; the protected sheet, locked `Controls!B2:B2`
target, range name/reference, legacy verifier, `Controls!D2=B2*C2` formula,
and direct `Dashboard!B4` consumer stay fixed. The raw validator checks the
synthetic element and compares the worksheet after erasing only that text. Its
public fact excludes the descriptor, range name, and verifier; it does not test
a password, encryption, identity, authentication, authorization, editable-range
enforcement, client behavior, or a result.

FormulaFence 0.224.0 reports the difference only as high-severity
`protected_range_permissions_changed` / `FF022` evidence. Its equal redacted
profiles retain one named range, one legacy verifier, one standard descriptor,
and no opaque metadata, while `security_descriptor_material_changed: true`
carries the change. It emits no descriptor, account identity, range name, or
verifier value.

FormulaFence 0.224.0 passed 1,598 tests. WCAB 0.42.0 has 59 cases, 61 facts,
and 280 passing tests. The full canonical note, with validation details and
installation commands, is at
https://sybilgambleyyu.github.io/posts/package-signature-scope-review.html.
