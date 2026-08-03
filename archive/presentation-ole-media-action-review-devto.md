# PowerPoint’s OLE and media actions should not be an unknown bucket

Not every important PowerPoint interaction is a macro, program launch, or
external-file link. A stored action can also ask an OLE object to perform a
verb or invoke a media action. Those are distinct review surfaces, and a
generic “other reserved action” bucket is not enough when a baseline changes.

[Microsoft’s action-button guidance](https://support.microsoft.com/en-us/powerpoint/add-commands-to-your-presentation-with-action-buttons)
describes object actions for OLE objects and media-related actions alongside
navigation, links, programs, and macros. The bounded claim is only that the
declaration is stored presentation state worth review—not that an object will
activate or media will play.

## A transparent refinement

[SlideFence 0.1.0](https://github.com/SybilGambleyyu/slidefence/releases/tag/v0.1.0)
kept unknown reserved actions visible in a safe aggregate bucket. While
validating a public macro-enabled `python-pptx` action-properties fixture, that
bucket contained one `ppaction://ole?verb=…` declaration and one
`ppaction://media` declaration.

[SlideFence 0.2.0](https://github.com/SybilGambleyyu/slidefence/releases/tag/v0.2.0)
promotes them to exact redacted categories: `ole_verb_action_count` and
`media_action_count`. Its public fixture has 15 stored actions and now reports
one each for macro, program, external file, external presentation, OLE verb,
and media, with no generic reserved-action remainder. The public output never
includes raw action strings, OLE verbs, targets, URLs, relationship IDs, shape
IDs, slide text, or payload bytes.

## Readable policy gates

```yaml
version: 1
rules:
  require_no_presentation_ole_verb_actions: true
  require_no_presentation_media_actions: true
  no_presentation_interaction_changes: true
```

The OLE-verb gate is critical; the media gate is high severity. Neither is a
runtime verdict. SlideFence does not open PowerPoint, render a deck, follow a
relationship, invoke a program, execute VBA, activate an OLE object, play
media, authenticate a user, inspect client policy, or predict Trust Center
behavior.

SlideFence 0.2.0 has 15 synthetic adversarial regressions, a passing hosted
Python 3.11–3.13 matrix, package checks, fresh wheel/source-distribution
installs, and a remote-release asset verification against the public action
fixture. The full canonical note, validation record, and release links are at
https://sybilgambleyyu.github.io/posts/presentation-ole-media-action-review.html.
