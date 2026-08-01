A Word template can look like an ordinary document while retaining enough
mail-merge state to point at a data source, retain a query or connection
configuration, and preserve recipient-selection data. That is a material
review boundary at a controlled handoff. Microsoft documents the prompt shown
when a linked mail-merge document would run a SQL query, and says accepting it
lets code run on the computer.

[DocFence 0.5.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.5.0)
makes that stored state review-visible as bounded, local evidence. It records
mail-merge configuration, external data/header-source relationships, and
internal recipient-data parts without placing source paths, connection strings,
queries, table names, field mappings, relationship IDs, or recipient data into
JSON, Markdown, or SARIF output.

## Stored dependency, not just a template setting

Mail-merge state lives in Word's `word/settings.xml` part. A `w:mailMerge`
configuration can point to an external `mailMergeSource`, an external header
source, and Office Data Source Object (`w:odso`) details such as connection
information, table names, queries, and mapped fields. The Open XML SDK's
[ODSO documentation](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.datasourceobject?view=openxml-3.0.1)
describes it as carrying both connection information and record-selection/
mapping state.

Recipient inclusion/exclusion information can also be stored separately as an
internal recipient-data part. Its presence does not disclose who a recipient is
or prove Word will access a source when the document opens. It remains stored
workflow state a clean handoff may need to review.

DocFence exposes only five aggregate counts:

- Mail-merge configurations.
- External data-source relationships.
- External header-source relationships.
- Internal recipient-data relationships.
- Recipient-data parts.

The private comparison signature includes the relevant configuration,
normalized relationship semantics, and recipient-data bytes. Values and targets
never leave the process.

## The relationship contract is checked

For direct `w:dataSource`, `w:headerSource`, ODSO `w:src`, and ODSO
`w:recipientData` references, DocFence requires the expected relationship kind
and target mode. Data and header sources must be external; recipient-data
targets must be internal stored package parts. A malformed recognized reference
fails closed instead of becoming a vague package change.

Recognized source and recipient relationships are still inventoried if no
current `w:mailMerge` element references them. A residual relationship can
continue to retain an external target or recipient payload, so absence of an
anchor is not a reason to hide it from review.

## “None” and “no change” are different policies

A clean-handoff policy can prohibit all stored mail-merge state in the
candidate:

```yaml
rules:
  require_no_mail_merge: true
```

This emits `DFP021`.

An approved template may intentionally retain a known merge setup. For that
case, preserve the baseline and reject a later mutation:

```yaml
rules:
  no_mail_merge_changes: true
```

This emits `DFP022` when the private inventory differs. Relationship IDs are
normalized, so an ID rewrite alone stays quiet. A query, source target, mapping,
or recipient-data mutation does not.

## Release evidence and limits

The release tests conventional and Strict OOXML relationships, both documented
recipient-data relationship spellings, query-only changes, recipient-data
changes, residual source relationships, malformed types and modes, missing
internal targets, policy output, redaction, and relationship-ID stability.
Distinct markers placed in connection settings, source/header targets, queries,
mappings, and recipient data are checked not to appear in public output.

The wheel and source archive were independently built twice from the release
commit with the same `SOURCE_DATE_EPOCH`; both artifact pairs were
byte-identical. The public release has a wheel, source archive, and SHA-256
manifest. I downloaded those exact assets, verified their checksums, installed
the wheel into a fresh environment, and confirmed its aggregate counts and
zero-result ID-rewrite comparison.

DocFence does not connect to a source, execute a query, select a recipient, or
decide whether mail-merge state is expected, personal, safe, or malicious. It
is evidence about stored package state, not a rendering, execution, or malware
verdict.

The installation command, full policy contract, and source links are on the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-050.html).
