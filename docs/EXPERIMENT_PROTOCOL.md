# Evaluation protocol for the MATLAB thresholding projects

This document describes the **executed** comparison, not a proposed image-processing benchmark. The implementation is [`collect_final_validation.m`](../tests/final/collect_final_validation.m), invoked through [`run_final.m`](../tests/final/run_final.m). The record for the successfully tested `main` commit is [GitHub Actions run 44769293994](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44769293994).

## Scientific question and unit of analysis

The immediate question is whether the working MATLAB functions implement their stated local and global threshold calculations, and how their outputs differ from the preserved original implementations under controlled illumination and contrast. It is **not** a hypothesis about biological image segmentation or a claim that one algorithm generalizes to all documents.

A benchmark case is a single **128 × 128** synthetic grayscale image with a corresponding binary reference mask. Each case is evaluated by the same **22 named methods or parameter configurations**, with no case-specific retuning. A `true` reference-mask pixel means **dark foreground**; the current algorithms' brighter-class outputs are complemented for this evaluation.

## Data generation

The test defines five foreground geometries in `makeFixture`: line-and-ring objects; two elliptical outlines and a slanted stroke; block glyph-like strokes of mixed width; disconnected loops and strokes; and crossing/parallel bars. Each geometry is crossed with three fixed illumination profiles, two contrast/noise conditions and two deterministic random realizations:

```text
5 geometries × 3 illumination profiles × 2 contrast conditions × 2 seeds = 60 cases.
60 cases × 22 implementations/configurations = 1,320 mask evaluations.
```

The noise seed is derived from a constant and the four case indices. The intensity is obtained by subtracting the chosen object contrast from the local background, adding Gaussian noise and clipping to `[0,1]`. This makes identical case indices reproducible, but the 60 outputs are not 60 independent real-world documents.

The first three geometry families correspond to the earlier 36-case comparison. The fourth and fifth families were introduced after inspecting the original results and selecting the centered Bradley sensitivity of `0.08`. They are an additional **synthetic stress test**, not an externally collected or blinded holdout corpus.

## Methods and parameters

The comparison includes the original, corrected and MathWorks Otsu methods; zero-margin original and corrected local mean; corrected centered local mean at `s=0.12`; the MathWorks `adaptthresh` reference; four original and four revised Wellner directions; three original and three revised Bradley window placements; and the explicitly labeled centered Bradley `T=0.08` preset.

For the MathWorks adaptive baseline, the source calls `adaptthresh` with sensitivity `0.5`, mean statistic, a `17 × 17` neighborhood and dark foreground polarity. These parameters are fixed rather than tuned per image. Sensitivities and window constructions differ across algorithms; this is a comparison of **specified configurations**, not a controlled optimization contest in which all methods receive equal tuning budgets.

The original source functions are kept byte-for-byte under [`tests/legacy_snapshot/`](../tests/legacy_snapshot), and their Git object IDs are listed in [the source manifest](../tests/final/original_source_manifest.csv). Mean, Wellner and Bradley originals are invoked from those files. The original Otsu demonstration is interactive, so the old numerical loop is transcribed for the comparison while its original histogram routine is invoked. The distinction is relevant when interpreting small Otsu differences.

## Metrics

Given a predicted foreground mask `P` and reference mask `G`, the evaluation records

```text
TP = count(P=1, G=1)      FP = count(P=1, G=0)
FN = count(P=0, G=1)      TN = count(P=0, G=0)

Dice        = 2 TP / (2 TP + FP + FN)
IoU         = TP / (TP + FP + FN)
Sensitivity = TP / (TP + FN)
Specificity = TN / (TN + FP)
Balanced accuracy = (Sensitivity + Specificity) / 2.
```

Denominators use explicit zero handling in the source. The summary reports the **mean of the case-level Dice scores**, not a Dice score formed by pooling all case masks first. No standard error or hypothesis-test p-value is asserted because the synthetic cases share the same designed generator and are not an independent biological or document sample.

For every method/case, `matched_metrics.csv` records the confusion counts, quality metrics, execution status, error information and runtime. `paired_comparison.csv` uses exactly matched input cases and states how many paired comparisons are available. `matched_arrays.mat` stores inputs, ground-truth masks and predictions so reviewers can recompute the metrics.

## Mathematical checks versus quality checks

The regression suite tests histogram, padding, cumulative-sum and directional-window calculations. Separate edge-case tests compare padding against MATLAB's own `padarray`, including small images and oversized padding. A **passing numerical test does not imply good segmentation**; earlier Bradley results demonstrated that fixing the window calculation can change the optimal sensitivity setting.

The calibrated Bradley acceptance guard compares the original centered version, the repaired default `T=0.20`, and the labeled `T=0.08` configuration separately on the earlier 36 and additional 24 synthetic cases. The latter must improve on the repaired default by more than 0.10 mean Dice and remain within a 0.025 mean-Dice loss of the original in both groups. This is a project-specific gate, not statistical equivalence and not evidence of real-document superiority.

## MATLAB example images without reference masks

The suite also processes eight installed MathWorks examples: `cameraman.tif`, `coins.png`, `rice.png`, `peppers.png`, `saturn.png`, `printedtext.png`, `pout.tif` and `liftingbody.png`. The longest side is resized to 256 pixels. These outputs produce descriptive mask comparisons, foreground fractions, connected-component counts and pixel disagreement between selected method pairs.

None of these eight images has an independently labeled foreground mask in this workflow. **Pixel agreement is not segmentation accuracy**, and component counts are not a substitute for a correct text/document mask. Accordingly, these images have no reported Dice, IoU, sensitivity or accuracy values.

## Reproduce and inspect

Use MATLAB R2024a with Image Processing Toolbox, and Signal Processing Toolbox for the separate signal demonstrations. From the repository root:

```matlab
run('tests/final/run_final.m')
```

The run writes its outputs to `validation_results/`, including `matched_metrics.csv`, `method_summary.csv`, `paired_comparison.csv`, `bradley_quality_gate.csv`, `matched_arrays.mat`, synthetic comparison figures and the native example-image comparisons. The [full output inventory](../tests/final/README.md) specifies the remaining filenames.

For the measured figures and interpretation, see [Results and figure provenance](RESULTS_AND_FIGURES.md). The output ZIP can be retrieved from the Artifacts section of the [verified R2024a run](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44769293994), while it remains within GitHub's artifact retention period.
