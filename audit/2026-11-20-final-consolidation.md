# Stage 03 final consolidation — methods, controls and release criteria

Date: 2026-11-20. The user requested one consolidated final correction pass following two separate MATLAB runs. The original programs remain attributed and preserved; no project history or reference PDF has been rewritten.

## Prior empirical evidence

- Original Stage 03 MATLAB R2024a run: 69 test groups passed; the initial synthetic figures were unsuitable for demonstrating image-segmentation quality.
- Revised Stage 03B MATLAB R2024a run: 72 regression groups passed. All 27 submitted predictions were independently reconciled against the supplied TP/FP/TN/FN and Dice/IoU metrics. Local mean achieved approximately 1.000, 1.000 and 0.998 Dice on the three prior controlled conditions, but the same underlying geometry was reused, and the text example had no ground truth.
- Therefore the revised Stage 03B result **does not prove universal superiority** or a statistically independent improvement over the original project.

## Final corrective approach

1. The exact pre-remediation algorithm source is pinned by Git object SHA inside `tests/legacy_snapshot` (14 files); metadata table in `tests/final/original_source_manifest.csv`.
2. Previously corrected Otsu, Bradley, Wellner, mean thresholding, integral image, padding and DSP source files are kept on a separate feature branch; their numerical and interpretive contracts are independently checked.
3. A single entrypoint `tests/final/run_final.m` runs the old regression suite, a new native-`padarray` differential test and 36 synthetic single-polarity test fixtures. No per-case tuning or model selection is permitted.
4. Source-level path switching runs the **actual original function files** for mean, Wellner and Bradley; the original Otsu interactive script cannot be called as a function and is **transcribed for the original threshold loop only**, using the unmodified original `ComputeHistogram.m`. This distinction is disclosed.
5. MATLAB toolbox methods are included, but sensitivity/window definitions are not asserted to be identical or optimally tuned between methods.
6. Every attempted method/case combination must appear in the CSV. Runtime errors retain their error ID, missing performance metrics are NaN and are excluded only transparently (with unmatched counts).
7. Primary code-level PASS criteria: all regression assertions pass, all extended edge checks pass, no corrected or toolbox algorithm crashes, and the predefined figures export. Legacy failure is evidence of an original bug, not a reason to falsely fail the repaired functions.
8. Primary scientific interpretation: describe per-condition error modes, the full distribution of Dice/IoU, and paired old-versus-new effects. No sweeping performance claims on arbitrary imagery.
9. Final code delivery is **not yet MATLAB-executed** until the owner runs the one-command suite; no PR is merged before results are reviewed.

## Evidence gap for quantitative generalization

The benchmark contains 36 deterministic synthetics and their explicit masks, spanning 3 geometric families, 3 illumination profiles, 2 contrast/noise settings and 2 noise realizations. These are deliberately varied but not equivalent to 36 independently collected real documents. Future generalization requires a labeled external benchmark and a held-out protocol. The current source tree includes no authenticated labeled real-document dataset, so a fabricated real-world accuracy number would be unacceptable.

## Account/project preservation

- Default `main` remains at `40240cd9d6aed4b6613697b535f84ad6fda80c29`.
- Historical project files and both PDF references remain as originally committed.
- This phase adds tests, an explicit original-source snapshot, documentation and reproducibility gates only.
- Existing earlier Draft PRs remain unmerged; a separate final PR will be reviewed before any consolidation.
