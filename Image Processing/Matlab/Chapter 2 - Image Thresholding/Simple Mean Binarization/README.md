# Local-mean adaptive thresholding

This project examines how a local neighborhood and its boundary extension affect binarization. The practical difference from global Otsu thresholding is that every pixel is compared against a nearby mean rather than one threshold for the entire image.

The working implementation comprises [`LocalMeanThreshold.m`](LocalMeanThreshold.m), [`ImageMean.m`](ImageMean.m), a local copy of [`PadArray.m`](PadArray.m), and the interactive [`Project2_PadArrayMeanBinarization.m`](Project2_PadArrayMeanBinarization.m).

## Method

For image intensity `I(r,c)`, let `M(r,c)` be the arithmetic mean of the corresponding padded neighborhood. The implemented decision is

```text
BW(r,c) = [ I(r,c) >= (1 - s) * M(r,c) ].
```

Here `s` is the contrast sensitivity in `[0,1)`, and the default is `0.12`. **`BW=true` means bright background**, while `~BW` is the dark-object mask used in the labeled benchmark. The comparison uses `>=`, which differs from the strict `>` used by some of the other implementations.

The direction argument determines the neighborhood geometry:

| Direction | Local window | Position relative to the evaluated pixel |
|---|---|---|
| `Pre` | `(Nr+1) x (Nc+1)` | preceding rows and columns |
| `Post` | `(Nr+1) x (Nc+1)` | following rows and columns |
| `Both` | `(2*Nr+1) x (2*Nc+1)` | centered |

The two numbers `Nr,Nc` are padding radii, not a total window width. The image is first extended by `PadArray` under one of the supported conventions: `zeros`, `ones`, `Replicate`, `Circular`, or `Symmetric`. `ImageMean` then forms a double-precision summed-area table and evaluates each rectangular sum through four table entries. This avoids a nested neighborhood loop for every pixel.

The margin `s=0.12` was introduced after an earlier zero-margin synthetic example produced many near-equality decisions. The value is an observed **configuration choice**. It does not have a universal statistical interpretation, and the improvement on the previous fixture should not be presented as independent out-of-sample validation.

## Run

In MATLAB R2024a with Image Processing Toolbox, open this folder and run:

```matlab
Project2_PadArrayMeanBinarization
```

The script asks for a MATLAB sample image, converts RGB inputs to grayscale, sets the per-axis radius to `max(1,round(size(I)/16))`, and displays nine combinations of direction and padding rule using the fixed 12% contrast margin.

To use the function without the interactive script:

```matlab
I = im2double(imread('cameraman.tif'));
[brightBackground, meanMap] = LocalMeanThreshold( ...
    I, [9 9], 'Both', 'Replicate', 0.12);
darkForeground = ~brightBackground;
```

The function returns a logical mask and the actual local-mean image. A manual result should be checked for image shape, foreground polarity and appropriate radius before comparing it with a reference mask.

## Validation and interpretation

The final [60-case benchmark](../../../../docs/EXPERIMENT_PROTOCOL.md) includes the original zero-margin implementation, the corrected zero-margin implementation and the corrected centered 12% configuration as *separate methods*. The earlier three-condition fixture showed Dice `1.000`, `1.000` and `0.998352` for the centered 12% configuration, but all three reused one geometry. The larger benchmark deliberately varies geometry, illumination, contrast and noise.

A small adaptive neighborhood can preserve fine local detail while treating slowly varying illumination more robustly than one global threshold. Conversely, background texture, edge padding, the chosen neighborhood width and the margin can alter the mask. The figures produced with MATLAB sample images are qualitative unless an independently annotated reference mask is provided.
