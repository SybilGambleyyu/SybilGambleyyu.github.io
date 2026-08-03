# A benchmark for reviewing PowerPoint changes, not just rendering them

A slide can look unchanged while its stored behavior changes. A DrawingML
click, hover, or mouse-over declaration can point somewhere new; a
macro-category action can be retargeted while its public count remains the
same; opaque macro or embedded-object bytes can change without a visible text
edit. Those are review surfaces, but a tool’s claim to notice them has been
difficult to compare or reproduce.

[Presentation Change Assurance Benchmark (PCAB)](https://github.com/SybilGambleyyu/presentation-change-benchmark)
is a narrow, reproducible answer. Its 0.1.0 release supplies twelve
deterministic baseline/candidate PresentationML pairs, public target-free truth
manifests, a structural validator, a portable observation protocol, and a
scorer. It evaluates a static presentation-review gate—not slide generation,
visual comparison, or runtime behavior.

## One stored boundary at a time

Every PCAB pair preserves visible DrawingML text and changes exactly one ZIP
member. The cases cover external hyperlink retargeting; macro, program,
external-file, external-presentation, OLE-verb, media, internal-navigation,
and reserved actions; a missing action relationship; opaque VBA-project bytes;
and opaque embedded-object bytes.

The targets use reserved `example.invalid` endpoints. The macro and embedded
members are deliberately inert marker bytes, not executable samples. The source
generator and `pcab validate` prove archive integrity, deterministic bytes, the
one-member package boundary, stable visible text, and bounded action/relationship
shape. Public truth excludes action strings, relationship IDs and targets,
macro names, slide text, payload bytes, and payload digests.

## A score that stays honest about scope

Tools can keep their own reports. An adapter emits a small normalized document
with cases it analyzed, exact public facts it found, and an optional `allow`,
`review`, or `block` reference disposition. Unsupported and errored cases are
explicit. PCAB reports expected-fact recall, analysis coverage,
reference-policy agreement, and complete cases.

The oracle is deliberately targeted, not exhaustive. An observation outside a
case’s declared fact remains visible as unrecognized evidence; PCAB does not
call it a false positive or manufacture a precision metric from a partial
oracle.

An optional [SlideFence 0.2.0](https://github.com/SybilGambleyyu/slidefence/releases/tag/v0.2.0)
adapter invokes its public JSON CLI and accepts a PCAB fact only when safe native
inventories and a change category exactly match the pair. It completes all 12
PCAB 0.1.0 cases with matching reference dispositions. That is an integration
result, not a requirement to use SlideFence or a claim that a declaration runs.

## Static means static

PCAB does not open PowerPoint, render a slide, resolve or fetch a relationship,
execute VBA, activate OLE, play media, parse opaque payload formats, verify
signatures, or infer a client, policy, security, or runtime outcome. It records
stored package state only.

```bash
python -m pip install \
  https://github.com/SybilGambleyyu/presentation-change-benchmark/releases/download/v0.1.0/presentation_change_benchmark-0.1.0-py3-none-any.whl

pcab validate
pcab observation-template --output observations.json
pcab score --observations observations.json --output score.json
```

PCAB 0.1.0 has a hosted Python 3.11–3.13 matrix, fresh wheel and
source-distribution checks, released-wheel verification, and a separate
SlideFence integration job. The fixture corpus is also mirrored as a public
[Hugging Face dataset](https://huggingface.co/datasets/SybilGambleyyu/presentation-change-assurance-benchmark).
The canonical note, release, and protocol are at
https://sybilgambleyyu.github.io/posts/presentation-change-assurance-benchmark.html.
