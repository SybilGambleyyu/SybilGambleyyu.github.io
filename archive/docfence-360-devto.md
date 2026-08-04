# When hidden is just a stored DrawingML declaration

A document diff can show that a drawing changed, yet fail to state the narrow
fact a reviewer needs: did a stored nonvisual declaration change from
explicitly shown to hidden? That is a useful handoff question. It is not a
claim about what Word or another client will render.

[DocFence 0.36.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.36.0)
adds a privacy-safe inventory for direct stored DrawingML nonvisual hidden
declarations in supported Word stories. It keeps the review signal local and
does not expose object metadata in reports.

## A direct marker, not a visibility engine

The Open XML SDK documents
[NonVisualDrawingProperties.Hidden](https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.drawing.nonvisualdrawingproperties.hidden?view=openxml-3.0.1)
as a state in which a DrawingML object can remain present but hidden; omission
is shown by default. DocFence recognizes only direct unqualified hidden
attributes on a fixed set of standard main, picture, WordprocessingDrawing,
and Word 2010 nonvisual-property elements in supported Word stories.

It canonicalizes true and 1 as hidden, false and 0 as explicitly shown, and
keeps invalid values as a separate review signal. It retains duplicate markers
and declarations in Markup Compatibility branches, but does not select a
branch, identify a rendered object, calculate effective visibility, lay out or
render DrawingML, or predict client behavior.

## Aggregate output with two usable gates

Reports expose only aggregate declaration/story counts and hidden, explicitly
shown, and invalid-value counts. Object names, descriptions, IDs, raw values,
story paths, and fingerprints stay private. Same-count hidden-to-shown rewrites
remain review-visible; metadata-only rewrites stay quiet.

~~~yaml
rules:
  require_no_hidden_drawing_objects: true
~~~

That candidate-state rule emits DFP084. A controlled template can instead
protect its baseline:

~~~yaml
rules:
  no_drawing_object_visibility_changes: true
~~~

DFP085 reports a material private inventory change. Neither gate says that a
client will actually hide or show an object.

## A paired static-review case

[DCAB 0.26.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.26.0)
adds its 37th paired synthetic WordprocessingML case for the same boundary. It
holds one compact inline DrawingML carrier, all package topology, and all stored
Word text stable while changing only wp:docPr hidden from false to true. The
pair is package and reader evidence, not a visual or runtime assertion.

The DocFence tag passed hosted CI, and fresh public release downloads matched
the rebuilt artifact hashes. An isolated installation validated all 37 DCAB
cases and reported the new visibility inventory transition.

The full contract, links to the policy and threat-model documentation, and
install instructions are in the
[canonical release note](https://sybilgambleyyu.github.io/posts/docfence-360.html).
