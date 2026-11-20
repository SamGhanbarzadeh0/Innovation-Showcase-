# Stage 03B — Review of executed MATLAB quality benchmark

**Run reviewed:** 2026-11-20  
**Environment:** MATLAB R2024a (24.1.0.2537033), macOS MACI64  
**Branch under review:** `fix/stage-03b-quantitative-qc-2026-11-20`  
**Status:** MATLAB tests passed; synthetic quality metrics verified; **general performance claims not yet supported**.

## 1. Provenance and integrity checks

The owner supplied `environment(1).txt`, `regression_console(1).txt`, `status(1).txt`, `quality_metrics.csv`, `quality_benchmark_arrays.mat` and the output PNG figures. The regression log reports **72 MATLAB assertion groups passed**; the run status reports **3/3 quality cases evaluated**, 9 methods per case, and reference masks available.

The supplied MAT arrays were independently loaded. For **all 27 segmentation masks**, TP, FP, TN, FN, Dice, IoU and balanced accuracy were recomputed and agreed with the CSV values (no discrepancies). Each image is 256×256 pixels, with **6,988 positive reference pixels out of 65,536 (10.6628%)**. Importantly, the **same ground-truth geometry** was used in all three lighting/noise settings; these are three conditions, **not three independent object datasets**.

## 2. Actual Dice by condition

| Method | Uniform | Uneven lighting | Low contrast | Mean over three | Worst case |
|---|---:|---:|---:|---:|---:|
| LocalMean_Both_T012 | 1.000000 | 1.000000 | 0.998352 | 0.999451 | 0.998352 |
| Bradley_Both | 0.999928 | 0.999284 | 0.822875 | 0.940696 | 0.822875 |
| Bradley_Post | 0.974690 | 0.978288 | 0.797970 | 0.916983 | 0.797970 |
| Bradley_Pre | 0.978138 | 0.963820 | 0.699423 | 0.880460 | 0.699423 |
| Wellner_LR | 0.774035 | 0.761322 | 0.702738 | 0.746032 | 0.702738 |
| Wellner_RL | 0.774143 | 0.780879 | 0.748567 | 0.767863 | 0.748567 |
| Wellner_UD | 0.793612 | 0.795899 | 0.769393 | 0.786302 | 0.769393 |
| Wellner_DU | 0.794237 | 0.795172 | 0.770043 | 0.786484 | 0.770043 |
| Otsu | 1.000000 | 0.474519 | 0.398404 | 0.624307 | 0.398404 |

**Interpretation:** On these fixed, single-polarity, dark-on-light synthetic fixtures, the centered local-mean method with a 12% contrast margin preserved the ground-truth strokes most consistently. That is a **condition-specific observation**, not evidence of universal superiority.

## 3. Failure-mechanism checks

| Condition / method | True positives | False positives | False negatives | Dice | IoU |
|---|---:|---:|---:|---:|---:|
| Low contrast — LocalMean_Both_T012 | 6966 | 1 | 22 | 0.998352 | 0.996709 |
| Low contrast — Bradley_Both | 4885 | 0 | 2103 | 0.822875 | 0.699056 |
| Low contrast — Otsu | 6988 | 21104 | 0 | 0.398404 | 0.248754 |
| Uneven — Otsu | 6988 | 15477 | 0 | 0.474519 | 0.311062 |
| Uneven — Bradley_Both | 6978 | 0 | 10 | 0.999284 | 0.998569 |

Otsu's low-contrast failure is predominantly **background oversegmentation** (21,104 false positives), not loss of reference strokes (0 false negatives). Bradley_Both's low-contrast failure is predominantly **underdetection** (2,103 false negatives). Directional Wellner methods also underdetect portions of strokes even in the uniform case. These distinctions are lost if judging only the overall fraction of dark/bright pixels.

## 4. Visual-review findings

- **Uniform:** Otsu and centered Local Mean match the reference mask exactly; Bradley_Both differs by one reference pixel; directional Wellner responses omit sizeable directional portions of strokes.
- **Uneven illumination:** Otsu creates a broad, incorrect dark-background region. Local Mean matches the reference; centered Bradley is very close.
- **Low contrast:** Otsu's erroneous dark-background region grows. Local Mean retains most foreground strokes (22 FN, 1 FP), whereas Bradley_Both misses 2,103 foreground pixels.
- **`printedtext_qualitative.png`:** This is an unlabeled image. Otsu and some directional methods show strong shadow/gradient artifacts. Local Mean and centered Bradley are more readable by visual inspection, but there are still fine-text losses/artifacts. **No Dice, IoU or real-image accuracy can be assigned to this image.** Do not present it as a quantitative validation.

## 5. Design limitations that prevent final release claims

1. Only **one reference geometry** is used for all three conditions. Noise is regenerated, but lettering, stroke widths, occupancy and object arrangement are not independent.
2. The methods use distinct sensitivity settings (Local Mean 0.12, Wellner 0.15, Bradley 0.20) and window geometries. This is a comparison of **these configurations**, not a controlled comparison of optimally tuned algorithms.
3. The method was revised after examining a previous synthetic figure. The current synthetic set cannot be treated as wholly external, preregistered validation.
4. There is no paired baseline-vs-corrected comparison on the **owner's original example images** with matching input, polarity, metrics and execution conditions.
5. A MATLAB sample image without a supplied ground-truth mask supports only qualitative inspection.
6. MATLAB's standard toolbox baselines (for example `adaptthresh` / `imbinarize`, with documented parameters) have not been evaluated in this run.
7. Spatially coherent illumination changes and noise are tested only at three hand-specified levels; this does not quantify generalization or variability across seeds/geometries.

## 6. Gate decision

- **GO — arithmetic and file integrity:** 72/72 MATLAB groups passed; 27/27 saved confusion matrices and metrics independently cross-checked.
- **GO — descriptive result:** LocalMean_Both_T012 performs best on the **three reported synthetic conditions**.
- **NO-GO — claims of algorithmic superiority / final GitHub presentation:** insufficient external benchmark diversity, no matched original-versus-revised comparison and unresolved qualitative artifacts on the unlabeled printed-text sample.
- **NEXT:** fixed, identical evaluation of old and revised code on the same test images, expansion to multiple independent geometries and noise seeds, standard MATLAB baselines, saved per-case thresholds/runtime, and review of real-document binarization with verified labels.

**Repository action:** This file documents the owner's observed run on the review branch only. The PNG files and original MAT artifact remain with the owner and are not claimed to have been uploaded to this GitHub branch. The default `main` and previous commits remain unchanged.
