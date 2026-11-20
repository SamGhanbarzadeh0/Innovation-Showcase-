# MATLAB corrections: numerical scope and validation history

**Source baseline:** `40240cd9d6aed4b6613697b535f84ad6fda80c29`  
**Initial correction branch:** `fix/stage-03-matlab-2026-11-20`

The first correction pass altered 14 existing MATLAB files and introduced `OtsuThreshold.m`, a callable implementation of two-class between-class variance maximization. The objective was to repair identifiable numerical errors while retaining the educational examples and the original repository history.

## Changes to the calculations

- **Otsu:** histogram indices are calculated without native-integer saturation. Logical, 8-bit, 16-bit and normalized floating-point images have explicit binning rules. Quantized floating-point images are classified using the same bins used to estimate their threshold.
- **Local mean:** `ImageMean.m` obtains neighborhood averages through a double-precision summed-area table. The distinction between one-sided and centered windows is explicit.
- **Padding:** the three identical `PadArray.m` copies validate direction and padding type. Replication, circular extension and symmetric reflection use index maps that also handle padding wider than the source image.
- **Wellner:** the directional neighborhood contains exactly the stated number of reference samples. Right-to-left and downward indexing were corrected, and narrow images no longer produce a zero-length reference window.
- **Bradley:** sums are taken from a cumulative table of the **padded image**, with the correct number of pixels in each window. Output coverage includes boundary pixels. The corrected function initially retained the original sensitivity parameter of `0.20`.
- **Integral images and demonstrations:** the cumulative-sum implementations were made explicit; the image scripts use consistently named methods, while the discrete sinusoid no longer degenerates at its chosen sample frequency. The finite-width impulse approximation is normalized by its sampled area.

These changes establish clearer computational definitions. They do not establish that the resulting segmentation is always closer to a reference mask.

## Sequence of validation

The initial review used 153 independent Python/NumPy reference checks. MATLAB was not available at that point, so no MATLAB pass was claimed. The subsequent owner-run MATLAB R2024a suite passed **69** regression groups, but its figures exposed a poorly specified synthetic example: bright and dark objects were combined under one-sided threshold conventions, and a zero-margin local mean produced near-equality artifacts.

The later 03B and final stages corrected the experimental design. In particular, a matched 36-case comparison revealed that default corrected Bradley with `T=0.20` had substantially lower synthetic Dice than the historical implementation. That finding was retained rather than hidden under the earlier passing regression tests. A distinct calibrated centered configuration and further validation were introduced in Stage 03C.

## How to reproduce

The historical numerical tests are available in `tests/run_regression.m`; the later, broader suite is described in `tests/final/README.md`. The original code remains accessible by its baseline Git SHA, and subsequently within `tests/legacy_snapshot/`.

The scripts require MATLAB and relevant MathWorks toolboxes for their image and signal demonstrations. These are educational implementations; neither the figures nor the tests constitute validation on clinical data or proof of general superiority in document binarization.
