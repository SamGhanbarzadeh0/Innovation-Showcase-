# Bradley-style adaptive thresholding with integral images

This project computes a local intensity threshold from a rectangular neighborhood. Its main computational device is the summed-area table: once cumulative sums have been formed, each local sum requires four indexed values, independently of the number of pixels in the neighborhood.

The working implementation is [`BradleyImage.m`](BradleyImage.m). Two explicit cumulative-sum examples, [`IntegralImage.m`](IntegralImage.m) and [`IntegralImagePlus.m`](IntegralImagePlus.m), calculate the same two-dimensional prefix sums in opposite accumulation orders. The [interactive script](Project4_BradleyThresholding.m) compares boundary extension and window placement, using the local [`PadArray.m`](PadArray.m) helper.

## Algorithm

Let `I(r,c)` denote pixel intensity and `M_d(r,c)` the mean of a padded rectangular window positioned according to direction `d`. The binary decision is

```text
BW(r,c) = [ I(r,c) > (1 - T) * M_d(r,c) ].
```

**`BW=true` identifies the brighter class**; to evaluate dark-object segmentation, use `~BW`. The strict comparison `>` is intentional. The function's default is `T=0.20`. Its sensitivity can be supplied through `opts.Sensitivity`.

The local window is derived from image size. The code sets

```text
S     = max([1,1], round([height,width]/8))
radius = max([1,1], round(S/2)).
```

For `Both`, the window is `(2*radius_row+1) x (2*radius_col+1)`. For `Pre` and `Post`, it is `(radius_row+1) x (radius_col+1)`, placed on the preceding or following side, respectively. Boundary values are supplied by replicated, symmetric, or circular padding.

Given padded image `J`, the prefix table has a zero first row and column:

```text
C(r,c) = sum_{i<r, j<c} J(i,j).
window_sum = C(r2,c2) - C(r1,c2) - C(r2,c1) + C(r1,c1).
M_d = window_sum / (window_rows * window_columns).
```

The reference calculation is therefore not the same as moving a sum across a *preexisting* integral image: the program pads the image first, then constructs the integral image. That distinction was material in the correction of the original code.

## Run the example

In MATLAB R2024a with Image Processing Toolbox, open this folder and execute:

```matlab
Project4_BradleyThresholding
```

The script prompts for a MATLAB sample image and displays nine direction/padding combinations. In this **demonstration only**, the centered `Bo` cases explicitly use sensitivity `0.08`; `Pr` and `Po` retain the function default `0.20`. Titles state the sensitivity actually used. An input/output montage is not a ground-truth quality measurement.

For a direct call:

```matlab
I = im2double(imread('cameraman.tif'));
options = struct('Direction','Bo','PadValue','Rp','Sensitivity',0.08);
brightBackground = BradleyImage(I,options);
darkForeground = ~brightBackground;
```

Omitting `Sensitivity` uses `0.20`. The option `Direction` accepts `Bo`, `Pr`, `Po` or their unabbreviated forms. `PadValue` accepts `Rp`, `Sm`, `Cr` or their unabbreviated forms.

## What the audit established

The initial mathematical repair corrected local rectangle sums and boundary coverage, but the synthetic masks changed substantially at `T=0.20`. The [reproducible analysis](../../../../audit/2026-11-20-stage-03c-bradley-quality-guard.md) records the resulting regression. A separate `T=0.08` centered configuration was selected after inspecting the first 36 synthetic cases, then examined on 24 additional synthetic cases.

| Labeled synthetic set | Original centered | Corrected, `T=0.20` | Centered preset, `T=0.08` |
|---|---:|---:|---:|
| Earlier 36 cases | 0.959523 | 0.634746 | 0.955697 |
| Additional 24 cases | 0.956426 | 0.661026 | 0.952052 |
| All 60 cases | **0.958284** | 0.645258 | **0.954239** |

These are **mean Dice scores**, not classification accuracy across naturally sampled documents. The calibrated preset brought performance close to the original but did **not** exceed it. The additional geometric cases are still synthetic and were introduced within the same iterative research process; they should not be called an independent external benchmark.

For the full test design and the input masks, see [the experiment protocol](../../../../docs/EXPERIMENT_PROTOCOL.md). Tests compare the preserved original functions, corrected functions, the labeled centered preset and selected MATLAB toolbox references. All eight installed MATLAB images lack trusted segmentation labels in this analysis, so their output differences cannot be converted into real-image Dice values.
