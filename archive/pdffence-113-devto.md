---
title: A PDF action can keep its type and still change behavior
published: true
description: PDFFence 1.13 detects selected PDF action behavior-field rewrites while preserving generic, privacy-safe CI output.
tags: pdf, security, opensource, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/pdffence-113.html
---

# A PDF action can keep its type and still change behavior

A PDF review can correctly say that an action is still a URI, sound, form, or
RichMedia action and still miss what that action will ask a viewer to do. The
subtype is only one piece of stored behavior. A same-type rewrite can change a
destination selector, coordinate-appending flag, selected field set,
transition, command, or another behavior-bearing member while a public action
count stays fixed.

[PDFFence 1.13.0](https://github.com/SybilGambleyyu/pdffence/releases/tag/v1.13.0)
adds a bounded private comparison of selected standard action fields. It turns
those same-inventory rewrites into the generic
`active_content_payload_changed` result and the existing `PFP001` policy
finding, without placing an action value or digest in normal CI output.

## Count the type; retain the behavior

The release covers direct document-open `Thread`, `URI`, `Sound`, `Movie`,
`Hide`, `Named`, `SubmitForm`, `ResetForm`, `Rendition`, `Trans`, and
`RichMediaExecute` actions. The selected fields include the Thread destination,
URI `IsMap` flag, sound stream, movie and Hide selectors, named viewer command,
form character set and fields, rendition JavaScript fallback, transition
dictionary, and RichMedia command.

This is a static boundary, not a viewer-behavior claim. PDFFence does not
render a PDF, execute an action, follow a URI, open an attachment, or predict
whether a viewer permits a command. It records a stored difference that
deserves review.

## Raw evidence without decoding a payload

Top-level JavaScript and Sound streams are compared as raw stored bytes plus
bounded raw `Filter` and `DecodeParms` representation. PDFFence does not call a
payload decoder to obtain that evidence. Nested streams remain outside this
behavior-field coverage.

JSON, Markdown, and SARIF reports remain generic: no script, URI, command,
field name, stream bytes, or private fingerprint is emitted. The tagged
[policy reference](https://github.com/SybilGambleyyu/pdffence/blob/v1.13.0/docs/policy.md)
and [threat model](https://github.com/SybilGambleyyu/pdffence/blob/v1.13.0/docs/threat-model.md)
define the exact scope.

## Make the claim scoreable

The companion [PDF Change Assurance Benchmark
1.13.0](https://github.com/SybilGambleyyu/pdf-change-benchmark/releases/tag/v1.13.0)
contains 128 deterministic paired PDFs. Eleven new pairs keep action type and
public inventory fixed while changing exactly one selected behavior field.
PDFFence 1.13.0 passes all 128 through its public CLI; the held 1.12.0 source
candidate passes the earlier 117 and misses exactly the eleven new rewrites.

The release passed 196 tests, Ruff, reproducible wheel/source-archive builds,
Twine metadata checks, and fresh Python 3.12/3.13 installations. Each clean
install verified and scored the full 128-pair benchmark.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/pdffence/releases/download/v1.13.0/pdffence-1.13.0-py3-none-any.whl

pdffence init pdffence.yml
pdffence check before.pdf after.pdf --policy pdffence.yml --format sarif
~~~

Read the canonical [PDFFence 1.13 release note](https://sybilgambleyyu.github.io/posts/pdffence-113.html)
for the validation record and the boundaries this static review gate does not
claim to cross.
