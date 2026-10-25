-- German. Same strings as enUS.lua, which explains the format. Drafted without a native
-- speaker; corrections welcome.
local L = LibStub("AceLocale-3.0"):NewLocale("QuietChat", "deDE")
if not L then
	return
end

-- Keywords (QuietChat.lua)
L["Type a keyword first"] = "Gib zuerst ein Schlüsselwort ein"
L["Use * only at the start or end of a keyword, e.g. %s or %s"] =
	"Verwende * nur am Anfang oder Ende eines Schlüsselworts, z. B. %s oder %s"
L['"%s" is already a keyword'] = '"%s" ist bereits ein Schlüsselwort'
L["Use * only at the start or end of a keyword. Fix these lines: %s"] =
	"Verwende * nur am Anfang oder Ende eines Schlüsselworts. Korrigiere diese Zeilen: %s"

-- Slash commands (Commands.lua)
L["Filter is active"] = "Filter ist aktiv"
L["Filter is disabled"] = "Filter ist deaktiviert"
L["Foreign languages are blocked"] = "Fremdsprachen werden blockiert"
L["Foreign languages are shown"] = "Fremdsprachen werden angezeigt"
L["Repeated messages are hidden for %s seconds after the first one"] =
	"Wiederholte Nachrichten werden nach der ersten %s Sekunden lang ausgeblendet"
L["Repeated messages are shown"] = "Wiederholte Nachrichten werden angezeigt"
L["Keywords: %s (/qc words to list them)"] = "Schlüsselwörter: %s (/qc words zeigt sie an)"
L["word"] = "Wort"
L["seconds"] = "Sekunden"
L["Open the settings panel"] = "Öffnet die Einstellungen"
L["Turn the filter on or off"] = "Schaltet den Filter ein oder aus"
L["Block or show messages in languages you don't speak (e.g. Orcish)"] =
	"Blockiert oder zeigt Nachrichten in Sprachen, die du nicht sprichst (z. B. Orcisch)"
L["Show a player's message only once within this many seconds, across all channels (0 = off)"] =
	"Zeigt die Nachricht eines Spielers innerhalb so vieler Sekunden nur einmal, über alle Kanäle hinweg (0 = aus)"
L["List keywords (whole words, case-insensitive)"] =
	"Listet die Schlüsselwörter auf (ganze Wörter, Groß-/Kleinschreibung egal)"
L['Add a keyword or phrase. A * at the start or end also matches inside words: %s matches "hello"'] =
	'Fügt ein Schlüsselwort oder eine Phrase hinzu. Ein * am Anfang oder Ende findet es auch innerhalb von Wörtern: %s findet "hello"'
L["Remove a keyword or phrase"] = "Entfernt ein Schlüsselwort oder eine Phrase"
L["Reset keywords to the default list"] = "Setzt die Schlüsselwörter auf die Standardliste zurück"
L["Hidden messages are listed in the settings panel, under Blocked messages"] =
	"Ausgeblendete Nachrichten stehen in den Einstellungen unter Blockierte Nachrichten"
L["Settings are still loading, try again in a moment"] =
	"Die Einstellungen werden noch geladen, versuche es gleich noch einmal"
L["The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely"] =
	"Die Einstellungen sind nicht geladen. Wenn du QuietChat gerade aktualisiert hast, beende WoW und starte es neu"
L["Usage: %s"] = "Verwendung: %s"
L["0 turns it off"] = "0 schaltet es aus"
L["No keywords set. Add one with %s"] = "Keine Schlüsselwörter gesetzt. Füge eines mit %s hinzu"
L["Keywords:"] = "Schlüsselwörter:"
L["(invalid, never matches)"] = "(ungültig, trifft nie zu)"
L['Added "%s"'] = '"%s" hinzugefügt'
L['Removed "%s"'] = '"%s" entfernt'
L['"%s" is not a keyword. See %s'] = '"%s" ist kein Schlüsselwort. Siehe %s'
L["Keywords reset to the default list"] = "Schlüsselwörter auf die Standardliste zurückgesetzt"

