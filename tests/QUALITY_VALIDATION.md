# Ground-truth evaluation of the thresholding examples

The first test figures demonstrated a practical limitation of assertion-based validation: a script can calculate neighborhood means correctly and still produce unhelpful segmentation masks. This benchmark therefore measures predictions against an explicit reference image rather than using figure appearance as a substitute for accuracy.

From the repository root:

```matlab
run('tests/run_quality_validation.m')
```

The script creates deterministic synthetic images with dark objects against a light background. It records nine algorithm configurations under uniform illumination, uneven illumination and reduced contrast, then exports confusion counts, Dice, IoU, sensitivity, specificity and balanced accuracy. Generated `comparison_*.png` files show the input, reference and prediction using the same foreground convention.

The corresponding MATLAB R2024a run passed 72 regression groups. Its 27 confusion matrices and metric calculations were independently checked against the stored masks. The three benchmark conditions, however, all use the **same reference geometry**. Their scores are descriptive of those conditions, not of general document-binarization performance.

An optional `printedtext.png` figure provides an unlabeled visual comparison. It is not assigned a Dice score. For comparisons with the original source and with MathWorks toolbox baselines across multiple geometries, use [the later matched benchmark](final/README.md).
