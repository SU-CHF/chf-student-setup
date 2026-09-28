# Setting up your Mac for CHF research

Allow about 45 minutes on a good connection (do this on campus Wi-Fi or at home, not on mobile data — it downloads roughly 3 GB). You need to be logged in to an account that can install software (an administrator account).

## Before you start: accounts

1. **ChatGPT** — do not buy a plan. The Centre provides a seat on its Team workspace: Jesse will send an invitation to your university email address. Accept it and set up your login before continuing. If you already have a personal ChatGPT account on that address, tell Jesse first.
2. **Zotero** — free account at zotero.org.
3. **GitHub** — free account at github.com; send your username to Jesse.

## Step 1: run the installer

Open **Terminal** (press Cmd+Space, type "Terminal", press Return). Paste this line and press Return:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SU-CHF/chf-student-setup/main/setup.sh)"
```

It first asks for your name and university email (for Git), then for your Mac password. Nothing appears as you type the password; that is normal. Press Return when asked to confirm. A window may pop up asking to install "command line developer tools" — click Install.

The script prints eight numbered stages. If it ends with a list of problems, simply paste the same line again; it skips whatever already worked. If the same problem appears twice, send Jesse a screenshot.

When it finishes, quit Terminal (Cmd+Q).

## Step 2: sign-ins and one-time setup

1. **GitHub Desktop → sign in.** Open GitHub Desktop → Sign in to GitHub.com, and log in in the browser window it opens.
2. **Zotero → sign in.** Open Zotero, then Zotero menu → Settings → Sync, and log in.
3. **Zotero → allow other apps.** Settings → Advanced → tick *"Allow other applications on this computer to communicate with Zotero"*.
4. **Zotero → Better BibTeX.** Download the latest `.xpi` file from <https://retorque.re/zotero-better-bibtex/installation/>. In Zotero: Tools → Plugins → gear icon → *Install Plugin From File* → choose the file. Accept the defaults in the wizard that follows.
5. **ChatGPT → sign in.** Open the ChatGPT app and log in with your university email. If asked which workspace to use, choose the Centre's workspace, not "Personal". Also open VS Code, click the ChatGPT/Codex icon in the left bar, and sign in there.

Also install the **Zotero Connector** for your browser (zotero.org/download) — this is how you add papers to your library.

## Step 3: six checks, easiest first

Do them in order; each one builds on the last. If one fails, stop there and see *If something goes wrong* below.

1. **Edit a file in VS Code.** On GitHub, open <https://github.com/SU-CHF/chf-thesis-template> and click **Use this template → Create a new repository**; name it after your thesis and keep it private. In GitHub Desktop: File → Clone repository → pick that repo. Click *Open in Visual Studio Code*. Open `thesis.qmd`, change "Student Name" to your name, save (Cmd+S).

2. **Commit, push, pull.** Back in GitHub Desktop the change is listed on the left. Type a summary ("Add my name"), click *Commit to main*, then *Push origin*. Reload the repo page on github.com: your name should be there. Then click *Fetch origin* — "no changes" means pull works too. This is the whole loop you will use every day: edit → commit → push.

3. **Add and annotate a paper in Zotero.** In your browser go to <https://doi.org/10.2307/2228949> (Becker's 1965 "A Theory of the Allocation of Time") and click the Zotero Connector button in the toolbar; it lands in your library, with the PDF if your campus has access. In Zotero double-click the item to open the PDF, highlight a sentence, and add a note to the highlight. Your Zotero library is now the place where all reading happens.

4. **Render a PDF: math, code, citation.** In VS Code open `check.qmd` and click **Preview** (top right). The first PDF can take several minutes and may look stuck at "luaotfload | db : Font names database not found" — that is normal, do not close the window; later renders take seconds. You should see an equation, a plot, a regression table, and a reference list. Then open `check-python.qmd` and Preview: a table, regression output, and a plot.

5. **Run code interactively.** In `check.qmd`, put the cursor inside the first R chunk and click *Run Cell* (the small link above the chunk). An R terminal opens and the plot appears in a panel. Do the same in `check-python.qmd`: VS Code asks which kernel to use — pick the one at `~/.venvs/research`. This is how you will do day-to-day data analysis.

   **Positron** is also installed. It is a version of VS Code built for R and Python analysis (variables pane, plots pane, data viewer). Open the same folder there (File → Open Folder), pick the R interpreter and the Python at `~/.venvs/research` when asked, and run the same chunks. Use whichever you prefer for analysis; Codex lives in VS Code and the ChatGPT app.

6. **Codex + Zotero.** With Zotero open, start a new Codex chat in the ChatGPT app and ask, in this order. Codex reads the student's personal Zotero library through the local connection. It does not have access to the CHF group library, and it cannot change Zotero items:
   - *"Use the Zotero tools to list the items in my library and summarise the Becker 1965 paper in five sentences."*
   - *"Find the DOI of Gronau's 1977 paper 'Leisure, home production, and work' in the Journal of Political Economy."* Codex cannot add it for you: in Zotero click the magic-wand icon (*Add item by identifier*), paste the DOI, press Return.
   - Now set up the Better BibTeX export (template README, *References*). Open `references.bib` in VS Code: both papers should be in it, without you typing a thing. In `thesis.qmd` type `@gron` and VS Code offers the Gronau key. Preview: the new citation renders.

If all six work, you have everything the Centre's workflow needs. Open `thesis.qmd`: that is where your thesis starts.

For an in-person walkthrough after setup, use the [validation checklist](VALIDATION-CHECKLIST.md).

## If something goes wrong

First, re-run the installer line from Step 1; it skips whatever already worked and only retries the failures. If that does not fix it, gather a diagnosis and ask ChatGPT (or Jesse) with it.

**Get a diagnosis.** In Terminal, paste:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SU-CHF/chf-student-setup/main/doctor.sh)"
```

