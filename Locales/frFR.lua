-- French. Same strings as enUS.lua, which explains the format. Drafted without a native
-- speaker; corrections welcome.
local L = LibStub("AceLocale-3.0"):NewLocale("QuietChat", "frFR")
if not L then
	return
end

-- Keywords (QuietChat.lua)
L["Type a keyword first"] = "Saisissez d'abord un mot-clé"
L["Use * only at the start or end of a keyword, e.g. %s or %s"] =
	"Utilisez * seulement au début ou à la fin d'un mot-clé, par ex. %s ou %s"
L['"%s" is already a keyword'] = '"%s" est déjà un mot-clé'
L["Use * only at the start or end of a keyword. Fix these lines: %s"] =
	"Utilisez * seulement au début ou à la fin d'un mot-clé. Corrigez ces lignes : %s"

-- Slash commands (Commands.lua)
L["Filter is active"] = "Le filtre est activé"
L["Filter is disabled"] = "Le filtre est désactivé"
L["Foreign languages are blocked"] = "Les langues étrangères sont bloquées"
L["Foreign languages are shown"] = "Les langues étrangères sont affichées"
L["Repeated messages are hidden for %s seconds after the first one"] =
	"Les messages répétés sont masqués pendant %s secondes après le premier"
L["Repeated messages are shown"] = "Les messages répétés sont affichés"
L["Keywords: %s (/qc words to list them)"] = "Mots-clés : %s (/qc words pour les lister)"
L["word"] = "mot"
L["seconds"] = "secondes"
L["Open the settings panel"] = "Ouvre le panneau des options"
L["Turn the filter on or off"] = "Active ou désactive le filtre"
L["Block or show messages in languages you don't speak (e.g. Orcish)"] =
	"Bloque ou affiche les messages dans les langues que vous ne parlez pas (par ex. l'orc)"
L["Show a player's message only once within this many seconds, across all channels (0 = off)"] =
	"N'affiche le message d'un joueur qu'une fois sur ce nombre de secondes, sur tous les canaux (0 = désactivé)"
L["List keywords (whole words, case-insensitive)"] =
	"Liste les mots-clés (mots entiers, sans tenir compte de la casse)"
L['Add a keyword or phrase. A * at the start or end also matches inside words: %s matches "hello"'] =
	'Ajoute un mot-clé ou une expression. Un * au début ou à la fin le trouve aussi à l\'intérieur des mots : %s trouve "hello"'
L["Remove a keyword or phrase"] = "Retire un mot-clé ou une expression"
L["Reset keywords to the default list"] = "Rétablit la liste de mots-clés par défaut"
L["Hidden messages are listed in the settings panel, under Blocked messages"] =
	"Les messages masqués sont listés dans le panneau des options, sous Messages bloqués"
L["Settings are still loading, try again in a moment"] =
	"Les options sont encore en cours de chargement, réessayez dans un instant"
L["The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely"] =
	"Le panneau des options n'est pas chargé. Si vous venez de mettre à jour QuietChat, quittez et relancez complètement WoW"
L["Usage: %s"] = "Utilisation : %s"
L["0 turns it off"] = "0 le désactive"
L["No keywords set. Add one with %s"] = "Aucun mot-clé. Ajoutez-en un avec %s"
L["Keywords:"] = "Mots-clés :"
L["(invalid, never matches)"] = "(invalide, ne correspond jamais)"
L['Added "%s"'] = '"%s" ajouté'
L['Removed "%s"'] = '"%s" retiré'
L['"%s" is not a keyword. See %s'] = '"%s" n\'est pas un mot-clé. Voir %s'
L["Keywords reset to the default list"] = "Mots-clés rétablis à la liste par défaut"

-- Settings panel (Options.lua)
L["General"] = "Général"
L["Hides chat spam in channels, /say and /yell. Messages from friends, guild, party and raid members aren't hidden unless you turn that on below, and your own never are."] =
	"Masque le spam du chat dans les canaux, /say et /yell. Les messages de vos amis, de votre guilde, de votre groupe et de votre raid ne sont pas masqués sauf si vous l'activez ci-dessous, et les vôtres jamais."
L["Enable filter"] = "Activer le filtre"
L["Turn all filtering on or off."] = "Active ou désactive tout le filtrage."
L["Block languages you don't speak"] = "Bloquer les langues que vous ne parlez pas"
L["Hide messages in languages your character can't read, like Orcish for Alliance or Common for Horde."] =
	"Masque les messages dans les langues que votre personnage ne comprend pas, comme l'orc pour l'Alliance ou le commun pour la Horde."
L["Also filter friends, guild and group"] = "Filtrer aussi amis, guilde et groupe"
L["Apply the filter to your friends, guild members, party and raid too. Your own messages are never hidden."] =
	"Applique aussi le filtre à vos amis, aux membres de votre guilde, à votre groupe et à votre raid. Vos propres messages ne sont jamais masqués."
L["Repeated messages"] = "Messages répétés"
L["When a player sends the same message several times, for example to Trade, General and /yell at once, show only the first copy. Their next copy shows again once this many seconds have passed. Set to 0 to show every copy."] =
	"Quand un joueur envoie le même message plusieurs fois, par exemple dans Commerce, Général et /yell en même temps, seule la première copie est affichée. Sa copie suivante s'affiche à nouveau une fois ce nombre de secondes écoulé. Mettez 0 pour afficher toutes les copies."
L["Show once every (seconds)"] = "Afficher une fois toutes les (secondes)"
L["Keywords"] = "Mots-clés"
L['Messages containing any of these keywords are hidden. Capitalization doesn\'t matter, and keywords only match whole words: %s hides "what the hell" but not "hello".'] =
	"Les messages contenant l'un de ces mots-clés sont masqués. La casse n'a pas d'importance, et les mots-clés ne correspondent qu'à des mots entiers : %s masque \"what the hell\" mais pas \"hello\"."
L['Put a * at the start or end to also match inside longer words: %s also hides "hello", and %s hides anything containing "gold".'] =
	'Ajoutez un * au début ou à la fin pour chercher aussi à l\'intérieur de mots plus longs : %s masque aussi "hello", et %s masque tout ce qui contient "gold".'
L["Keywords (%s), one per line. Click Accept to save"] =
	"Mots-clés (%s), un par ligne. Cliquez sur Accepter pour enregistrer"
L["Add, edit or delete lines, then click Accept. Blank lines and duplicates are ignored."] =
	"Ajoutez, modifiez ou supprimez des lignes, puis cliquez sur Accepter. Les lignes vides et les doublons sont ignorés."
L["These keywords never match because of a misplaced *:"] =
	"Ces mots-clés ne correspondent jamais à cause d'un * mal placé :"
L["Reset to defaults"] = "Rétablir les défauts"
L["Replace your keywords with the default list."] = "Remplace vos mots-clés par la liste par défaut."
L["Replace your keywords with the default list (%s)?"] = "Remplacer vos mots-clés par la liste par défaut (%s) ?"
L["Blocked messages"] = "Messages bloqués"
L["The last %s messages hidden this session, newest first. The list is cleared when you log out or reload."] =
	"Les %s derniers messages masqués pendant cette session, du plus récent au plus ancien. La liste est vidée à la déconnexion ou au rechargement."
L["Refresh"] = "Actualiser"
L["Show messages hidden since the panel was opened."] = "Affiche les messages masqués depuis l'ouverture du panneau."
L["Nothing has been hidden yet."] = "Rien n'a encore été masqué."
L['keyword "%s"'] = 'mot-clé "%s"'
L["repeat"] = "répétition"
