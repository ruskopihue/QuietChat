-- Slash commands: /qc and /quietchat.
-- Settings live in QuietChat.db; keyword changes go through the shared QuietChat.* functions.

local addon = QuietChat
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

local function ShowStatus(db)
	Print("Filter is " .. OnOff(db.active, "active", "disabled"))
	print("  Foreign languages: " .. OnOff(db.blockForeign, "blocked", "shown"))
	print("  Repeats: " .. OnOff(db.repeatWindow > 0, "hidden for " .. db.repeatWindow .. "s", "shown"))
	print("  Keywords: " .. Highlight(#db.words) .. " (/qc words to list them)")
end

local function ShowHelp()
	print("/qc config - Open the settings panel")
	print("/qc toggle - Turn the filter |cff00ff00on|r / |cffff0000off|r")
	print("/qc foreign - Block or show messages in languages you don't speak (e.g. Orcish)")
	print(
		"/qc repeat ["
			.. Highlight("seconds")
			.. "] - Show a player's message only once within this many seconds, across all channels (0 = off)"
	)
	print("/qc words - List keywords (whole words, case-insensitive)")
	print(
		"/qc add "
			.. Highlight("word")
			.. " - Add a keyword or phrase. A * at the start or end also matches inside words: "
			.. Highlight("hell*")
			.. ' matches "hello"'
	)
	print("/qc remove " .. Highlight("word") .. " - Remove a keyword or phrase")
	print("/qc default - Reset keywords to the default list")
	print("Hidden messages are listed in the settings panel, under Blocked messages")
end

local function RunCommand(input)
	local db = addon.db
	if not db then
		Print("Settings are still loading, try again in a moment")
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
			Print("The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely")
		end
	elseif cmd == "toggle" then
		db.active = not db.active
		Print("Filter is now " .. OnOff(db.active, "active", "disabled"))
	elseif cmd == "foreign" then
		db.blockForeign = not db.blockForeign
		Print("Foreign language messages will be " .. OnOff(db.blockForeign, "blocked", "shown"))
	elseif cmd == "repeat" then
		if arg then
			if not arg:match("^%d+$") then
				Print("Usage: /qc repeat [" .. Highlight("seconds") .. "], 0 turns it off")
				return
			end
			addon.SetRepeatWindow(tonumber(arg))
		end
		if db.repeatWindow > 0 then
			Print("Repeated messages are hidden for " .. Highlight(db.repeatWindow .. "s") .. " after the first one")
		else
			Print("Repeated messages are |cffff0000shown|r")
		end
	elseif cmd == "words" then
		if #db.words == 0 then
			Print("No keywords set. Add one with /qc add " .. Highlight("word"))
			return
		end
		Print("Keywords:")
		for _, word in ipairs(db.words) do
			local note = addon.IsValidKeyword(word) and "" or " |cffff0000(invalid, never matches)|r"
			print('  "' .. Highlight(word) .. '"' .. note)
		end
	elseif cmd == "add" then
		if not arg then
			Print("Usage: /qc add " .. Highlight("word"))
			return
		end
		local word, err = addon.AddKeyword(arg)
		if word then
			Print('Added "' .. Highlight(word) .. '"')
		else
			Print(err)
		end
	elseif cmd == "remove" then
		if not arg then
			Print("Usage: /qc remove " .. Highlight("word"))
			return
		end
		local removed = addon.RemoveKeyword(arg)
		if removed then
			Print('Removed "' .. Highlight(removed) .. '"')
		else
			Print('"' .. Highlight(arg) .. '" is not a keyword. See /qc words')
		end
	elseif cmd == "default" then
		addon.ResetKeywords()
		Print("Keywords reset to the default list")
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
