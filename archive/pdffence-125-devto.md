---
title: A batch report should know less than its manifest
published: true
description: PDFFence 1.25 adds manifest-driven PDF batch review with opaque public IDs, private paths, and a CI gate for added or removed documents.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-125.html
---

# A batch report should know less than its manifest

A serious PDF handoff is rarely one file. It may be a release directory, a contract set, or an evidence bundle. A review tool needs to pair each before/after source, including a rename—but filenames and directory layout can themselves be sensitive. A CI artifact that exposes them is often not safe to share.

[PDFFence 1.25.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.25.0) adds `pdffence batch`, a manifest-driven workflow designed around that boundary: the manifest knows private paths; the report does not.

## Declare pairs instead of guessing them

Batch review takes separate local before/after roots and a strict JSON manifest. Every item has a caller-chosen public ID and explicitly selected paths:

~~~json
{
  "version": 1,
  "documents": [
    {
      "id": "review-001",
      "before": "contracts/draft.pdf",
      "after": "contracts/final.pdf"
    },
    {
      "id": "review-002",
      "before": "retired/notice.pdf",
      "after": null
    }
  ]
}
~~~

The first is an explicit rename; the second is a removal. An after-only item is an addition. PDFFence never scans a directory tree, infers a match from a filename, or silently omits an unpaired document. A malformed, unsafe, missing, or symbolic-link source fails the entire batch rather than producing a partial success.

## Keep the paths private

Roots and manifest paths stay local inputs. JSON, Markdown, SARIF, findings, and expected errors contain no paths, filenames, page text, action targets, attachment names, or hashes. Results use one of three fixed statuses—`compared`, `added`, or `removed`—and an opaque manifest ID.

That ID is deliberately public. Batch SARIF stores it as `properties.document_id` so a finding is actionable without a file location. Use an alias such as `review-001`, not a customer name or filename. The ID syntax is intentionally small and documented; a caller-provided label is not assumed to be secret.

## Fail CI when the set changes

The new batch-only policy rule `require_same_document_set` (PFP016) produces one high-severity finding for every added or removed declared entry. It is enabled by the starter policy:

~~~bash
pdffence init pdffence.yml
pdffence batch baseline/ candidate/ \
  --manifest review.json --policy pdffence.yml --format sarif
~~~

Existing pair-level policies still run independently on each `compared` entry. For example, `no_active_content_changes` can flag an action change within one paired PDF while PFP016 flags a different document that was removed. PFP016 has no effect on the normal two-file `pdffence check` command.

## Tested beyond one directory

PDFFence 1.25 passed 269 tests, Ruff, and bytecode compilation. The new tests put a deliberately sensitive marker in private paths and PDF content, then verify that JSON, Markdown, SARIF, and errors never reproduce it. They also cover duplicate JSON keys, traversal attempts, renamed pairs, additions, removals, policy exit status, and symbolic-link roots and sources.

An opaque-ID manifest was also run over all 161 pairs in [PDFCAB 1.24.1](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.24.1). It reported 161 changed documents and no findings without a policy. Every batch entry's public snapshots, changes, and findings exactly matched its standalone `pdffence diff --format json` report; fixture roots and baseline/candidate paths were absent.

The release builds reproducibly with a fixed timestamp, passes Twine checks, and has been tested from fresh Python 3.12/3.13 installations. The published GitHub wheel was re-downloaded, checksum-verified, installed from its public URL, and used for the same 161-document run.

This is structural review evidence, not a visual comparison, directory discovery tool, malware sandbox, PDF conformance checker, or signature-validation service. A manifest only checks the declared set. PDFFence does not render pages, execute actions, follow URIs, extract text, decrypt PDFs, or decide whether a signature is trusted, valid, authorized, or safe.

Read the canonical [PDFFence 1.25 release note](https://sybilgambleyyu.github.io/posts/pdffence-125.html) for the manifest contract, threat model, validation record, and release links.
