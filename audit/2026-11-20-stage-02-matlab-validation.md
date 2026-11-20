# Mathematical review of the original MATLAB implementations

**Review date:** 20 November 2026  
**Source:** `main` at `40240cd9d6aed4b6613697b535f84ad6fda80c29`

This review preceded any changes to the 14 original MATLAB files. It examines Otsu thresholding, local means, directional Wellner and Bradley methods, image padding, integral images and elementary signal demonstrations. Three directories contain byte-identical copies of `PadArray.m`. Those copies are treated as one implementation for mathematical discussion, while their individual paths remain listed below.

The central question was whether each computation matched the algorithm it purported to implement. I distinguished errors that can be demonstrated by elementary counterexamples from cases dependent on MATLAB type semantics or unavailable runtime behavior. The work was a source inspection supported by independent numerical references; the original MATLAB scripts were **not executed in this stage**. Their later successful or unsuccessful execution is a separate event in the project history.

## Source-level findings

| Current tracked source (relative to repository) | Status and specific findings |
|---|---|
| `Image Processing/Matlab/Chapter 2 - Image Thresholding/OTSU Binarization/ComputeHistogram.m` | **P0: possible uint8 saturation at maximum intensity** in `L=max(I(:))+1`, `HIST(Temp+1)` (lines 9, 17 and color equivalents). Native-class integer arithmetic should be checked in MATLAB and replaced by explicit double/int indexing. Also check 16-bit, logical, floating-point and empty inputs; code assumes integer intensity bins starting at zero. |
| `.../OTSU Binarization/Project1_OtsuBinarization.m` | **P1:** same native-class `L` risk at line 100; class weights at line 130 are mathematically reasonable for nonempty classes; ties/degenerate images and `ylim([0,max(VarBet)*1.5])` need dedicated tests. Verify intensity-to-bin mapping and threshold convention; GUI depends on sample images and interactivity. |
| `.../Simple Mean Binarization/ImageMean.m` | **P1:** nested-loop local means are well-defined for valid nonempty compatible dimensions, but `Mu` grows by implicit assignment with no preallocation, and empty loop ranges leave `Mu` undefined. Test zero padding width, small images, and class handling. Both mode uses `(2Nr+1)x(2Nc+1)` window, unlike Pre/Post `(Nr+1)x(Nc+1)`; comparisons have different neighborhood support. |
| `.../Simple Mean Binarization/PadArray.m` | **P1:** same SHA as the copies in Wellner and Bradley; validate all 3 directions x 5 padding types with exact small arrays, including zero pad sizes and pad widths exceeding input sizes. Current circular/symmetric indexing can fail when requested pad width exceeds a dimension. Invalid direction/type has no explicit error path. |
| `.../Simple Mean Binarization/Project2_PadArrayMeanBinarization.m` | **P0 output mismatch:** seventh subplot displays `BW4` instead of computed `BW7` (lines 102–106). First case selects padding type `ones` but labels it as Replicate. Nine subplot comparisons mix one-sided and two-sided neighborhood sizes. Hard-coded 100-pixel pad widths reject or behave unexpectedly on smaller inputs. |
| `.../Wellner Thresholding/PadArray.m` | Identical blob SHA `19d50f739f68d55dd7f589c349d0d57af7c0abae`; same audit as above. |
| `.../Wellner Thresholding/WellnerImage.m` | **P0:** RL uses `J(i,j:j+Nc)` (S+1 samples) but divides by S (lines 44–47). On constant ones with width 8, S=1, T=15, replicate padding: threshold=1.7 and a one-valued pixel is incorrectly set to zero. **P0:** DU uses Post padding but UD's Pre-index pattern (lines 75–89), shifting the sampled origin and generating incorrect boundary behavior. **P1:** `S=round(width/8)` can be zero for narrow images, causing zero division and malformed padding; both vertical modes also derive S from image width rather than height. Inputs/options are not validated. |
| `.../Wellner Thresholding/Project3_WellnerThresholding.m` | No independent core mathematical algorithm; GUI uses four directions x three pad styles and inherits `WellnerImage` and `PadArray` issues. Titles and screenshots must not be treated as evidence of numeric validity. |
| `.../Bradley Thresholding/PadArray.m` | Byte-identical third copy of `PadArray.m`; same audit. |
| `.../Bradley Thresholding/IntegralImage.m` | Prefix-sum recurrence matches `cumsum(cumsum(double(I),1),2)` on finite 2D arrays. Mark **conditional pass by inspection** for this definition; test 1x1, rectangular, zero, large-intensity and NaN cases in MATLAB. |
| `.../Bradley Thresholding/IntegralImagePlus.m` | Rowwise alternative prefix-sum recurrence is algebraically equivalent; **conditional pass by inspection**, pending MATLAB tests. |
| `.../Bradley Thresholding/BradleyImage.m` | **P0:** inclusive integral-image rectangle `J(x2,y2)-J(x1-1,y2)-J(x2,y1-1)+J(x1-1,y1-1)` contains `(x2-x1+1)(y2-y1+1)` pixels while `Count` omits both +1 terms (lines 37–46). At 64x64, S=8, half-width=4: Count=64 vs true 81 (20.99% understatement). **P0:** for Pre or Post, the loops visit only 59x59 positions on a 64x64 input with Nr=Nc=5 (lines 35–36), leaving a 5-pixel bottom/right strip in zero-initialized `BW`. **P0:** padding the *integral image* is not equivalent to computing the integral of the appropriately padded *image*; boundary rectangle sums are not generally valid. Add a separate proof and test for intended border semantics. Validate short dimensions and missing opts fields. |
| `.../Bradley Thresholding/Project4_BradleyThresholding.m` | **P1:** comments and final supertitle incorrectly say Wellner, although `BradleyImage` runs. Nine pad/direction combinations inherit Bradley problems. No automated assertions. |
| `Signal Processing/Matlab/Chapter 1- Define Signal/Project1_CDSignals.m` | **P0 pedagogical problem:** discrete `Sin_Wave_n=sin(2*pi*5*n/10)=sin(pi*n)=0` for every integer n. **P1:** continuous impulse proxy of amplitude 100 for `|t|<=0.01` is not unit-area (ideal continuous integral 2; sampled Riemann approximation ~1.9 subject to floating-point endpoints). `sawtooth` requires Signal Processing Toolbox, `sinc` availability must be checked, and use of `stem` for dense continuous-time impulse samples should be documented as plotting choice, not exact Dirac representation. |

