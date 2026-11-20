# MATLAB R2024a results: the first labeled quality comparison

**Execution reviewed:** 20 November 2026  
**Scope:** nine method configurations under three illumination/noise conditions, with one shared object geometry.

The submitted `quality_benchmark_arrays.mat` and `quality_metrics.csv` were checked against each other. Every one of the **27** saved segmentation masks reproduced its reported TP, FP, TN, FN, Dice, IoU and balanced accuracy. The regression suite passed **72** MATLAB assertion groups. Each image contains 65,536 pixels, of which 6,988 belong to the reference foreground.

## Dice against the supplied reference mask

| Configuration | Uniform | Uneven illumination | Low contrast |
|---|---:|---:|---:|
| Local Mean, centered, sensitivity 0.12 | 1.000000 | 1.000000 | 0.998352 |
| Bradley, centered | 0.999928 | 0.999284 | 0.822875 |
| Bradley, Post | 0.974690 | 0.978288 | 0.797970 |
| Bradley, Pre | 0.978138 | 0.963820 | 0.699423 |
| Wellner, left to right | 0.774035 | 0.761322 | 0.702738 |
| Wellner, right to left | 0.774143 | 0.780879 | 0.748567 |
| Wellner, upward direction | 0.793612 | 0.795899 | 0.769393 |
| Wellner, downward direction | 0.794237 | 0.795172 | 0.770043 |
| Otsu | 1.000000 | 0.474519 | 0.398404 |

Local Mean recovered 6,966 of 6,988 foreground pixels in the low-contrast condition, with one false positive and 22 false negatives. Centered Bradley recovered 4,885, with 2,103 false negatives and no false positives. Otsu found all reference pixels but incorrectly classified **21,104 background pixels** as foreground. These errors represent different failure mechanisms: missed strokes for Bradley and background oversegmentation for Otsu.

The visible masks agree with the numerical results. On uniform illumination, Otsu and centered Local Mean exactly matched the reference. With uneven illumination, Otsu produced a broad false foreground region. Directional Wellner variants omitted stroke segments under each condition. The separate `printedtext.png` sample remains a **qualitative image only**: its mask has not been validated against an independently annotated ground truth.

## What can be concluded

The centered local mean at sensitivity `0.12` performed best **under these fixed conditions**. The three images share the same shape, stroke layout and foreground fraction; illumination and noise alone were varied. The compared algorithms also use different sensitivity and window settings. Consequently, these results do not isolate a universal benefit of one mathematical method over the others.

The next evaluation matched original and revised source code on identical input arrays and extended the synthetic geometries. No clinical or real-document accuracy was inferred from this experiment. The original MATLAB output files remain separately recoverable; this report is a numerical record, not a substitute for them.