It prints the version of every tool and which of the setup stages left something missing, and copies the report to the clipboard.

**Ask ChatGPT.** Start a new chat (not Codex) and paste one of these, filling in the parts in angle brackets:

- *Installer failed:* "I am a student on a fresh Apple Silicon Mac. I ran a setup script that installs Homebrew, R, Quarto, TinyTeX, VS Code, uv and a Zotero MCP server for Codex. Stage <N> ended with this error: <paste the red or last lines>. Here is the diagnosis report: <paste>. Explain the likely cause in plain language and give me the single command or click to fix it. Do not suggest reinstalling everything."
- *Quarto render failed:* "Rendering a Quarto `.qmd` to PDF in VS Code fails. Engine: <knitr or jupyter>. Here are the last 40 lines of the Quarto output: <paste>. Here is `quarto check`: <paste>. What is wrong and what is the smallest fix?"
- *Codex cannot see Zotero:* "In the ChatGPT desktop app, Codex does not list Zotero tools. Zotero is running and 'Allow other applications' is ticked. My `~/.codex/config.toml` contains: <paste>. Running `~/.local/bin/zotero-mcp serve` in Terminal prints: <paste>. What should I check?"
- *Git problem:* "In GitHub Desktop I get this message when I try to <push / pull / commit>: <paste>. Explain what it means and the safest way to resolve it without losing my changes."

Useful commands to paste into those prompts: `quarto check` (whole Quarto pipeline), `brew doctor` (Homebrew), `Rscript -e 'sessionInfo()'` (R), `~/.venvs/research/bin/python -m jupyter --version` (Python), `cat ~/.codex/config.toml` (Codex config, safe to share: it contains no secrets).

If ChatGPT proposes anything that starts with `sudo rm`, deletes a folder in your home directory, or reinstalls macOS, stop and send Jesse a screenshot instead.

## Everyday rules

Zotero is the only place references live: add papers with the browser connector, set up the one-time Better BibTeX export described in the template's README, and cite in Quarto by typing `@`. Render PDFs with the Preview button in VS Code rather than by asking Codex to run Quarto. Use the Centre's workspace, never a personal ChatGPT account, for research work. Even there, never paste confidential or restricted data into ChatGPT/Codex, and do not open Codex in a folder that contains such data — ask Jesse first.

## What was installed

Homebrew (installer), Zotero, R with the main analysis packages, Quarto, TinyTeX (LaTeX), VS Code with the Quarto, R, Python, Jupyter and Codex extensions, Positron (optional analysis IDE), the ChatGPT app (includes Codex), GitHub Desktop, git-lfs, uv (Python manager) with a Python environment at `~/.venvs/research`, the Zotero MCP server that lets Codex read your library, and a short set of working conventions for Codex at `~/.codex/AGENTS.md` (Zotero for references, Quarto for documents, no confidential data).
