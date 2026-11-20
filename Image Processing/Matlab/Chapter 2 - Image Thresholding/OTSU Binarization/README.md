# Otsu thresholding

This project implements global grayscale binarization by maximizing the variance between two intensity classes. It is useful when the histogram separates foreground and background reasonably well, but a single threshold cannot represent illumination that changes substantially across an image.

The working files are [`ComputeHistogram.m`](ComputeHistogram.m), [`OtsuThreshold.m`](OtsuThreshold.m) and the interactive [`Project1_OtsuBinarization.m`](Project1_OtsuBinarization.m). The folder retains a copy of Otsu's 1979 paper, *A Threshold Selection Method from Gray-Level Histograms*, as a historical reference; permission to redistribute that specific PDF has not been independently established.

## Calculation

For histogram bins `0,...,L-1`, let `h(k)` be the pixel count and `p(k)=h(k)/sum(h)`. For a candidate threshold `t`, the lower class has weight `w0(t)=sum(p(k), k<=t)`, and the upper class has `w1(t)=1-w0(t)`. Their mean levels are `mu0(t)` and `mu1(t)`. The objective is

```text
sigma_between^2(t) = w0(t) * w1(t) * [mu0(t)-mu1(t)]^2.
```

The function uses the algebraically equivalent cumulative-moment form. Candidate thresholds with an empty class have variance zero; the first maximizer is selected if several thresholds tie. A nearly uniform histogram may not admit an informative two-class split.

`ComputeHistogram` supports logical, `uint8`, `uint16`, and finite `single`/`double` images within `[0,1]`. Integer histograms retain their native intensity bins (two bins for logical, 256 for `uint8`, 65,536 for `uint16`). Floating-point images are quantized to 256 levels using nearest-level rounding. The returned threshold for floating-point inputs is the boundary between the selected bin and the next bin, but the binary decision is made on the *quantized bin indices* so it agrees with the histogram used to estimate the threshold.

**Polarity:** `OtsuThreshold` returns `BW=true` for pixels assigned to the **higher-intensity class**. A dark-object foreground mask is `~BW`. This distinction matters when comparing Otsu with other methods using a dark-positive ground truth.

## Run the example

In MATLAB R2024a with Image Processing Toolbox, navigate to this folder and execute:

```matlab
Project1_OtsuBinarization
```

Choose one of the listed MATLAB sample images. The script displays the grayscale input, histogram, class probabilities, cumulative probabilities, between-class variance and binary output; it also prints the selected level. It is an interactive demonstration and does not save an accuracy score.

For a programmatic call, with the folder on the MATLAB path:

```matlab
I = imread('cameraman.tif');
[brightClass, threshold, detail] = OtsuThreshold(I);
darkForeground = ~brightClass;
```

`detail` includes the histogram, cumulative probabilities, variance profile and selected level. The computation is global: no spatial neighborhood information enters the threshold.

## Evaluation and limitations

The [matched evaluation protocol](../../../../docs/EXPERIMENT_PROTOCOL.md) compares Otsu against local methods on the same synthetic image pixels and known dark-object masks. In the earlier three-condition demonstration, Otsu's Dice fell from `1.000` under uniform lighting to approximately `0.475` under uneven lighting and `0.398` at reduced contrast. These values belong to **that specific fixture**, not to an independently sampled document corpus. In the low-contrast fixture, the primary error was background oversegmentation (21,104 false-positive pixels).

The original interactive Otsu script is not directly called as a function inside the legacy benchmark. Its numerical threshold loop was transcribed for comparison while the original histogram function was invoked directly; this difference is disclosed in the [validation guide](../../../../tests/final/README.md). Use the current function when the objective is to reproduce the corrected numerical implementation.
