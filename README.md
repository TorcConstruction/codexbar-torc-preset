# CodexBar Torc preset

Shareable macOS setup for [CodexBar](https://github.com/steipete/CodexBar) with Torc Construction’s **lean overview**.

| Setting | Value |
|--------|--------|
| Menu bar | **One merged icon** |
| Overview | Claude → Cursor → Codex (Codex last) |
| Bars | **Used %** (fill toward 100%, Claude-style) |
| Dollars / spend | **Off** |
| Agent sessions | **Off** |
| Accents | Claude `#D97757`, Cursor `#3B82F6`, Codex `#10A37F` |
| Clutter rows | Credits / Spark / Daily Routines / sessions hidden |

CodexBar itself stays upstream (`brew install --cask codexbar`). This repo only installs it and applies prefs. **No logins or secrets** are stored here.

## Install (any Mac)

```bash
git clone https://github.com/TorcConstruction/codexbar-torc-preset.git
cd codexbar-torc-preset
./install.sh
```

## After install — sign in once per Mac

1. **Claude** — `claude auth login` or stay signed in at [claude.ai](https://claude.ai). If CodexBar says OAuth missing, sync Keychain → `~/.claude/.credentials.json` (Claude Code keeps tokens in Keychain).
2. **Cursor** (GrokBot lane) — sign in at [cursor.com](https://cursor.com), grant CodexBar **Full Disk Access** if asked, then connect Cursor in CodexBar.
3. **Codex** — existing ChatGPT / Codex session.

## What you should see

Click the menu bar icon → **Overview** with three short cards (Claude, Cursor, Codex). Used-% bars and reset timing. No spend header, no scroll of junk rows.

Hover session/weekly tips on bars cannot be turned off upstream. Ignore them; Overview is the source of truth. Open an individual provider for deeper detail when you want it.

## Uninstall preset only

```bash
defaults delete com.steipete.codexbar
# optional: rm ~/.config/codexbar/config.json
brew uninstall --cask codexbar
```

## License

MIT. CodexBar is MIT by [steipete](https://github.com/steipete/CodexBar).
