#!/bin/bash
# CHF student Mac setup -- assumes a freshly wiped Apple Silicon Mac, macOS up to date, admin account.
# Safe to re-run: every step skips what is already done.
#
# Run with (replace URL with wherever this file is hosted):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SU-CHF/chf-student-setup/main/setup.sh)"
#
# Status: bash -n syntax-checked and reviewed against ~/dotfiles on 2026-09-19. Not yet executed
# end to end on a clean account (HANDOFF.md, task 5).

set -u
say()  { printf "\n\033[1;34m==> %s\033[0m\n" "$1"; }
warn() { printf "\033[1;33m[!] %s\033[0m\n" "$1"; FAILED+=("$1"); }
FAILED=()

# ---------------------------------------------------------------- 0. Preflight
say "0/8 Checking this Mac"
if [ "$(uname -m)" != "arm64" ]; then
  echo "This script is for Apple Silicon Macs (M1 or later). Stopping."
  exit 1
fi
if ! id -Gn | tr ' ' '\n' | grep -qx admin; then
  echo "This account is not an administrator, so software cannot be installed."
  echo "If this is a university-managed Mac, ask IT for admin rights (or ask Jesse). Stopping."
  exit 1
fi

# Git identity: asked now, before anything slow, but applied in stage 3. Do not call `git`
# here: on a fresh Mac that triggers the command-line-tools dialog before Homebrew installs
# them. ~/.gitconfig is read directly instead.
GIT_NAME=""; GIT_EMAIL=""
if ! grep -qs '^[[:space:]]*name[[:space:]]*=' ~/.gitconfig 2>/dev/null; then
  echo
  echo "Git needs to know who you are (this is what appears on your commits)."
  read -r -p "Your full name: " GIT_NAME </dev/tty
  read -r -p "Your university email: " GIT_EMAIL </dev/tty
fi

# ---------------------------------------------------------------- 1. Homebrew
say "1/8 Homebrew (asks for your Mac password; installs Apple's command-line tools)"
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { echo "Homebrew failed to install. Are you on an admin account?"; exit 1; }
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
grep -qs 'brew shellenv' ~/.zprofile || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# ---------------------------------------------------------------- 2. Apps
say "2/8 Apps: Zotero, R, Quarto, VS Code, Positron, ChatGPT (includes Codex), GitHub Desktop (may ask for your password again)"
# Cask names verified against formulae.brew.sh on 2026-09-19.
brew bundle --file=- <<'BREWFILE' || warn "Some apps failed to install -- re-run this script"
brew "git-lfs"
brew "uv"
cask "zotero"
cask "r-app"
cask "quarto"
cask "visual-studio-code"
cask "chatgpt"
cask "github"
cask "positron"   # optional data-science IDE (Posit); VS Code remains the primary editor
BREWFILE

# ---------------------------------------------------------------- 3. Git config
say "3/8 Git defaults"
if [ -n "$GIT_NAME" ]; then
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
fi
git lfs install >/dev/null 2>&1 || true
git config --global core.excludesfile "$HOME/.gitignore_global"
git config --global color.ui true
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor nano   # if git ever opens an editor in Terminal, not vim
# Global ignore: OS and R clutter. Project-level ignores (Quarto output, LaTeX aux files)
# live in the template repo's .gitignore.
cat > ~/.gitignore_global <<'IGNORE'
*~
.DS_Store
.Rhistory
.RData
.Rproj.user/
IGNORE

# ---------------------------------------------------------------- 4. LaTeX
say "4/8 TinyTeX (small LaTeX; Quarto fetches any missing packages on first render)"
TEXBIN="$HOME/Library/TinyTeX/bin/universal-darwin"
TLMGR="$TEXBIN/tlmgr"
command -v quarto >/dev/null || warn "quarto not on PATH (did the Quarto app install?)"
[ -x "$TLMGR" ] || quarto install tinytex --no-prompt || warn "TinyTeX install failed"
# Pre-load what the template repo (thesis.qmd, slides.qmd, check*.qmd) uses beyond Quarto's
# base TinyTeX bundle, so the first render does not stall on package downloads. Anything
# missed here is fetched automatically by Quarto at render time.
[ -x "$TLMGR" ] && "$TLMGR" install beamer pgf translator booktabs caption float \
  setspace multirow threeparttable siunitx microtype csquotes tabularray >/dev/null 2>&1 || true
