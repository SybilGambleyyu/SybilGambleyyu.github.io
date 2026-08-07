---
title: A batch manifest should be generated, not hand-written
published: true
description: PDFFence 1.26 generates a private deterministic manifest for large PDF batch review without guessing renames or publishing paths.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-126.html
---

# A batch manifest should be generated, not hand-written

A privacy-safe PDF batch report needs an explicit manifest: it cannot safely reveal or guess the private paths that connect before and after documents. But typing that manifest for hundreds of PDFs turns a sound review design into a workflow people avoid.

[PDFFence 1.26.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.26.0) adds `pdffence batch-init`, a deliberately narrow generator for the common case where two directory trees preserve the same relative PDF paths.

## Create the private starting map locally

~~~bash
pdffence batch-init baseline/ candidate/ review.json
pdffence batch baseline/ candidate/ \
  --manifest review.json --policy pdffence.yml --format sarif
~~~

`batch-init` recursively walks the two selected local roots and writes a strict JSON manifest. It pairs only same-relative-path PDFs and gives each one a deterministic opaque ID such as `document-0001`. A path found on just one side stays a one-sided entry, making it an explicit addition or removal in the normal batch report.

The generated manifest itself is private because it contains relative paths. Keep it out of public repositories and CI artifacts unless those paths are appropriate there. The command requires an explicit destination, writes atomically, and emits no path-bearing standard output.

## A rename still needs a human decision

The generator does not decide that two different paths are a rename. Similar names, equal sizes, or similar contents are not enough to establish identity in a serious handoff. Guessing would create silent review omissions.

Instead, an unmatched path becomes an added or removed entry. When a reviewer knows a rename is real, they edit the private manifest to put the before and after paths under the same existing opaque ID. PDFFence can then structurally compare the pair while the report still excludes both paths.

## Bound the scan

The scanner is capped at 100,000 tree entries; the generated manifest retains the 4,096-document and 256 KiB limits. It rejects every symbolic link in a scanned tree rather than following or skipping it, rejects PDF-named non-regular entries and invalid path forms, and detects repeated directory identities. Non-PDF files are ignored.

These rules create a safe local starting point, not a claim that a directory crawl found every business document or that a folder is trustworthy.

## Full-corpus evidence

PDFFence 1.26 passed 273 tests, Ruff, and bytecode compilation. The tests cover deterministic pairing, strict round-tripping, private-path error redaction, force behavior, links, invalid names, and scan/document/manifest limits.

A fresh two-tree projection of all 161 [PDFCAB 1.24.1](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.24.1) pairs also went through `batch-init`. It generated 161 entries, and the resulting batch report recorded 161 changed documents with no policy findings. Every generator-routed public report exactly matched its standalone `pdffence diff --format json` output.

The release builds reproducibly with a fixed timestamp, passes Twine checks, and has passed clean Python 3.12/3.13 installs. The published GitHub wheel was re-downloaded, checksum-verified, installed through its public URL, and used to repeat the 161-entry workflow. A clean dependency audit found no known vulnerabilities.

This is structural review tooling, not a visual comparison, conformance validator, malware sandbox, signature validator, or directory-completeness claim. It does not render a page, run an action, follow a URI, extract text, decrypt a source, or decide whether a signature is valid, trusted, authorized, or safe.

Read the canonical [PDFFence 1.26 release note](https://sybilgambleyyu.github.io/posts/pdffence-126.html) for the manifest contract, threat model, validation record, and release links.
