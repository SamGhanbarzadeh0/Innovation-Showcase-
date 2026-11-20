#!/usr/bin/env python3
"""Deterministic workflow safety checks. Does not scan accounts or secrets."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
workflows = sorted((root / ".github" / "workflows").glob("*.yml"))
issues = []
count = 0

def check(ok, description):
    global count
    count += 1
    if not ok:
        issues.append(description)

check(len(workflows) == 2, "Unexpected workflow count")
pattern = re.compile(r"(?m)^\s*(?:-\s*)?uses:\s*([^\s#]+)")
for path in workflows:
    text = path.read_text(encoding="utf-8")
    check("permissions:\n  contents: read" in text, str(path.name) + ": require read-only token")
    check("pull_request_target:" not in text and "workflow_run:" not in text,
          str(path.name) + ": unexpected privileged trigger")
    check("secrets." not in text, str(path.name) + ": secret injection needs review")
    check("timeout-minutes:" in text, str(path.name) + ": missing job timeout")
    check(not re.search(r"(?m)^\s+\S+:\s*write\s*$", text),
          str(path.name) + ": write access declared")
    actions = list(pattern.finditer(text))
    check(len(actions) > 0, str(path.name) + ": no action to inspect")
    for match in actions:
        name = match.group(1)
        check(re.fullmatch(r"[\w.-]+/[\w.-]+@[0-9a-f]{40}", name) is not None,
              str(path.name) + ": action must use an immutable SHA: " + name)
        if name.startswith("actions/checkout@"):
            segment = text[match.end():].splitlines()[:7]
            check(any(re.fullmatch(r"\s+persist-credentials:\s*false\s*", line)
                      for line in segment),
                  str(path.name) + ": checkout must not persist credentials")
matlab = (root / ".github" / "workflows" / "matlab-final-verification.yml").read_text()
check("\n  pull_request:\n" in matlab, "MATLAB check must run on every PR")
check("id: scope" in matlab and "steps.scope.outputs.needs_matlab" in matlab,
      "MATLAB must execute for changed source, not every text-only PR")

if issues:
    print("FAIL: {} / {} checks".format(len(issues), count))
    for issue in issues:
        print(" - " + issue)
    raise SystemExit(1)
print("PASS: {} workflow security checks".format(count))
