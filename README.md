# QuietChat

A chat spam filter for **World of Warcraft 3.3.5a** (Wrath of the Lich King).

QuietChat hides gold sellers, boost ads, recruitment spam and copy-pasted messages from
channels, /say and /yell, without hiding anything from your friends, guild or group.

## Features

- **Keyword filter.** Hide messages containing words or phrases you choose. Matching ignores
  capitalization and only matches whole words, so `hell` hides "what the hell" but not "hello".
  Put a `*` at the start or end to also match inside longer words: `boost*` also hides
  "boosting", and `*gold*` hides anything containing "gold".
- **Repeated messages shown once.** When a player posts the same message to Trade, General and
  /yell within seconds, you see it once. Their next round shows again after a delay you choose
  (15 seconds by default). Changes in capitalization, spacing or symbols don't count as a new
  message.
- **Foreign languages.** Optionally hide /say and /yell in languages your character doesn't speak,
  such as Orcish for Alliance or Common for Horde.
- **Whispers.** Optionally apply the filter to whispers too.
- **Never hides** messages from friends, guild members, your party or raid, or yourself.
- **Settings panel** under *Interface → AddOns → QuietChat*, plus slash commands.
- **Blocked messages log** to check what was hidden this session.

## Installing

1. Download `QuietChat-<version>.zip` from the **Releases** page (not the green *Code* button,
   whose zip has the wrong folder name and won't load) and extract it into
   `World of Warcraft/Interface/AddOns/`, so you end up with
   `Interface/AddOns/QuietChat/QuietChat.toc`.
2. Restart the game (a `/reload` doesn't pick up new addons).
3. Open the settings with `/qc config`.

## Commands

`/qc` or `/quietchat` on its own shows the current settings and this list.

| Command | What it does |
|---|---|
| `/qc config` | Open the settings panel |
| `/qc toggle` | Turn the filter on or off |
| `/qc foreign` | Hide or show languages you don't speak |
| `/qc whispers` | Also filter whispers |
| `/qc repeat [seconds]` | Show a player's message once within this many seconds (0 = off) |
| `/qc verbose` | Print a line in chat when something is hidden |
| `/qc words` | List keywords |
| `/qc add <word>` | Add a keyword or phrase |
| `/qc remove <word or number>` | Remove a keyword |
| `/qc log [n]` | Show the last *n* hidden messages (up to 20) |
| `/qc default` | Reset keywords to the default list |

The default keywords are `wts`, `wtb`, `recruiting` and `lfw`.

## Credits

- Based on the idea of **ChatFilter** by **Xcom** (hellohamburger on the Warmane forum), a small
  keyword filter for 3.3.5a shared there in 2019. QuietChat started as an update to it and has
  since been rewritten.
- The settings panel uses the **[Ace3](https://github.com/WoWUIDev/Ace3)** libraries
  (LibStub, CallbackHandler, AceGUI, AceConfigRegistry and AceConfigDialog), included unmodified
  in `libs/`. See `libs/Ace3-LICENSE.txt`.

## License

MIT, see `LICENSE`. The Ace3 libraries in `libs/` keep their own license.

## Development

The tests run the addon's real Lua code in a Lua 5.1 interpreter, with the WoW functions it uses
replaced by stand-ins. They check the logic, not how anything looks in game. They need
[uv](https://docs.astral.sh/uv/):

```sh
uv run pytest
```

Lua is checked with [luacheck](https://github.com/lunarmodules/luacheck) and formatted with
[StyLua](https://github.com/JohnnyMorganz/StyLua); the Python tests with
[ruff](https://docs.astral.sh/ruff/). The same checks run on GitHub for every push and pull request.

```sh
luacheck .
stylua .
uv run ruff check .
uv run ruff format .
```

To try changes in game, set `WOW_ADDONS_DIR` (see `deploy.sh`) and run `./deploy.sh`.

To publish a release, set `## Version:` in `QuietChat.toc`, commit, and push a matching tag
(`git tag v1.1 && git push origin v1.1`). GitHub runs the checks, builds the zip with
`package.sh` and attaches it to a new release. `./package.sh` builds the same zip locally in
`dist/`.
