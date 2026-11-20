# Image and Signal Processing in MATLAB

This repository contains MATLAB projects on image thresholding and elementary signal representations. The code covers global and locally adaptive binarization, neighborhood padding, integral images, and sampled continuous- and discrete-time signals. I have retained the original implementations alongside the corrected versions so that the numerical changes can be examined rather than inferred from the resulting figures.

Although my broader research interests include biomedical signal processing, the files in this repository are **image-processing and signal-processing exercises**. They are not experiments on EEG, MRI, fNIRS, ECG, or patient data.

## Projects

| Topic | Source | What is implemented |
|---|---|---|
| Otsu thresholding | [Otsu folder](Image%20Processing/Matlab/Chapter%202%20-%20Image%20Thresholding/OTSU%20Binarization) | Grayscale histograms, between-class variance, and binary decisions |
| Local mean thresholding | [Mean folder](Image%20Processing/Matlab/Chapter%202%20-%20Image%20Thresholding/Simple%20Mean%20Binarization) | Padded neighborhood means and contrast-margin decisions |
| Wellner thresholding | [Wellner folder](Image%20Processing/Matlab/Chapter%202%20-%20Image%20Thresholding/Wellner%20Thresholding) | Direction-dependent neighborhood references |
| Bradley thresholding | [Bradley folder](Image%20Processing/Matlab/Chapter%202%20-%20Image%20Thresholding/Bradley%20Thresholding) | Local thresholds computed from summed-area tables |
| Basic signals | [Signal Processing](Signal%20Processing/Matlab/Chapter%201-%20Define%20Signal) | Continuous and discrete signal examples |

The four image-processing folders include scripts that produce figures. The underlying helper functions can also be tested without using the interactive demonstrations.

## Reproduce the MATLAB tests

The verified environment is **MATLAB R2024a** with Image Processing Toolbox; the signal-visualization script uses functions from Signal Processing Toolbox. After cloning the repository, run this command from its top-level directory:

```matlab
run('tests/final/run_final.m')
```

The suite compares the source-original functions, corrected implementations, and selected MathWorks toolbox references. It includes boundary tests against `padarray`, **60 synthetic images with known masks**, and eight MATLAB-installed sample images. It saves confusion counts, Dice, IoU, run times, paired comparisons, and generated figures under `validation_results/`. Instructions and the output inventory are in [the validation guide](tests/final/README.md).

The original 14 MATLAB source files are preserved under [`tests/legacy_snapshot/`](tests/legacy_snapshot), with Git object IDs recorded in [the source manifest](tests/final/original_source_manifest.csv). This allows a direct comparison with the original repository state rather than a reconstruction of the earlier code.

## Results and interpretation

The [verified MATLAB R2024a workflow](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44763150733) passed the regression and boundary tests and evaluated 22 method configurations on 60 synthetic images. A particular finding concerns centered Bradley thresholding:

| Bradley configuration | Mean Dice on 60 synthetic images |
|---|---:|
| Original implementation | 0.9583 |
| Corrected window calculation, sensitivity 0.20 | 0.6453 |
| Corrected window calculation, centered preset 0.08 | 0.9542 |

Fixing the window calculation exposed a substantial loss in segmentation performance at the earlier sensitivity setting. The labeled 0.08 preset recovered most of that loss but remained slightly below the original on this benchmark. Both numerical correctness and the quality of the binary mask are therefore assessed explicitly; the two should not be treated as interchangeable.

The eight installed MATLAB examples were processed without runtime errors. They do not have trusted ground-truth masks in this experiment, so their output figures provide **qualitative comparisons only**. The synthetic scores are not evidence of universal superiority, nor do they establish performance on medical images.

The full analysis, including the earlier failed quality-guard run and its correction, is documented in the [Bradley evaluation record](audit/2026-11-20-stage-03c-bradley-quality-guard.md). The MATLAB workflow retains the logs and generated artifacts for reproducibility.

## Provenance

The original repository is preserved at commit `40240cd9d6aed4b6613697b535f84ad6fda80c29`; later corrections are recorded as ordinary Git commits. Two reference PDFs remain in the image-thresholding folders unchanged. Their inclusion should not be interpreted as a statement that the repository owns the publications or grants redistribution rights.

These projects document my work with MATLAB implementations and their limitations. Further performance claims would require independently labeled evaluation images, a fixed tuning protocol, and a comparison beyond the synthetic conditions used here.
