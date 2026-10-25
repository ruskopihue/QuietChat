-- Settings panel under Interface > AddOns > QuietChat.
-- The panel is described as a table of options; Ace3's AceConfigDialog turns it into
-- checkboxes, sliders and buttons. Each option reads and writes QuietChat.db.

local addon = QuietChat
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local Highlight = addon.Highlight
local APP = "QuietChat"
local mainPanel

local function Inactive()
	return not addon.db.active
end

local function GeneralOptions()
	return {
		type = "group",
		name = "General",
		order = 1,
		-- Options in this group store their value in db under their own key (e.g. db.blockForeign)
		get = function(info)
			return addon.db[info[#info]]
		end,
		set = function(info, value)
			addon.db[info[#info]] = value
		end,
		args = {
			intro = {
				type = "description",
				order = 1,
				fontSize = "medium",
				name = "Hides chat spam in channels, /say and /yell. Messages from friends, guild, party and raid members aren't hidden unless you turn that on below, and your own never are.\n",
			},
			active = {
				type = "toggle",
				order = 2,
				width = "full",
				name = "Enable filter",
				desc = "Turn all filtering on or off.",
			},
			blockForeign = {
				type = "toggle",
				order = 3,
				width = "full",
				name = "Block languages you don't speak",
				desc = "Hide messages in languages your character can't read, like Orcish for Alliance or Common for Horde.",
				disabled = Inactive,
			},
			filterExempt = {
				type = "toggle",
				order = 4,
				width = "full",
				name = "Also filter friends, guild and group",
				desc = "Apply the filter to your friends, guild members, party and raid too. Your own messages are never hidden.",
				disabled = Inactive,
			},
			repeatHeader = {
				type = "header",
				order = 10,
				name = "Repeated messages",
			},
			repeatHelp = {
				type = "description",
				order = 11,
				name = "When a player sends the same message several times, for example to Trade, General and /yell at once, show only the first copy. Their next copy shows again once this many seconds have passed. Set to 0 to show every copy.\n",
			},
			repeatWindow = {
				type = "range",
				order = 12,
				width = "double",
				name = "Show once every (seconds)",
				min = 0,
				max = 3600,
				softMax = 120,
				step = 1,
				bigStep = 5,
				set = function(info, value)
					addon.SetRepeatWindow(value)
				end,
				disabled = Inactive,
			},
		},
	}
end

local function KeywordOptions()
	local words = addon.db.words
	local args = {
		intro = {
			type = "description",
			order = 1,
			fontSize = "medium",
			name = "Messages containing any of these keywords are hidden. Capitalization doesn't matter, and keywords only match whole words: "
				.. Highlight("hell")
				.. ' hides "what the hell" but not "hello".\n\n'
				.. "Put a * at the start or end to also match inside longer words: "
				.. Highlight("hell*")
				.. ' also hides "hello", and '
				.. Highlight("*gold*")
				.. ' hides anything containing "gold".\n',
		},
		words = {
			type = "input",
			order = 2,
			width = "full",
			multiline = 14,
			name = "Keywords (" .. #words .. "), one per line. Click Accept to save",
			desc = "Add, edit or delete lines, then click Accept. Blank lines and duplicates are ignored.",
			get = function()
				return table.concat(addon.db.words, "\n")
			end,
			validate = function(info, value)
				local _, err = addon.ParseKeywordList(value)
				return err or true
			end,
			set = function(info, value)
				addon.SetKeywords(addon.ParseKeywordList(value))
			end,
		},
		reset = {
			type = "execute",
			order = 4,
			name = "Reset to defaults",
			desc = "Replace your keywords with the default list.",
			confirm = true,
			confirmText = "Replace your keywords with the default list ("
				.. table.concat(addon.DEFAULT_WORDS, ", ")
				.. ")?",
			func = function()
				addon.ResetKeywords()
			end,
		},
	}
	-- The saved list can only hold invalid keywords if it was edited by hand; point them out
	local invalid = {}
	for _, word in ipairs(words) do
		if not addon.IsValidKeyword(word) then
			tinsert(invalid, Highlight(word))
		end
	end
	if #invalid > 0 then
		args.invalid = {
			type = "description",
			order = 3,
			name = "|cffff2020These keywords never match because of a misplaced *:|r "
				.. table.concat(invalid, ", ")
				.. "\n",
		}
	end
	return {
		type = "group",
		name = "Keywords",
		order = 2,
		args = args,
	}
end

-- One line of the Blocked messages page: who, what, and why it was hidden
local function FormatLogEntry(entry)
	local why = entry.reason
	if entry.reason == "keyword" then
		why = 'keyword "' .. entry.detail .. '"'
	elseif entry.reason == "language" then
		why = entry.detail
	end
	return format("|cffd3d3d3[%s]|r: %s |cffd3d3d3(%s)|r", entry.player, entry.text, why)
end

local function LogOptions()
	return {
		type = "group",
		name = "Blocked messages",
		order = 3,
		args = {
			intro = {
				type = "description",
				order = 1,
				name = "The last "
					.. #addon.messageLog
					.. " messages hidden this session, newest first. The list is cleared when you log out or reload.\n",
			},
			refresh = {
				type = "execute",
				order = 2,
				name = "Refresh",
				desc = "Show messages hidden since the panel was opened.",
				-- The panel redraws itself after any button click, which is all this needs
				func = function() end,
			},
			messages = {
				type = "description",
				order = 3,
				fontSize = "medium",
				name = function()
					if #addon.messageLog == 0 then
						return "\nNothing has been hidden yet."
					end
					local lines = {}
					for i, entry in ipairs(addon.messageLog) do
						lines[i] = FormatLogEntry(entry)
					end
					return "\n" .. table.concat(lines, "\n\n")
				end,
			},
		},
	}
end

-- Built again each time the panel is drawn, so the keyword list and log stay current
local function GetOptions()
	return {
		type = "group",
		name = "QuietChat",
		args = {
			general = GeneralOptions(),
			keywords = KeywordOptions(),
			log = LogOptions(),
		},
	}
end

function addon.InitOptions()
	AceConfigRegistry:RegisterOptionsTable(APP, GetOptions)
	mainPanel = AceConfigDialog:AddToBlizOptions(APP, "QuietChat", nil, "general")
	AceConfigDialog:AddToBlizOptions(APP, "Keywords", "QuietChat", "keywords")
	AceConfigDialog:AddToBlizOptions(APP, "Blocked messages", "QuietChat", "log")
	-- Replaces the do-nothing version in QuietChat.lua now that the panel exists
	---@diagnostic disable-next-line: duplicate-set-field
	addon.RefreshOptions = function()
		AceConfigRegistry:NotifyChange(APP)
	end
end

function addon.OpenOptions()
	-- Called twice on purpose: the first call on 3.3.5 often opens the panel without selecting it
	InterfaceOptionsFrame_OpenToCategory(mainPanel)
	InterfaceOptionsFrame_OpenToCategory(mainPanel)
end
