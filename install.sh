#!/usr/bin/env bash
# CodexBar Torc preset installer
# Installs CodexBar and applies the Torc display preset (used-% bars, no $, Claude/Cursor/Codex order).
# Does NOT copy login sessions. Each Mac signs into Claude / Cursor / Codex once after install.
set -euo pipefail

PRESET_DIR="$(cd "$(dirname "$0")" && pwd)"
DOMAIN="com.steipete.codexbar"
CONFIG_DIR="${HOME}/.config/codexbar"

echo "==> Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install from https://brew.sh then re-run."
  exit 1
fi

echo "==> Installing CodexBar (cask)"
brew install --cask codexbar

echo "==> Quitting CodexBar if running"
killall CodexBar 2>/dev/null || true
sleep 1

echo "==> Applying preferences"
# Core toggles
defaults write "$DOMAIN" usageBarsShowUsed -bool true
defaults write "$DOMAIN" lastObservedUsageBarsShowUsed -bool true
defaults write "$DOMAIN" lastSwitcherUsageBarsShowUsed -bool true
defaults write "$DOMAIN" tokenCostUsageEnabled -bool false
defaults write "$DOMAIN" costSummaryDisplayStyle -string off
defaults write "$DOMAIN" costSummaryDisplayStyleRaw -string off
defaults write "$DOMAIN" menuBarDisplayMode -string percent
defaults write "$DOMAIN" menuBarDisplayModeRaw -string percent
defaults write "$DOMAIN" providersSortedAlphabetically -bool false
defaults write "$DOMAIN" showOptionalCreditsAndExtraUsage -bool false
defaults write "$DOMAIN" costHistoryChartEnabled -bool false
defaults write "$DOMAIN" "NSStatusItem VisibleCC codexbar-merged" -bool true
# Provider order: Claude, Cursor, Codex (Codex at bottom)
defaults write "$DOMAIN" lastProviderOrder -array claude cursor codex
defaults write "$DOMAIN" _providerOrder -array claude cursor codex

echo "==> Writing config (enabled providers only; no secrets)"
mkdir -p "$CONFIG_DIR"
# Merge: if config exists, enable our three and set order; else copy preset
if [[ -f "$CONFIG_DIR/config.json" ]]; then
  python3 - "$CONFIG_DIR/config.json" "$PRESET_DIR/config.json" <<'PY'
import json, sys
from pathlib import Path
cur=json.loads(Path(sys.argv[1]).read_text())
preset=json.loads(Path(sys.argv[2]).read_text())
want=["claude","cursor","codex"]
by={p.get("id"): dict(p) for p in cur.get("providers", []) if p.get("id")}
for i in want:
    p=by.get(i, {"id": i})
    p["enabled"]=True
    # strip secrets if any
    for k in list(p):
        if any(s in k.lower() for s in ("key","token","secret","cookie","credential","auth")) and k != "id":
            p.pop(k, None)
    by[i]=p
# disable nothing else automatically — only ensure ours on
ordered=[]
for i in want:
    ordered.append(by.pop(i))
ordered.extend(by.values())
cur["providers"]=ordered
cur["providersSortedAlphabetically"]=False
Path(sys.argv[1]).write_text(json.dumps(cur, indent=2)+"\n")
print("merged", sys.argv[1])
PY
else
  cp "$PRESET_DIR/config.json" "$CONFIG_DIR/config.json"
  chmod 600 "$CONFIG_DIR/config.json"
fi


echo "==> Separate icons with provider names"
defaults write "$DOMAIN" mergeIcons -bool false
defaults write "$DOMAIN" lastMergeIcons -bool false
defaults write "$DOMAIN" menuBarLayoutPrimaryLabel -string providerName
defaults write "$DOMAIN" storedMenuBarLayout -string '{"lines":[[{"icon":{}},{"providerName":{}},{"space":{}},{"percent":{"window":"automatic"}}]]}'
defaults delete "$DOMAIN" "NSStatusItem VisibleCC codexbar-merged" 2>/dev/null || true

echo "==> Launching CodexBar"
open -a CodexBar || open /Applications/CodexBar.app

cat <<'MSG'

Done. CodexBar preset applied:
  • Bars = used % (fills up toward 100%)
  • Dollars / cost summary off
  • Providers: Claude → Cursor → Codex (Codex at bottom)

Sign-in (each machine, once):
  1. Claude: run `claude auth login` in Terminal, or sign in at claude.ai
  2. Cursor: sign in at cursor.com in Chrome, then CodexBar → Add / switch account → Cursor
     (grant CodexBar Full Disk Access if prompted)
  3. Codex: already uses your ChatGPT/Codex login when present

Friends: same install.sh. They use their own accounts — this repo never stores sessions.
MSG