## Independent numerical checks

The following tests were run against mathematical reference implementations rather than against the MATLAB runtime. `PASS` denotes agreement within this limited reference calculation; it does not certify the original MATLAB file.

| ID | Case | Observation |
|---|---|---|
| REF-01 | 4x4 increasing array, 2D integral image | Double cumulative sum reproduces the expected prefix sums (**PASS for mathematical reference**) |
| REF-02 | 64x64, Bradley region 9x9 | Source Count 64; actual inclusive cardinality 81 (**FAIL**) |
| REF-03 | 64x64, Nr=Nc=5, Bradley Pre and Post | Only 59 rows and 59 columns assigned instead of 64 (**FAIL**) |
| REF-04 | Wellner RL, 8-column constant ones, replicate boundary, S=1 | Mean uses 2 samples divided by 1, decision 0 instead of expected 1 (**FAIL**) |
| REF-05 | DSP discrete sine, n=-10..10 | Maximum numerical absolute amplitude approximately 1.23e-15 (**FAIL as illustrative sinusoid**) |
| REF-06 | DSP impulse rectangle, dt=.001 | Approximate discrete sample area 1.9, not 1 (**FAIL as unit-area approximation**) |
| REF-07 | All 14 MATLAB files | **NOT RUN** in MATLAB or Octave |
| REF-08 | Otsu uint8 max=255 | **NOT RUN** in MATLAB; arithmetic semantics need MATLAB reference test |

## Interpretation and subsequent verification

The clearest source-level defects concerned mismatched Bradley integral-image rectangle areas, incomplete Pre/Post output coverage, Wellner's inconsistent sample counts and scan-direction indexing, and a Nyquist-degenerate discrete sine demonstration. The histogram and padding routines also required explicit input-class and boundary tests before being treated as reliable.

The follow-up MATLAB work was therefore specified to compare every window sum with a direct neighborhood calculation, exercise small and degenerate inputs, and retain original data types where meaningful. Otsu required a stated tie-breaking and intensity-bin convention; graphical scripts required distinct tests for numerical output and figure labeling. Successful array-shape assertions alone could not establish image-segmentation quality.

Subsequent branches introduced rewritten functions, MATLAB regression tests and controlled segmentation comparisons. Their results should be read alongside this source-level record, not retroactively attributed to Stage 02.

This branch changes documentation only. The original MATLAB files, PDFs, Git history and default branch were left unchanged.
