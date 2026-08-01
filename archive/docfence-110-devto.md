# A sensitivity label can retain your tenant’s metadata

Removing a visible header or changing a file name does not necessarily remove
the governance state a Word package carries. Office can retain
sensitivity-label metadata that identifies label and tenant context, records
state and method, and may name header, footer, or watermark markings. That
matters at an external handoff, but a CI report must not become another way to
disclose it.

[DocFence 0.11.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.11.0)
makes this stored package evidence review-visible as bounded, private inventory.
It emits only aggregate counts useful to a gate; the actual label metadata
remains inside a local SHA-256 comparison signature.

## Two compatible storage forms

Modern Office packages can hold an Office 2021
[Sensitivity Label Information part](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oi29500/c0599e21-b77f-475e-99e0-bd647f60bcbb).
Its <code>labelList</code> records label identity, enabled or removed state,
method, tenant site ID, and optional details. Microsoft also specifies how that
part relates to the older property model through
[LabelInfo/custom-property precedence](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-offcrypto/13939de6-c833-44ab-b213-e0088bf02341).

Older and compatibility paths can retain MIP metadata in custom document
properties such as <code>MSIP_Label_&lt;GUID&gt;_&lt;attribute&gt;</code>, including
custom and versioned attributes in Microsoft’s
[MIP metadata guidance](https://learn.microsoft.com/en-us/information-protection/develop/concept-mip-metadata).
DocFence also recognizes the legacy <code>Sensitivity</code> property and Word’s
documented header, footer, and watermark content-marking property names.

## Reports show counts; comparisons retain the detail privately

Profile, Markdown, and SARIF output contain only aggregate LabelInfo part,
label, enabled-label, removed-label, extension, legacy MIP-label, legacy
MIP-property, legacy Sensitivity-property, and Word content-marking-property
counts. They do not print label or tenant IDs, label names, methods, dates,
action IDs, extension payloads, custom property names or values, marking text,
or part paths.

The full recognized inventory is privately fingerprinted. A label-name,
extension-payload, or legacy-property change can therefore fail a protected
baseline even when every public count is unchanged. Relationship-ID renumbering
alone remains quiet.

## Two policy choices

For a clean publishing or handoff boundary:

~~~yaml
rules:
  require_no_sensitivity_label_metadata: true
~~~

This yields <code>DFP035</code> and fails if any sensitivity-label count is
nonzero, including an empty recognized LabelInfo part. For a controlled template
that intentionally retains approved label metadata:

~~~yaml
rules:
  no_sensitivity_label_metadata_changes: true
~~~

<code>DFP036</code> protects that approved baseline from private-inventory
mutation.

## Evidence boundary

DocFence discovers modern metadata through the standard classification-label
relationship, Office SDK content type, or conventional
<code>docMetadata/LabelInfo</code> paths. A recognized relationship must
originate at the package root, be internal, and resolve to a stored member. At
most one LabelInfo part is accepted; malformed recognized roots, state,
tenant-site IDs, or extension structure fail closed. Recognized legacy metadata
is found even when a custom-property part has a noncanonical relationship target.

This is stored-package evidence, not label enforcement. DocFence does not
decrypt IRM-protected content, read LabelInfo from encrypted storage, resolve
tenant policy or effective labels, calculate permissions, apply or remove a
label, render header/footer/watermark markings, or prove enforcement.

The release has 31 tests covering same-count mutations, redaction,
policy/SARIF behavior, discovery modes, malformed and unavailable
relationships, multiple parts, noncanonical legacy properties, and
relationship-ID churn. Its wheel and source archive were independently rebuilt
from the release commit and matched byte-for-byte.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.11.0/docfence-0.11.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
~~~

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-110.html)
has the detailed evidence, source links, policy reference, and threat-model
links.
