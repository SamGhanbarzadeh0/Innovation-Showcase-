# MATLAB regression tests

The tests in this directory exercise individual numerical operations and boundary cases. They do not measure segmentation quality unless a reference mask is supplied. MATLAB R2024a was used for the subsequent validation runs; some image demonstrations require Image Processing Toolbox, and signal examples may require Signal Processing Toolbox.

From the repository root, run:

```matlab
run('tests/run_regression.m')
```

The suite checks full-range histograms for `uint8` and `uint16`, Otsu threshold conventions, three padding directions, integral-image recurrences, direct versus cumulative local means, directional Wellner windows, centered and one-sided Bradley neighborhoods, and small-image boundary cases.

An earlier MATLAB run completed 69 assertion groups; after the local-mean controls were added, the owner-run R2024a suite completed **72 groups**. Those results concern the specific assertions in the source file. They do not demonstrate that every output is perceptually satisfactory.

For the expanded matched image benchmark and the automatically collected output files, see [the final validation instructions](final/README.md). Results from separate execution dates should be interpreted with their corresponding commit SHA, since the suite was extended during the review.
