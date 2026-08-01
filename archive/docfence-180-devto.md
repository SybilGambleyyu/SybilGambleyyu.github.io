# A relationship is not a Word hyperlink

Package relationships are a useful review surface, but their count is not a
count of Word links. A hyperlink relationship can remain after visible markup
is gone. Conversely, direct WordprocessingML `w:hyperlink` markup can point to
an in-document anchor—or the start of the document—without a relationship.

That matters in CI and controlled handoffs. Review should identify the stored
element a Word client can interpret, not treat an unrelated or residual package
record as a proxy. The useful evidence is that direct hyperlink markup exists
and changed, without copying target material into a build log.

[DocFence 0.18.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.18.0)
adds a privacy-safe boundary for that markup.

## Three stored target forms

The OOXML [`w:hyperlink` definition](https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_hyperlink_topic_ID0EIMX1.html)
separates a relationship ID from a local anchor:

- With `r:id`, the relationship specifies the target.
- With no ID, `w:anchor` can name a local destination.
- With neither, the documented form navigates to the start of the current document.

When both `r:id` and `w:anchor` occur, the relationship wins. The anchor is
stored evidence, not a second target. A recognized hyperlink relationship can
have internal or external target mode, but that stored mode is not a claim that
the target is a web URL, reachable, permitted, safe, or rendered by a client.

## Count direct markup, not guesses

The new inventory reports aggregate direct-element and story counts;
relationship-backed totals; external, internal, and unsupported relationship
classes; anchor-only and current-document-start forms; and anchors shadowed by
a relationship-backed element. A relationship with no direct `w:hyperlink`
reference does not inflate the count.

Targets, anchors, locations, tooltips, frame names, history, display text,
relationship IDs, story paths, and fingerprints remain private. The private
signature catches same-count target or markup rewrites while keeping a
relationship-ID renumbering with otherwise identical semantics quiet.

DocFence does not resolve, retrieve, follow, validate, evaluate, or render a
link. It is stored-package review evidence, not a link scanner, URL validator,
or safety verdict.

## Two policy choices

For a handoff that must contain no direct Word hyperlink markup:

```yaml
rules:
  require_no_word_hyperlink_markup: true
```

This produces `DFP049`. For a governed template that intentionally retains
direct links:

```yaml
rules:
  no_word_hyperlink_markup_changes: true
```

`DFP050` protects the private direct-markup baseline. These rules complement
the generic relationship policy and the separate `HYPERLINK` field policies;
each representation carries different evidence.

## Release evidence

The 0.18 suite has 44 tests. It covers relationship modes/type mismatch,
anchor precedence, anchor-only/default forms, body/header and Strict
encodings, orphaned-relationship exclusion, same-count target and markup
changes, relationship-ID renumbering stability, policy/SARIF output, and
redaction.

The released wheel profiles python-docx’s public
[`par-hyperlinks.docx` fixture](https://github.com/python-openxml/python-docx/blob/e45454602b53e8e572b179ccf1c91093ec9f4ed7/features/steps/test_files/par-hyperlinks.docx).
It reports four direct elements and four external relationship-backed elements
without emitting targets or display text. Hosted Python 3.11/3.13 CI,
reproducible builds, fresh release-download checksums, package checks, and an
isolated-install smoke test all passed.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.18.0/docfence-0.18.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-180.html)
has the detailed evidence, policy reference, and threat-model links.
