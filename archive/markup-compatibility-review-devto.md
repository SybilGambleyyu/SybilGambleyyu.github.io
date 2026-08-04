---
title: A compatibility branch is a review boundary—not a rendering claim
published: true
description: DocFence 0.35 and DCAB 0.25 make stored OOXML Markup Compatibility choice requirements reviewable without selecting a branch or exposing branch material.
tags: word, ooxml, security, productivity
canonical_url: https://sybilgambleyyu.github.io/posts/markup-compatibility-review.html
---

# A compatibility branch is a review boundary—not a rendering claim

OOXML Markup Compatibility and Extensibility (MCE) can retain an alternative in
a Word package even when ordinary visible text is unchanged. A changed Choice
requirement is meaningful stored review evidence, but it is not proof of which
branch a particular client will select or render.

[DocFence 0.35.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.35.0)
records that narrow boundary without copying branch material into CI output.
[DCAB 0.25.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.25.0)
adds a deterministic, target-free pair that changes only a Choice requirement.
Neither release resolves a prefix, selects a branch, targets an Office version,
preprocesses or saves a package, opens Word, or makes a rendering claim.

## Selection belongs to the consumer

Microsoft's [Markup Compatibility introduction](https://learn.microsoft.com/en-us/office/open-xml/general/introduction-to-markup-compatibility)
describes AlternateContent as alternatives chosen by a consumer according to
its supported features and processing settings. Its preprocessing model can
select and remove branches before a package is saved.

~~~text
word/document.xml
  mc:AlternateContent
    mc:Choice Requires="private feature prefix"
      stable stored branch
    mc:Fallback
      stable stored fallback
~~~

That is why static review should preserve the evidence of a stored rewrite
without claiming to reproduce consumer behavior.

## Aggregate evidence, not a branch side channel

DocFence scans stored non-relationship Word XML members using the standard MCE
namespace. Its public report contains only aggregate part, AlternateContent,
Choice, Fallback, and compatibility-rule token counts. The recognized
structure remains in a private digest, so an equal-count rewrite becomes
markup_compatibility_inventory_changed without exposing branch bodies,
feature-prefix values, qualified names, paths, or fingerprints.

~~~yaml
rules:
  require_no_markup_compatibility: true
  no_markup_compatibility_changes: true
~~~

The first is a candidate-state gate for a clean handoff. The second protects an
approved baseline that intentionally retains stored MCE markup. The resulting
findings are DFP082 and DFP083; neither validates MCE conformance or selects a
branch.

## A deterministic, target-free pair

DCAB's thirty-sixth pair is
review.markup_compatibility_choice_requirement_changed. Both packages retain
one AlternateContent, one Choice, one Fallback, the same package-member set,
and the same stored Word text. Only the private Choice requirement changes, so
word/document.xml is the sole changed package member.

The public truth names only the fact category. It excludes feature-prefix
values, branch bodies, qualified names, compatibility-rule values, paths, and
fingerprints. The verifier regenerates the package pair and validates the
stored-member/text invariants without invoking Word or preprocessing either
package.

## Evidence and use

DocFence 0.35 profiles the public Open XML SDK Strict Word
[2D Column-O12-Word-Charts.docx](https://github.com/dotnet/Open-XML-SDK/blob/main/test/DocumentFormat.OpenXml.Tests.Assets/assets/TestDataStorage/O14ISOStrict/Graphics/2D%20Column-O12-Word-Charts.docx)
at nine MCE-bearing Word XML parts, three AlternateContent nodes, three Choice
nodes, three Fallback nodes, three requirement prefixes, and eight Ignorable
prefixes. That is stored-package evidence, not a client compatibility verdict.

Both hosted CI runs passed; fresh wheel and source-distribution installs
validate the 36-case corpus, and independently installed DocFence 0.35 plus
DCAB 0.25 strictly score 36/36 cases. The
[Hugging Face mirror](https://huggingface.co/datasets/SybilGambleyyu/document-change-assurance-benchmark)
was atomically synchronized with the new fixture and documentation.

~~~bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.35.0/docfence-0.35.0-py3-none-any.whl
python -m pip install https://github.com/SybilGambleyyu/document-change-benchmark/releases/download/v0.25.0/document_change_benchmark-0.25.0-py3-none-any.whl

docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
dcab validate
~~~

The [canonical release note](https://sybilgambleyyu.github.io/posts/markup-compatibility-review.html)
has the full policy, threat-model, validation, source, and reproducibility
links. A compatibility branch is stored evidence worth reviewing when policy
says it is—not a rendering claim.
