---
title: An action inventory needs an execution path too
published: true
description: PDFFence 1.16 prevents private action-shaped PDF data from manufacturing public active-content inventory evidence.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-116.html
---

# An action inventory needs an execution path too

An action count can look objective: count every PDF dictionary whose `/S` value
names an action. But a private application dictionary can have exactly that
shape without being executable. Its local shape does not establish that a
viewer can execute it.

[PDFFence 1.16.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.16.0)
now applies the same semantic-path requirement to its public action inventory
that version 1.15 introduced for behavior-field evidence.

## The remaining boundary leak

Version 1.15 correctly required a standard document path before treating action
payload fields as behavior. Its generic object inventory still counted every
reachable action-shaped dictionary and every `/AA` container, though. A private
value below `/PieceInfo` could therefore manufacture
`active_content_inventory_changed` even when it was not a document action.

That is a real review distinction. A reviewer should see that stored bytes or
the reachable-object count changed. They should not be told that active content
grew just because producer metadata resembles an action.

## Inventory follows a semantic owner

PDFFence now records action categories and additional-action-container counts
only after bounded traversal establishes a supported execution owner: catalog
actions, catalog JavaScript name-tree values, the actual catalog page tree and
its annotations, AcroForm fields and widgets, outline items, or page
presentation-step navigation nodes. A successor is included only through a
`/Next` chain that begins at one of those roots.

This is intentionally narrower than recursively interpreting every dictionary.
It follows the format's context-sensitive meaning: an action name is meaningful
because of its standard owner and route, not just a familiar key spelling. The
relevant structures are described in the [PDF 1.7 reference](https://opensource.adobe.com/dc-acrobat-sdk-docs/standards/pdfstandards/pdf/PDF32000_2008.pdf).

## Two controls that would otherwise look active

[PDF Change Assurance Benchmark
1.16.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.16.0)
adds two deterministic negative controls. One rewrites a private `PieceInfo`
action subtype while keeping object count fixed. The other adds a private `/AA`
container and action. Their expected results are `stored_pdf_bytes_changed`, or
`reachable_object_count_changed` plus `stored_pdf_bytes_changed`—never an
active-content inventory signal or `PFP001`.

PDFFence 1.16.0 scores all 152 benchmark pairs. The released 1.15.0 wheel
scores 150/152, adding an active-content inventory change to exactly the two
new private controls. Standard page additional-action and semantic action-chain
inventory cases remain covered.

PDFFence passed 227 tests and Ruff; PDFCAB passed 82 tests and Ruff. Two
fixed-timestamp builds of each package were byte-for-byte reproducible, passed
Twine metadata checks, and were exercised by clean Python 3.12/3.13 wheel
installs plus a clean Python 3.12 source-archive install.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.16.0/pdffence-1.16.0-py3-none-any.whl

pdffence init pdffence.yml
pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.16 release note](https://sybilgambleyyu.github.io/posts/pdffence-116.html)
for the exact static-review boundary and validation record.
