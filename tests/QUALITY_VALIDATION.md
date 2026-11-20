# Quality validation after the Stage 03 image-review failure

The earlier MATLAB `Regression tests: PASS` only established that specified assertions and output shapes succeeded. Its synthetic pictures were not a scientifically valid segmentation benchmark.

**Current quality-review branch:** `fix/stage-03b-quantitative-qc-2026-11-20`.

Run in MATLAB R2024a (the user's verified environment) from the extracted repository root:

```matlab
run('tests/run_quality_validation.m')
```

This creates `validation_results/MATLAB_Quality_Validation_YYYYMMDD_HHMMSS.zip` with:
- `quality_metrics.csv`: TP/FP/TN/FN, Dice, IoU and error rates for 9 method variants across 3 fixed synthetic conditions
- `comparison_uniform.png`, `comparison_uneven.png`, `comparison_low_contrast.png`
- `input_*.png`, `truth_*.png`, `quality_benchmark_arrays.mat`, `status.txt`, `regression_console.txt`
- Optional `printedtext_qualitative.png` if MATLAB can locate that sample

**Send the complete ZIP back to the analysis conversation.** A quality label of PASS is never inferred from a completed plotting command: actual Dice and IoU, comparison against the ground truth, and visually readable results are all required.

All masks use true=dark foreground for evaluation; the displayed images show dark objects against white background. No clinical performance or comparison with the user's original code is claimed without matching tests.