# Quarto 1.10 renders PDF with lualatex; on its first run luaotfload builds a font-name
# database, which takes several minutes and looks like a hang. Trigger it here instead.
# (luaotfload-tool is a texlua script, so the TinyTeX bin dir must be on PATH for it.)
[ -x "$TEXBIN/luaotfload-tool" ] && \
  PATH="$TEXBIN:$PATH" "$TEXBIN/luaotfload-tool" --update >/dev/null 2>&1 || true

# ---------------------------------------------------------------- 5. R packages
say "5/8 R packages (a few minutes)"
# rmarkdown/knitr: Quarto's R engine.  languageserver: VS Code R extension.
# tinytable: modelsummary's default table backend.
command -v Rscript >/dev/null || warn "Rscript not on PATH (did R install?)"
# install.packages() only warns on failure, so re-check afterwards and exit non-zero.
Rscript -e '
  pk <- c("rmarkdown","knitr","languageserver","tidyverse","data.table","haven",
          "fixest","modelsummary","tinytable","kableExtra","here")
  need <- setdiff(pk, rownames(installed.packages()))
  if (length(need)) install.packages(need, repos = "https://cloud.r-project.org")
  miss <- setdiff(pk, rownames(installed.packages()))
  if (length(miss)) { cat("Missing R packages:", miss, "\n"); quit(status = 1) }
' || warn "R packages failed (see above)"

# ---------------------------------------------------------------- 6. Python
say "6/8 Python environment for Quarto/Jupyter (~/.venvs/research)"
PY="$HOME/.venvs/research/bin/python"
[ -x "$PY" ] || uv venv --python 3.13 "$HOME/.venvs/research" || warn "Python venv failed"
uv pip install --python "$PY" -q jupyter pandas numpy matplotlib statsmodels pyfixest tabulate \
  || warn "Python packages failed"
grep -qs 'QUARTO_PYTHON' ~/.zprofile || echo "export QUARTO_PYTHON=\"$PY\"" >> ~/.zprofile

# ---------------------------------------------------------------- 7. VS Code
say "7/8 VS Code extensions"
for ext in quarto.quarto reditorsupport.r ms-python.python ms-toolsai.jupyter \
           openai.chatgpt mechatroner.rainbow-csv tomoki1207.pdf; do
  code --install-extension "$ext" --force >/dev/null 2>&1 || warn "VS Code extension $ext"
done
# Point the Python and R extensions at the shared environment so the student never has to
# pick an interpreter. Written only if no settings file exists yet.
VSC="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSC"
[ -f "$VSC/settings.json" ] || cat > "$VSC/settings.json" <<JSON
{
  "python.defaultInterpreterPath": "$PY",
  "editor.minimap.enabled": false,
  "git.autofetch": true
}
JSON

# ---------------------------------------------------------------- 8. Zotero <-> Codex
say "8/8 Zotero MCP server, registered with Codex/ChatGPT (local, read-only)"
uv tool install --python 3.13 zotero-mcp-server >/dev/null 2>&1 \
  || uv tool upgrade zotero-mcp-server >/dev/null 2>&1 || warn "zotero-mcp install failed"
uv tool update-shell >/dev/null 2>&1 || true
mkdir -p ~/.codex && touch ~/.codex/config.toml
# Read-only local mode: no API key, no library ID. ZOTERO_LOCAL=true is sufficient on
# zotero-mcp-server 0.12.x (checked against the 0.12.4 source). Zotero must be running and
# Settings -> Advanced -> "Allow other applications..." ticked.
if ! grep -qs '^\[mcp_servers\.zotero\]' ~/.codex/config.toml; then
cat >> ~/.codex/config.toml <<TOML

