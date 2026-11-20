# Stage 05: repository structure and technical housekeeping

**Baseline:** `ddfd1b310303da5dccddf0c143224646af82cd01`, the tested `main` commit before this stage  
**Review date:** 20 November 2026  
**Scope:** working-tree hygiene, MATLAB path stability, generated-output separation and source provenance. No algorithm changes.

## Inventory and rationale

The baseline contains 14 preserved original MATLAB files under `tests/legacy_snapshot/`, working thresholding and signal scripts, two publication PDFs, and eight tracked `.DS_Store` files. The existing ignore file was predominantly a Python template despite the active project being MATLAB-based.

The Bradley, Wellner and local-mean directories each contain `PadArray.m` with Git blob `5bb635ebed1df875d96d403cf39a26ab42995c21`. The copies are identical. The final MATLAB harness adds these source directories to its path and temporarily resolves original functions from the historical snapshot. Relocating or deduplicating the helpers would change MATLAB resolution rules and require substantive code/test revisions. **The three working copies were deliberately retained.**

The original folder names, including spaces and chapter wording, remain intact. This preserves existing links, project provenance and interactive MATLAB demonstrations.

## Changes made

1. Replaced the unrelated Python-oriented root ignore template with concise MATLAB, macOS, editor and local-configuration rules. No blanket `.mat`, `.csv`, `.fig`, `.png` or `.pdf` exclusion was added.
2. Removed the eight tracked `.DS_Store` files from the current tree. They are Finder metadata, not source code; their original Git objects remain reachable in the baseline commit.
3. Added `docs/REPOSITORY_LAYOUT.md`, explaining project directories, duplicate helper functions and path conventions.
4. Added `docs/OUTPUT_POLICY.md`, describing temporary MATLAB outputs and requirements for curated scientific artifacts.
5. Added `tools/check_repository_layout.py`, a Python-standard-library check of all 14 preserved source Git SHAs, the identical working `PadArray.m` copies, the two original PDF hashes, required project files, locally linked documentation, and absence of tracked Finder/generated files.
6. Added a lightweight `repository-structure.yml` workflow for pull requests and `main` pushes. The MATLAB workflow is retained unchanged; source-free documentation housekeeping does not need to re-run expensive MATLAB computations.

## Explicitly unchanged

- All working MATLAB algorithms and tests, including Bradley's calibrated preset.
- Every archived historical MATLAB source and its recorded Git SHA.
- Both reference PDFs and their contents.
- Original repository history; no force-push or rewrite.
- Existing quantitative results and the previous successful R2024a run.

## Acceptance criteria

| Check | Expected result |
|---|---|
| Structure script | `PASS` in GitHub Actions on the PR head |
| Git diff | No added, deleted or modified `.m` files |
| Research binaries | Exactly the same two PDF Git blobs |
| Archived original source | All 14 expected Git SHAs verified |
| Current Finder files | Eight removed; none tracked |
| `PadArray.m` | Three active copies remain byte-identical |
| Documentation | Relative links resolve within the repository |
| `Machine_Learning` | No invented directory hierarchy or artificial model test |
| Rollback | Closing the unmerged PR leaves `main` unchanged; after merge, use a normal revert |

The absence of structural errors does not establish benchmark accuracy, account security or publication rights. Those questions are distinct from file organization.
