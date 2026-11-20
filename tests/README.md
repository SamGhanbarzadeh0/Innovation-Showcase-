# Tests

Run `run('tests/run_regression.m')` from the repository root in MATLAB. This suite includes known image-histogram endpoints, small exact padding arrays, integral-image recurrences, brute-force local-means, all Bradley padding combinations, all Wellner direction/padding combinations, and zero/constant-image edge cases.

The suite was **authored but not executed in MATLAB** during Stage 03, because that runtime is unavailable in this environment. Independent Python/NumPy reference calculations passed 153 out of 153 checks, but they do not replace MATLAB execution. See [Stage 03 verification record](../audit/2026-11-20-stage-03-matlab-results.md).

Before merging, run the suite and inspect the image figures in a local supported MATLAB release. If any assertion fails, keep the pull request in draft, fix that specific case and rerun the full suite.
