-- English, the base language. Each key is the English text; translations in the other files
-- use the same keys, and anything they leave out shows in English.
--
-- %s marks where the code inserts a value (a keyword, a number, a command). Translations keep
-- the same number of %s, in the same order.
local L = LibStub("AceLocale-3.0"):NewLocale("QuietChat", "enUS", true)

-- Keywords (QuietChat.lua)
L["Type a keyword first"] = true
L["Use * only at the start or end of a keyword, e.g. %s or %s"] = true
L['"%s" is already a keyword'] = true
L["Use * only at the start or end of a keyword. Fix these lines: %s"] = true

-- Slash commands (Commands.lua)
L["Filter is active"] = true
L["Filter is disabled"] = true
L["Foreign languages are blocked"] = true
L["Foreign languages are shown"] = true
L["Repeated messages are hidden for %s seconds after the first one"] = true
L["Repeated messages are shown"] = true
L["Keywords: %s (/qc words to list them)"] = true
L["word"] = true
L["seconds"] = true
L["Open the settings panel"] = true
L["Turn the filter on or off"] = true
L["Block or show messages in languages you don't speak (e.g. Orcish)"] = true
L["Show a player's message only once within this many seconds, across all channels (0 = off)"] = true
L["List keywords (whole words, case-insensitive)"] = true
L['Add a keyword or phrase. A * at the start or end also matches inside words: %s matches "hello"'] = true
L["Remove a keyword or phrase"] = true
L["Reset keywords to the default list"] = true
L["Hidden messages are listed in the settings panel, under Blocked messages"] = true
L["Settings are still loading, try again in a moment"] = true
L["The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely"] = true
L["Usage: %s"] = true
L["0 turns it off"] = true
L["No keywords set. Add one with %s"] = true
L["Keywords:"] = true
L["(invalid, never matches)"] = true
L['Added "%s"'] = true
L['Removed "%s"'] = true
L['"%s" is not a keyword. See %s'] = true
L["Keywords reset to the default list"] = true

-- Settings panel (Options.lua)
L["General"] = true
L["Hides chat spam in channels, /say and /yell. Messages from friends, guild, party and raid members aren't hidden unless you turn that on below, and your own never are."] =
	true
L["Enable filter"] = true
L["Turn all filtering on or off."] = true
L["Block languages you don't speak"] = true
L["Hide messages in languages your character can't read, like Orcish for Alliance or Common for Horde."] = true
L["Also filter friends, guild and group"] = true
L["Apply the filter to your friends, guild members, party and raid too. Your own messages are never hidden."] = true
L["Repeated messages"] = true
L["When a player sends the same message several times, for example to Trade, General and /yell at once, show only the first copy. Their next copy shows again once this many seconds have passed. Set to 0 to show every copy."] =
	true
L["Show once every (seconds)"] = true
L["Keywords"] = true
L['Messages containing any of these keywords are hidden. Capitalization doesn\'t matter, and keywords only match whole words: %s hides "what the hell" but not "hello".'] =
	true
L['Put a * at the start or end to also match inside longer words: %s also hides "hello", and %s hides anything containing "gold".'] =
	true
L["Keywords (%s), one per line. Click Accept to save"] = true
L["Add, edit or delete lines, then click Accept. Blank lines and duplicates are ignored."] = true
L["These keywords never match because of a misplaced *:"] = true
L["Reset to defaults"] = true
L["Replace your keywords with the default list."] = true
L["Replace your keywords with the default list (%s)?"] = true
L["Blocked messages"] = true
L["The last %s messages hidden this session, newest first. The list is cleared when you log out or reload."] = true
L["Refresh"] = true
L["Show messages hidden since the panel was opened."] = true
L["Nothing has been hidden yet."] = true
L['keyword "%s"'] = true
L["repeat"] = true
