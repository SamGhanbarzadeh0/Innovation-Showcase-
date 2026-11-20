# MATLAB validation and reproducible comparisons

The repository contains educational MATLAB implementations of global and local thresholding, directional neighborhood methods and integral-image calculations. The original source code remains identifiable by Git object SHA. The test suite compares those implementations with the revised functions and MathWorks toolbox references, using the same input pixels for each method.

## Reproduce the experiment

Use MATLAB R2024a with Image Processing Toolbox; the signal examples additionally use Signal Processing Toolbox. From the extracted repository root, execute:

```matlab
run('tests/final/run_final.m')
```

The command runs the numerical regression checks, compares padding against MATLAB's `padarray`, evaluates the synthetic images and the installed MATLAB example images, then writes a ZIP in `validation_results/`. A failed numerical assertion or quality gate yields a nonzero CI result. Diagnostic output is still retained.

The current 60-case experiment evaluates **22 configurations on 60 synthetic images**. The geometry-expanded comparison contains three earlier families and two additional families, crossed with three illumination patterns, two contrast/noise levels and two seeds. The `Bradley_Both_T008` configuration is labeled separately from the corrected default `T=0.20`. All synthetic inputs have known reference masks. The test does not select method parameters separately for each image.

## Source and measurement conventions

The 14 original MATLAB files are preserved under `tests/legacy_snapshot/`, with exact object SHA values listed in [the source manifest](original_source_manifest.csv). The legacy local-mean, Wellner and Bradley functions are called from the original sources. The interactive Otsu script is represented by a numerical transcription of its threshold loop, with the original histogram routine called directly; this exception is documented so that it is not mistaken for a verbatim function execution.

For labeled synthetic images, a true pixel denotes **dark foreground**. The suite reports TP, FP, TN, FN, Dice, IoU, sensitivity, specificity, balanced accuracy and runtime. It also records method errors and counts successful paired comparisons before calculating original-versus-revised differences. The resulting tables and MAT arrays permit independent recomputation of the metrics.

Eight MATLAB-installed images—`cameraman.tif`, `coins.png`, `rice.png`, `peppers.png`, `saturn.png`, `printedtext.png`, `pout.tif`, and `liftingbody.png`—are handled separately. Their largest dimension is scaled to 256 pixels for consistent runtime. They have **no trusted segmentation labels** in this test, so the figures show differences in output, not ground-truth accuracy.

## Output files

| File | Purpose |
|---|---|
| `status.txt` | Acceptance checks and missing or failed steps |
| `regression_console.txt`, `extended_edge_console.txt` | Numerical and boundary-test output |
| `matched_metrics.csv`, `method_summary.csv` | Per-image and aggregated synthetic measurements |
| `paired_comparison.csv` | Differences between matched historical and revised methods |
| `matched_arrays.mat` | Inputs, reference masks and predictions |
| `case_light_*.png` | Fixed, preselected synthetic examples |
| `native_image_manifest.csv` | Availability and dimensions of installed example images |
| `native_method_results.csv`, `native_paired_disagreement.csv` | Unlabeled example-image measurements |
| `native_*.png`, `native_image_arrays.mat` | Side-by-side masks and underlying arrays |
| `failures.txt`, `environment.txt` | Error records and MATLAB environment |

The calibrated Bradley test also writes `bradley_quality_gate.csv`. The guard compares original centered Bradley, the corrected `T=0.20` default and the labeled `T=0.08` preset. It checks the 36 earlier and 24 additional synthetic fixtures separately. The tolerance of 0.025 mean Dice below the original is a project-specific non-inferiority criterion, not a claim of statistical equivalence on real images.

## Executed MATLAB results

The latest [GitHub Actions run](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44763150733) passed the numerical and performance guards. Across 60 synthetic cases, the calibrated Bradley preset achieved mean Dice 0.954239, compared with 0.958284 for the original and 0.645258 for the repaired default. The earlier failed run remains visible because it exposed a mistake in the guard's case indexing, which was corrected before the successful rerun.

## Interpretation

The test establishes how these specific implementations and parameter settings behave on reproducible fixtures. It does not establish that one method is best for arbitrary images, nor does it provide clinical validation. Labeled external documents would be needed for broader claims. Review the numerical tables and example images before merging any stacked pull request.
