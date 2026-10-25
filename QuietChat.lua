-- QuietChat: hides chat spam by keyword, language and repeated messages.
-- Based on the idea of ChatFilter by Xcom (hellohamburger on the Warmane forum), a small keyword
-- filter for WoW 3.3.5a.

-- Shared with Options.lua, which builds the settings panel
local addon = {}
QuietChat = addon

local PREFIX = "|cff00ffffQuietChat:|r "
local LOG_SIZE = 20
local defaultWords = { "wts", "wtb", "recruiting", "lfw" }
local defaults = { active = true, blockForeign = false, repeatWindow = 15 }

local db
local messageLog = {}
local recentMessages = {} -- [player:text] = time the message was last shown
local lastPrune = 0

local function Print(msg)
	print(PREFIX .. msg)
end

local function Highlight(text)
	return "|cff00ffff" .. text .. "|r"
end

local function OnOff(enabled, onText, offText)
	if enabled then
		return "|cff00ff00" .. onText .. "|r"
	else
		return "|cffff0000" .. offText .. "|r"
	end
end

local function CopyDefaultWords()
	local t = {}
	for i, word in ipairs(defaultWords) do
		t[i] = word
	end
	return t
end

local function FindWord(word)
	for i, w in ipairs(db.words) do
		if w == word then
			return i
		end
	end
end

-- Letters, digits and any non-ASCII byte (accented letters, Cyrillic, ...) count as part of a word
local WORD_CHARS = "%w\128-\255"

-- Turns a keyword into a Lua pattern that only matches whole words.
-- A * at the start or end lets the keyword match inside longer words ("hell*" matches "hello").
-- Returns nil if the keyword is invalid (empty, or a * anywhere else).
local function CompileKeyword(keyword)
	local core = keyword:match("^%*?(.-)%*?$")
	if core == "" or core:find("*", 1, true) then
		return nil
	end
	local pattern = core:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
	-- Edges only make sense next to word characters, so ":)" or "[wts" still match
	if keyword:sub(1, 1) ~= "*" and core:find("^[" .. WORD_CHARS .. "]") then
		pattern = "%f[" .. WORD_CHARS .. "]" .. pattern
	end
	if keyword:sub(-1) ~= "*" and core:find("[" .. WORD_CHARS .. "]$") then
		pattern = pattern .. "%f[^" .. WORD_CHARS .. "]"
	end
	return pattern
end

-- Compiled patterns, built the first time each keyword is used
local patterns = setmetatable({}, {
	__index = function(t, keyword)
		local pattern = CompileKeyword(keyword) or false
		t[keyword] = pattern
		return pattern
	end,
})

local function NormalizeKeyword(text)
	return (strlower(strtrim(text)):gsub("%s+", " "))
end

-- Lowercase text as the player sees it: no color codes, link data or icons, single spaces
local function CleanMessage(msg)
	msg = msg:gsub("|c%x%x%x%x%x%x%x%x", "")
		:gsub("|r", "")
		:gsub("|H.-|h", "")
		:gsub("|h", "")
		:gsub("|T.-|t", "")
		:gsub("%s+", " ")
	return strlower(msg)
end

-- Settings are saved in QuietChatDB; fill in anything missing with the defaults
local function InitDB()
	if type(QuietChatDB) ~= "table" then
		QuietChatDB = {}
	end
	db = QuietChatDB

	for key, value in pairs(defaults) do
		if db[key] == nil then
			db[key] = value
		end
	end
	-- Settings that no longer exist (notifications and whisper filtering, removed in 1.0)
	db.verbose = nil
	db.whispers = nil
	if type(db.words) ~= "table" then
		db.words = CopyDefaultWords()
	end
	for i, word in ipairs(db.words) do
		db.words[i] = NormalizeKeyword(word)
	end
end

local function IsFriend(name)
	for i = 1, GetNumFriends() do
		if name == GetFriendInfo(i) then
			return true
		end
	end
	return false
end

local function KnowsLanguage(language)
	for i = 1, GetNumLanguages() do
		if language == GetLanguageByIndex(i) then
			return true
		end
	end
	return false
end

-- True if the player already sent this text (ignoring case, spacing and symbols)
-- within the last db.repeatWindow seconds. The window starts from the copy that was shown.
local function IsRepeat(player, msg)
	if db.repeatWindow <= 0 then
		return false
	end
	local now = GetTime()
	if now - lastPrune > 60 then
		for key, shown in pairs(recentMessages) do
			if now - shown >= db.repeatWindow then
				recentMessages[key] = nil
			end
		end
		lastPrune = now
	end
	local key = player .. ":" .. CleanMessage(msg):gsub("[^" .. WORD_CHARS .. "]", "")
	local shown = recentMessages[key]
	if shown and now - shown < db.repeatWindow then
		return true
	end
	recentMessages[key] = now
	return false
end

