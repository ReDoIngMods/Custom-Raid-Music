---@diagnostic disable: undefined-global, param-type-mismatch

Configurator = class()

-- GLOBALS

sm.customRaidMusic = sm.customRaidMusic or {}

if sm.customRaidMusic.addedBuiltIn == nil then sm.customRaidMusic.addedBuiltIn = false end
sm.customRaidMusic.musicPacks = sm.customRaidMusic.musicPacks or {}

-- PACKS

if not sm.customRaidMusic.addedBuiltIn then
	local musicPacks = {
		{
			name = "Scrap Mechanic Pack",
			--Music Pack Icon
			image = "$CONTENT_DATA/Gui/Images/pack_sm_thumbnail.png",
			color = sm.color.new("#df7f00"),
			songs = {
				--Effect name (prepend mod uuid!!) = {loopStart (seconds, 0.25 second precision), loopEnd (seconds, 0.25 second precision)}
				["Vanilla"] = { name = "???", composer = "Zheanna \"Zhea\" Erose", origin = "Scrap Mechanic" }
			}
		}
	}

	for _, pack in ipairs(musicPacks) do
		table.insert(sm.customRaidMusic.musicPacks, pack)
	end
	sm.customRaidMusic.addedBuiltIn = true
end

-- LOCALS

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
		featured_tracks = "Features Tracks from:",
		featured_tracks_more = "And more...",
		songs_created_by = "by:",
		unknown_composer = "Unknown"
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
        featured_tracks = "Enthält Titel von:",
        featured_tracks_more = "Und mehr...",
        songs_created_by = "von:",
        unknown_composer = "Unbekannt"
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
		songs_created_by = "di:",
		unknown_composer = "Sconosciuto"
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
        unknown_composer = "Nieznany twórca"
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
		unknown_composer = "Неизвестен"
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
        featured_tracks = "Enthält Titel fo:",
        featured_tracks_more = "Und mehr...",
        songs_created_by = "fo:",
        unknown_composer = "Unbekannt"
    }
}

-- LOCAL FUNCTIONS

local function getRealLength(tbl)
    if not tbl then return 0 end

	local count = 0
	for k, v in pairs(tbl) do
		count = count + 1
	end

	return count
end

local function getByIndex(tbl, index, getKey)
    if not tbl then return end

	local count = 1
	for k, v in pairs(tbl) do
		if count == index then
			return getKey and k or v
		end

		count = count + 1
	end
end

local function valueExists(array, value)
	for _, v in ipairs( array ) do
		if v == value then
			return true
		end
	end
	return false
end

local swissEasterEgg = (math.random(0, 1) == 0)
local function translate(tag)
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

local function mapAndClamp(value, inMin, inMax, outMin, outMax)
    local t = (value - inMin) / (inMax - inMin)
    t = math.max(0, math.min(1, t))
    return math.floor(outMin + (outMax - outMin) * t)
end

local function hexToRgb(hex)
    hex = hex:gsub("#","")
    return tonumber(hex:sub(1,2),16),
           tonumber(hex:sub(3,4),16),
           tonumber(hex:sub(5,6),16)
end

local function rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function colorGradient(hexColor1, hexColor2, t)
    t = math.max(0, math.min(1, t))

    local r1, g1, b1 = hexToRgb(hexColor1)
    local r2, g2, b2 = hexToRgb(hexColor2)

    local r = math.floor(sm.util.lerp(r1, r2, t) + 0.5)
    local g = math.floor(sm.util.lerp(g1, g2, t) + 0.5)
    local b = math.floor(sm.util.lerp(b1, b2, t) + 0.5)

    return rgbToHex(r, g, b)
end

-- ACTUAL CODE

function Configurator:server_onCreate()
	sm.customRaidMusic.tool = self.tool
end

