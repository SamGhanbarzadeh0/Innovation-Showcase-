# Repository layout and MATLAB paths

This file records the structure used after the November 2026 housekeeping pass. The original folder names, including spaces and the chapter titles, remain unchanged because the demonstrations and earlier project references depend on them.

| Directory | Contents |
|---|---|
| [Image Processing](../Image%20Processing) | Otsu, mean, Wellner and Bradley thresholding exercises |
| [Signal Processing](../Signal%20Processing) | Continuous- and discrete-time signal demonstrations |
| [tests](../tests) | Regression and benchmark scripts |
| [tests/final](../tests/final) | Matched original-versus-revised MATLAB tests |
| [tests/legacy_snapshot](../tests/legacy_snapshot) | The 14 original MATLAB blobs, pinned by Git SHA |
| [audit](../audit) | Dated audit and experiment records |
| [tools](../tools) | Lightweight repository integrity checks |
| [.github/workflows](../.github/workflows) | MATLAB and structural checks in GitHub Actions |

## Repeated local helper

Three project folders include `PadArray.m`. Their Git content SHA is identical. Each demonstration can therefore resolve its own local helper; the final tests add these folders to the MATLAB path. Consolidating them would change path resolution for separate projects and introduce a source-level change unrelated to housekeeping. Stage 05 retains all three and checks that they remain identical.

The final regression harness deliberately resolves original function names from `tests/legacy_snapshot/` during baseline comparisons. Do not add that entire historical folder recursively to your permanent MATLAB path. To run the complete suite, select the repository root in MATLAB and execute:

```matlab
run('tests/final/run_final.m')
```

## Retention decisions

Eight tracked `.DS_Store` files are removed from the current working tree. They are Finder metadata, not research data; their original Git objects remain in the original `ddfd1b310303da5dccddf0c143224646af82cd01` commit. MATLAB sources, reference PDFs and archived baseline source files are not removed or renamed.

The root README describes the scientific scope. [The output policy](OUTPUT_POLICY.md) distinguishes temporary run products from files intentionally published in Git. The detailed test methods are in [the validation guide](../tests/final/README.md).
