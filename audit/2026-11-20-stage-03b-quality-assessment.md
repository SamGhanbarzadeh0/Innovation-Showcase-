# Revising the segmentation benchmark after the first MATLAB run

**Review date:** 20 November 2026  
**Follow-up branch:** `fix/stage-03b-quantitative-qc-2026-11-20`

The first MATLAB R2024a run passed 69 numerical regression groups, yet its binary images were unsuitable for assessing segmentation quality. Passing an assertion about array dimensions or neighborhood sums had been conflated with obtaining a useful mask. The fixture itself also combined a dark rectangle and a bright rectangle in a smooth gradient, although the methods were applied with one foreground-polarity convention.

Inspection of the original saved arrays showed that approximately **44.83%** of the pixels differed from their local mean by less than `1e-11`. With a zero contrast margin, roundoff-level differences affected binary decisions in otherwise smooth regions. This explains the visible speckling without implying that local-mean thresholding is intrinsically defective.

## Changes to the evaluation

A separate `LocalMeanThreshold.m` helper introduced the explicit decision rule

```
bright_background = I >= (1 - sensitivity) * local_mean
```

with the demonstrated sensitivity set to `0.12`. A black foreground mask is obtained by inverting that decision. The parameter is a testable configuration, not a theoretical guarantee of performance.

The revised benchmark uses three deterministic dark-object conditions: uniform illumination, uneven illumination and lower contrast. Each includes a known binary mask and a fixed random seed. Nine configurations are evaluated without case-by-case tuning, with TP, FP, TN, FN, Dice, IoU, sensitivity, specificity and balanced accuracy recorded separately. The generated figures share the same black-object/white-background interpretation.

## What the later run established

The owner's MATLAB R2024a execution passed **72 regression groups**. All **27** saved mask/metric pairs were independently reconciled with their reported confusion counts and Dice/IoU values. The local mean at sensitivity `0.12` performed strongly on these fixtures; Otsu was adversely affected by the illumination gradient, while some directional methods missed substantial portions of strokes.

All three conditions reused **one reference geometry with 6,988 foreground pixels**. They do not establish variation across independently collected documents or validate a general ranking of algorithms. The qualitative `printedtext.png` example had no reference mask, so neither Dice nor accuracy was assigned to it.

Later comparisons introduced additional geometry families, direct original-versus-corrected tests and MathWorks toolbox baselines. This note records the reasoning behind Stage 03B rather than implying that its first synthetic fixture was a final external benchmark.
