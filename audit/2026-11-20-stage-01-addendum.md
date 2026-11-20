# Stage 01 addendum — historical objects, publication rights and account security

Audit follow-up date: 2026-11-20. This document supplements `2026-11-20-stage-01.md`; it does not supersede the SHA-pinned baseline and makes no changes to prior work.

## Git history verification

The 14 accessible commits from the 2024-11-02 to 2024-11-07 history were enumerated. Each commit's recursive Git tree was separately queried and reported as not truncated. This exposed historical paths from `Image Processinng`, including previous MATLAB versions that no longer appear under the current paths. The additional historical **text** blob variants were checked for common private-key headers, GitHub PATs, AWS access keys, straightforward credential assignments and user-specific absolute paths; no hits were found. Accessible commit diffs were also reviewed for these basic patterns.

**Limit:** This is an API-based textual pattern review, not Gitleaks across the full locally cloned Git object database. Binary payloads (historical `.DS_Store` and two publication PDFs) were not decoded: the GitHub connector returned Unicode decoding errors for binary blobs. History beyond the reachable commits and any hidden server-side data is not certified.

## Publication rights

- `Image Processing/Matlab/Chapter 2 - Image Thresholding/OTSU Binarization/A Threshold Selection Method from Gray-Level Histograms.pdf`: the identified Otsu publication is Nobuyuki Otsu (1979), IEEE Transactions on Systems, Man, and Cybernetics, DOI https://doi.org/10.1109/TSMC.1979.4310076. An IEEE copyright notice appears on publicly available copies. That fact does *not* demonstrate the redistribution rights of the particular PDF blob stored in this repository.
- `Image Processing/Matlab/Chapter 2 - Image Thresholding/Wellner Thresholding/Wellner Method.pdf`: the Wellner work corresponds to Pierre Wellner's *Adaptive Thresholding for the DigitalDesk*, Technical Report EPC-1993-110, publicly indexed with a Rank Xerox Ltd copyright notice. The permission status of this exact repository PDF is not established.
- Both existing documents remain untouched. A later owner-approved cleanup may replace hosted PDFs with bibliographic citations and official links after metadata, version and license checks. Removal from the current tree alone would not remove historical Git blobs.

## Owner-only account checklist

GitHub account 2FA, recovery codes, passkeys, active sessions, token scopes and authorized OAuth/GitHub Apps are private. This connector does not expose them. The owner should verify https://github.com/settings/security and https://github.com/settings/applications; do not supply secrets or recovery codes to collaborators or tools.

## Local security completion requirement

Use a trusted local clone with all reachable refs, run a current history-aware scanner (for example Gitleaks), inspect Git-tracked PDF metadata/embedded files and `.DS_Store` strings locally, and keep any resulting finding report private. Any confirmed leaked secrets should be revoked and rotated before changes to Git history are considered. The current state is **reviewed with limitations**, not formally security-certified.
