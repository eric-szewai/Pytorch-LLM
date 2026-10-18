# Lever task repo

Your task card on HAI has the task ID, source repo, base commit, task type, and the
number of context files and changed files. `metadata.json` here is pre-filled
with those values — do not change them.

**Those file counts are exact, and every file has to be one the fix uses.** Pick a change
that genuinely needs that many context files and edits that many files together. Don't
pick a small fix and add unrelated files, or copy the same edit into extra files, to reach
the number: Auto QC and the review block both.

## Layout (v2 — multi-file)

```
environment/Dockerfile            builds the test environment; exposes /test.sh
environment/run-tests-eval.sh     /test.sh [csv-of-test-ids] — always tests states/before/
states/before/<path>...           the context files at their repo-relative paths, before your change
states/after/<path>...            the same files after your change (plus any new file)
states/README.md                  where the files came from (source repo @ base_commit) and any splits
instruction.md                    ### Context (one path line + code block per file) then ### Task
solution.md                       the reference answer, written exactly as the model must answer
tests/fail2pass/                  tests that FAIL on before and PASS on after
tests/pass2pass/                  tests that PASS on both
metadata.json                     the v2 manifest (context_items, targets, tests)
```

## The rules that Auto QC enforces

- **Exactly the card's number of context files (2–10)**, each a *different* file, listed in
  `metadata.json → context_items` and shown in `### Context` as its full repo-relative path on
  one line followed by a fenced code block. Every context file must be one the fix uses: code
  it calls or matches, or code that calls or uses what it changes. If the fix needs one big
  file, you may split it into smaller files to reach the number, as long as each part is code
  the fix uses (say so in `states/README.md`). Never refer to files by position in `### Task`
  — the model sees them in random order.
- **Exactly the card's number of changed files (1–5)**, one entry each in `targets`, each with
  its own `output_contract` and locator, and edits that depend on each other (not the same
  edit repeated). No file deletions.
- **`solution.md`** = for every changed file: the path on its own line, then one fenced block
  with exactly what the model must output for that file. Same format for a single file.
- **Tests:** at least **3 fail2pass + 1 per changed file** and **2 pass2pass + 1 per changed
  file** (1 file → 4/3, 2 files → 5/4, 3 files → 6/5). Every fail2pass test must fail on
  `states/before/` on its own. Each changed file needs at least one of each, listed under
  `targets[].covers`.
- **Budgets:** `### Context` + `### Task` ≤ 4,000 tokens; `solution.md` ≤ 1,000 tokens total.
- **Real code only.** `### Context` shows code exactly as it is in the file: no
  `# ... existing code unchanged ...`, `// ...` or other placeholder lines. To show part of a
  file, show one continuous chunk.
- **`states/before/` is the real code:** each file is the file from `source_repo` at
  `base_commit`, whole or as one continuous chunk (the same chunk `### Context` shows).
  Never an edited or stitched-together excerpt. `states/after/` is the same with your change.
- **Answer format:** `### Task` names every changed file by its full path, with one line per
  file saying what to return, for example:
  - For `pkg/parse.py`, return the entire file.
  - For `pkg/parse.py`, return only the body of `parse_row`: no signature, no surrounding code.
  - For `pkg/parse.py`, return only the replacement text for the marked region, nothing before or after it.
  - For `pkg/new_mod.py`, return the entire contents of the new file.
- **Tests must catch wrong answers:** undoing any one part of your change must make a test
  fail. If the tests still pass without it, that part is untested and the task is blocked.
- **Base image pinned by digest:** `FROM image:tag@sha256:…` in `environment/Dockerfile`.
  If it's missing, the Auto QC failure prints the exact line to paste. Install only what the
  tests need, assume no network at test time, and copy only `states/before/` into the image,
  never `states/after/` or `solution.md`.
- **No leftover instructions** in task files: comments that tell you what to do (like the ones
  older versions of this template had at the top of the Dockerfile) fail Auto QC. Delete them.
- **No internal names** in task files: nothing that says "lever" (as a word, e.g.
  `LEVER_TEST_H`) or "handshake". The task folder is delivered to the client as written.

## How to work

Branch from `main` as `golden-solve`. Six commits, in order:
`[env]` `[states]` `[prompt]` `[sol]` `[tests]` `[meta]`.
Open a **draft** PR into `main` titled `[LEVER TASK] <task_id>`. Auto QC comments on the PR;
fix every ❌, then mark the PR **Ready for review**. Do not edit `.github/workflows/`.

Handbook: https://project-lever.learn.joinhandshake.com/
