# Stage 07 — GitHub security and automation review

**Review date:** 20 November 2026  
**Repositories:** `hesamghd/Innovation-Showcase-` and `hesamghd/Machine_Learning`  
**Code baseline:** `Innovation-Showcase-` at `1c11affcbf2ce027c6f2df39e1cf5d771a187df3`. MATLAB algorithm files, original snapshots, binary assets and benchmark CSVs are unchanged.

## Verified repository observations

Both repositories are public, user-owned, and have `main` as the default branch. The GitHub branch API returned `protected: false` for each, and the rulesets collection returned an empty array for each repository. Consequently, **neither repository currently has an enforced main-branch ruleset** at the start of this review.

The connector identifies repository-admin-level permissions for the authenticated user, but GitHub App management permissions are narrower: reads of the branch-protection administration endpoint returned `403 Resource not accessible by integration`. The current GitHub Actions settings, secret/Dependabot alert status, account MFA and private vulnerability reporting settings were also not readable through this connection. Their status must not be invented.

At baseline, `Innovation-Showcase-` contained two workflows. Both already declared `contents: read` at workflow scope. The MATLAB workflow used major-version tags for `checkout`, `setup-matlab`, `run-command` and `upload-artifact`; the structure workflow used `checkout@v7`. The MATLAB workflow ran only when paths matched, which meant that a documentation-only PR did not receive a stable MATLAB check name. This is incompatible with requiring the same MATLAB check on every pull request in a ruleset.

`Machine_Learning` has no executable model, package manifest or GitHub Actions workflow. No CI job or fabricated model dependency is introduced as a substitute for a real application.

## Changes applied in this stage

1. **Immutable action references.** Every workflow action is pinned to a complete 40-character Git commit SHA, verified against the relevant upstream `v7`, `v4` or `v3` tag reference on 20 November 2026. Upgrading a pinned SHA requires a reviewable change rather than silent movement of a major-version tag.
2. **Least-privilege execution.** Both workflows explicitly grant `contents: read`. Checkout uses `persist-credentials: false`; there is no `pull_request_target`, privileged user-text evaluation or secret injection.
3. **Stable PR validation.** The MATLAB job now runs on every pull request to `main`. A small, fail-closed diff check determines whether `.m`, the original-source manifest or the MATLAB workflow itself changed. If not, the job succeeds without installing MATLAB. A relevant source change triggers the existing R2024a numerical and matched-comparison suite, and its artifacts are still uploaded when that execution fails.
4. **Limited runner usage.** Source-changing pushes to `main` still trigger MATLAB; documentation-only pushes do not. A concurrency group cancels obsolete runs for the same PR.
5. **Automated configuration checks.** `tools/check_workflow_security.py` checks action pin syntax, read-only token declarations, checkout credential persistence, disallowed privileged trigger patterns and the stable MATLAB PR scope. It runs alongside the existing repository-integrity checks.
6. **Dependency review.** Dependabot is configured to propose updates to GitHub Actions monthly, capped at three open PRs. No generic Python package manifest or MATLAB dependency file is invented.
7. **Disclosure guidance.** `.github/SECURITY.md` distinguishes private security reporting from ordinary numerical correctness issues and avoids unsupported support guarantees.

The pinned upstream GitHub action commits in this review are:
- `actions/checkout` v7: `3d3c42e5aac5ba805825da76410c181273ba90b1`
- `actions/upload-artifact` v4: `ea165f8d65b6e75b540449e92b4886f43607fa02`
- `matlab-actions/setup-matlab` v3: `f9e43010f1ae678f7cfa0542fe2a4f60f7d1ad8d`
- `matlab-actions/run-command` v3: `bfa857648f4895aa98a446fe41c85e0788421ed5`

These SHAs identify the action source at the time checked; they do not eliminate all upstream or runtime supply-chain risk.

## Owner action: protect main

The connected app cannot create or edit enforced rulesets. The owner must use GitHub's **Settings → Rules → Rulesets** in each repository. Rulesets are supported for public user-owned repositories, including GitHub Free. A suitable conservative setup is documented in [OWNER_SECURITY_SETTINGS.md](OWNER_SECURITY_SETTINGS.md).

For `Innovation-Showcase-`, the target should be `main`, with deletion and force-push restrictions, PR-based merging and **two required checks**:
- `Verify source archive and project links`
- `R2024a numerical and matched-comparison audit`

The second check is always present for a PR after this change but runs the expensive MATLAB suite only for relevant source changes. The rule should be enabled **after both workflows are verified on the new commit**. If a check name is not offered or a rule would prevent the sole maintainer from merging, investigate its GitHub UI settings before enabling enforcement.

For `Machine_Learning`, require PR-based merging and prohibit force pushes and deletion; do not require an imaginary CI check. When a model is eventually added, test and review requirements should be reconsidered.

## Other settings requiring owner confirmation

- **Actions settings:** set default `GITHUB_TOKEN` permissions to read-only and review whether fork PR workflows require approval; the YAML-level setting is verified, but the account/repository toggle is not.
- **Security settings:** examine the dependency graph, Dependabot alerts, secret-scanning alerts, push protection and private vulnerability reporting. Absence of a reported alert is not proof that a complete secret scan occurred.
- **Account security:** review MFA/passkeys, authorized GitHub Apps, active sessions and recovery methods directly in account settings. None was inspected through this repository connector.
- **Collaborator access:** review external access and remove permissions no longer required. The connection's repository-scoped metadata cannot certify the full set of account authorizations.

No source-code deletion, historical rewrite, PDF modification, credential exposure or unapproved change to GitHub account settings is performed by this review.

## Acceptance

The two GitHub Actions checks must pass on the Stage 07 pull request and, after merging, on the resulting `main` commit. In particular, the MATLAB job must run on its own workflow change and upload its usual diagnostic output. The completed PR must contain no changes to `.m` files, protected MATLAB snapshots, reference PDFs or benchmark data.

The code-level hardening can be considered complete after that evidence is recorded. **Administrative branch protection cannot be marked complete until the owner enables and verifies the rulesets in GitHub settings.** No document or CI run can substitute for that enforcement.
