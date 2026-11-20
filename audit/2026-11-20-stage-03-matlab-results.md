# Stage 03 — MATLAB corrections and verification status

Date: 2026-11-20. Baseline: `40240cd9d6aed4b6613697b535f84ad6fda80c29` (unmodified `main`).
This branch changes the MATLAB source but does not touch either PDF, any `.DS_Store`, existing history or license metadata.

## Correction log

- `ComputeHistogram.m`: avoid uint8/uint16 arithmetic saturation; count the complete nominal intensity range; define floating-point histogram quantization in [0,1]; support RGB channel histograms.
- `OtsuThreshold.m` (new): expose a deterministic two-class between-class-variance thresholding function with a documented lowest-index tie convention. The displayed Otsu script now uses the same calculation, including matching quantization semantics for floating-point inputs.
- `ImageMean.m`: use double-precision summed-area tables for padded local means, with dimensions and pre/post/both window sizes explicitly defined.
- `PadArray.m` (three identical copies): preserve input class, make extension semantics explicit, support pad widths larger than the image, validate unsupported options, and use integer index maps.
- `WellnerImage.m`: exclude the current pixel from S-neighbor reference windows, correct RL sample-count normalization and DU indexing, and avoid zero-width windows on small arrays.
- `BradleyImage.m`: calculate local means from the *padded intensity image*, not a padded integral image; normalize by the actual number of samples; assign every output pixel under Pre/Post/Both.
- `IntegralImage.m` and `IntegralImagePlus.m`: use two equivalent double-precision cumulative-sum identities.
- `Project1_OtsuBinarization.m`, `Project2_PadArrayMeanBinarization.m`, `Project3_WellnerThresholding.m`, `Project4_BradleyThresholding.m`: align visualization scripts with corrected functions, validate user input and label displayed methods correctly.
- `Project1_CDSignals.m`: avoid a discrete sinusoid sampled at its degenerate Nyquist phase; normalize the narrow pulse by its actual sampled area; change dense narrow-pulse stem to a continuous plot.

All 14 original MATLAB source files on `main` are updated on this branch. The method definitions preserve the educational aims but can change numerical outputs, especially for incorrect border cases. Previous figures should be re-generated; old outputs are not re-described as new experimentally verified results.

## Actual execution evidence

- **Independent Python/NumPy reference tests: 153 passed / 153 executed** on a deterministic seed (20261120). These test boundary-extension indexing, direct-versus-summed-area local means, Bradley windows on multiple dimensions, Wellner directions/boundaries, Otsu extreme-intensity cases and discrete DSP identities.
- **MATLAB tests: NOT EXECUTED.** Neither MATLAB nor GNU Octave is installed in the current execution environment. The source-level MATLAB regression suite is `tests/run_regression.m`.
- The Python reference tests are **independent algorithmic tests**, not execution of MATLAB source. Their success does not constitute proof of MATLAB syntax, toolbox availability, graphical behavior or bit-for-bit identical MATLAB output.

## MATLAB acceptance command

From the repository root with a supported MATLAB installation:

```matlab
run('tests/run_regression.m')
```

Expected stdout **only if all checks pass**: `PASS: <N> MATLAB assertions/groups (all tests reached).`
Do not claim the results were validated in MATLAB until the test command has actually executed.

For graphical scripts, open each project folder and run its `Project*.m` file. Recommended reference fixtures: `coins.png`, `cameraman.tif`, `rice.png`, `peppers.png` and synthetic constant/gradient images. The scripts require Image Processing Toolbox functions; DSP visualization uses Signal Processing Toolbox functions such as `sawtooth`.

## Exit criteria / unresolved

- [x] Mathematical bug fixes and safe indexing changes committed to a separate branch.
- [x] Exact-shape and edge-case regression test source added.
- [x] 153/153 independent NumPy algorithm-reference checks passed.
- [ ] MATLAB R2022a or newer script/runtime verification, including any toolbox/API compatibility failures.
- [ ] Visual inspection of generated MATLAB figures and reproducible saved outputs from actual MATLAB execution.
- [ ] Merge only after review and MATLAB execution; `main` should remain at the audited baseline in the meantime.

Do not use this branch to imply scientific validation of clinical/biomedical data, since these are educational imaging and signal-processing examples rather than a tested medical application.
