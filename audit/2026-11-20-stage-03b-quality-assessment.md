# Stage 03B — correction of the evaluation design

Date: 2026-11-20. This is a **follow-up to Draft PR #3** and preserves the original code history and the user's R2024a validation files. It does not replace the prior successful execution record.

## Verified facts from the user's actual MATLAB run

The user ran MATLAB R2024a on macOS. The original suite returned **69 assertion/groups PASS** and the figure collector completed; this is execution/array-shape success, **not** segmentation accuracy or superiority over the user's pre-existing algorithms.

The submitted `synthetic_outputs.mat` and `summary_metrics.csv` reveal:
- The original test fixture inserted **both a dark rectangle and a bright rectangle** into a smooth illumination gradient, but each evaluated algorithm assumed a **single-sided brightness polarity**. A binary one-threshold mask cannot simultaneously identify both opposite-contrast targets as one foreground class without a different detection model.
- The original Local Mean example compared `I>=localMean` with **zero contrast margin**. On the supplied synthetic image, approximately **44.83%** of pixels satisfy `abs(I-localMean)<1e-11`. Roundoff-level mean differences then produce unstable black/white stippling in visually smooth regions.
- The old output figures were not supplied with a true segmentation mask. Their visual quality cannot be converted into Dice, IoU, detection accuracy, or evidence of improved scientific performance.
- The reported fractions from the old collector measure bright pixels, **not** true objects: Wellner LR 0.9227, RL 0.8090, UD 0.9417, DU 0.9146; Bradley Pre 0.9442, Post 0.9083, Both 0.9205. Treating these fractions as accuracy would be erroneous.

## Corrective changes in this branch

1. `LocalMeanThreshold.m`: add an explicit, documented margin `I >= (1-sensitivity)*localMean` (default sensitivity 0.12) to avoid near-tie stippling. This changes the original zero-margin threshold convention; it is a **choice to test**, not a theorem proving superior performance.
2. The simple-mean demonstration now states the margin explicitly and uses the same helper.
3. `tests/run_regression.m` adds three near-tie and stroke controls (constant background, smooth gradient and dark stripe).
4. `tests/run_quality_validation.m` and `tests/collect_quality_validation_bundle.m` provide an entirely separate **ground-truth-based** comparison. Each fixed synthetic test has exclusively dark objects, exactly known segmentation labels, a reproducible seed, and three illumination/contrast conditions. Algorithms are run without per-image parameter tuning.
5. For every method and condition, the export includes TP, FP, TN, FN, Dice, IoU, sensitivity, specificity, balanced accuracy and predicted foreground fraction. Figures show input, the ground-truth mask and all nine outputs with a **consistent black-foreground/white-background** convention.
6. A MATLAB-provided `printedtext.png` image is optionally displayed as a **qualitative preview only**. It has no reference labels and receives no invented accuracy score.

## Reproducibility and validation limits

- Earlier 69-group MATLAB suite: **PASS as supplied by the user**; the new three tests **have not yet been run in MATLAB**.
- The new synthetic benchmark and local mean sensitivity change: **NOT YET EXECUTED IN MATLAB**. The owner must run the new command and upload its result ZIP.
- These synthetics are diagnostic examples; they are not proof of improvement on arbitrary natural images, medical images or the owner's legacy MATLAB cases.
- No original research data, publication PDFs or prior Git commits are changed; the existing Draft PR #3 remains a separate comparison point.
- Even a high Dice on the synthetic fixture cannot justify claiming the revised method is categorically superior to the user's original project. A credible before/after comparison requires **matching images, threshold conventions, runtime settings and labels**.

## How to run

Download the `fix/stage-03b-quantitative-qc-2026-11-20` branch ZIP, extract it, set MATLAB Current Folder to its root, and run:

```matlab
run('tests/run_quality_validation.m')
```

The script prints the ZIP location: `validation_results/MATLAB_Quality_Validation_YYYYMMDD_HHMMSS.zip`. Upload that ZIP for independent review. If the new regression suite fails, the failure is logged and the benchmark attempts to continue; do not treat incomplete cases as valid data.

## Acceptance criteria

- [x] Root-cause analysis from actual MATLAB MAT/CSV outputs
- [x] Separate corrective branch; existing Stage 03 branch and main left unchanged
- [x] Explicit polarity, target labels, metrics and deterministic fixture definition
- [ ] MATLAB execution of the new quality suite and all cases
- [ ] Independent review of exported masks, metrics and figure artifacts
- [ ] Evaluation on the user's **original** example images with consistent settings
- [ ] Owner acceptance before any merge
