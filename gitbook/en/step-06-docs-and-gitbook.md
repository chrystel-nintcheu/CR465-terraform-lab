# Step 6: Docs and GitBook

## Goal
Keep the tutorial pages and the GitBook source aligned with the executable lab.

## Prerequisites
- Step 5 validation passed

## What is GitBook?

[GitBook](https://www.gitbook.com/) is a documentation platform that renders Markdown into a web-readable book. The `gitbook/` directory in this repo is the source — it follows GitBook's expected structure:

- `gitbook/SUMMARY.md` — the table of contents. Every page must be listed here.
- `gitbook/README.md` — the landing page for the book.
- `gitbook/en/` — English tutorial pages, one file per step.
- `gitbook/fr/` — French tutorial pages, one file per step (structurally identical to `en/`).

### Rendering locally

To preview the book locally, install the GitBook CLI:

```powershell
npm install -g gitbook-cli
cd gitbook
gitbook serve
```

Then open `http://localhost:4000` in a browser. Alternatively, publish to gitbook.com by connecting the repository.

## Structural parity

"Structural parity" means both language versions have the same sections in the same order. The validation script `tests/validate-tutorial-order.ps1` enforces this by checking that every English page has a French counterpart and that both contain the required headings (`## Goal`, `## Verification`, `## Recovery`).

### What "drift" looks like

Documentation drift happens when code changes but docs don't. Examples:
- A new variable is added to `variables.tf` but not mentioned in any tutorial page.
- The French translation of Step 4 still references the old script name after a rename.
- `SUMMARY.md` lists a page that no longer exists.

The fix rule is simple: **repair the diverged page pair before changing anything else**. Never let one language get ahead of the other.

## Validation checks performed

`tests/validate-tutorial-order.ps1` checks:
1. All runner scripts exist (`scripts/apply.ps1`, etc.)
2. All Terraform files exist (`terraform/main.tf`, etc.)
3. `versions.tf` uses `todoroff/multipass`
4. `main.tf` contains required tokens and no forbidden patterns
5. All 18 GitBook pages exist (9 English + 9 French — including README and SUMMARY)
6. `SUMMARY.md` contains required navigation tokens
7. Each step page contains `## `, `Verification`, and `Recovery` (English) or `Vérification` and `Récupération` (French)

## Expected output
- English and French pages stay structurally aligned.
- The GitBook summary mirrors the tutorial progression.

## Verification
Inspect `gitbook/SUMMARY.md` and the step pages, then run `powershell -File tests/run.ps1`.

## Recovery
If the docs drift, fix the page pair that diverged before changing anything else. Run `tests/validate-tutorial-order.ps1` after each fix to confirm the issue is resolved before moving on.
