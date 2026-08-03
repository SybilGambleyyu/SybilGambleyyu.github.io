# A mail-merge source can change without changing Word text

Mail-merge setup can live in a Word package’s settings rather than its visible
text. That means a document can retain every stored text node, its mail-merge
anchor, and its relationship ID while the stored target of an external data
source changes.

[Document Change Assurance Benchmark 0.6.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.6.0)
adds its seventeenth deterministic pair:
`external.mail_merge_data_source_target_retargeted`. Both sides retain fixed
`w:mailMerge` and `w:dataSource` markup, a fixed relationship ID, every package
member, and every stored `w:t` sequence. Only
`word/_rels/settings.xml.rels` changes.

## Review the stored binding; do not connect

Microsoft’s [Open XML documentation for `DataSourceReference`](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.datasourcereference?view=openxml-3.0.1)
describes `w:dataSource` as the relationship to the external source used for a
mail merge, through a `mailMergeSource` relationship. DCAB fixes the anchor and
relationship type, uses only synthetic `example.invalid` targets, and changes
only the stored target.

The builder, verifier, scorer, and adapter do not resolve a relationship, open
Word, connect to a data source, execute a query, parse a connection string, or
claim what a client will merge. Public truth names only
`mail_merge_data_source_target_changed`, an external binding, the relationship
category, and its settings source; it excludes targets, relationship IDs, and
stored settings details.

## A deterministic settings relationship boundary

The independent verifier checks the fixed settings anchor, relationship ID,
standard relationship type, external mode, deterministic package bytes, stable
members, unchanged stored text, and exact one-member pair boundary.
`python-docx` opens all 32 `.docx` fixtures, and its lower-level OPC reader
opens all 34 packages.

The optional local [DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter maps aggregate mail-merge inventory evidence while configuration and
data-source relationship counts remain one and header/recipient-data counts
remain zero. It does not consume targets or private signatures.

DCAB 0.6.0 retains fixture schema version 1 and extends the corpus from 16 to
17 cases. It does not claim a source is reachable, safe, queried, rendered, or
used by a client.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-mail-merge-review.html)
for the full boundary and install command.
