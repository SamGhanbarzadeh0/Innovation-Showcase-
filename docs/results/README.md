# Archived MATLAB benchmark summaries

These three CSV files are **unchanged copies** of the tables produced by the published MATLAB R2024a workflow at [run 44769293994](https://github.com/SamGhanbarzadeh0/Innovation-Showcase-/actions/runs/44769293994). They are retained in the repository because GitHub Actions artifacts have limited retention periods.

| File | Git blob SHA | Contents |
|---|---|---|
| [`method_summary_2026-11-20.csv`](method_summary_2026-11-20.csv) | `e695b08da6675765be99a6ac5d5e8e3c57941cb3` | 22 configurations, 60 synthetic cases each: mean/median/min Dice, mean IoU and median measured runtime |
| [`paired_comparison_2026-11-20.csv`](paired_comparison_2026-11-20.csv) | `16c7e2e6e82fae40344e551cd3eecca7ac537e22` | 12 matched old-versus-revised comparisons, counts of worse/better/tied fixtures |
| [`bradley_quality_gate_2026-11-20.csv`](bradley_quality_gate_2026-11-20.csv) | `9297ccd523a740b83834f7b71fd67dfae016b6bc` | Centered Bradley mean Dice on the earlier 36, additional 24 and combined 60 cases |

Each blob SHA was checked against the corresponding source CSV in the workflow ZIP; the files were not rounded or recomputed for this archive. The generating MATLAB source is fixed by commit `ddfd1b310303da5dccddf0c143224646af82cd01` and the [evaluation protocol](../EXPERIMENT_PROTOCOL.md).

These are **summaries**, not a substitute for the underlying `matched_arrays.mat`, per-case `matched_metrics.csv`, MATLAB installation details or example-image PNGs. The larger arrays and images remain available in the Actions artifact during its retention window and can be regenerated with:

```matlab
run('tests/final/run_final.m')
```

No native MATLAB example-image Dice score is reported: this experiment did not include verified segmentation masks for those images. The interpretation and limitations appear in [Results and figure provenance](../RESULTS_AND_FIGURES.md).
