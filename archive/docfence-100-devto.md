# A Word document can carry a task graph—and an add-in

A clean paragraph count and a clean comment count do not necessarily mean a
Word file is free of workflow state. A modern comment can become an assigned
task; the package can retain task history, users, titles, dates, progress, and
comment anchors in a separate OOXML part. It can also retain configuration for
an Office task pane and the content controls associated with it.

[DocFence 0.10.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.10.0)
makes both surfaces review-visible as bounded, private evidence. It reports
aggregate counts useful to a CI gate, while task and add-in material remains
inside local SHA-256 comparison signatures.

## Two stored surfaces outside document prose

Microsoft's [modern-comments guidance](https://support.microsoft.com/en-us/word/using-modern-comments-in-word)
describes assigning a comment as a task. The corresponding
[document-task OOXML contract](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-otaskxml/652d0608-31b8-4e90-a83a-98d6957b7fed)
stores tasks, histories, attribution, assignments, schedules, progress,
priority, deletion, and undo events. That is useful workflow data, but it is a
separate handoff surface from comment text.

Office add-ins have their own package representation. Microsoft's
[web-extension OOXML contract](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-owexml/29f59f30-b835-461a-bd8a-ca400a7bc717)
defines stored extension references, properties, bindings, and task panes.
Word's [removable-document-information model](https://learn.microsoft.com/en-us/javascript/api/word/word.removedocinfotype?view=word-js-preview)
lists both document tasks and task-pane web extensions. A file can therefore
carry a workflow boundary that is neither visible prose nor an external link.

## Counts in reports, private comparisons underneath

DocFence profiles document-task parts as aggregate task, history-event,
user-reference, comment-anchor, and event-category counts. It never prints task
IDs, event IDs, user IDs or names, titles, dates, priority, progress, or comment
IDs. A same-count rewrite still changes the private inventory, so a baseline gate
can notice it without turning CI output into a copy of task data.

The task-pane inventory similarly reports only aggregate task-pane,
visible/locked-pane, web-extension-part, store-reference, property, binding,
enabled auto-show-property, and Word content-control marker counts. Extension
IDs, stores, property names and values, binding references, pane layout values,
marker values, relationship IDs, and package paths stay private. Relationship-ID
renumbering alone remains quiet because DocFence compares normalized relationship
semantics instead of transient IDs.

## Choose a clean handoff or a protected baseline

For a publishing or clean-handoff boundary, reject either retained surface:

```yaml
rules:
  require_no_document_tasks: true
  require_no_taskpane_web_extensions: true
```

These produce `DFP031` and `DFP033`. For a controlled template that intentionally
contains approved workflow or add-in configuration, freeze the baseline instead:

```yaml
rules:
  no_document_task_changes: true
  no_taskpane_web_extension_changes: true
```

`DFP032` and `DFP034` then block a private-inventory mutation, even when public
counts match. The other DocFence inventories remain independent, so teams can
enforce the narrower rule they actually mean.

## Stored-state evidence, not Office automation

DocFence finds recognized parts through standard content types, relationship
types, and conventional Word paths. It validates document-task, task-pane, and
web-extension roots; a direct task-pane reference must resolve through the
expected internal relationship or parsing fails closed. It accepts both
`webextension` and `webextensionref` task-pane references. For a Word content
control, an enabled `w15:webExtensionCreated` marker takes precedence over
`w15:webExtensionLinked`.

This is deliberately stored-state evidence, not an add-in sandbox or a task
client. DocFence does not install, load, execute, authenticate to, fetch,
validate, or judge an add-in. It does not assign, complete, synchronize, or
notify on a task. An enabled `Office.AutoShowTaskpaneWithDocument` property is
counted as stored configuration only; it is not a claim that a particular Word
client will open a pane. Microsoft's [auto-open guidance](https://learn.microsoft.com/en-us/office/dev/add-ins/develop/automatically-open-a-task-pane-with-a-document)
explains why that distinction matters.

## Release evidence

The 0.10 regression suite covers semantic same-count mutations,
JSON/Markdown/SARIF redaction, policy findings, noncanonical and unlinked
conventional discovery, extensionless paths, both task-pane reference spellings,
marker precedence, malformed roots and references, external recognized
relationships, and relationship-ID churn. The final wheel was installed outside
its source tree and profiled against a package carrying both inventories. The
wheel and source archive were rebuilt from the release commit and matched
byte-for-byte.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.10.0/docfence-0.10.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The public release includes the wheel, source archive, and SHA-256 manifest.
Read the [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-100.html)
for precise rule semantics, evidence boundaries, and links to the policy
reference and threat model.