function Configurator:client_onCreate()
	sm.customRaidMusic.tool = self.tool

    -- GUIs
    self.cacheGUI = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Vinyl_cache.layout", true, {
        isHud = true,
        isInteractive = false,
        needsCursor = false,
        hidesHotbar = false,
        isOverlapped = false,
        backgroundAlpha = 0
    })
    self.cacheGUI:open()

    self.mainGUI = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Configurator.layout", false, {
        isHud = false,
        isInteractive = true,
        needsCursor = true,
        hidesHotbar = false,
        isOverlapped = false,
        backgroundAlpha = 0
    })
	self.mainGUI:setImage("volume_image", "$CONTENT_DATA/Gui/Images/volume/volume_arrow_0.png")
    self.mainGUI:createHorizontalSlider("volume_slider", 101, 101, "cl_onSliderChange", true)
    self.mainGUI:setButtonCallback("open_playlist", "cl_openPlaylist")

    self.playlistGui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Playlist.layout", false, {
        isHud = false,
        isInteractive = true,
        needsCursor = true,
        hidesHotbar = false,
        isOverlapped = true,
        backgroundAlpha = 0
    })
    self.playlistGui:setOnCloseCallback("cl_playlistClose")
	self.currentSelectedPack = 0
	self.currentPackPage = 1
	self.currentSongsPage = 1
	for i = 1, 2 do
		self.playlistGui:setButtonCallback( "Pack"..i, "cl_selectPack" )
	end
	self.playlistGui:setButtonCallback( "NextPagePacks", "cl_onPacksPageChange" )
	self.playlistGui:setButtonCallback( "PrevPagePacks", "cl_onPacksPageChange" )
	self:cl_updatePacks()
	for i = 1, 5 do
		self.playlistGui:setButtonCallback( "Song"..i, "cl_selectSong" )
	end
	self.playlistGui:setButtonCallback( "NextPageTracks", "cl_onSongPageChange" )
	self.playlistGui:setButtonCallback( "PrevPageTracks", "cl_onSongPageChange" )

    -- Misc data
    self.saveableVolume = 101
    self.animProgress = 0
    self.frame = 1
    self.volumeSaveCooldown = 0
    self.imageCacheCountdown = 40
end

