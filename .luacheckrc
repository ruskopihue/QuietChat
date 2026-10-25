-- luacheck settings: https://luacheck.readthedocs.io/en/stable/config.html
std = "lua51"
-- StyLua keeps code within 120 columns; only long text strings go past it, which is fine
max_line_length = false
exclude_files = { "libs/", ".venv/" }
-- WoW and Ace3 call our functions with fixed argument lists, so unused arguments are expected
unused_args = false

-- Globals the addon sets
globals = {
	"QuietChat",
	"QuietChatDB",
	"SLASH_QUIETCHAT1",
	"SLASH_QUIETCHAT2",
	"SlashCmdList",
}

-- WoW API (3.3.5a) and bundled libraries the addon reads. Add new ones here when luacheck reports
-- "accessing undefined variable"; check the function exists in 3.3.5a first.
read_globals = {
	-- Lua functions WoW adds or renames
	"format",
	"min",
	"strjoin",
	"strlower",
	"strsplit",
	"strtrim",
	"tContains",
	"tinsert",
	"tremove",
	"wipe",

	-- Game API
	"ChatFrame_AddMessageEventFilter",
	"CreateFrame",
	"GetFriendInfo",
	"GetLanguageByIndex",
	"GetNumFriends",
	"GetNumLanguages",
	"GetTime",
	"InterfaceOptionsFrame_OpenToCategory",
	"UnitInParty",
	"UnitInRaid",
	"UnitIsInMyGuild",
	"UnitName",

	-- Libraries in libs/
	"LibStub",
}
