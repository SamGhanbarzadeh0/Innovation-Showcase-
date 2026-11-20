# Bradley thresholding: numerical correction and sensitivity calibration

**Observed source runs:** [36-case MATLAB comparison](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44758952636) and [60-case MATLAB comparison](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44763150733)  
**MATLAB environment:** R2024a with Image Processing Toolbox

The corrected Bradley calculation uses a summed-area table of the padded intensity image and normalizes each local window by its actual sample count. That repaired a defect in the earlier implementation, but changing the window arithmetic altered its output at the original sensitivity setting.

## What the initial comparison found

Across 36 synthetic images with reference masks, the original centered implementation achieved mean Dice **0.959523**. The corrected function with `Sensitivity=0.20` reached **0.634746**, with 24 paired cases worse than the baseline, one better and 11 tied. A regression suite that checked arithmetic and array dimensions had passed; it had not detected this loss of segmentation quality.

The method exposes a sensitivity parameter, so I evaluated a separate centered configuration with `Sensitivity=0.08`. This value was selected after inspecting the first 36 cases. Those results are exploratory and cannot be treated as independent evidence for the choice.

The later audit introduced 24 further fixtures with different geometric arrangements, retaining deterministic illumination, contrast and noise controls. A predeclared project-level acceptance check required the calibrated version to exceed `T=0.20` by more than 0.10 mean Dice and to remain within 0.025 mean Dice of the original in each group.

## Verified R2024a results

| Synthetic cases | Original Bradley | Corrected, T=0.20 | Centered preset, T=0.08 |
|---|---:|---:|---:|
| Earlier 36 | 0.959523 | 0.634746 | 0.955697 |
| Additional 24 | 0.956426 | 0.661026 | 0.952052 |
| All 60 | **0.958284** | 0.645258 | **0.954239** |

The final [GitHub Actions execution](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44763150733) passed 72 regression groups, 245 extended numerical/boundary checks and the defined quality guard. All **1,320** synthetic mask evaluations were recorded without runtime errors, and their saved confusion counts and Dice values were independently reconciled. Eight MATLAB-installed example images also completed without runtime errors.

The preceding [failed run](https://github.com/hesamghd/Innovation-Showcase-/actions/runs/44762387521) was caused by a mistake in the new quality-guard code: it indexed the list of method names rather than the 60 case rows in the results table. That indexing error was corrected and the workflow was rerun. The failure remains in GitHub's execution history.

## Decision and limits

The `T=0.08` centered preset recovers most of the synthetic performance lost under `T=0.20`, while remaining slightly below the original mean Dice. It is a parameter choice, not a new thresholding algorithm. The function's default `T=0.20` is retained; the centered preset is explicit in the revised demonstration and comparison suite.

The eight installed MATLAB samples provide a useful visual check of object boundaries, text detail and illumination artifacts, but no trusted reference masks were supplied for those images. Neither the 60-case synthetic score nor the successful CI run establishes general accuracy on real documents. A labeled external benchmark would be required for that claim.
