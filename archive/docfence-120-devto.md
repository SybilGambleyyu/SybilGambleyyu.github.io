# A Word file can carry a signature without proving trust

A signed Word file is not a yes-or-no security fact. An Office Open XML package
can carry an OPC signature origin, XML Signature parts, optional certificate
parts, and inline certificate data—yet whether a signature is valid or
trustworthy depends on cryptographic validation, certificate and policy
evaluation, and the consuming application. A review gate first needs a
narrower, reliable question: did the package’s stored signature material
change?

[DocFence 0.12.0](https://github.com/SybilGambleyyu/docfence/releases/tag/v0.12.0)
makes that package state review-visible without treating a signature as a trust
verdict. It emits bounded aggregate evidence for a handoff or baseline policy,
while retaining the actual signature material only in a local comparison digest.

## What a Word package can retain

The [Open Packaging Conventions](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/opc/open-packaging-conventions-overview)
define package signatures as package components: an origin points to XML
Signature parts, which may reference certificate parts and contain inline X.509
material. The package consumer is responsible for deciding what a signer or
certificate means. A recognizable signature is therefore not, by itself, a
locally valid, trusted, current, or sufficiently covering signature.

Public [research on OOXML signature security](https://www.usenix.org/conference/usenixsecurity23/presentation/rohlmann)
also makes the boundary important: “signed” is not a substitute for knowing
the exact validation and trust model. DocFence never turns stored presence into
a passing security claim.

## Counts in reports; signature material stays private

Profile JSON, Markdown, and SARIF expose only origin, XML-signature, and
certificate-part counts, plus SignedInfo reference, manifest-reference,
relationship-reference, inline-X.509-certificate, and signature-property
counts. They do not print signature values, signer or certificate material,
algorithms, signing times, comments, provider data, reference URIs,
relationship IDs, package paths, or fingerprints.

The full recognized inventory is privately fingerprinted so a same-count
mutation to signature XML or certificate bytes still changes a protected
baseline. Re-signing deliberately changes stored signature material; DocFence
does not normalize that away.

## Two policy choices

For an external handoff that must carry no stored package-signature material:

```yaml
rules:
  require_no_package_digital_signatures: true
```

This produces ``DFP037``. It fails for any nonzero signature inventory count,
including an otherwise empty recognized signature origin. For a controlled
workflow where an approved package is expected to retain signature material:

```yaml
rules:
  no_package_digital_signature_changes: true
```

``DFP038`` detects a private-inventory change from the approved baseline. Neither
rule validates a signature or declares an author trustworthy.

## Strict discovery, intentionally limited scope

DocFence recognizes an origin through the conventional path, exact OPC content
type, or standard root origin relationship. It constrains recognized signature
and certificate relationships to expected sources, internal stored targets, and
exact content types, including correctly declared content-type defaults. It
allows only one origin and root origin relationship, checks bounded XMLDSIG
structure, and fails closed on malformed recognized topology or shape.

This is stored-package evidence, not cryptographic verification. DocFence does
not validate a signature or referenced digest; build a certificate chain; check
revocation, timestamps, signer identity, coverage, policy, or algorithm
suitability; or reproduce Microsoft Office’s trust decision.

## Release evidence

The 0.12 suite has 33 tests covering same-count signature and certificate
mutations, redaction across report formats, policy/SARIF behavior, discovery
modes, malformed XMLDSIG structure, invalid targets and content types, and
relationship semantics. It passed Python 3.11/3.13 CI, Ruff, and compilation
checks. Its wheel and source archive were independently rebuilt from the
release commit and matched byte-for-byte.

An installed wheel profiled a
[public signed-package fixture](https://github.com/RUB-NDS/OOXML_Signature_Security/blob/main/PoC_OOXML_Signature_Attacks/Microsoft_Office/Windows/5-1_CIA/01_document_signed_by_trusted_entity.docx)
without exposing signature data: one origin, one XML Signature, three
SignedInfo references, eight manifest references, six relationship references,
one inline X.509 certificate, and two signature properties. Ordinary Open XML
SDK Word document and template fixtures reported zero signature counts.

```bash
python -m pip install https://github.com/SybilGambleyyu/docfence/releases/download/v0.12.0/docfence-0.12.0-py3-none-any.whl

docfence profile candidate.docx --format markdown
docfence check approved.docx candidate.docx --policy docfence.yml --format sarif --output docfence.sarif
```

The [canonical release note](https://sybilgambleyyu.github.io/posts/docfence-120.html)
has the detailed evidence, source links, policy reference, and threat-model
links.
