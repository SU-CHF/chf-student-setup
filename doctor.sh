#!/bin/bash
# CHF student Mac: diagnosis report. Read-only; installs nothing.
# Run with:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SU-CHF/chf-student-setup/main/doctor.sh)"
# Prints tool versions and which setup stages are incomplete, and copies the report to the clipboard.

set -u
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
PY="$HOME/.venvs/research/bin/python"
TEXBIN="$HOME/Library/TinyTeX/bin/universal-darwin"

report() {
  echo "CHF setup diagnosis  $(date '+%Y-%m-%d %H:%M')"
  echo "macOS $(sw_vers -productVersion) on $(uname -m); user $(whoami); admin: $(id -Gn | tr ' ' '\n' | grep -qx admin && echo yes || echo NO)"
  echo
  v() { # label, command...
    local label=$1; shift
    if out=$("$@" 2>&1); then printf '  ok   %-14s %s\n' "$label" "$(echo "$out" | head -1)"
    else printf '  MISS %-14s (%s)\n' "$label" "$(echo "$out" | head -1)"; fi
  }
  echo "Stage 1 Homebrew";      v brew brew --version
  echo "Stage 2 Apps"
  for app in Zotero R "Visual Studio Code" Positron ChatGPT "GitHub Desktop"; do
    [ -d "/Applications/$app.app" ] && printf '  ok   %s\n' "$app" || printf '  MISS %s\n' "$app"
  done
  v quarto quarto --version; v uv uv --version; v git-lfs git lfs version
  echo "Stage 3 Git"
  printf '  name/email:    %s <%s>\n' "$(git config --global user.name 2>/dev/null)" "$(git config --global user.email 2>/dev/null)"
  echo "Stage 4 LaTeX"
  v tlmgr "$TEXBIN/tlmgr" --version
  [ -x "$TEXBIN/lualatex" ] && echo "  ok   lualatex" || echo "  MISS lualatex"
  echo "Stage 5 R"
  v R R --version
  command -v Rscript >/dev/null && Rscript -e '
    pk <- c("rmarkdown","knitr","languageserver","tidyverse","data.table","haven",
            "fixest","modelsummary","tinytable","kableExtra","here")
    miss <- setdiff(pk, rownames(installed.packages()))
    cat(if (length(miss)) paste("  MISS R packages:", paste(miss, collapse=" ")) else "  ok   R packages", "\n")' 2>/dev/null
  echo "Stage 6 Python"
  v python "$PY" --version
  [ -x "$PY" ] && "$PY" - <<'EOF' 2>/dev/null
import importlib
miss=[m for m in ["jupyter","pandas","numpy","matplotlib","statsmodels","pyfixest","tabulate"] if importlib.util.find_spec(m) is None]
print("  MISS Python packages:", " ".join(miss)) if miss else print("  ok   Python packages")
EOF
  grep -qs QUARTO_PYTHON ~/.zprofile && echo "  ok   QUARTO_PYTHON in ~/.zprofile" || echo "  MISS QUARTO_PYTHON in ~/.zprofile"
  echo "Stage 7 VS Code"
  if command -v code >/dev/null; then
    have=$(code --list-extensions 2>/dev/null)
    for e in quarto.quarto reditorsupport.r ms-python.python ms-toolsai.jupyter openai.chatgpt; do
      echo "$have" | grep -qi "^$e$" && printf '  ok   %s\n' "$e" || printf '  MISS %s\n' "$e"
    done
  else echo "  MISS code command"; fi
  echo "Stage 8 Zotero MCP / Codex"
  v zotero-mcp "$HOME/.local/bin/zotero-mcp" --version
  grep -qs '^\[mcp_servers\.zotero\]' ~/.codex/config.toml && echo "  ok   [mcp_servers.zotero] in ~/.codex/config.toml" || echo "  MISS [mcp_servers.zotero] in ~/.codex/config.toml"
  [ -f ~/.codex/AGENTS.md ] && echo "  ok   ~/.codex/AGENTS.md" || echo "  MISS ~/.codex/AGENTS.md"
  pgrep -qx Zotero && echo "  ok   Zotero is running" || echo "  note Zotero is not running (Codex needs it open)"
  curl -s -m 2 http://127.0.0.1:23119/connector/ping >/dev/null 2>&1 && echo "  ok   Zotero local API answers" || echo "  note Zotero local API not answering (open Zotero; Settings > Advanced > Allow other applications)"
  echo
  echo "Quarto check (abridged):"
  command -v quarto >/dev/null && quarto check 2>&1 | grep -E '^\[|OK|ERROR|WARN|not found' | head -25
}

out=$(report 2>&1)
echo "$out"
echo "$out" | pbcopy 2>/dev/null && echo && echo "(Report copied to the clipboard: paste it into ChatGPT or an email to Jesse.)"
