# A PowerPoint action can change what it launches without changing visible text

A presentation can retain identical visible text, images, and layout while a
click or hover action changes what it names. That stored boundary deserves a
review signal that does not launch a program, invoke a macro, follow a link, or
send a confidential deck to a comparison service.

This is more urgent because PowerPoint's built-in Compare and Merge workflow is
being retired from the Microsoft 365 Windows app beginning with version 2502;
Microsoft also notes that it is unavailable in current Mac and web versions.
The [Microsoft comparison guidance](https://support.microsoft.com/en-us/powerpoint/track-changes-in-your-presentation)
documents both the workflow and retirement.

## A stored action is not visible text

PresentationML can store DrawingML `a:hlinkClick`, `a:hlinkHover`, and
`a:hlinkMouseOver` declarations separately from a slide's visible content.
They can bind to an OOXML relationship rather than placing a destination in
text. PowerPoint's documented action vocabulary includes external-file and
external-presentation links, program launch, and macro invocation; see
Microsoft's [OOXML interoperability note](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/7ff3db24-b7b9-4ffe-aa78-3ec47cab2489)
and [relationship-bound hyperlink example](https://learn.microsoft.com/en-us/office/open-xml/presentation/how-to-get-all-the-external-hyperlinks-in-a-presentation).

That makes the review question more precise: not just “what text changed?” but
“what stored interaction declaration changed?”

## A privacy-safe static review boundary

[SlideFence 0.1.0](https://github.com/SybilGambleyyu/slidefence/releases/tag/v0.1.0)
is a local-only, non-executing CLI for supported PowerPoint OOXML packages. It
profiles and diffs action declarations, relationship bindings, package-wide
external relationship classes, VBA-project presence, and embedded
OLE/package/control evidence.

Its public output contains only counts and fixed categories. Raw action
strings, macro names, program commands, URLs, file paths, relationship IDs,
shape identifiers, slide text, notes, and embedded bytes remain out of public
reports. Their private stored state contributes only to an in-memory digest, so
a target or assignment rewrite remains observable even when public counts stay
the same.

## What it does not establish

A stored declaration is not proof that a macro exists, resolves, is enabled,
runs, opens a target, or produces a result. SlideFence does not open PowerPoint,
render a deck, follow a relationship, execute VBA, load an OLE object,
authenticate a user, inspect endpoint policy, or predict Trust Center behavior.

SlideFence 0.1.0 has 12 synthetic adversarial regressions, a passing hosted
Python 3.11–3.13 matrix, package checks, and fresh wheel/source-distribution
installs against public `python-pptx` fixtures. The full canonical note,
commands, fixture hashes, and validation details are at
https://sybilgambleyyu.github.io/posts/presentation-action-review.html.
