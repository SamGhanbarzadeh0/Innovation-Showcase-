# Results and figure provenance

**Evaluated source:** `ddfd1b310303da5dccddf0c143224646af82cd01` (MATLAB code; unchanged by Stages 05–06).  
**Executed environment:** MATLAB R2024a, [GitHub Actions run 44769293994](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44769293994).  
**Primary source files:** `method_summary.csv`, `paired_comparison.csv`, `matched_metrics.csv`, `bradley_quality_gate.csv`, `matched_arrays.mat`, and the generated PNG panels in the workflow's `MATLAB-R2024a-quality-guard-validation` artifact.

I checked these data against the stored run output, rather than copying scores from a screenshot. The artifact records 60 synthetic cases and 22 method configurations, all 1,320 attempts with a successful execution status. The numerical check reported 72 regression groups and 245 edge-case assertions passing. It also processed all eight installed MATLAB example images. These are **execution and synthetic-benchmark results**, not claims of general real-image accuracy.

## Synthetic segmentation results

Scores below are the **unweighted mean Dice across the same 60 labeled synthetic cases**. Each method has 60 successful cases and zero runtime errors; more decimal places than shown would not imply greater generalizability.

| Configuration | Mean Dice | Minimum case Dice |
|---|---:|---:|
| Original Otsu | 0.6900 | 0.2255 |
| Corrected Otsu | 0.6858 | 0.2187 |
| MATLAB toolbox Otsu | 0.6880 | 0.2221 |
| Original local mean, zero margin | 0.4143 | 0.2692 |
| Corrected local mean, zero margin | 0.4143 | 0.2692 |
| Corrected local mean, margin 0.12 | **0.9226** | 0.7350 |
| MATLAB toolbox adaptive mean | **0.9517** | 0.8335 |
| Original Wellner LR | 0.7619 | 0.4983 |
| Corrected Wellner LR | 0.7619 | 0.4983 |
| Original Wellner RL | 0.8331 | 0.6268 |
| Corrected Wellner RL | 0.8038 | 0.5369 |
| Original Wellner UD | 0.7320 | 0.5335 |
| Corrected Wellner UD | 0.7320 | 0.5335 |
| Original Wellner DU | **0.0358** | 0.0053 |
| Corrected Wellner DU | **0.7315** | 0.5306 |
| Original Bradley Pre | 0.5760 | 0.4656 |
| Corrected Bradley Pre | 0.6355 | 0.1512 |
| Original Bradley Post | 0.5843 | 0.4339 |
| Corrected Bradley Post | 0.6659 | 0.1544 |
| Original Bradley Both | **0.9583** | 0.8478 |
| Corrected Bradley Both, default 0.20 | 0.6453 | 0.0860 |
| Corrected Bradley Both, centered preset 0.08 | **0.9542** | 0.8582 |

The table intentionally retains unfavorable results. For example, correcting Wellner DU increased mean Dice by about **0.696**, while corrected Wellner RL declined by about **0.029**. Corrected Otsu was about **0.004** below its original numerical-transcription baseline. Local Mean at zero margin was unchanged, whereas the explicit 12% margin increased mean Dice by about **0.508** on the same cases. These are paired fixture effects, not estimates of causal benefit for arbitrary documents.

The strongest Bradley result in this table is the **original centered implementation**, not the new default. The corrected centered preset at `0.08` approached the original but remained about **0.004** lower in mean Dice. This is why the code exposes the preset explicitly instead of silently replacing the function's default or claiming to have improved on every historical output.

### Bradley: earlier and additional geometric cases

| Synthetic group | Original centered | Repaired default 0.20 | Calibrated preset 0.08 |
|---|---:|---:|---:|
| Earlier 36 | 0.959523 | 0.634746 | 0.955697 |
| Additional 24 | 0.956426 | 0.661026 | 0.952052 |
| Combined 60 | **0.958284** | 0.645258 | **0.954239** |

The `0.08` value was selected after seeing earlier results. Although the later 24 cases use different synthetic geometries, they do not form a blind external holdout. The stated non-inferiority tolerance is a project acceptance rule, not a statistical confidence interval. The exact methodological decision is recorded in [the Bradley audit](../audit/2026-11-20-stage-03c-bradley-quality-guard.md).

## Figure selection and captions

All figures described here are actual exports of the MATLAB workflow. **They are not committed as permanent source-controlled images**, and they must be retrieved from the workflow artifact while it is retained. The corresponding arrays and CSV files remain the quantitative evidence. Images in a README should never be confused with a separate experiment or an automatically inferred accuracy value.

| Filename in run artifact | Suitable figure caption | Interpretation |
|---|---|---|
| `case_light_1.png` | Matched threshold outputs under the first illumination profile, with known binary reference | Shows a fixed first-geometry, high-contrast, first-seed case; Dice labels are ground-truth based |
| `case_light_2.png` | Response to spatially varying illumination on the same predefined geometry | The zero-margin mean generates false foreground texture; Otsu can classify a large background region as foreground |
| `case_light_3.png` | Matched outputs under the third illumination profile | A third predefined illumination condition, **not** a new object geometry |
| `native_printedtext.png` | Unlabeled MATLAB text image: qualitative comparison of source, corrected and toolbox masks | A broad dark-background artifact remains under global Otsu; fine character detail is also lost by some local methods; no GT metric applies |
| `native_cameraman.png` | Natural-image visual comparison with matched inputs | Illustrates differences in thresholded texture and contours; pixel disagreement is not segmentation accuracy |
| `native_coins.png` | MATLAB sample image with repeated object boundaries | Shows method-dependent fragmentation and foreground occupancy without an annotated reference mask |

The other five sample-image panels are `native_rice.png`, `native_peppers.png`, `native_saturn.png`, `native_pout.png`, and `native_liftingbody.png`. The scripts also generate `printedtext_comparison.png` as an additional descriptive panel. For a permanent publication-quality gallery, the selected figures should be archived alongside their CSV/MAT provenance and the reference masks where available, rather than relying on expiring workflow artifacts.

## Limitations that matter when citing these results

1. All 60 labeled images are generated by one controlled synthetic fixture program. Differences in geometry, illumination and random seed make the comparison informative, but they do not establish a population of independent scanned documents.
2. The methods do not share a common window construction or sensitivity optimization budget. Comparisons address **specified configurations**.
3. The MATLAB example images were resized for fixed-cost inspection and lack verified foreground labels. Their connected-component counts, dark-pixel fractions and pairwise agreements are descriptive only.
4. The reported execution times include MATLAB implementation and calling overhead; they should not be read as a platform-independent algorithmic-speed ranking.
5. No comparison here demonstrates clinical utility, segmentation of biomedical recordings, or universally optimal thresholding.

## Retrieve the evidence

Open [GitHub Actions run 44769293994](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44769293994), select **Artifacts**, and obtain `MATLAB-R2024a-quality-guard-validation` while available. Its tables, binary masks and images permit an independent review. The generator and exact input definitions are in [the experiment protocol](EXPERIMENT_PROTOCOL.md) and [the MATLAB validation entry point](../tests/final/run_final.m).
