-- Spanish, for both Spanish clients: esES (Spain) and esMX (Latin America). Same strings as
-- enUS.lua, which explains the format. Drafted without a native speaker; corrections welcome.
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("QuietChat", "esES") or AceLocale:NewLocale("QuietChat", "esMX")
if not L then
	return
end

-- Keywords (QuietChat.lua)
L["Type a keyword first"] = "Escribe primero una palabra clave"
L["Use * only at the start or end of a keyword, e.g. %s or %s"] =
	"Usa * solo al principio o al final de una palabra clave, p. ej. %s o %s"
L['"%s" is already a keyword'] = '"%s" ya es una palabra clave'
L["Use * only at the start or end of a keyword. Fix these lines: %s"] =
	"Usa * solo al principio o al final de una palabra clave. Corrige estas líneas: %s"

-- Slash commands (Commands.lua)
L["Filter is active"] = "El filtro está activado"
L["Filter is disabled"] = "El filtro está desactivado"
L["The other faction's speech is hidden"] = "Se oculta lo que dice la otra facción"
L["The other faction's speech is shown"] = "Se muestra lo que dice la otra facción"
L["Repeated messages are hidden for %s seconds after the first one"] =
	"Los mensajes repetidos se ocultan durante %s segundos después del primero"
L["Repeated messages are shown"] = "Los mensajes repetidos se muestran"
L["Keywords: %s (/qc words to list them)"] = "Palabras clave: %s (/qc words para verlas)"
L["word"] = "palabra"
L["seconds"] = "segundos"
L["Open the settings panel"] = "Abre el panel de opciones"
L["Turn the filter on or off"] = "Activa o desactiva el filtro"
L["Hide or show the other faction's speech"] = "Oculta o muestra lo que dice la otra facción"
L["Show a player's message only once within this many seconds, across all channels (0 = off)"] =
	"Muestra el mensaje de un jugador solo una vez en este número de segundos, en todos los canales (0 = desactivado)"
L["List keywords (whole words, case-insensitive)"] =
	"Lista las palabras clave (palabras completas, sin distinguir mayúsculas)"
L['Add a keyword or phrase. A * at the start or end also matches inside words: %s matches "hello"'] =
	'Añade una palabra clave o frase. Un * al principio o al final también busca dentro de palabras: %s encuentra "hello"'
L["Remove a keyword or phrase"] = "Quita una palabra clave o frase"
L["Reset keywords to the default list"] = "Restablece las palabras clave a la lista predeterminada"
L["Hidden messages are listed in the settings panel, under Blocked messages"] =
	"Los mensajes ocultos aparecen en el panel de opciones, en Mensajes bloqueados"
L["Settings are still loading, try again in a moment"] =
	"Las opciones aún se están cargando, inténtalo de nuevo en un momento"
L["The settings panel isn't loaded. If you just updated QuietChat, exit and restart WoW completely"] =
	"El panel de opciones no está cargado. Si acabas de actualizar QuietChat, cierra WoW y vuelve a abrirlo"
L["Usage: %s"] = "Uso: %s"
L["0 turns it off"] = "0 lo desactiva"
L["No keywords set. Add one with %s"] = "No hay palabras clave. Añade una con %s"
L["Keywords:"] = "Palabras clave:"
L["(invalid, never matches)"] = "(no válida, nunca coincide)"
L['Added "%s"'] = 'Se ha añadido "%s"'
L['Removed "%s"'] = 'Se ha quitado "%s"'
L['"%s" is not a keyword. See %s'] = '"%s" no es una palabra clave. Consulta %s'
L["Keywords reset to the default list"] = "Palabras clave restablecidas a la lista predeterminada"

-- Settings panel (Options.lua)
L["General"] = "General"
L["Hides chat spam in channels, /say and /yell. Messages from friends, guild, party and raid members aren't hidden unless you turn that on below, and your own never are."] =
	"Oculta el spam del chat en los canales, /say y /yell. Los mensajes de amigos, hermandad, grupo y banda no se ocultan salvo que lo actives abajo, y los tuyos nunca."
L["Enable filter"] = "Activar filtro"
L["Turn all filtering on or off."] = "Activa o desactiva todo el filtrado."
L["Hide the other faction's speech"] = "Ocultar lo que dice la otra facción"
L["Hides /say and /yell in languages your character can't read: Orcish for Alliance, Common for Horde, and your own faction's racial languages you don't know."] =
	"Oculta /say y /yell en idiomas que tu personaje no entiende: orco para la Alianza, común para la Horda, y los idiomas raciales de tu propia facción que no conoces."
L["Also filter friends, guild and group"] = "Filtrar también a amigos, hermandad y grupo"
L["Apply the filter to your friends, guild members, party and raid too. Your own messages are never hidden."] =
	"Aplica el filtro también a tus amigos, a los miembros de tu hermandad, a tu grupo y a tu banda. Tus propios mensajes nunca se ocultan."
L["Repeated messages"] = "Mensajes repetidos"
L["When a player sends the same message several times, for example to Trade, General and /yell at once, show only the first copy. Their next copy shows again once this many seconds have passed. Set to 0 to show every copy."] =
	"Cuando un jugador envía el mismo mensaje varias veces, por ejemplo a Comercio, General y /yell a la vez, solo se muestra la primera copia. Su siguiente copia vuelve a mostrarse cuando hayan pasado estos segundos. Pon 0 para mostrar todas las copias."
L["Show once every (seconds)"] = "Mostrar una vez cada (segundos)"
L["Keywords"] = "Palabras clave"
L['Messages containing any of these keywords are hidden. Capitalization doesn\'t matter, and keywords only match whole words: %s hides "what the hell" but not "hello".'] =
	'Se ocultan los mensajes que contienen alguna de estas palabras clave. No importan las mayúsculas, y solo coinciden palabras completas: %s oculta "what the hell" pero no "hello".'
L['Put a * at the start or end to also match inside longer words: %s also hides "hello", and %s hides anything containing "gold".'] =
	'Pon un * al principio o al final para buscar también dentro de palabras más largas: %s también oculta "hello", y %s oculta todo lo que contenga "gold".'
L["Keywords (%s), one per line. Click Accept to save"] =
	"Palabras clave (%s), una por línea. Pulsa Aceptar para guardar"
L["Add, edit or delete lines, then click Accept. Blank lines and duplicates are ignored."] =
	"Añade, edita o borra líneas y pulsa Aceptar. Las líneas vacías y repetidas se ignoran."
L["These keywords never match because of a misplaced *:"] =
	"Estas palabras clave nunca coinciden por un * mal colocado:"
L["Reset to defaults"] = "Restablecer"
L["Replace your keywords with the default list."] = "Sustituye tus palabras clave por la lista predeterminada."
L["Replace your keywords with the default list (%s)?"] =
	"¿Sustituir tus palabras clave por la lista predeterminada (%s)?"
L["Blocked messages"] = "Mensajes bloqueados"
L["The last %s messages hidden this session, newest first. The list is cleared when you log out or reload."] =
	"Los últimos %s mensajes ocultados en esta sesión, del más reciente al más antiguo. La lista se vacía al cerrar sesión o recargar."
L["Refresh"] = "Actualizar"
L["Show messages hidden since the panel was opened."] = "Muestra los mensajes ocultados desde que se abrió el panel."
L["Nothing has been hidden yet."] = "Todavía no se ha ocultado nada."
L['keyword "%s"'] = 'palabra clave "%s"'
L["repeat"] = "repetido"
