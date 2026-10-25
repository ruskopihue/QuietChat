-- Slash commands: /qc and /quietchat.
-- Settings live in QuietChat.db; keyword changes go through the shared QuietChat.* functions.
-- The commands themselves stay in English in every language; their descriptions are translated.

local addon = QuietChat
local L = LibStub("AceLocale-3.0"):GetLocale("QuietChat")
local Highlight = addon.Highlight
local PREFIX = "|cff00ffffQuietChat:|r "

local function Print(msg)
	print(PREFIX .. msg)
end

local function OnOff(enabled, onText, offText)
	if enabled then
		return "|cff00ff00" .. onText .. "|r"
	else
		return "|cffff0000" .. offText .. "|r"
	end
end

-- Each setting's state as one sentence, shown by /qc and after changing it
local function FilterState(db)
	return OnOff(db.active, L["Filter is active"], L["Filter is disabled"])
end

local function LanguageState(db)
	return OnOff(db.blockForeign, L["The other faction's speech is hidden"], L["The other faction's speech is shown"])
end

local function RepeatState(db)
	return OnOff(
		db.repeatWindow > 0,
		format(L["Repeated messages are hidden for %s seconds after the first one"], db.repeatWindow),
		L["Repeated messages are shown"]
	)
end

local function ShowStatus(db)
	Print(FilterState(db))
	print("  " .. LanguageState(db))
	print("  " .. RepeatState(db))
	print("  " .. format(L["Keywords: %s (/qc words to list them)"], Highlight(#db.words)))
end

local function HelpLine(command, description)
	print(command .. " - " .. description)
end

local function ShowHelp()
	local word, seconds = Highlight(L["word"]), Highlight(L["seconds"])
	HelpLine("/qc config", L["Open the settings panel"])
	HelpLine("/qc toggle", L["Turn the filter on or off"])
	HelpLine("/qc languages", L["Hide or show the other faction's speech"])
	HelpLine(
		"/qc repeat [" .. seconds .. "]",
		L["Show a player's message only once within this many seconds, across all channels (0 = off)"]
	)
	HelpLine("/qc words", L["List keywords (whole words, case-insensitive)"])
	HelpLine(
		"/qc add " .. word,
		format(
			L['Add a keyword or phrase. A * at the start or end also matches inside words: %s matches "hello"'],
			Highlight("hell*")
		)
	)
	HelpLine("/qc remove " .. word, L["Remove a keyword or phrase"])
	HelpLine("/qc default", L["Reset keywords to the default list"])
	print(L["Hidden messages are listed in the settings panel, under Blocked messages"])
end

local function Usage(command)
	Print(format(L["Usage: %s"], command))
end

local function RunCommand(input)
	local db = addon.db
	if not db then
		Print(L["Settings are still loading, try again in a moment"])
		return
	end
	local cmd, arg = strsplit(" ", strtrim(input or ""), 2)
	cmd = strlower(cmd or "")
	if arg then
		arg = strtrim(arg)
		if arg == "" then
			arg = nil
		end
	end

	if cmd == "config" or cmd == "options" then
		if addon.OpenOptions then
			addon.OpenOptions()
		else
			-- WoW only reads new files from the .toc on a full restart, not on /reload
			Print(L["The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely"])
		end
	elseif cmd == "toggle" then
		db.active = not db.active
		Print(FilterState(db))
	elseif cmd == "languages" then
		db.blockForeign = not db.blockForeign
		Print(LanguageState(db))
	elseif cmd == "repeat" then
		if arg then
			if not arg:match("^%d+$") then
				Usage("/qc repeat [" .. Highlight(L["seconds"]) .. "], " .. L["0 turns it off"])
				return
			end
			addon.SetRepeatWindow(tonumber(arg))
		end
		Print(RepeatState(db))
	elseif cmd == "words" then
		if #db.words == 0 then
			Print(format(L["No keywords set. Add one with %s"], "/qc add " .. Highlight(L["word"])))
			return
		end
		Print(L["Keywords:"])
		for _, word in ipairs(db.words) do
			local note = addon.IsValidKeyword(word) and "" or " |cffff0000" .. L["(invalid, never matches)"] .. "|r"
			print('  "' .. Highlight(word) .. '"' .. note)
		end
	elseif cmd == "add" then
		if not arg then
			Usage("/qc add " .. Highlight(L["word"]))
			return
		end
		local word, err = addon.AddKeyword(arg)
		if word then
			Print(format(L['Added "%s"'], Highlight(word)))
		else
			Print(err)
		end
	elseif cmd == "remove" then
		if not arg then
			Usage("/qc remove " .. Highlight(L["word"]))
			return
		end
		local removed = addon.RemoveKeyword(arg)
		if removed then
			Print(format(L['Removed "%s"'], Highlight(removed)))
		else
			Print(format(L['"%s" is not a keyword. See %s'], Highlight(arg), "/qc words"))
		end
	elseif cmd == "default" then
		addon.ResetKeywords()
		Print(L["Keywords reset to the default list"])
	else
		ShowStatus(db)
		ShowHelp()
	end
end

SLASH_QUIETCHAT1, SLASH_QUIETCHAT2 = "/qc", "/quietchat"
SlashCmdList["QUIETCHAT"] = function(input)
	RunCommand(input)
	-- Keep the settings panel in sync if it's open
	addon.RefreshOptions()
end
