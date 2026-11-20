# Stage 06: project-level scientific documentation

**Baseline:** `6cbadb7b5fbffe65382f874cd35881f93ddb848e`  
**Review date:** 20 November 2026  
**Scope:** documentation, a data-derived static SVG figure, and archival copies of three verified result tables. No MATLAB code, historical object or publication PDF is changed.

## Source inspection

The five working demonstrations and their helper functions were read from the baseline repository before writing their respective guides. The documentation uses the equations and parameter definitions in the **actual source**:

- Otsu: categorical histogram counts, cumulative class moments and a first-maximum tie rule. Bright-class polarity and the floating-point quantization convention are explicit.
- Local mean: summed-area neighborhood averaging, `Pre/Post/Both` window sizes, padding rules and a margin of 0.12 in the demonstrated configuration.
- Wellner: four finite-direction reference windows excluding the evaluated pixel, a default sensitivity of 0.15 and orientation-dependent sample count.
- Bradley: padded-image integral sums, direction-specific window sizes, the default sensitivity of 0.20 and a separately labeled centered 0.08 preset. The latter is a post-hoc configuration, not a new algorithm.
- Elementary signals: the precise sample grids, continuous/discrete impulse conventions and 16 displayed signal expressions. These are teaching examples, not neural recording analyses.

No formula, method name or dataset was added solely to make the projects appear more advanced. The signal script's session-wide graphics and warning settings are documented rather than silently changed.

## Measured evidence

The MATLAB R2024a [published-main run](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44769293994) was downloaded and its tables and selected PNG panels were inspected. It contains 60 labeled synthetic cases × 22 configurations, eight unlabeled installed MATLAB examples, 72 passed regression groups and 245 passed extended checks, with zero recorded method errors.

The mean-Dice results are reported for **all 22 configurations**, not a selected subset. Unfavorable results are retained: the corrected default centered Bradley had mean Dice 0.6453 against 0.9583 originally; the explicit 0.08 centered preset reached 0.9542, still below the original. Corrected Wellner RL also declined on these fixtures. There is no inferred Dice score for the eight unlabeled MathWorks images.

Three small CSV files are archived in `docs/results/`. Their Git blob SHA values were verified to match the actual byte sequences in the run artifact. A simple SVG plot of the three centered Bradley averages is embedded in the root README; it is a data-derived chart, **not a synthetic segmentation output or a MATLAB-rendered mask**.

The actual MATLAB mask panels remain in the workflow artifact because no binary figures were silently reconstructed or uploaded under new research filenames. The guides name and caption the specific available figures, and the generator can recreate them.

## Changes and non-changes

New files:

- Five project-specific `README.md` guides in the original project folders.
- `docs/EXPERIMENT_PROTOCOL.md`, `docs/RESULTS_AND_FIGURES.md`, and `docs/results/README.md`.
- `docs/results/` contains three original summary CSVs.
- `docs/figures/bradley_synthetic_dice.svg`, with its data source and limitations written into the image.
- This audit record.

The root README receives direct project-documentation links, the figure and references to the verified protocol and results. The lightweight repository checker is extended to inspect Markdown links in all tracked documents, including each new project guide.

No existing `.m`, `.pdf`, `.mat`, historical snapshot, MATLAB workflow, measured CSV inside an earlier artifact or Git commit was rewritten. The second repository, `Machine_Learning`, contains no executable model; no research narrative or synthetic model results are invented for it.

## Acceptance

- All new relative Markdown links resolve and the repository integrity workflow passes on the proposed PR head.
- Every claim about code behavior agrees with the inspected function implementation.
- The three archived CSV Git blobs match their original workflow files.
- No MATLAB source or reference PDF is added, modified or removed.
- Synthetic numerical results and unlabeled MATLAB images have distinct, clearly stated interpretations.
- A normal PR merge leaves the baseline commit reachable; no history rewrite is used.

An independent, labeled real-document benchmark and publication-rights review would be separate work. Neither can be represented as completed by writing better documentation.