function Configurator:cl_onPacksPageChange(btnName)
	if btnName == "NextPagePacks" then
		self.currentPackPage = sm.util.clamp(self.currentPackPage + 1, 1, math.ceil(#sm.customRaidMusic.musicPacks / 2))
	elseif btnName == "PrevPagePacks" then
		self.currentPackPage = sm.util.clamp(self.currentPackPage - 1, 1, math.ceil(#sm.customRaidMusic.musicPacks / 2))
	end
	self:cl_updatePacks()
end

function Configurator:cl_selectPack(btn)
	local index = (self.currentPackPage - 1) * 2 + string.sub(btn, -1)
	self.currentSelectedPack = index
	self:cl_updatePacks()
	self.currentSongsPage = 1
	self:cl_updateSongs()
end

function Configurator:cl_updatePacks()

	local maxPage = math.ceil(#sm.customRaidMusic.musicPacks / 2)
	self.playlistGui:setText("CurrPagePacks", self.currentPackPage.."/"..maxPage)
	self.playlistGui:setVisible("CurrPagePacks", maxPage > 1)
	self.playlistGui:setVisible("NextPagePacks", self.currentPackPage < maxPage)
	self.playlistGui:setVisible("PrevPagePacks", self.currentPackPage > 1)

	for i = 1, 2 do
		local packI = (self.currentPackPage - 1) * 2 + i
		local pack = sm.customRaidMusic.musicPacks[packI]
		self.playlistGui:setButtonState("Pack"..i, packI == self.currentSelectedPack)
		if packI == self.currentSelectedPack then
			self.playlistGui:setColor("VinylVisual", pack and pack.color or sm.color.new("#ffffff"))
		end
		if pack ~= nil then
			self.playlistGui:setVisible("Pack"..i, true)
			self.playlistGui:setText("PackName"..i, pack.name or "UNNAMED!!!")
			if pack.image and pcall(sm.json.fileExists, pack.image) and sm.json.fileExists(pack.image) then
				self.playlistGui:setImage("PackThumb"..i, pack.image)
			else
				self.playlistGui:setImage("PackThumb"..i, "$CONTENT_DATA/Gui/Images/missing.png")
			end

			local songCount = pack.songs and getRealLength(pack.songs) or 0
			if pack.songs and songCount > 0 then
				local songsText = translate("featured_tracks")
				local added = {}
				local shown = 0

				for _, v in pairs(pack.songs) do
					local o = v.origin
					if o and not added[o] then
						added[o] = true
						shown = shown + 1
						if shown <= 4 then
							songsText = songsText .. "\n" .. o
						elseif shown == 5 then
							songsText = songsText .. "\n" .. o
						elseif shown >= 6 then
							songsText = songsText:sub(1, #songsText - #o) .. translate("featured_tracks_more")
							break
						end
					end
				end

				self.playlistGui:setText("PackContains"..i, songsText)
			else
				self.playlistGui:setText("PackContains"..i, "")
			end
		else
			self.playlistGui:setVisible("Pack"..i, false)
		end
	end
end

function Configurator:cl_onSongPageChange(btnName)
	if btnName == "NextPageTracks" then
		self.currentSongsPage = sm.util.clamp(self.currentSongsPage + 1, 1, math.ceil(getRealLength(sm.customRaidMusic.musicPacks[self.currentSelectedPack].songs) / 5))
	elseif btnName == "PrevPageTracks" then
		self.currentSongsPage = sm.util.clamp(self.currentSongsPage - 1, 1, math.ceil(getRealLength(sm.customRaidMusic.musicPacks[self.currentSelectedPack].songs) / 5))
	end
	self:cl_updateSongs()
end

function Configurator:cl_selectSong(btn)
	local index = (self.currentSongsPage - 1) * 5 + string.sub(btn, -1)

	local packSongs = sm.customRaidMusic.musicPacks[self.currentSelectedPack].songs
	local playlist = sm.customRaidMusic.songData.playlist

	if playlist == 0 then
		sm.customRaidMusic.songData.playlist = {}
		playlist = sm.customRaidMusic.songData.playlist
	end

	local songName = getByIndex(packSongs, index, true)
	if valueExists(playlist, songName) then
		for i = #playlist, 1, -1 do
			if playlist[i] == songName then
				table.remove(playlist, i)
				break
			end
		end
	else
		table.insert(playlist, songName)
	end

	if #playlist < 1 then
		playlist = 0
	end

	self:cl_updateSongs()
end

function Configurator:cl_updateSongs()
	local maxPage = math.ceil(getRealLength(sm.customRaidMusic.musicPacks[self.currentSelectedPack].songs) / 5)
	self.playlistGui:setText("CurrPageTracks", self.currentSongsPage.."/"..maxPage)
	self.playlistGui:setVisible("CurrPageTracks", maxPage > 1)
	self.playlistGui:setVisible("NextPageTracks", self.currentSongsPage < maxPage)
	self.playlistGui:setVisible("PrevPageTracks", self.currentSongsPage > 1)

	local packSongs = sm.customRaidMusic.musicPacks[self.currentSelectedPack].songs
	local playlist = sm.customRaidMusic.songData.playlist

	for i = 1, 5 do
		local songI = (self.currentSongsPage - 1) * 5 + i
		local songEffect = getByIndex(packSongs, songI, true)
		local song = packSongs[songEffect]

		if song ~= nil then
			self.playlistGui:setVisible("Song"..i, true)
			local isEnabled = playlist ~= 0 and valueExists(playlist, songEffect)

			self.playlistGui:setButtonState("Song"..i, isEnabled)
			self.playlistGui:setColor("SongCheck"..i, isEnabled and sm.color.new("#FFD44A") or sm.color.new("#767676"))
			self.playlistGui:setImage("SongCheck"..i, isEnabled and "IconCheckmarkSelected.png" or "IconCheckmarkDefault.png")
			self.playlistGui:setText("SongName"..i, (isEnabled and "#FFD44A" or "#ffffff")..(song.name or "UNNAMED!!!"))
			self.playlistGui:setText("SongComposer"..i, (isEnabled and "#BFA337" or "#808080")..(song.composer and (translate("songs_created_by").." "..song.composer) or translate("songs_created_by").." "..translate("unknown_composer")))
		else
			self.playlistGui:setVisible("Song"..i, false)
		end
	end
end

function Configurator:sv_openGui(params)
	self.network:sendToClient(params.player, "cl_openGui", params)
end

function Configurator:cl_openGui()
	if not sm.cae_injected then
		sm.gui.chatMessage("#ff0000"..translate("interaction_deny").."\n"..translate("interaction_deny_desc"))
		sm.gui.displayAlertText("#ff0000"..translate("interaction_deny"), 8)
		return
	end
    -- Localize
    self.mainGUI:setText("full_title", translate("full_title"))
    self.mainGUI:setText("volume_title", translate("volume_title"))
    self.mainGUI:setText("select_title", translate("select_title"))
    self.mainGUI:setText("volume_warning", translate("volume_warning"))
    -- Load data
    local json = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
    self.mainGUI:setSliderPosition("volume_slider", json.volume * 1000)
    self.saveableVolume = json.volume * 1000
    self.saveableSong = json.selectedSong
    self:cl_updateVolumeVisuals()
    self.mainGUI:open()
end

function Configurator:cl_updateVolumeVisuals()
    local imageIndex = mapAndClamp(self.saveableVolume, 0, 100, 0, 59)
    self.mainGUI:setImage("volume_image", "$CONTENT_DATA/Gui/Images/volume/volume_arrow_"..imageIndex..".png")
    self.mainGUI:setColor("volume_image", sm.color.new(colorGradient("#56D9CD", "#F1385A", self.saveableVolume * 0.01)))
	local str = tostring(self.saveableVolume)
    self.mainGUI:setText("volume_number", string.rep(" ", 3 - #str)..str)
end

function Configurator:cl_onSliderChange(newNumber)
    -- Update data
    self.saveableVolume = newNumber
    self:cl_updateVolumeVisuals()
    -- Reset cooldown
    self.volumeSaveCooldown = 10
end

function Configurator:cl_openPlaylist()
	self.mainGUI:close()
    self.playlistGui:open()
	self.playlistGui:setText("Title", translate("choose_songs_title"))
	self.playlistGui:setText("PacksTitle", translate("loaded_packs_title"))
	self.playlistGui:setText("TracksTitle", translate("tracks_title"))
end

function Configurator:cl_playlistClose()
	self.mainGUI:open()
	if sm.customRaidMusic.songData.playlist ~= 0 and #sm.customRaidMusic.songData.playlist < 1 then
		sm.customRaidMusic.songData.playlist = 0
	end
	sm.json.save(sm.customRaidMusic.songData, "$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
	sm.event.sendToTool(sm.customRaidMusic.musicHook, "cl_buildPlaylist")
end

function Configurator:client_onFixedUpdate(dt)
    -- Save new volume
    if self.volumeSaveCooldown == 1 then
        print("[RAID MUSIC] Saved volume:", self.saveableVolume)
        local json = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
        json.volume = self.saveableVolume * 0.001
        sm.json.save(json, "$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
        sm.event.sendToTool(sm.customRaidMusic.musicHook, "cl_resetJson")
    end
    -- Tick cooldown
    if self.volumeSaveCooldown > 0 then
        self.volumeSaveCooldown = self.volumeSaveCooldown - 1
    end
end

local frameFraction = (1 / 60)
function Configurator:client_onUpdate(dt)
    -- Unload the cacheing GUI
    if self.cacheGUI and sm.exists(self.cacheGUI) and self.cacheGUI:isActive() then
        if self.imageCacheCountdown > 0 then
            self.imageCacheCountdown = self.imageCacheCountdown - 1
        else
            self.cacheGUI:destroy()
            self.cacheGUI = nil
            self.imageCacheCountdown = nil
        end
    end
    -- Animate the vinyl
    if self.playlistGui:isActive() then
        self.animProgress = self.animProgress + dt
        if self.animProgress >= frameFraction then
            self.playlistGui:setImage("VinylVisual", "$CONTENT_DATA/Gui/Images/vinyl/vinyl_frame_"..self.frame..".png")
            self.frame = self.frame + 1
            if self.frame > 300 then
                self.frame = 1
            end
            self.animProgress = self.animProgress - frameFraction
        end
    end
end