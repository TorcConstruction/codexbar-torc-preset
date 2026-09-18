#!/usr/bin/env bash
# CodexBar Torc lean-overview preset
# Used-% bars, merged overview, Claude→Cursor→Codex, accents, no $.
# Does NOT copy login sessions.
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

echo "==> Applying lean Torc preferences"
defaults write "$DOMAIN" usageBarsShowUsed -bool true
defaults write "$DOMAIN" lastObservedUsageBarsShowUsed -bool true
defaults write "$DOMAIN" lastSwitcherUsageBarsShowUsed -bool true
defaults write "$DOMAIN" tokenCostUsageEnabled -bool false
defaults write "$DOMAIN" costSummaryDisplayStyle -string off
defaults write "$DOMAIN" costSummaryDisplayStyleRaw -string off
defaults write "$DOMAIN" costSummaryInlineEnabled -bool false
defaults write "$DOMAIN" tokenCostMenuSectionEnabled -bool false
defaults write "$DOMAIN" costHistoryChartEnabled -bool false
defaults write "$DOMAIN" agentSessionsEnabled -bool false
defaults write "$DOMAIN" showOptionalCreditsAndExtraUsage -bool false
defaults write "$DOMAIN" claudeDailyRoutinesUsageVisible -bool false
defaults write "$DOMAIN" claudeModelScopedWeeklyUsageVisible -bool false
defaults write "$DOMAIN" codexSparkUsageVisible -bool false
defaults write "$DOMAIN" showCodexOpenAIWebExtras -bool false
defaults write "$DOMAIN" menuBarDisplayMode -string percent
defaults write "$DOMAIN" menuBarDisplayModeRaw -string percent
defaults write "$DOMAIN" menuBarLayoutGapRaw -string tight
defaults write "$DOMAIN" menuBarLayoutSizeRaw -string small
defaults write "$DOMAIN" providersSortedAlphabetically -bool false
defaults write "$DOMAIN" lastProviderOrder -array claude cursor codex
defaults write "$DOMAIN" _providerOrder -array claude cursor codex
defaults write "$DOMAIN" mergedOverviewSelectedProviders -array claude cursor codex
defaults write "$DOMAIN" mergedMenuLastSelectedWasOverview -bool true
defaults write "$DOMAIN" "NSStatusItem VisibleCC codexbar-merged" -bool true

# Drop the old separate-icon layout if a prior preset left it behind
defaults delete "$DOMAIN" mergeIcons 2>/dev/null || true
defaults delete "$DOMAIN" lastMergeIcons 2>/dev/null || true
defaults delete "$DOMAIN" menuBarLayoutPrimaryLabel 2>/dev/null || true
defaults delete "$DOMAIN" storedMenuBarLayout 2>/dev/null || true

defaults write "$DOMAIN" providerAccentColors -dict \
  claude "#D97757" \
  cursor "#3B82F6" \
  codex "#10A37F"

echo "==> Writing config (enabled providers + hidden clutter; no secrets)"
mkdir -p "$CONFIG_DIR"
python3 - "$CONFIG_DIR/config.json" "$PRESET_DIR/config.json" <<'PY'
import json, sys
from pathlib import Path
dest, src = Path(sys.argv[1]), Path(sys.argv[2])
preset = json.loads(src.read_text())
want = ["claude", "cursor", "codex"]
if dest.exists():
    cur = json.loads(dest.read_text())
else:
    cur = {"version": 1, "providers": []}
by = {p.get("id"): dict(p) for p in cur.get("providers", []) if p.get("id")}
preset_by = {p["id"]: p for p in preset.get("providers", [])}
for i in want:
    p = by.get(i, {"id": i})
    p["enabled"] = True
    for field in ("accentColor", "hiddenUsageItemIDs"):
        if i in preset_by and field in preset_by[i]:
            p[field] = preset_by[i][field]
    for k in list(p):
        if any(s in k.lower() for s in ("key", "token", "secret", "cookie", "credential", "auth")) and k != "id":
            p.pop(k, None)
    by[i] = p
ordered = [by.pop(i) for i in want]
ordered.extend(by.values())
cur["providers"] = ordered
cur["providersSortedAlphabetically"] = False
cur["version"] = cur.get("version", 1)
dest.write_text(json.dumps(cur, indent=2) + "\n")
print("wrote", dest)
PY
chmod 600 "$CONFIG_DIR/config.json"

echo "==> Launching CodexBar"
open /Applications/CodexBar.app 2>/dev/null || open -a CodexBar

cat <<'MSG'

Done. Torc lean CodexBar preset applied:
  • Merged menu bar icon / Overview
  • Claude → Cursor → Codex
  • Used-% bars (fill toward 100%)
  • Dollars / agent sessions / clutter rows off
  • Provider accent colors on

Sign-in (each machine, once):
  1. Claude: `claude auth login` or claude.ai
  2. Cursor: cursor.com + Full Disk Access if prompted
  3. Codex: existing ChatGPT / Codex session

Friends use the same install.sh with their own accounts. No secrets in this repo.
MSG
