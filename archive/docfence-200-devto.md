# The Word link your relationship scan cannot see

A relationship scan is useful, but it is not a complete link inventory. A
legacy Word package can place a URL directly on a VML shape’s `href` attribute.
That leaves no OOXML hyperlink relationship, no `HYPERLINK` field, no
`w:hyperlink`, and no DrawingML action for a review gate to find.

[DocFence 0.20.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.20.0)
adds a privacy-safe inventory for that distinct stored surface: direct legacy
VML shape-link markup in supported Word stories.

## Count the direct marker, not an imagined click

Microsoft’s [HRef shape attribute documentation](https://learn.microsoft.com/en-us/windows/win32/vml/href-attribute--shape--vml)
defines a URL for a shape, and the W3C’s [VML note](https://www.w3.org/TR/NOTE-VML)
describes it as the URL to jump to when clicked, with `target` as the frame.
That is a storage fact, not a rendering claim.

DocFence scans direct, unqualified `href` attributes only on the documented
VML shape-family elements: `arc`, `curve`, `image`, `line`, `oval`, `polyline`,
`rect`, `roundrect`, `shape`, `group`, and `shapetype`. It reports only
aggregate element/story, concrete-shape/group/shape-template, and
`target`-attribute-presence counts. URLs, target frames, titles, alternate text,
shape IDs, story paths, and fingerprints remain private.

It does not infer a link inherited from a group or shape template, scan
arbitrary VML attributes, choose a Markup Compatibility branch, resolve,
retrieve, follow, validate, evaluate, render, or execute an action.

## Policies for a clean handoff or a governed baseline

```yaml
rules:
  require_no_word_vml_hyperlinks: true
```

This produces `DFP053` for a candidate containing supported direct VML
shape-link markup. A governed legacy template can instead use:

```yaml
rules:
  no_word_vml_hyperlink_changes: true
```

`DFP054` protects the private marker baseline. These complement relationship,
field-code, direct WordprocessingML, and DrawingML gates because the stored
mechanisms differ.

## Evidence, with the important limitation

The 0.20 suite has 46 tests. Its VML case covers every supported element kind
across body and header stories, an empty direct `href`, target-attribute
presence, same-count target and `href` changes, policy/SARIF output, and
redaction. It also proves that a VML-only package can have zero relationship,
`HYPERLINK`-field, `w:hyperlink`, and DrawingML link counts.

I searched for a public authored Word fixture before making broader claims. A
scan of the Open XML SDK’s pinned public Word assets found legacy VML shapes but
no direct VML `href`. The release therefore uses a controlled,
standards-shaped Word-story package as exact parser evidence and treats the
feature as a stored-XML compatibility boundary—not proof that contemporary Word
commonly authors such links.

Hosted Python 3.11/3.13 CI, tag CI, reproducible builds, fresh public-release
checksum verification, package checks, and an isolated-wheel VML probe all
passed.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.20.0/docfence-0.20.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

Read the full release note, exact policy contract, and threat-model limits in
the [canonical article](https://sybilgambleyyu.github.io/posts/docfence-200.html).
