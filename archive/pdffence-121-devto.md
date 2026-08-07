---
title: A PDF signature ByteRange belongs to its own revision
published: true
description: PDFFence 1.21 adds a static own-revision ByteRange gate for historical PDF signatures.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-121.html
---

# A PDF signature ByteRange belongs to its own revision

PDF signatures are commonly added as incremental updates. That makes one
distinction important in review: an earlier signature's `/ByteRange` should end
at the end of the revision that added that signature, not necessarily at the
end of the current file.

[PDFFence 1.21.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.21.0)
adds PFP013, `require_signature_byte_range_own_revision_coverage`, to make
that static boundary reviewable. The [PDF 2.0 signature
errata](https://pdf-issues.pdfa.org/32000-2-2020/clause12.html) describe the
multiple-signature range as ending at the `%%EOF` that terminates the
incremental update adding the signature dictionary, with a possible optional
EOL.

## A different question from current-file coverage

Current-file coverage is useful when the latest stored file must be covered.
But it classifies any older signature as non-current after a later incremental
update. PFP013 instead asks whether each semantic signature's well-formed
range ends at its own revision footer.

~~~yaml
version: 1
rules:
  require_signature_byte_range_own_revision_coverage: true
~~~

PDFFence uses catalog-reachable AcroForm signature fields and catalog `/Perms`
signature roots only. For an xref-addressable indirect signature dictionary, it
follows a bounded confirmed `/Prev` chain and requires an unambiguous revision
footer. It reports aggregate counts only: no object references, offsets,
revision boundaries, signature bytes, digests, certificates, transforms, or
trust decisions.

Unavailable, ambiguous, malformed, direct, compressed, or over-limit evidence
does not receive a positive count. This is static review evidence, not
signature, digest, certificate, trust, permission, or incremental-update
validation.

## A control for historical signatures

[PDFCAB 1.21.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.21.0)
adds a 158th deterministic pair where both sides have a signature followed by
a later incremental update. Neither range reaches the current file end. The
baseline reaches its signing revision footer; the candidate stops short of it.
Only the new own-revision inventory event and PFP013 are expected. PDFFence
1.20 reports changed bytes alone on this pair.

PDFFence 1.21 passed 254 tests and Ruff; PDFCAB passed 88 tests and Ruff. The
public process-bound score was exact at 158 of 158 pairs, with reproducible
wheel/source builds and clean Python 3.12/3.13 installs. A pyHanko
two-signature exercise counted both signatures at their own revisions while
only the newest reached current EOF.

Read the canonical [PDFFence 1.21 release note](https://sybilgambleyyu.github.io/posts/pdffence-121.html)
for the supported boundary, validation record, and release links.
