# A task pane can be enabled without changing Word text

A Word document can carry Office Add-in configuration in package parts that a
text diff never sees. One stored property can change from <code>false</code>
to <code>true</code> while every <code>w:t</code> node remains the same. That
is static review evidence, not proof that an add-in is installed, trusted, or
will run.

[Document Change Assurance Benchmark 0.10.0](https://github.com/SybilGambleyyu/document-change-benchmark/releases/tag/v0.10.0)
adds its twenty-first deterministic paired package:
<code>interaction.taskpane_auto_show_setting_enabled</code>. Both packages
retain their members, Word text, content types, internal relationship chain,
task-pane declaration, web-extension reference shape, and property name. Only
<code>word/webextensions/webextension1.xml</code> changes: the stored
<code>Office.AutoShowTaskpaneWithDocument</code> value moves from
<code>false</code> to <code>true</code>.

## A stored configuration, not an installed add-in

Microsoft’s [Office web-extension XML specification](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-owexml/29f59f30-b835-461a-bd8a-ca400a7bc717)
describes document-borne structures for Office Add-ins. Its [task-pane
auto-open guidance](https://learn.microsoft.com/en-us/office/dev/add-ins/develop/automatically-open-a-task-pane-with-a-document)
specifies the <code>webextension</code>/<code>taskpane</code> parts and this
property.

That guidance also makes the limit clear: the setting is ignored if the add-in
is not already installed and, as of March 2, 2026, auto-open is supported only
for centrally deployed or sideloaded add-ins. DCAB provides only a syntactic,
internally linked package pair. It supplies no manifest and does not retrieve,
install, authenticate, execute, or assert the opening of an add-in task pane.

## One property, a complete internal topology

The pair retains the main-document-to-taskpane relationship, one invisible and
unlocked task pane, the taskpane-to-webextension relationship, fixed synthetic
IDs, an <code>EXCatalog</code> reference shape, one property, no bindings, and
an empty snapshot. The independent verifier checks those parts and
relationships, deterministic bytes, stable members, unchanged Word text, and
the one-member boundary.

Standard <code>python-docx</code> opens all 40 <code>.docx</code> fixtures and
its lower-level OPC reader opens all 42 packages. The optional local
[DocFence 0.27.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.27.0)
adapter reports aggregate <code>taskpane_web_extension_inventory_changed</code>
evidence: all structural counts stay fixed while only the auto-show setting
count moves from 0 to 1. It uses counts and private local signatures, not raw
IDs, store data, or property values.

DCAB 0.10.0 retains fixture schema version 1 and extends the corpus from 20 to
21 cases. It publishes a narrow static-review fact, not a deployment, identity,
trust, client-behavior, or security-policy claim.

The source, generated corpus, and verifier are MIT-licensed on
[GitHub](https://github.com/SybilGambleyyu/document-change-benchmark). Read the
[canonical release note](https://sybilgambleyyu.github.io/posts/document-taskpane-review.html)
for the full boundary and install command.
