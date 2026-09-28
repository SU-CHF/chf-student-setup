# Student Mac setup validation checklist

Use this checklist with the student after they have tried the written setup themselves. Let them drive the Mac and explain what they see; record the exact step and message when something fails. Do not troubleshoot by reinstalling everything.

## Before the session

- [ ] Ask what worked, what failed, and what they have already retried.
- [ ] Confirm she used the Centre's ChatGPT workspace and her own Zotero and GitHub accounts.
- [ ] Confirm the laptop is an Apple Silicon Mac and her account has administrator rights.
- [ ] Ask her to bring any screenshot or diagnosis report. Do not ask her to send data, passwords, API keys, or confidential research material.
- [ ] If setup is incomplete, open Terminal and run the diagnosis script from the setup repository. Review its output together before changing anything.

## Installer and applications

- [ ] Did the one-line installer start? Record the stage number and the last error if it stopped.
- [ ] Did Homebrew install and did the apps open: Zotero, R, Quarto, VS Code, ChatGPT, and GitHub Desktop? Positron is optional.
- [ ] Did the installer finish with any listed problems? If yes, note which stages and whether one rerun fixed them.
- [ ] Check that the student can reopen Terminal and that `brew --version`, `R --version`, `quarto --version`, and `git --version` return versions.
- [ ] Confirm Git name and university email are set without displaying or sharing unrelated configuration.

## Accounts and Zotero

- [ ] GitHub Desktop is signed in to the account the student will use for the thesis repository.
- [ ] Zotero is signed in and syncing.
- [ ] In Zotero, **Settings → Advanced**, “Allow other applications on this computer to communicate with Zotero” is enabled.
- [ ] Better BibTeX is installed and the Zotero Connector is available in her browser.
- [ ] Save the Becker 1965 article with the connector; open its PDF, highlight a sentence, and add a note.
- [ ] With Zotero open, ask Codex to find and summarize the Becker item. Confirm it can see the personal library. The student setup is intentionally local and read-only; Codex is not expected to search the CHF group library or add items to Zotero.

## GitHub workflow

- [ ] Open the CHF thesis template page and use **Use this template** to create a private thesis repository.
- [ ] Clone it with GitHub Desktop and open it in VS Code.
- [ ] Change the name in `thesis.qmd`, commit, and push. Confirm the change appears on GitHub.
- [ ] Fetch origin and confirm GitHub Desktop reports no incoming changes.

## Quarto and analysis

- [ ] Preview `check.qmd` to PDF. Confirm the equation, figure, regression table, citation, and references render. The first render may take several minutes while LaTeX builds its font database.
- [ ] Preview `check-python.qmd` to PDF. Confirm the table, regression, figure, and version information appear.
- [ ] Run one R cell using **Run Cell**. Confirm a plot appears.
- [ ] Run one Python cell using **Run Cell**. If prompted for a kernel, select the interpreter under `~/.venvs/research`.
- [ ] If a render fails, record the engine (R/knitr or Python/Jupyter), the last 40 lines of the Quarto output, and `quarto check` output.

## References and bibliography

- [ ] Ask Codex for the DOI of Gronau's 1977 paper, then add it in Zotero with **Add Item by Identifier**.
- [ ] In Zotero, set up Better BibTeX **Keep updated** export to the thesis repo's `references.bib`.
- [ ] Confirm the Becker and Gronau entries appear in `references.bib` without manual edits.
- [ ] Cite Gronau in `thesis.qmd` and preview the document to confirm the citation and reference render.

## Closeout and troubleshooting notes

- [ ] Confirm the student knows where the thesis repository is and can commit and push at the end of a work session.
- [ ] Record each unresolved issue below with its step, exact message, and next action. Never include credentials or research data.

| Step | What happened / exact message | Next action and owner |
|---|---|---|
| | | |
| | | |
| | | |
