"""Runs QuietChat in a real Lua 5.1 interpreter with the parts of the WoW API it uses stubbed out.

This covers the addon's logic, not how anything looks in game.
"""

import os

from lupa import lua51

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def addon_files():
    """The addon's own Lua files, in the order QuietChat.toc loads them (libraries excluded)."""
    with open(os.path.join(ROOT, "QuietChat.toc"), encoding="utf-8") as f:
        lines = [line.strip() for line in f]
    return [line for line in lines if line.endswith(".lua") and not line.startswith("libs")]


ACE_LIBS = [
    "libs/LibStub/LibStub.lua",
    "libs/CallbackHandler-1.0/CallbackHandler-1.0.lua",
    "libs/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua",
]

WOW_API = r"""
strmatch = string.match; strsub = string.sub; strfind = string.find; gsub = string.gsub; tconcat = table.concat
strlower = string.lower; format = string.format; tinsert = table.insert; tremove = table.remove; min = math.min
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function strjoin(sep, ...) return table.concat({...}, sep) end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
-- Only the two-part split the addon uses: strsplit(" ", text, 2)
function strsplit(sep, s, n) local a, b = s:match("^(%S*)%s*(.*)$"); if b == "" then b = nil end; return a, b end
function tContains(t, v) for _, x in ipairs(t) do if x == v then return true end end return false end
function geterrorhandler() return function(e) error(e, 2) end end

NOW = 0
PLAYER = "Me"
FRIENDS = {}
LANGUAGES = { "Common" }
function GetTime() return NOW end
function UnitName() return PLAYER end
function GetNumFriends() return #FRIENDS end
function GetFriendInfo(i) return FRIENDS[i] end
function UnitIsInMyGuild() return false end
function UnitInRaid() return nil end
function UnitInParty() return nil end
function GetNumLanguages() return #LANGUAGES end
function GetLanguageByIndex(i) return LANGUAGES[i] end

OUTPUT = {}
function print(...)
  local parts = {}
  for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
  OUTPUT[#OUTPUT + 1] = table.concat(parts, " ")
end

FILTERS = {}
function ChatFrame_AddMessageEventFilter(event, filter) FILTERS[event] = filter end
SlashCmdList = {}
FRAMES = {}
function CreateFrame()
  local f = {}
  function f:RegisterEvent() end
  function f:UnregisterEvent() end
  function f:SetScript(_, fn) f.onEvent = fn end
  FRAMES[#FRAMES + 1] = f
  return f
end
OPENED = 0
function InterfaceOptionsFrame_OpenToCategory() OPENED = OPENED + 1 end

-- Delivers a chat message the way WoW does: the filter runs once for each chat frame
-- showing it, with the same arguments, and every frame must reach the same decision.
function Deliver(event, msg, player, language, channel, frames, lineID)
  local hidden
  for _ = 1, frames do
    local result = FILTERS[event](nil, event, msg, player, language, channel, "", "", 0, 0, "", 0, lineID) and true or false
    if hidden == nil then
      hidden = result
    elseif result ~= hidden then
      error("chat frames disagreed about the same message")
    end
  end
  return hidden
end
"""

# Stands in for AceConfigDialog, which needs real WoW frames. It records the panels the
# addon registers and counts redraw requests.
FAKE_DIALOG = r"""
local dialog = LibStub:NewLibrary("AceConfigDialog-3.0", 999999)
PANELS = {}
function dialog:AddToBlizOptions(app, name, parent, path)
  local panel = { name = name, parent = parent, path = path }
  PANELS[#PANELS + 1] = panel
  return panel
end
REDRAWS = 0
LibStub("AceConfigRegistry-3.0").RegisterCallback(dialog, "ConfigTableChange", function() REDRAWS = REDRAWS + 1 end)
"""


class Addon:
    """A freshly loaded copy of QuietChat with default settings."""

    def __init__(self, with_options=False):
        self.lua = lua51.LuaRuntime()
        self.lua.execute(WOW_API)
        if with_options:
            for path in ACE_LIBS:
                self._run(path)
            self.lua.execute(FAKE_DIALOG)
        for path in addon_files():
            # Options.lua needs the Ace3 libraries, which only load with_options
            if path != "Options.lua" or with_options:
                self._run(path)
        self.lua.execute('for _, f in ipairs(FRAMES) do f.onEvent(f, "ADDON_LOADED", "QuietChat") end')
        self.g = self.lua.globals()
        self.addon = self.g.QuietChat
        self._line_id = 0

    def _run(self, path):
        with open(os.path.join(ROOT, path), encoding="utf-8") as f:
            self.lua.execute(f.read())

    @property
    def db(self):
        return self.addon.db

    @property
    def keywords(self):
        return [self.db.words[i] for i in range(1, len(self.db.words) + 1)]

    def command(self, text):
        """Runs a slash command (without the /qc) and returns what it printed."""
        self.lua.execute("OUTPUT = {}")
        self.g.SlashCmdList.QUIETCHAT(text)
        return self.lua.eval('table.concat(OUTPUT, "\\n")')

    def is_hidden(
        self, msg, player="Spammer", event="CHAT_MSG_SAY", channel="", language="", at=None, frames=2, line_id=True
    ):
        """Sends a chat message and returns whether QuietChat hid it."""
        if at is not None:
            self.g["NOW"] = at
        self._line_id += 1
        return bool(self.g.Deliver(event, msg, player, language, channel, frames, self._line_id if line_id else None))

    def options(self):
        """Returns the settings panel's options table, validated by the real AceConfigRegistry."""
        self.lua.execute('LibStub("AceConfigRegistry-3.0").validated.dialog.QuietChat = nil')
        return self.lua.eval('LibStub("AceConfigRegistry-3.0"):GetOptionsTable("QuietChat", "dialog", "Tests-1.0")')

    def lua_list(self, values):
        return self.lua.table_from(values)
