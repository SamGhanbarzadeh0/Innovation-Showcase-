# Stage 03 final MATLAB verification — single-run package

**Target runtime:** MATLAB R2024a with Image Processing Toolbox and Signal Processing Toolbox (the user's verified environment). No original code is deleted, and neither paper PDF is modified.

## Download and run

Download the entire GitHub branch `fix/stage-03-final-evaluation-2026-11-20` as a ZIP. Extract it, choose the extracted top-level folder as MATLAB **Current Folder**, and execute exactly one command:

```matlab
run('tests/final/run_final.m')
```

The code automatically writes `validation_results/MATLAB_Final_Validation_YYYYMMDD_HHMMSS.zip`. **Upload this complete results ZIP** for final code and data review. Do not manually merge Pull Requests based only on a green MATLAB console message.

## What the test really does

1. Re-runs the previously executed 72-group MATLAB regression suite.
2. Executes additional differential edge-case checks against MATLAB's `padarray`: 3 image shapes × 3 directions × 5 padding modes × 3 padding widths, plus local means, Otsu extremes and DSP sanity.
3. Constructs **36 deterministic, distinct single-polarity synthetic fixtures** (3 geometries × 3 illumination models × 2 contrast/noise levels × 2 independent noise seeds). Each has an exact dark-foreground ground-truth mask; method parameters are fixed before inspecting results.
4. Evaluates **21 explicitly named methods/configurations**, including legacy source-based algorithms, repaired ones and toolbox `graythresh`/`imbinarize`/`adaptthresh` references. An exception is recorded in the CSV instead of aborting or being silently dropped.
5. Computes confusion counts, Dice, IoU, sensitivity, specificity, balanced accuracy and runtime **for every attempted method on every case**. Paired method differences are computed on matched cases only; unmatched cases are counted.
6. Saves all inputs, ground-truth masks and predicted masks for independent metric recomputation, plus readable comparison PNG figures and an optional unlabeled `printedtext.png` preview.

## Exact provenance of original version

All **14 original MATLAB files**, corresponding exactly to the original audited Git commit `40240cd9d6aed4b6613697b535f84ad6fda80c29`, are preserved under `tests/legacy_snapshot/` using their original Git blob SHAs. The complete audit list is `original_source_manifest.csv`. Original scripts are still present for independent inspection, but interactive originals are **not executed interactively by the benchmark**. The legacy Otsu comparison numerically transcribes the threshold calculations in the original interactive `Project1_OtsuBinarization.m` (Steps 5–9) while invoking the **actual original** `ComputeHistogram.m`. All other baseline algorithm functions are called directly from the original source via isolated path switching. If a legacy function fails on a test, the error remains visible.

The MATLAB-toolbox adaptive baseline is `adaptthresh(I,0.5,'Statistic','mean','NeighborhoodSize',[17 17],'ForegroundPolarity','dark')` followed by `imbinarize`. These parameters and the original algorithm parameters are not claimed to be mutually optimized. Some original and corrected window definitions differ, as documented by their implementation; comparison is descriptive for these *configurations*, not a clean causal ablation of a single code edit.

## Output interpretation

| Result artifact | Contents |
|---|---|
| `status.txt` | Regression, extended checks, benchmark failures and functional release gate |
| `regression_console.txt` | Existing MATLAB regression assertions |
| `extended_edge_console.txt` | Differential testing against native MATLAB `padarray` |
| `matched_metrics.csv` | 36 × 21 attempts, including all successes and errors |
| `method_summary.csv` | Success/error counts, mean/median/min Dice, mean IoU and median runtime |
| `paired_comparison.csv` | Original vs corrected, matched counts, better/worse/tied cases |
| `matched_arrays.mat` | All synthetic inputs, truth masks and 21 predictions per case |
| `case_light_1.png`, `case_light_2.png`, `case_light_3.png` | Fixed, non-cherry-picked comparisons |
| `printedtext_comparison.png` | Optional qualitative-only image; no invented metrics |
| `failures.txt`, `environment.txt` | Errors and reproducible environment details |

The release gate rejects **any corrected/toolbox method error**, any regression failure, an extended differential failure or failed figure production. Legacy errors are **reported but do not automatically fail repaired-code correctness**. Performance superiority is **not** a condition for an educational implementation to be correct. Output quality is reported separately and cannot be extrapolated to other images.

## Scientific limitations and closure

The original user-run Stage 03B benchmark passed 72 MATLAB test groups and 27/27 metric recomputations, but used one reference geometry under three conditions. This new suite diversifies synthetic geometry and prevents cherry-picking. It still **is not a blind real-document benchmark**: no real-image Dice claim is legitimate without human-verified reference labels. A final repository claim of broadly superior binarization requires external holdout data, such as images and labeled masks from the DIBCO series, with licenses checked by the user.

Only after reviewing the actual final MATLAB ZIP should this code-level audit be marked *closed*. PRs remain Draft until then. The correct final technical claim is **tested and documented educational implementations**, not flawless image segmentation.
