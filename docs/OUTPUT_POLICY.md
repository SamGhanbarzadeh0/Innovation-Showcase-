# Source files and validation outputs

The repository holds source code, audited historical implementations, test programs and records of measured results. MATLAB produces run-specific PNG figures, CSV tables, MAT arrays and a ZIP archive under `validation_results/`. This directory is ignored locally; the MATLAB GitHub Actions workflow uploads it as a temporary workflow artifact.

Only the generated output directory is excluded. `.mat`, `.csv`, `.nwb`, `.png`, `.fig` and `.pdf` are **not ignored globally**, since they may be scientifically meaningful. Curated results can be committed with a documented input, method and generating commit. Credentials and restricted input data must not be committed.

The preserved 14-file MATLAB source archive is checked against [the original SHA manifest](../tests/final/original_source_manifest.csv). The three active `PadArray.m` copies are intentionally retained and verified for equality.

The two existing research-reference PDFs remain unchanged. Their continued presence does not establish redistribution permission. The structural review neither interprets their licenses nor changes their Git history.

Finder and editor byproducts such as `.DS_Store`, `*.asv` and swap files are excluded from future tracking. Removing the eight existing Finder files from the current branch does not erase them from earlier commits.

The repository integrity script checks these decisions without running MATLAB. It is not a substitute for checking actual algorithmic correctness, research validity or account security.
