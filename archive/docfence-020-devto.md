Word’s hidden-text problem is more subtle than a checkbox in a CI policy.

A direct `w:vanish` property on an ordinary run is evidence about that run. A
property on a paragraph mark is a different thing. And a declaration inside a
style can participate in an inherited, toggle-based hierarchy before Word
decides what to show.

That makes two common shortcuts unsafe: calling every style declaration a
hidden run, or ignoring the style part altogether. [DocFence 0.2.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.2.0)
adds a third option—more evidence, with an explicit limit on what the evidence
means.

## Three separate signals

The release reports three intentionally separate inventories:

- `hidden_text_run_count` covers direct `w:vanish` markup on ordinary runs.
- `hidden_paragraph_mark_count` covers direct `w:vanish` and `w:specVanish`
  markup under `w:pPr/w:rPr`.
- The style inventory reports enabled text-run `w:vanish` declarations in
  stored styles and whether document-default run properties declare it.

Microsoft describes hidden text as a toggle property when it appears in a
style, while direct formatting sets an absolute state. Its Open XML reference
also defines `w:specVanish` as a paragraph-mark property; on another run it can
be ignored. That is why the DocFence signals do not collapse into one number.

## An honest CI boundary

The style inventory is not an effective-format calculation. DocFence does not
claim which styles are applied, resolve `basedOn`, table or numbering styles, or
calculate the full toggle hierarchy. It therefore cannot honestly say which
candidate runs Word will display as hidden.

What it can say is useful: the stored package contains style or document-default
declarations worth reviewing. Direct paragraph-mark properties are kept
separate, and tracked historical formatting inside a style does not inflate the
current text-style count.

This turns a blind spot into a review signal without creating a fake rendering
verdict.

## Explicit policy gates

The two new candidate-state rules are opt-in:

```yaml
rules:
  require_no_hidden_text: true
  require_no_hidden_paragraph_marks: true
  require_no_hidden_text_style_declarations: true
```

They map to `DFP006`, `DFP014`, and `DFP013`. Reports remain privacy-safe:
aggregate counts and fixed categories rather than source text, style names,
style IDs, package paths, or fingerprints.

## Release evidence

DocFence 0.2.0 adds regression cases for false values, paragraph-mark
`specVanish`, style declarations, tracked style history, malformed styles parts,
policy output, and report redaction. It was also smoke-tested against a
conventionally generated Word package with 164 standard styles.

The wheel and source distribution were built twice from the release commit with
the same `SOURCE_DATE_EPOCH` and matched byte-for-byte. The release includes
both artifacts plus a SHA-256 manifest.

The full reasoning, sources, policy scope, and install command are on the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-020.html).
