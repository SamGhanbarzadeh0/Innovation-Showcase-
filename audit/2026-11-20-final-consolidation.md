# Reproducible comparison of the original and revised MATLAB code

**Established baseline:** `40240cd9d6aed4b6613697b535f84ad6fda80c29`  
**Final comparison branch:** `fix/stage-03-final-evaluation-2026-11-20`

The original thresholding scripts are interactive demonstrations. Several numerical corrections were subsequently necessary, but the first revised figures showed that mathematical consistency and useful segmentation were not interchangeable. A more informative test had to compare the old and revised implementations on identical pixels, retain failures, and examine quality independently of whether MATLAB completed without an exception.

## Source provenance

The exact Git objects for all 14 original MATLAB files were retained under `tests/legacy_snapshot/`. Their paths and SHA values are recorded in `tests/final/original_source_manifest.csv`. The historical sources were not silently rewritten. Mean, Wellner and Bradley baseline functions are invoked from those copies. The original Otsu driver is interactive; its numerical threshold loop is transcribed for automated comparison while the original histogram function is called directly. This is a stated limitation of the baseline comparison.

## Evaluation design and observed runs

The initial consolidated suite compared **21 configurations on 36 deterministic synthetic images**: three object geometries, three illumination patterns, two contrast/noise settings and two independent noise realizations. Every input has a known dark-foreground mask. A separate set of eight MATLAB-installed image examples was processed with fixed parameters; these natural and document-like images have no accompanying trusted segmentation masks in this workflow.

Confusion counts, Dice, IoU, sensitivity, specificity, balanced accuracy, runtime and paired differences are exported for every synthetic attempt. Errors remain in the output tables. The corresponding [MATLAB R2024a workflow](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44758952636) completed successfully, including the eight installed sample images.

Inspection of those results exposed a meaningful regression: centered Bradley with its corrected window geometry but `T=0.20` had mean synthetic Dice **0.634746**, compared with **0.959523** for the original implementation. The passing numerical suite did not justify describing the revised Bradley result as an improvement.

The subsequent Stage 03C review retained the repaired computation but introduced an explicitly labeled centered `T=0.08` preset and a non-inferiority check. The expanded [R2024a run](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44763150733) assessed 22 configurations across 60 synthetic fixtures and eight unlabeled MATLAB samples. Its functional tests passed, and the calibrated centered Bradley reached **0.954239** mean Dice across the 60 fixtures, against **0.958284** for the original. The fixed default `T=0.20` remained available for reproducible comparison.

## Interpretation

The corrected source is numerically better specified, while the centered Bradley preset substantially reduces the performance loss introduced by the earlier default. The calibrated configuration has not demonstrated overall superiority to the historical method. The new fixture families remain synthetic; qualitative agreement on MATLAB examples is not evidence of labeled real-image accuracy.

The project can reasonably be described as a reproducible set of educational image-processing implementations with documented algorithmic choices, tested boundary conditions and preserved source history. It cannot be presented as universally optimal document binarization or validated medical-image analysis.

Neither the original PDFs nor the default branch were changed by this documentation review. A merge requires review of the stacked changes and the actual test artifacts, rather than reliance on a green CI badge alone.
