# A Word restriction is not encryption

A Word template can open as read-only, permit only comments or form fields,
recommend read-only mode, or ask before leaving a restriction. Those controls
can matter enormously to a publishing, review, or handoff workflow. But they
are not the same as encrypting a file, and a package that stores them should
not be described as cryptographically secure merely because a password-looking
value appears in its settings.

Microsoft’s [WordprocessingML document-protection contract](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.documentprotection?view=openxml-3.0.1)
states the critical boundary: editing restrictions prevent unintentional
changes, do not encrypt the document, and are not intended as a security
feature. The independent [write-protection setting](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.wordprocessing.writeprotection?view=openxml-3.0.1)
carries the same caveat. Both remain meaningful stored state, and protection
elements can retain password-verifier fields such as hashes and salts.

[DocFence 0.13.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.13.0)
makes that boundary review-visible without exposing protection material or
overstating what it means.

## What the package can retain

Word stores direct `w:documentProtection` and `w:writeProtection` elements in a
document Settings part. The first can specify an editing mode such as read-only,
comments, tracked changes, or forms, plus formatting and an enforcement
attribute. The second can recommend read-only mode or retain write-protection
material. Client behavior can differ, especially when enforcement is absent, so
DocFence reports stored evidence rather than predicting what an editor will do.

DocFence discovers Settings through Word’s conventional `word/settings.xml` path
and recognized Transitional or Strict settings relationships from the main or
glossary document. It checks direct protection leaves, permits at most one of
each per Settings part, and rejects malformed recognized shape, attributes,
edit modes, or boolean values.

## Counts in reports; verifier material stays private

Profile JSON, Markdown, and SARIF expose only aggregate document-protection
element, explicitly-enabled enforcement, formatting-restriction, edit-mode,
write-protection, read-only-recommendation, and password-material counts. A
password-material count means an element stores at least one hash or salt
attribute; it does not say the verifier is complete, valid, or strong.

DocFence never prints hashes, salts, verifier values, provider or algorithm
fields, other protection attributes, Settings-part paths, or fingerprints. The
full direct elements are privately fingerprinted, so a same-count verifier
rewrite remains review-visible without putting password-verifier material in CI
output.

## Two policy choices

For an external handoff that must carry no stored Word editing or
write-protection state:

```yaml
rules:
  require_no_word_protection: true
```

This produces `DFP039`. It fails whenever a recognized protection element is
present, including an otherwise empty one. For an approved template that
intentionally retains a known restriction:

```yaml
rules:
  no_word_protection_changes: true
```

`DFP040` detects a private-inventory change from that baseline. These rules
protect package state; they do not turn an editing restriction into an
encryption or security claim.

## What this deliberately does not do

DocFence does not validate password construction or strength, derive, test, or
recover a password, assess an algorithm, bypass a restriction, decrypt a
document, determine effective Office enforcement, or decide whether a document
is secure. A counts-and-private-digest boundary is intentionally much narrower
than a password or cryptographic analysis tool.

## Release evidence

The 0.13 suite has 35 tests covering same-count hash/verifier rewrites,
redaction, policy/SARIF behavior, conventional/Transitional/Strict/glossary
Settings discovery, malformed markup, and external Settings relationships. It
passed Python 3.11/3.13 CI, Ruff, and compilation checks. Its wheel and source
archive were independently rebuilt from the release commit and matched
byte-for-byte.

An installed wheel profiled two independent Open XML SDK protection assets: one
reported a stored write-protection element and read-only recommendation; another
reported a document-protection element with explicit enforcement and a
formatting restriction. Neither reported password-material attributes. The
release smoke also preserved DocFence’s existing public signed-package and
ordinary Word-package checks.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.13.0/docfence-0.13.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-130.html)
has the detailed evidence, source links, policy reference, and threat-model
links.