[mcp_servers.zotero]
command = "$HOME/.local/bin/zotero-mcp"
args = ["serve"]

[mcp_servers.zotero.env]
ZOTERO_LOCAL = "true"
TOML
fi

# Global Codex instructions. Research conventions only; no machine policy. Rewritten on every
# run so a re-run picks up an updated version of this script.
cat > ~/.codex/AGENTS.md <<'AGENTS'
# Working conventions (CHF student setup)

You are helping a Stellenbosch University economics student at the Centre for Household
Finance (CHF) with thesis and coursework. Tools on this Mac: R, Python (one shared
environment at `~/.venvs/research`), Quarto, TinyTeX, Zotero, VS Code, GitHub Desktop.

## Data and confidentiality

- Never read, print, or copy `.env` files, `~/.ssh`, `~/.Renviron`, API keys, or passwords.
- Restricted or confidential data (anything under a data transfer agreement, anything the
  student has been told is restricted) never lives on this laptop and must never be pasted
  into a chat. If a folder looks like it contains such data, stop and say so.
- Do not install software system-wide or change shell configuration. R packages and the
  Python environment at `~/.venvs/research` are shared across projects; record what a
  project needs in a `setup.R` / `requirements.txt` at its root, never inline in an
  analysis script.

## References: Zotero is the single source of truth

- Every cited work must exist in the student's Zotero library. Cite it in Quarto by its
  Better BibTeX key, e.g. `[@beckerTheoryAllocationTime1965]`.
- `references.bib` is written by Zotero's Better BibTeX auto-export. Never hand-write or
  hand-edit an entry in it. If a work is missing or its metadata is wrong, tell the student
  to add or fix it in Zotero (the browser connector adds most items in one click); the
  `.bib` updates by itself. Do not cite as plain text.
- Use the Zotero MCP tools to look up works. For citation details use
  `qmode: "titleCreatorYear"`; `qmode: "everything"` searches PDF full text and often
  returns the PDF attachment rather than the parent record, so do not read citation
  metadata off an attachment. Non-article sources (working papers, reports, legislation)
  should carry a URL in Zotero.

## Documents

- Write in Quarto (`.qmd`), rendered to PDF via LaTeX. Do not write raw `.tex` documents
  unless the student already has one. Use `references.bib` plus a CSL style; do not switch
  to biblatex/natbib.
- Prose over bullet points in written work. Number equations that are referred to.

## Tables and figures (economics house style)

- Regression tables: `modelsummary` or `fixest::etable` in R; `statsmodels` summaries in
  Python. Booktabs rules, standard errors in parentheses, SE type stated in a note.
  Never `stargazer`; never `xtable` without booktabs.
- Descriptive tables: `modelsummary::datasummary*` or `kableExtra` with `booktabs = TRUE`.
- Figures: `ggplot2` in R, `matplotlib` in Python. Never `seaborn` or `plotly` for a
  figure that goes into a document. Save vector output (`cairo_pdf` / PDF) for LaTeX.
- Colour-blind-safe palettes (Okabe-Ito for categories, viridis for continuous).

## Code

- R: `library()` calls at the top, `here::here()` for paths, `data.table` or `tidyverse`
  as the student prefers, `fixest` for regressions with fixed effects.
- Python: `pathlib` for paths, `pandas`, `statsmodels` / `pyfixest`.
- Do not run `install.packages()` or `pip install` from inside scripts or chat unless the
  student explicitly asks; explain what would be installed first.
- Commit messages: imperative subject line, short body when the change is not obvious.
AGENTS

# ---------------------------------------------------------------- report
say "Finished."
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "These steps had problems (re-running the script usually fixes them):"
  printf '  - %s\n' "${FAILED[@]}"
fi
echo "Now do the manual steps in the README (Zotero sign-in, local API tick-box,"
echo "Better BibTeX, ChatGPT sign-in). Then quit and reopen Terminal."