local function AddLog(player, msg, reason)
	-- Skip duplicates so a spammer can't push everything else out of the log
	local message = format("|cffd3d3d3[%s]|r: %s", player, msg)
	if reason then
		message = message .. " |cffd3d3d3(" .. reason .. ")|r"
	end
	if not tContains(messageLog, message) then
		tinsert(messageLog, 1, message)
	end
	if #messageLog > LOG_SIZE then
		tremove(messageLog)
	end
end

local function ShouldHide(msg, player, language)
	if not db or not db.active then
		return false
	end
	if
		player == UnitName("player")
		or UnitIsInMyGuild(player)
		or IsFriend(player)
		or UnitInRaid(player)
		or UnitInParty(player)
	then
		return false
	end
	-- Block messages in languages we can't understand (e.g. Orcish for Alliance, Common for Horde)
	if db.blockForeign and language and language ~= "" and not KnowsLanguage(language) then
		AddLog(player, msg)
		return true
	end
	local text = CleanMessage(msg)
	for _, word in ipairs(db.words) do
		local pattern = patterns[word]
		if pattern and text:find(pattern) then
			AddLog(player, msg)
			return true
		end
	end
	if IsRepeat(player, msg) then
		AddLog(player, msg, "repeat")
		return true
	end
	return false
end

-- WoW calls the filter once per chat frame that shows the message. Decide once per
-- message (identified by its line ID) so a second chat tab doesn't look like a repeat.
local lastLineID, lastResult
local function OnChatMessage(self, event, msg, player, language, ...)
	local channel = ...
	local lineID = select(8, ...) or strjoin(":", event, channel or "", player, msg, tostring(GetTime()))
	if lineID == lastLineID then
		return lastResult
	end
	lastLineID = lineID
	lastResult = ShouldHide(msg, player, language)
	return lastResult
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", OnChatMessage)

-- Actions shared by the slash commands and the settings panel

addon.DEFAULT_WORDS = defaultWords
addon.messageLog = messageLog
addon.Highlight = Highlight
-- Redraws the settings panel after a slash command (replaced by Options.lua). Not called
-- for changes made in the panel: it redraws itself, and redrawing mid-drag breaks sliders.
addon.RefreshOptions = function() end

function addon.IsValidKeyword(word)
	return patterns[word] and true or false
end

-- Returns the keyword as it would be stored, or nil and the reason it can't be added
function addon.CheckKeyword(text)
	local word = NormalizeKeyword(text or "")
	if word == "" then
		return nil, "Type a keyword first"
	end
	if not patterns[word] then
		return nil,
			"Use * only at the start or end of a keyword, e.g. " .. Highlight("hell*") .. " or " .. Highlight("*gold*")
	end
	if FindWord(word) then
		return nil, '"' .. Highlight(word) .. '" is already a keyword'
	end
	return word
end

function addon.AddKeyword(text)
	local word, err = addon.CheckKeyword(text)
	if word then
		tinsert(db.words, word)
	end
	return word, err
end

-- Reads a list of keywords, one per line, skipping blank lines and duplicates.
-- Returns the list, or nil and a message naming the lines that aren't valid.
function addon.ParseKeywordList(text)
	local list, seen, bad = {}, {}, {}
	for line in (text or ""):gmatch("[^\r\n]+") do
		local word = NormalizeKeyword(line)
		if word ~= "" and not seen[word] then
			seen[word] = true
			if patterns[word] then
				tinsert(list, word)
			else
				tinsert(bad, Highlight(word))
			end
		end
	end
	if #bad > 0 then
		return nil, "Use * only at the start or end of a keyword. Fix these lines: " .. table.concat(bad, ", ")
	end
	return list
end

function addon.SetKeywords(list)
	db.words = list
end

function addon.RemoveKeyword(index)
	return tremove(db.words, index)
end

function addon.ResetKeywords()
	db.words = CopyDefaultWords()
end

function addon.SetRepeatWindow(seconds)
	db.repeatWindow = seconds
	wipe(recentMessages)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
	if name == "QuietChat" then
		InitDB()
		addon.db = db
		if addon.InitOptions then
			addon.InitOptions()
		end
		self:UnregisterEvent("ADDON_LOADED")
	end
end)

local function ShowStatus()
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
			local note = patterns[word] and "" or " |cffff0000(invalid, never matches)|r"
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
		local index = FindWord(NormalizeKeyword(arg))
		if not index then
			Print('"' .. Highlight(arg) .. '" is not a keyword. See /qc words')
			return
		end
		local removed = addon.RemoveKeyword(index)
		Print('Removed "' .. Highlight(removed) .. '"')
	elseif cmd == "default" then
		addon.ResetKeywords()
		Print("Keywords reset to the default list")
	else
		ShowStatus()
		ShowHelp()
	end
end

SLASH_QUIETCHAT1, SLASH_QUIETCHAT2 = "/qc", "/quietchat"
SlashCmdList["QUIETCHAT"] = function(input)
	RunCommand(input)
	-- Keep the settings panel in sync if it's open
	addon.RefreshOptions()
end