-- Settings panel (Options.lua)
L["General"] = "Allgemein"
L["Hides chat spam in channels, /say and /yell. Messages from friends, guild, party and raid members aren't hidden unless you turn that on below, and your own never are."] =
	"Blendet Chat-Spam in Kanälen, /say und /yell aus. Nachrichten von Freunden, Gilde, Gruppe und Schlachtzug werden nicht ausgeblendet, außer du schaltest das unten ein, und deine eigenen nie."
L["Enable filter"] = "Filter aktivieren"
L["Turn all filtering on or off."] = "Schaltet das gesamte Filtern ein oder aus."
L["Block languages you don't speak"] = "Sprachen blockieren, die du nicht sprichst"
L["Hide messages in languages your character can't read, like Orcish for Alliance or Common for Horde."] =
	"Blendet Nachrichten in Sprachen aus, die dein Charakter nicht versteht, etwa Orcisch für die Allianz oder Gemeinsprache für die Horde."
L["Also filter friends, guild and group"] = "Auch Freunde, Gilde und Gruppe filtern"
L["Apply the filter to your friends, guild members, party and raid too. Your own messages are never hidden."] =
	"Wendet den Filter auch auf deine Freunde, Gildenmitglieder, Gruppe und Schlachtzug an. Deine eigenen Nachrichten werden nie ausgeblendet."
L["Repeated messages"] = "Wiederholte Nachrichten"
L["When a player sends the same message several times, for example to Trade, General and /yell at once, show only the first copy. Their next copy shows again once this many seconds have passed. Set to 0 to show every copy."] =
	"Wenn ein Spieler dieselbe Nachricht mehrmals sendet, zum Beispiel gleichzeitig in Handel, Allgemein und /yell, wird nur die erste Kopie angezeigt. Seine nächste Kopie erscheint erst wieder, wenn so viele Sekunden vergangen sind. Bei 0 wird jede Kopie angezeigt."
L["Show once every (seconds)"] = "Einmal anzeigen alle (Sekunden)"
L["Keywords"] = "Schlüsselwörter"
L['Messages containing any of these keywords are hidden. Capitalization doesn\'t matter, and keywords only match whole words: %s hides "what the hell" but not "hello".'] =
	'Nachrichten mit einem dieser Schlüsselwörter werden ausgeblendet. Groß- und Kleinschreibung spielt keine Rolle, und Schlüsselwörter treffen nur ganze Wörter: %s blendet "what the hell" aus, aber nicht "hello".'
L['Put a * at the start or end to also match inside longer words: %s also hides "hello", and %s hides anything containing "gold".'] =
	'Setze ein * an den Anfang oder das Ende, um auch innerhalb längerer Wörter zu suchen: %s blendet auch "hello" aus, und %s alles, was "gold" enthält.'
L["Keywords (%s), one per line. Click Accept to save"] =
	"Schlüsselwörter (%s), eines pro Zeile. Zum Speichern auf Annehmen klicken"
L["Add, edit or delete lines, then click Accept. Blank lines and duplicates are ignored."] =
	"Zeilen hinzufügen, ändern oder löschen, dann auf Annehmen klicken. Leere und doppelte Zeilen werden ignoriert."
L["These keywords never match because of a misplaced *:"] =
	"Diese Schlüsselwörter treffen nie zu, weil ein * falsch steht:"
L["Reset to defaults"] = "Standard wiederherstellen"
L["Replace your keywords with the default list."] = "Ersetzt deine Schlüsselwörter durch die Standardliste."
L["Replace your keywords with the default list (%s)?"] =
	"Deine Schlüsselwörter durch die Standardliste (%s) ersetzen?"
L["Blocked messages"] = "Blockierte Nachrichten"
L["The last %s messages hidden this session, newest first. The list is cleared when you log out or reload."] =
	"Die letzten %s in dieser Sitzung ausgeblendeten Nachrichten, die neueste zuerst. Die Liste wird beim Ausloggen oder Neuladen geleert."
L["Refresh"] = "Aktualisieren"
L["Show messages hidden since the panel was opened."] =
	"Zeigt Nachrichten, die seit dem Öffnen der Einstellungen ausgeblendet wurden."
L["Nothing has been hidden yet."] = "Bisher wurde nichts ausgeblendet."
L['keyword "%s"'] = 'Schlüsselwort "%s"'
L["repeat"] = "Wiederholung"
