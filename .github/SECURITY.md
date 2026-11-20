# Security policy

This repository contains educational MATLAB image- and signal-processing implementations, their tests and supporting documentation. It is not a hosted service, and it does not process sensitive patient data.

## Reporting a potential issue

Please avoid placing passwords, API tokens, private keys, unpublished data or actionable exploit details in a public issue. If GitHub's **private vulnerability reporting** option is enabled, use the repository's **Security** tab to submit a private report. Otherwise contact the maintainer through an existing private, verified channel. Do not assume a public GitHub issue is confidential.

For a report, provide the affected file and commit, MATLAB or operating-system version when relevant, minimal reproduction steps that contain no secrets, and the observed versus expected behavior. A numerical segmentation defect should be reported as a reproducibility or correctness issue unless it has an actual security impact.

The repository does not promise a fixed security-response deadline. A reported issue will be assessed against the affected source and the available verification environment. Sensitive data and exploit material should not be committed while preparing a fix.

## Version and dependency scope

The maintained branch is `main`; historical MATLAB snapshots under `tests/legacy_snapshot/` are retained for comparison and are **not maintained distributions**. GitHub Actions uses commit-pinned external actions. Dependabot opens proposed GitHub Actions dependency updates for review; such updates do not constitute automatic authorization to deploy or merge code.

The two reference PDFs are preserved historical files. Their redistribution rights remain a separate question from software vulnerability reporting.
