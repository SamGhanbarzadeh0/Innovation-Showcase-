# Stage 03C — regression-resistant Bradley quality improvement

Date: 2026-11-20. This work was triggered by inspecting the **actual GitHub Actions R2024a artifact**, rather than relying on a green test badge. This note records observed data before this branch's new test is run.

## Verified results from previous complete CI run

Source run: [44758952636](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44758952636), artifact `MATLAB-R2024a-final-validation` (downloaded and inspected in the analysis session). The saved 36-fixture `method_summary.csv` and `paired_comparison.csv` show:

| Variant | Mean Dice (36) | Minimum Dice |
|---|---:|---:|
| Original Bradley Both | 0.959523 | 0.885743 |
| Corrected Bradley Both, default T=0.20 | 0.634746 | 0.086001 |
| Corrected Local Mean T=0.12 | 0.921743 | 0.761493 |
| MathWorks adaptive reference | 0.952703 | 0.873369 |
| Original Wellner DU | 0.040448 | 0.009783 |
| Corrected Wellner DU | 0.742840 | 0.530557 |

The 36 paired Bradley Both comparisons had **24 worse cases, one better case, and 11 ties**. Therefore the original Stage 03/03B/03 final functional green status must not be described as overall improvement in image segmentation.

## Targeted correction rather than unprincipled rewrite

The repaired `BradleyImage.m` uses an explicit `Sensitivity` option; its default remains `0.20`. The revised demo applies `Sensitivity=0.08` **only for the centered Both mode**. This is a configuration/preset adjustment, not a new mathematical algorithm. All original educational projects and exact baseline blobs remain preserved.

A transparent Python reference sweep over the previous 36 saved image arrays with matched 17×17 replicate-padded means indicated that T=0.08 produced about 0.956 mean Dice, whereas T=0.20 produced about 0.635. This is **post-hoc exploratory evidence**, not an independent MATLAB confirmation or proof of improvement over original (approximately 0.960).

To challenge the selected preset, the new MATLAB CI adds 24 additional cases with two geometries not present in the previous stored benchmark, and reports results separately for the 36 historical and 24 additional cases. The guard requires mean Dice of calibrated Bradley (a) exceed T=0.20 by >0.10 on each group and (b) be no worse than the original implementation by more than 0.025 on each group. This threshold is explicitly a project-level synthetic non-inferiority policy.

## Integrity and output contract

- All 22 configurations run on identical cases and identical test masks.
- Compare the old, mathematically repaired default, and calibrated preset using `bradley_quality_gate.csv`, `method_summary.csv`, `paired_comparison.csv`, `matched_arrays.mat`.
- All 8 installed MATLAB images are still analyzed, including a separate calibrated Bradley panel and paired pixel-disagreement table. These have **no trusted ground-truth segmentation labels**; no image quality Dice or IoU may be asserted for them.
- The original 14 MATLAB blobs remain byte-for-byte preserved under `tests/legacy_snapshot`.
- Only one existing demonstration file is modified for the new preset; the core `BradleyImage.m` default remains compatible.
- No PDFs, Git history, source attribution or default `main` are modified.
- New MATLAB outcomes are **not yet known** until the new CI run completes.

## Scientific interpretation

Method-specific numerical fixes can improve correctness while changing segmentation sensitivity. A threshold-margin configuration that improves synthetic Dice must not be misrepresented as a theorem or universal advantage, and poor results on arbitrary unlabeled MATLAB images cannot be assigned an invented accuracy figure. A real-document, labeled external dataset remains necessary for a generalizable performance claim.
