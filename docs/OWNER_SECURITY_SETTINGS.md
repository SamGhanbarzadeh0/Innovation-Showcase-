# Owner-only GitHub settings checklist

These controls are **not activated by this Markdown file**. They require a repository administrator in the GitHub web interface. The GitHub connector used for the Stage 07 source changes cannot modify these settings, even though it can create and merge source-code pull requests.

## A. Protect the default branch: Innovation-Showcase-

1. Open [repository Rulesets settings](https://github.com/hesamghd/Innovation-Showcase-/settings/rules).
2. Choose **New ruleset → New branch ruleset**; give it a clear name such as `Protect main and require CI`.
3. Target only `main` and set enforcement to **Active** after confirming that the new workflows have passed on the Stage 07 PR.
4. Disallow branch deletion and force pushes. Require updates to reach `main` through a pull request.
5. Require these **exact check names**: `Verify source archive and project links` and `R2024a numerical and matched-comparison audit`. Check GitHub's status-check selector for the actual names rather than inventing a similarly named requirement.
6. For this sole-maintainer repository, **do not require one or more external review approvals** unless a separate, available reviewer has agreed to review. A PR requirement with zero required approving reviews can still enforce auditability and CI. Add required reviews later if an appropriate collaborator joins.
7. Prefer no bypass actors for ordinary commits and disable force push overrides where the interface permits it. Check that routine documented PR merges still work before considering the ruleset operational.

The MATLAB check is present on every PR under the revised workflow, including documentation-only changes. It executes MATLAB R2024a when source `.m`, the original-object manifest or its own workflow changes. The repository-structure check is always evaluated and validates source provenance, links and workflow safety.

## B. Protect Machine_Learning

Open [its repository Rulesets settings](https://github.com/hesamghd/Machine_Learning/settings/rules). Apply equivalent protection for `main`: disallow deletion and force pushes, and require pull requests with an achievable approval count. **Do not require a non-existent CI job**. That repository currently has no executable model and no workflow.

## C. Set account and repository security defaults

In each repository's **Settings → Actions → General**, review allowed actions and default workflow permissions. The repository should use **read-only** as the default token permission. The MATLAB workflow needs third-party `matlab-actions`, so a setting permitting *only* GitHub-authored actions would break the verified pipeline. Use an appropriate allowlist if your GitHub account offers one; keep the in-repository action references pinned.

In the **Settings → Security & analysis / Security and quality** area, inspect the dependency graph, Dependabot alerts, security updates, secret-scanning alerts, push protection and private vulnerability reporting. Enable useful options supported for the public repository; confirm their effective status in the UI. Do not infer that a clean-looking source tree is the same as a finished security scan.

Review personal [GitHub authentication](https://github.com/settings/security), [authorized applications](https://github.com/settings/applications) and access tokens in the account's security pages. Confirm MFA or passkeys, recovery access and active app permissions yourself. **Do not paste recovery codes, secrets or tokens into a chat, issue or repository file.**

## D. Acceptance evidence

Once the rulesets are applied, check that both repository **Rulesets** pages show an **Active** rule targeting `main`. Also verify that a deliberately unmerged pull request displays the correct required checks and that a direct change to `main` would not bypass them. Use GitHub's standard controls for the test; do not force-push or delete a branch to prove protection.

The completion record can then note: ruleset name, target branch, required checks (if any), enforcement status and date. The Stage 07 source changes are independently verifiable; the settings above cannot be reported as enabled until those checks are observed in GitHub.
