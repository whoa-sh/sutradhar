# Security Policy

## Supported Versions

Sutradhar follows active-line support for the current major release line and the current development line on `master`.

- Latest release line: supported for security fixes.
- `master` snapshot line: supported for pre-release hardening and remediation validation.
- End-of-life lines: not guaranteed to receive fixes.

## Reporting A Vulnerability

Report security issues privately to:

- `security@whoa.sh`

Do not file public GitHub issues for vulnerability reports.

When reporting, include:

1. A clear description of the issue and affected component(s).
2. Affected version(s) and package coordinates (Maven/npm, and tag if relevant).
3. Reproduction steps, including payload/contract examples where applicable.
4. Impact assessment (confidentiality, integrity, availability, tenant scope).
5. Any proposed mitigation or workaround.

## Triage And Response

Initial process expectations:

1. Acknowledge receipt of a valid report.
2. Reproduce and assess severity.
3. Define fix scope across contracts, generated SDK surfaces, and release workflows.
4. Prepare coordinated remediation and release notes.

Response timing depends on severity, exploitability, and release risk, but critical issues are prioritized immediately.

## Disclosure Policy

- Coordinated disclosure only.
- Public advisory is published after a fix is available (or compensating controls are documented).
- Reporters are credited where requested and appropriate.

## Scope Notes For This Repository

This repository is contract and SDK-surface focused. Security reports are especially relevant for:

- contract-level data classification and validation gaps,
- compatibility or versioning behaviors that can cause unsafe consumer behavior,
- release/publish workflow weaknesses,
- generated SDK helper surfaces that can cause unsafe defaults.

Service-runtime vulnerabilities outside this repository should still be reported to `security@whoa.sh` and will be routed appropriately.
