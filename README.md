# CodexBar Torc preset

Shareable macOS setup for [CodexBar](https://github.com/steipete/CodexBar) with the Torc Construction display prefs:

| Setting | Value |
|--------|--------|
| Usage bars | **Used %** (fills up like Claude’s meter, not a fuel tank) |
| Dollars / cost | **Off** |
| Menu bar | **Percent** |
| Providers | **Claude → Cursor → Codex** (Codex at bottom) |
| Icons | **Separate** Claude / Cursor / Codex with **provider name** + % |

CodexBar itself stays upstream (`brew install --cask codexbar`). This repo only installs it and applies prefs.

## Install (any Mac)

```bash
brew install --cask codexbar   # if you want to peek first
git clone https://github.com/TorcConstruction/codexbar-torc-preset.git
cd codexbar-torc-preset
./install.sh
```

Or one-liner after clone:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/TorcConstruction/codexbar-torc-preset/main/install.sh)"
```

> One-liner needs the raw `install.sh` to be self-contained for prefs; prefer clone + `./install.sh` so `config.json` ships with it.

## After install — sign in once per Mac

This preset does **not** copy logins (by design, safe to share).

1. **Claude** — `claude auth login` or stay signed in at [claude.ai](https://claude.ai)
2. **Cursor** (Grady / GrokBot pool) — sign in at [cursor.com](https://cursor.com), enable CodexBar Full Disk Access if asked, then CodexBar → Add / switch account → Cursor
3. **Codex** — your existing ChatGPT / Codex session

## What friends get

- Same bar behavior and provider order  
- Their own Claude / Cursor / Codex accounts  
- No Torc credentials in this repo  

## Uninstall preset only

Delete `~/.config/codexbar/config.json` overrides as you like, or reinstall CodexBar and reset prefs:

```bash
defaults delete com.steipete.codexbar
```

Remove the app: `brew uninstall --cask codexbar`

## License

MIT. CodexBar is MIT by [steipete](https://github.com/steipete/CodexBar).
