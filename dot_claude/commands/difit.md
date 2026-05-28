---
description: Show git diff from branch point with difit
allowed-tools: Bash(git:*), Bash(difit:*)
---

Show git diff from branch point with difit (including uncommitted changes, excluding unmerged main changes).

Wait for the browser to close and capture review comments.

```bash
UNTRACKED=$(git ls-files --others --exclude-standard); [ -n "$UNTRACKED" ] && echo "$UNTRACKED" | xargs git add -N; git diff $(git merge-base origin/main HEAD) | difit --clean; [ -n "$UNTRACKED" ] && echo "$UNTRACKED" | xargs git reset -q; true
```

Run with `timeout: 600000` (10 minutes max) to wait for browser close.
If review takes longer, use `run_in_background: true` and check output with TaskOutput.
