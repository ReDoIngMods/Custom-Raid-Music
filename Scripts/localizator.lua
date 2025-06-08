---@diagnostic disable: lowercase-global

local text = {
    English = {
        interaction = "Configure Raid Music",
        interaction_deny = "! CUSTOM AUDIO DLL MOD NOT INSTALLED !",
		interaction_deny_desc = "The mod will still work, however only vanilla music will be played!\n#ffffff(which is \"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\")",
        full_title = "RAID MUSIC CONFIGURATOR",
        volume_title = "VOLUME",
        select_title = "SONG SELECT",
        volume_warning = "Warning! If you have the\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusic selected, it will ONLY be affected by the volume slider in the settings!",
		choose_songs_title = "CHOOSE SONGS",
		loaded_packs_title = "LOADED PACKS",
		tracks_title = "TRACKS",
		featured_tracks = "Features tracks from:",
		featured_tracks_more = "And more...",
		songs_created_by = "By:",
		unknown_composer = "Unknown",
        from = "From:"
    },
    German = {
        interaction = "Konfiguriere Kampf Musik",
        interaction_deny = "! CUSTOM AUDIO DLL MOD NICHT INSTALLIERT !",
        full_title = "KAMPF MUSIK EINSTELLUNGEN",
        volume_title = "LAUTSTÄRKE",
        select_title = "MUSIK SELEKTION",
        volume_warning = "Warnung! Wen du die\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusik ausgewählt hast, wird es nur vom Lautstärkeregler in den Einstellungen betroffen",
		choose_songs_title = "LIEDER AUSWÄHLEN",
        loaded_packs_title = "GELADENE PAKETE",
        tracks_title = "TITEL",
        featured_tracks = "Enthält titel von:",
        featured_tracks_more = "Und mehr...",
        songs_created_by = "Von:",
        unknown_composer = "Unbekannt",
        from = "Von:"
    },
    Italian = {
        interaction = "Configura Musica Assalto",
        interaction_deny = "! MOD CUSTOM AUDIO DLL NON INSTALLATA !",
        full_title = "CONFIGURATORE MUSICA ASSALTO",
        volume_title = "VOLUME",
        select_title = "SELEZIONA MUSICA",
        volume_warning = "Attenzione! Se hai la canzone\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nselezionata, sarà SOLTANTO influenzata dal volume nelle impostazioni!",
		choose_songs_title = "SCEGLI CANZONI",
		loaded_packs_title = "PACCHETTI CARICATI",
		tracks_title = "TRACCE",
		featured_tracks = "Contiene tracce da:",
		featured_tracks_more = "E altro...",
		songs_created_by = "Di:",
		unknown_composer = "Sconosciuto",
        from = "Dal:"
    },
    Polish = {
        interaction = "Zkonfiguruj Muzyke Najazdu",
        interaction_deny = "! NIE ZAINSTALOWANO MODYFIKACJI CUSTOM AUDIO DLL !",
        full_title = "KONFIGURATOR MUZYKI NAJAZDU",
        volume_title = "GŁOŚNOŚĆ",
        select_title = "WYBÓR PIOSENKI",
        volume_warning = "Uwaga! Jeśli masz wybraną piosenke \n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\n, jej głośność będzie zmieniona TYLKO przez suwak głośności w ustawieniach!",
		choose_songs_title = "WYBIERZ PIOSENKI",
        loaded_packs_title = "ZAŁADOWANE PACZKI",
        tracks_title = "UTWORY",
        featured_tracks = "Zawiera utwory z:",
        featured_tracks_more = "I więcej... ",
        songs_created_by = "Stworzona przez:",
        unknown_composer = "Nieznany twórca",
        from = "Z:"
    },
    Russian = {
        interaction = "Настроить Музыку Рейдов",
        interaction_deny = "! НЕ УСТАНОВЛЕН CUSTOM AUDIO DLL МОД !",
        full_title = "НАСТРОЙЩИК МУЗЫКИ РЕЙДОВ",
        volume_title = "ГРОМКОСТЬ",
        select_title = "ВЫБОР МУЗЫКИ",
        volume_warning = "Внимание! Если у вас выбрана музыка\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\",\nна неё повлияет ТОЛЬКО ползунок громкости в настройках!",
		choose_songs_title = "КОНСТРУКТОР ПЛЕЙЛИСТА",
		loaded_packs_title = "АЛЬБОМЫ",
		tracks_title = "КОМПОЗИЦИИ",
		featured_tracks = "Включает композиции из:",
		featured_tracks_more = "И других...",
		songs_created_by = "Композитор:",
		unknown_composer = "Неизвестен",
        from = "Из:"
    },
    ["Swiss German"] = {
        interaction = "Konfigurier d'Kampf Musik",
        interaction_deny = "! CUSTOM AUDIO DLL MOD ISCH NÖD INSTALLIERT !",
        full_title = "KAMPF MUSIK ISTELLIGÄ",
        volume_title = "LUTSTÄRCHI",
        select_title = "MUSIK USWÄHLÄ",
        volume_warning = "Achtung! Wen du d'\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusik usgwält hesch, wird es nur vom Lautstärkäregler i de Istelligä betroffä",
		choose_songs_title = "LIEÄDER USWÄHLÄ",
        loaded_packs_title = "GLADENI PAKET",
        tracks_title = "TITEL",
        featured_tracks = "Enthält titel fo:",
        featured_tracks_more = "Und mehr...",
        songs_created_by = "Fo:",
        unknown_composer = "Unbekannt",
        from = "Vo:"
    }
}

local swissEasterEgg = (math.random(0, 1) == 0)
function translate(tag)
    local lang = sm.gui.getCurrentLanguage()
    if lang == "German" then
        if swissEasterEgg then
			return text["Swiss German"][tag]
        else
            return text[lang][tag]
        end
    else
        if text[lang] then
            return text[lang][tag]
        else
            return text.English[tag]
        end
    end
end