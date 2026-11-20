# Historical objects and account-security follow-up

**Review date:** 20 November 2026. This note records what could be established through the connected GitHub repository and what remained outside its reach.

The 14 reachable commits were inspected through their Git trees, each returned without truncation. Earlier MATLAB paths, including `Image Processinng`, were identified and the accessible historical text variants screened for common private-key blocks, GitHub token patterns, AWS access-key identifiers and simple credential assignments. The review did not identify matching text. It was not a full history-aware scan of raw Git objects.

Attempts to retrieve certain `.DS_Store` and PDF blobs as text failed because they contain binary data. Their contents, metadata and embedded objects were not independently examined. A local clone and a dedicated secret scanner remain necessary if formal assurance is required. Potential credentials should be revoked or rotated before considering a history rewrite.

## Publications kept in place

The repository contains Nobuyuki Otsu's 1979 IEEE paper, *A Threshold Selection Method from Gray-Level Histograms* (DOI: [10.1109/TSMC.1979.4310076](https://doi.org/10.1109/TSMC.1979.4310076)), and a copy of Pierre Wellner's *Adaptive Thresholding for the DigitalDesk* (technical report EPC-1993-110, 1993). Their publication provenance is identifiable, but the redistribution permissions of the **specific PDFs committed here** have not been established.

The repository owner instructed that both files remain untouched and that PDF cleanup be removed from the present work programme. This resolves the requested repository action, not the underlying copyright question. No PDF was modified or removed.

## Settings available only to the owner

The connector did not expose the account's two-factor authentication status, passkeys, recovery methods, active sessions or authorization scopes. These can be reviewed directly in [GitHub authentication settings](https://github.com/settings/security) and [authorized applications](https://github.com/settings/applications). Private keys, passwords and recovery codes should not be shared to complete this review.

The original source code, historical commits and account settings were not modified by this follow-up.
