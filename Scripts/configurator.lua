---@diagnostic disable: undefined-global

Configurator = class()

sm.customRaidMusic = sm.customRaidMusic or {}

if sm.customRaidMusic.addedBuiltIn == nil then sm.customRaidMusic.addedBuiltIn = false end
sm.customRaidMusic.musicPacks = sm.customRaidMusic.musicPacks or {}


if not sm.customRaidMusic.addedBuiltIn then
	local musicPacks = {
		{
			name = "Black Mesa",
			--Music Pack Icon
			image = "",
			songs = {
				--Effect name (prepent mod uuid!!) = {loopStart (seconds, 0.25 second precision), loopEnd (seconds, 0.25 second precision)}
				["BMBS - TakeControl"] = { name = "Take Control", composer = "Your Mom", origin = "Black Mesa: Blue Shift", loopStart = 35, loopEnd = 181 }
			}
		}
	}

	for _, pack in ipairs(musicPacks) do
		table.insert(sm.customRaidMusic.musicPacks, pack)
	end
	sm.customRaidMusic.addedBuiltIn = true
end

local text = {
    English = {
        interaction = "Configure Raid Music",
        interaction_deny = "! CUSTOM AUDIO DLL MOD NOT INSTALLED !",
        full_title = "RAID MUSIC CONFIGURATOR",
        volume_title = "VOLUME",
        select_title = "SONG SELECT",
        volume_warning = "Warning! If you have the\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusic selected, it will ONLY be affected by the volume slider in the settings!"
    },
    German = {
        interaction = "Konfiguriere Kampf Musik",
        interaction_deny = "! CUSTOM AUDIO DLL MOD NICHT INSTALLIERT !",
        full_title = "KAMPF MUSIK EINSTELLUNGEN",
        volume_title = "LAUTSTÄRKE",
        select_title = "MUSIK SELEKTION",
        volume_warning = "Warnung! Wen du die\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusik ausgewählt hast, wird es nur vom Lautstärkeregler in den Einstellungen betroffen"
    },
    Italian = {
        interaction = "Configura Musica Assalto",
        interaction_deny = "! MOD CUSTOM AUDIO DLL NON INSTALLATA !",
        full_title = "CONFIGURATORE MUSICA ASSALTO",
        volume_title = "VOLUME",
        select_title = "SELEZIONA MUSICA",
        volume_warning = "Attenzione! Se hai la canzone\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nselezionata, sarà SOLTANTO influenzata dal volume nelle impostazioni!"
    },
    Polish = {
        interaction = "Zkonfiguruj Muzyke Najazdu",
        interaction_deny = "! NIE ZAINSTALOWANO MODYFIKACJI CUSTOM AUDIO DLL !",
        full_title = "KONFIGURATOR MUZYKI NAJAZDU",
        volume_title = "GŁOŚNOŚĆ",
        select_title = "WYBÓR PIOSENKI",
        volume_warning = "Uwaga! Jeśli masz wybraną piosenke \n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\n, jej głośność będzie zmieniona TYLKO przez suwak głośności w ustawieniach!"
    },
    Russian = {
        interaction = "Настроить Музыку Рейдов",
        interaction_deny = "! НЕ УСТАНОВЛЕН CUSTOM AUDIO DLL МОД !",
        full_title = "НАСТРОЙЩИК МУЗЫКИ РЕЙДОВ",
        volume_title = "ГРОМКОСТЬ",
        select_title = "ВЫБОР МУЗЫКИ",
        volume_warning = "Внимание! Если у вас выбрана музыка\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\",\nна неё повлияет ТОЛЬКО ползунок громкости в настройках!"
    },
    ["Swiss German"] = {
        interaction = "Konfigurier d'Kampf Musik",
        interaction_deny = "! CUSTOM AUDIO DLL MOD ISCH NÖD INSTALLIERT !",
        full_title = "KAMPF MUSIK ISTELLIGÄ",
        volume_title = "LUTSTÄRCHI",
        select_title = "MUSIK USWÄHLÄ",
        volume_warning = "Achtung! Wen du d'\n\"Scrap Mechanic - Zheanna \"Zhea\" Erose - ???\"\nmusik usgwält hesch, wird es nur vom Lautstärkäregler i de Istelligä betroffä"
    }
}

local swissEasterEgg = (math.random(0, 1) == 0)
local function translate(tag)
    local lang = sm.gui.getCurrentLanguage()
    if lang == "German" then
        if swissEasterEgg then
            return text[lang][tag]
        else
            return text["Swiss German"][tag]
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

function Configurator:server_onCreate()
	sm.customRaidMusic.tool = self.tool
end

function Configurator:client_onCreate()
	sm.customRaidMusic.tool = self.tool
    self.saveableVolume = 101
    self.gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Configurator.layout", false, {
        isHud = false,
        isInteractive = true,
        needsCursor = true,
        hidesHotbar = false,
        isOverlapped = false,
        backgroundAlpha = 0.25
    })
    self.playlistGUI = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Playlist.layout", false, {
        isHud = false,
        isInteractive = true,
        needsCursor = true,
        hidesHotbar = false,
        isOverlapped = false,
        backgroundAlpha = 0.25
    })
    self.gui:setImage("volume_image", "$CONTENT_DATA/Gui/Images/volume_arrow_0.png")
    self.gui:createHorizontalSlider("volume_slider", 101, 101, "cl_onSliderChange", true)
    self.gui:setButtonCallback("open_playlist", "cl_openPlaylist")
end

function Configurator:cl_updateVolumeVisuals()
    local imageIndex = mapAndClamp(self.saveableVolume, 0, 100, 0, 59)
    self.gui:setImage("volume_image", "$CONTENT_DATA/Gui/Images/volume_arrow_" .. imageIndex .. ".png")
    self.gui:setColor("volume_image", sm.color.new(colorGradient("#56D9CD", "#F1385A", self.saveableVolume * 0.01)))
    self.gui:setText("volume_number", tostring(self.saveableVolume))
end

function Configurator:cl_onSliderChange(newNumber)
    -- Update data
    self.saveableVolume = newNumber
    self:cl_updateVolumeVisuals()
    -- Save new volume
    local json = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
    json.volume = self.saveableVolume * 0.001
    sm.json.save(json, "$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
    sm.event.sendToTool(sm.customRaidMusic.musicHook, "cl_resetJson")
end

function Configurator:cl_openPlaylist()
    self.playlistGUI:open()
end

function Configurator:sv_openGui(params)
	self.network:sendToClient(params.player, "cl_openGui", params)
end

function Configurator:cl_openGui()
    -- Localize
    self.gui:setText("full_title", translate("full_title"))
    self.gui:setText("volume_title", translate("volume_title"))
    self.gui:setText("select_title", translate("select_title"))
    self.gui:setText("volume_warning", translate("volume_warning"))
    -- Load data
    local json = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
    self.gui:setSliderPosition("volume_slider", json.volume * 1000)
    self.gui:setSelectedDropDownItem("song_select_dropdown", json.selectedSong)
    self.saveableVolume = json.volume * 1000
    self.saveableSong = json.selectedSong
    self:cl_updateVolumeVisuals()
    self.gui:open()
end