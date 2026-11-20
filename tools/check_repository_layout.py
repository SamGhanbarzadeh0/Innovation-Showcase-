#!/usr/bin/env python3
"""Check preserved MATLAB sources, references and repository layout.

Requires Python 3.9+ and Git; uses no external Python packages.
    python3 tools/check_repository_layout.py
"""
from __future__ import annotations

import csv
import hashlib
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[1]
BASELINE = "40240cd9d6aed4b6613697b535f84ad6fda80c29"
MANIFEST = ROOT / "tests/final/original_source_manifest.csv"
PREFIX = "Image Processing/Matlab/Chapter 2 - Image Thresholding/"
PDFS = {
    PREFIX + "OTSU Binarization/A Threshold Selection Method from Gray-Level Histograms.pdf":
        "e0278178adbd269680743576b2c2b7c87322e9ad",
    PREFIX + "Wellner Thresholding/Wellner Method.pdf":
        "88de18c7077f85019ef9e5d15fe182dbdc4ec417",
}
PAD_COPIES = [PREFIX + p + "/PadArray.m" for p in
              ("Bradley Thresholding", "Simple Mean Binarization", "Wellner Thresholding")]
REQUIRED = (
    "README.md", ".gitignore", "docs/REPOSITORY_LAYOUT.md", "docs/OUTPUT_POLICY.md",
    ".github/workflows/matlab-final-verification.yml",
    ".github/workflows/repository-structure.yml",
    "tests/run_regression.m", "tests/final/run_final.m",
    "tests/final/collect_final_validation.m", "tests/final/validate_builtin_images.m",
)
LINKED_DOCS = ("README.md", "docs/REPOSITORY_LAYOUT.md", "docs/OUTPUT_POLICY.md",
               "tests/README.md", "tests/final/README.md")
problems: list[str] = []
checked = 0


def verify(condition: bool, description: str) -> None:
    global checked
    checked += 1
    if not condition:
        problems.append(description)


def git_blob_hash(path: Path) -> str:
    value = path.read_bytes()
    return hashlib.sha1(b"blob " + str(len(value)).encode() + b"\0" + value).hexdigest()


result = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
tracked = {x.decode("utf-8") for x in result.split(b"\0") if x}

for name in REQUIRED:
    verify(name in tracked and (ROOT / name).is_file(), f"Required file missing: {name}")

verify(MANIFEST.is_file(), "Original-source manifest is missing")
if MANIFEST.is_file():
    with MANIFEST.open(encoding="utf-8-sig", newline="") as handle:
        entries = list(csv.DictReader(handle))
    verify(len(entries) == 14, f"Expected 14 original MATLAB entries; found {len(entries)}")
    observed = set()
    for entry in entries:
        original = entry["original_relative_path"]
        copy = entry["copy_path"]
        sha = entry["original_git_blob_sha"]
        verify(entry["source_commit"] == BASELINE, f"Unrecognized baseline commit: {original}")
        verify(copy == "tests/legacy_snapshot/" + original, f"Unexpected archive path: {copy}")
        verify(original in tracked, f"Working MATLAB file missing: {original}")
        verify(copy in tracked and (ROOT / copy).is_file(), f"Archived source missing: {copy}")
        if (ROOT / copy).is_file():
            verify(git_blob_hash(ROOT / copy) == sha, f"Archived Git blob changed: {copy}")
        verify(copy not in observed, f"Repeated manifest entry: {copy}")
        observed.add(copy)

pad_shas = []
for name in PAD_COPIES:
    verify(name in tracked and (ROOT / name).is_file(), f"PadArray copy missing: {name}")
    if (ROOT / name).is_file():
        pad_shas.append(git_blob_hash(ROOT / name))
verify(len(pad_shas) == 3 and len(set(pad_shas)) == 1,
       "Active PadArray copies must remain identical")

for path, sha in PDFS.items():
    verify(path in tracked and (ROOT / path).is_file(), f"Reference PDF missing: {path}")
    if (ROOT / path).is_file():
        verify(git_blob_hash(ROOT / path) == sha, f"Reference PDF modified: {path}")

verify(not any(Path(x).name == ".DS_Store" or Path(x).name.startswith("._") for x in tracked),
       "Finder metadata remains tracked")
verify(not any("validation_results" in Path(x).parts for x in tracked),
       "Generated validation outputs were committed")
verify(not any(x.endswith((".asv", ".autosave", ".m~", ".slxc")) for x in tracked),
       "MATLAB autosave or intermediate files were committed")

for name in LINKED_DOCS:
    file = ROOT / name
    if not file.is_file():
        continue
    contents = file.read_text(encoding="utf-8")
    for target in re.findall(r"\[[^\]]+\]\(([^)\n]+)\)", contents):
        candidate = target.strip("<>").split(" ", 1)[0]
        if candidate.startswith(("#", "mailto:")) or urlparse(candidate).scheme:
            continue
        local = unquote(candidate.split("#", 1)[0])
        if local:
            destination = (file.parent / local).resolve()
            verify(destination.is_relative_to(ROOT) and destination.exists(),
                   f"Broken Markdown link in {name}: {target}")

if problems:
    print(f"FAIL: {len(problems)} issue(s) in {checked} structure checks")
    for problem in problems:
        print(f" - {problem}")
    sys.exit(1)
print(f"PASS: {checked} structure checks")
print("Preserved original MATLAB sources: 14 SHA verified")
print("Active PadArray copies: 3 equal")
print("Original PDF files: 2 unchanged")
print("Finder metadata and generated validation outputs: not tracked")
