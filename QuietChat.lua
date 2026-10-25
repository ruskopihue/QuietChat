-- QuietChat: hides chat spam by keyword, language and repeated messages.
-- Based on the idea of ChatFilter by Xcom (hellohamburger on the Warmane forum), a small keyword
-- filter for WoW 3.3.5a.

-- Shared with Commands.lua (slash commands) and Options.lua (settings panel)
local addon = {}
QuietChat = addon

local LOG_SIZE = 20
local defaultWords = { "wts", "wtb", "recruiting", "lfw" }
local defaults = { active = true, blockForeign = false, filterExempt = false, repeatWindow = 15 }

local db
local messageLog = {}
local recentMessages = {} -- [player:text] = time the message was last shown
local lastPrune = 0

local function Highlight(text)
	return "|cff00ffff" .. text .. "|r"
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

-- Settings are saved in QuietChatDB. The file may come from an older version or be edited by
-- hand, so it's checked here once and the rest of the addon can trust it.
local function InitDB()
	if type(QuietChatDB) ~= "table" then
		QuietChatDB = {}
	end
	db = QuietChatDB

	-- Anything missing or of the wrong type (e.g. repeatWindow = "30") gets its default
	for key, value in pairs(defaults) do
		if type(db[key]) ~= type(value) then
			db[key] = value
		end
	end
	-- Settings that no longer exist (notifications and whisper filtering, removed in 1.0)
	db.verbose = nil
	db.whispers = nil
	if type(db.words) ~= "table" then
		db.words = CopyDefaultWords()
	end
	local words = {}
	for _, word in ipairs(db.words) do
		word = type(word) == "string" and NormalizeKeyword(word) or ""
		if word ~= "" then
			tinsert(words, word)
		end
	end
	db.words = words
end

local function IsFriend(name)
	for i = 1, GetNumFriends() do
		if name == GetFriendInfo(i) then
			return true
		end
	end
	return false
end

-- Messages from these players are never hidden: you, and your friends, guild, party and raid
-- unless db.filterExempt is on
local function IsExempt(player)
	if player == UnitName("player") then
		return true
	end
	return not db.filterExempt
		and (UnitIsInMyGuild(player) or IsFriend(player) or UnitInRaid(player) or UnitInParty(player))
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
	local text = CleanMessage(msg):gsub("[^" .. WORD_CHARS .. "]", "")
	-- Only symbols, like ":)" or "?": nothing to compare, or they'd all count as the same message
	if text == "" then
		return false
	end
	local key = player .. ":" .. text
	local shown = recentMessages[key]
	if shown and now - shown < db.repeatWindow then
		return true
	end
	recentMessages[key] = now
	return false
end

-- Keeps a hidden message for the Blocked messages page, newest first, as
-- { player, text, reason, detail } (reason and detail as HideReason returns them)
local function AddLog(player, msg, reason, detail)
	-- Skip duplicates so a spammer can't push everything else out of the log
	for _, entry in ipairs(messageLog) do
		if entry.player == player and entry.text == msg then
			return
		end
	end
	tinsert(messageLog, 1, { player = player, text = msg, reason = reason, detail = detail })
	if #messageLog > LOG_SIZE then
		tremove(messageLog)
	end
end

-- Why a message should be hidden, or nil to show it: "language" (detail: the language),
-- "keyword" (detail: the keyword that matched) or "repeat"
local function HideReason(msg, player, language)
	if not db or not db.active or IsExempt(player) then
		return nil
	end
	-- Languages we can't understand (e.g. Orcish for Alliance, Common for Horde)
	if db.blockForeign and language and language ~= "" and not KnowsLanguage(language) then
		return "language", language
	end
	local text = CleanMessage(msg)
	for _, word in ipairs(db.words) do
		local pattern = patterns[word]
		if pattern and text:find(pattern) then
			return "keyword", word
		end
	end
	if IsRepeat(player, msg) then
		return "repeat"
	end
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
	local reason, detail = HideReason(msg, player, language)
	if reason then
		AddLog(player, msg, reason, detail)
	end
	lastResult = reason ~= nil
	return lastResult
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", OnChatMessage)

-- Actions shared by the slash commands and the settings panel

addon.DEFAULT_WORDS = defaultWords
addon.messageLog = messageLog -- hidden messages, see AddLog
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

-- Removes a keyword, typed the way it was added. Returns the removed keyword, or nil if there's none
function addon.RemoveKeyword(text)
	local index = FindWord(NormalizeKeyword(text or ""))
	return index and tremove(db.words, index)
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
