# MATLAB validation (run before merging PR #3)

Use MATLAB R2022a or a compatible newer version with Image Processing Toolbox (and Signal Processing Toolbox for the signal-demo script). The repository has **not yet passed a real MATLAB run** in this workflow.

1. Download the ZIP of branch `fix/stage-03-matlab-2026-11-20` and extract it.
2. In MATLAB, make the extracted repository root the **Current Folder** (the folder containing `tests`, `Image Processing`, and `Signal Processing`).
3. Run the single command:

```matlab
run('tests/collect_validation.m')
```

The collector calls `run_regression.m` in an isolated function workspace, checks the thresholding methods on a deterministic synthetic image, and writes a ZIP to `validation_results/MATLAB_Validation_Results_YYYYMMDD_HHMMSS.zip`. Its contents are `status.txt`, `environment.txt`, `regression_console.txt`, `summary_metrics.csv`, `synthetic_outputs.mat`, and two PNG figures (where figure generation succeeds). A failing test is recorded, not suppressed, and the ZIP is generated when possible.

**Upload the generated ZIP back to the ChatGPT conversation** for diagnosis and report preparation. If the collector fails before creating a ZIP, send the MATLAB error text and screenshot. Do not upload credentials or private data.

You can also run only the regression suite:

```matlab
run('tests/run_regression.m')
```

This suite checks histogram endpoints, Otsu masks, padding boundaries, integral-image identities, direct local means, Bradley neighborhood rules, Wellner direction rules and small images. The results remain unverified in MATLAB until run by the owner.

Stage 03 source changes and the test suite are under [Draft PR #3](https://github.com/hesamghd/Innovation-Showcase-/pull/3). Do **not** merge until the actual MATLAB regression output and figures are reviewed.
