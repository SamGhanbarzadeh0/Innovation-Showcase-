# Directional adaptive thresholding (Wellner-style)

This example studies the dependence of a pixel's binary decision on the direction in which its local reference is constructed. It is a **directional finite-neighborhood implementation**, not a claim that every detail of Wellner's original streaming algorithm has been reproduced.

The working files are [`WellnerImage.m`](WellnerImage.m), [`Project3_WellnerThresholding.m`](Project3_WellnerThresholding.m), and a local [`PadArray.m`](PadArray.m). The folder also contains the historical *Wellner Method* PDF, whose redistribution permission has not been independently confirmed.

## Reference window and threshold

For intensity `I(r,c)`, the method forms an arithmetic reference mean `R_d(r,c)` over exactly `S` adjacent pixels along direction `d`. The current pixel is **excluded** from that reference. The decision is

```text
BW(r,c) = [ I(r,c) > (1 - T) * R_d(r,c) ].
```

The default sensitivity is `T=0.15`. The implementation accepts an optional `opts.Sensitivity` between `0` and `1`, excluding `1`. The returned logical `BW=true` identifies pixels brighter than their directional reference; the labeled benchmark takes `~BW` as dark foreground.

| `opts.Method` | Reference pixels | Number of pixels |
|---|---|---|
| `LR` | pixels immediately left | `max(1,round(width/8))` |
| `RL` | pixels immediately right | `max(1,round(width/8))` |
| `UD` | pixels immediately above | `max(1,round(height/8))` |
| `DU` | pixels immediately below | `max(1,round(height/8))` |

At an image boundary, `PadArray` supplies the missing reference pixels under the chosen extension rule: replication (`Rp`), symmetric reflection (`Sm`), or circular wrapping (`Cr`). The complete names are also accepted. No averaging takes place across both directions unless the caller explicitly constructs a separate combination; the supplied function always uses one direction at a time.

## Run

In MATLAB R2024a with Image Processing Toolbox, navigate to this folder and run:

```matlab
Project3_WellnerThresholding
```

After choosing a sample image, the script displays all 12 combinations of scan direction and boundary rule. Each panel is an input/output montage, not a quantitative accuracy visualization.

A direct call is:

```matlab
I = imread('cameraman.tif');
opts = struct('Method','DU','PadValue','Rp','Sensitivity',0.15);
brightBackground = WellnerImage(I,opts);
darkForeground = ~brightBackground;
```

For a valid comparison, keep input pixels, boundary rule and sensitivity fixed across directions. Apparent gaps in thin strokes may reflect the directional reference rather than a faulty image export.

## Findings and limits

The [MATLAB comparison](../../../../docs/EXPERIMENT_PROTOCOL.md) retains the original and corrected functions separately for LR, RL, UD and DU. In the earlier **36-image synthetic comparison**, the corrected DU implementation had mean Dice approximately `0.743`, compared with approximately `0.040` for its original counterpart. Those measurements indicate a substantial change on that test design; they do **not** prove the corrected directional method is preferable to all other local thresholding algorithms.

Directional methods can respond differently to the same stroke depending on orientation and local brightness. The eight installed MATLAB example images were therefore used for visual inspection only, without fabricated Dice/IoU values. A general claim about text binarization would require independently labeled real-document images and a fixed method-selection protocol.
