---@diagnostic disable: undefined-global, param-type-mismatch
dofile("$CONTENT_DATA/Scripts/localizator.lua")

MusicHook = class()

-- Hooking hell, do not touch
sm.customRaidMusic = sm.customRaidMusic or {}
if sm.customRaidMusic.hooked == nil then sm.customRaidMusic.hooked = false end
if not sm.customRaidMusic.hooked then
	local oldBindCommand = sm.game.bindChatCommand

	local function bindCommandHook(command, params, callback, help)
		if not sm.customRaidMusic.hooked then
			dofile("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/Scripts/dofiler.lua")
			print("[RAID MUSIC] Hooking Raid Music...")
			sm.customRaidMusic.hooked = true
			oldBindCommand("/musicconfig", {}, "cl_onChatCommand", "Opens the Raid Music configuration menu.")
		end
		oldBindCommand(command, params, callback, help)
	end
	sm.game.bindChatCommand = bindCommandHook

	local oldWorldEvent = oldWorldEvent or sm.event.sendToWorld

	local function worldEventHook(world, callback, params)
		if not params then
			oldWorldEvent(world, callback, params)
			return
		end

		if params[1] == "/musicconfig" then
			sm.event.sendToTool(sm.customRaidMusic.tool, "sv_openGui", params)
		else
			oldWorldEvent(world, callback, params)
		end
	end

	sm.event.sendToWorld = worldEventHook
end

-- More normal code (marginally)

sm.customRaidMusic.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
sm.customRaidMusic.songData.playlist = sm.customRaidMusic.songData.playlist or {}

-- Stolen from challenge mode's world_util but modified to notify when when the table is actually modified
local function removeFromArray(t, fnShouldRemove)
	local n = #t
	local j = 1
	local wasModified = false

	for i = 1, n do
		if fnShouldRemove(t[i]) then
			t[i] = nil;
			wasModified = true
		else
			if i ~= j then
				t[j] = t[i]
				t[i] = nil
			end
			j = j + 1
		end
	end

	return t, wasModified
end

function MusicHook:client_onCreate()
	sm.customRaidMusic.musicHook = self.tool
	self:cl_buildPlaylist()
	-- Five million flags is a sign of a good mod, trust me
	self.musicPlaying = false
	self.songProgress = 0
	self.queuedEffectRecreation = false
	self.jumpToEnd = false
	self.prevPlayingState = false
	-- Popup stuff
	self.popupCountdown = 0
	self.popupFadeCountdown = 0
	self.animProgress = 0
    self.frame = 1
	self.vinylJumpFrame = 1
	self.holdOnFirstJumpFrame = 0
	self.songImage = "$CONTENT_DATA/Gui/Images/missing.png"
	self.songColor = sm.color.new("#ffffff")
end

-- Playlist builder that accounts for stupid users who got a music pack, enabled songs from it and then promptly uninstalled it, leaving us with a pile of non-existent entries
function MusicHook:cl_buildPlaylist(soundKill)
	if soundKill then
		self.music:destroy()
		self.music = nil
	end
	self.playlist = {}
	if sm.customRaidMusic.songData.playlist ~= 0 then
		for _, playlistSong in pairs(sm.customRaidMusic.songData.playlist) do
			for _, pack in pairs(sm.customRaidMusic.musicPacks) do
				for packSongName, _ in pairs(pack.songs) do
					if playlistSong == packSongName then
						self.playlist[#self.playlist+1] = playlistSong
					end
				end
			end
		end
		if self.music and sm.exists(self.music) and self.music:isPlaying() then
			if sm.cae_injected then
				sm.effect.playHostedEffect("Transition", sm.localPlayer.getPlayer().character)
			end
			self.music:destroy()
			self.music = nil
			print("[RAID MUSIC] Killed playing music!")
		end
		print("[RAID MUSIC] Built playlist:", self.playlist)
	end
end

-- Using this only to save volume, playlist init is there too, redundancies never killed anyone!
function MusicHook:cl_resetJson()
	sm.customRaidMusic.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
	sm.customRaidMusic.songData.playlist = sm.customRaidMusic.songData.playlist or {}
end

function MusicHook:client_onFixedUpdate(dt)
	-- Import raid data we yoinked from the game script
	local raids, sv, curTick = sm.customRaidMusic.raids, sm.customRaidMusic.UM_SvSelf, sm.game.getCurrentTick()
	if not (raids and sv) then return end
	-- Reset variable at a staggered rate to allow for the 0 seconds on the raid timer to pass, thanks John Axolot
	if curTick % 40 == 0 then
		self.musicPlaying = false
	end
	-- Removing units as they're killed
	for _, raid in ipairs(raids) do
		local _, wasModified = removeFromArray(raid.raiders, function(unit) return not sm.exists(unit) end)
		if wasModified and #raid.raiders < 1 then
			self.queuedEffectRecreation = true
		end
	end
	-- Check attack cells
	if self.playlist[1] == "Vanilla" or not sm.cae_injected then
		for _, cell in pairs(sv.sv.cropAttackCells) do
			local attackPos = cell.saved.attackPos
			if attackPos and (sm.localPlayer.getPlayer().character.worldPosition - attackPos):length() < 500 then
				for _, raid in ipairs(raids) do
					if #raid.raiders > 0 and curTick < raid.endTick and raid.attackPos == attackPos then
						self.musicPlaying = true
						break
					end
				end
			end
		end
	else
		for _, cell in pairs(sv.sv.cropAttackCells) do
			local attackPos = cell.saved.attackPos
			if attackPos and (sm.localPlayer.getPlayer().character.worldPosition - attackPos):length() < 500 then
				local attackTick = cell.saved.attackTick
				if attackTick and self.currentSongData and curTick >= (attackTick - self.currentSongData.loopStart * 40) then
					self.musicPlaying = true
					break
				else
					for _, raid in ipairs(raids) do
						if #raid.raiders > 0 and curTick < raid.endTick and raid.attackPos == attackPos then
							self.musicPlaying = true
							break
						end
					end
				end
			end
		end
	end
	-- Effect stuff
	if self.music and sm.exists(self.music) then
		if self.playlist[1] == "Vanilla" or not sm.cae_injected then
			-- Vanilla handles looping on it's own so we just let it do it's thing and tell it when to start and stop
			if self.musicPlaying then
				if not self.music:isPlaying() then
					self.music:start()
				end
			else
				if self.music:isPlaying() then
					self.music:stop()
				end
			end
		else
			-- Song looping
			if self.currentSongData then
				if self.musicPlaying then
					-- Start playing
					if not self.music:isPlaying() then
						self.music:start()
					end
					-- Tick progress
					if curTick % 10 == 0 then
						self.songProgress = self.songProgress + 0.25
					end
					-- Jump back to start
					if self.songProgress >= self.currentSongData.loopEnd then
						self.songProgress = self.currentSongData.loopStart
					end
					-- Force update progress to loop and stuff
					if curTick % 10 == 0 then
						self.music:setParameter("CAE_Position", self.songProgress)
					end
					-- Prepare to jump
					self.jumpToEnd = true
				else
					if self.jumpToEnd then
						-- Jump once
						self.jumpToEnd = false
						-- Jump to the end and let it finish playing on it's own
						self.music:setParameter("CAE_Position", self.currentSongData.loopEnd)
						-- Reset progress, since we're just letting the song finish on it's own, it no londer needs forced progress
						self.songProgress = 0
					end
				end
			else
				-- Grab song data from the corresponding pack in the most cursed way possible
				for _, pack in ipairs(sm.customRaidMusic.musicPacks) do
					self.currentSongData = pack.songs[self.playlist[1]]
					if self.currentSongData then break end
				end
			end
		end
		-- Recreate effect after it's done to advance the playlist
		if self.queuedEffectRecreation and self.music and sm.exists(self.music) and not self.musicPlaying and not self.music:isPlaying() then
			self.queuedEffectRecreation = false
			self.music:destroy()
			self.music = nil
		end
	else
		-- Create music if somehow missing
		if sm.cae_injected then
			if sm.customRaidMusic.songData.playlist ~= 0 then -- Allow users to have an empty playlist... Who installs a music mod to then disable music?
				if self.playlist and #self.playlist > 0 then
					self.music = sm.effect.createEffect(self.playlist[1], sm.localPlayer.getPlayer().character)
					local imagePath = "$CONTENT_"..string.sub(self.playlist[1], 0, 36).."/pack_thumbnail.png"
					local sucks, ass = pcall(sm.json.fileExists, imagePath)
					if sucks and ass then
						self.songImage = imagePath
					else
						self.songImage = "$CONTENT_DATA/Gui/Images/missing.png"
					end
					for _, pack in ipairs(sm.customRaidMusic.musicPacks) do
						self.currentSongData = pack.songs[self.playlist[1]]
						self.songColor = pack.color or sm.color.new("#ffffff")
					end
					table.remove(self.playlist, 1)
					if #self.playlist < 1 then
						self:cl_buildPlaylist()
					end
				else
					self:cl_buildPlaylist()
				end
			end
		else
			self.music = sm.effect.createEffect("Vanilla", sm.localPlayer.getPlayer().character)
		end
	end
	-- Set volume all the time because I can't be bothered with checking when it's changed this has literally 0 performance impact, so whatever
	if sm.cae_injected and self.music and sm.exists(self.music) and curTick % 10 == 0 then
		self.music:setParameter("CAE_Volume", sm.customRaidMusic.songData.volume)
	end
	-- Show popup every time we start playing music
	if self.musicPlaying ~= self.prevPlayingState then
		self.prevPlayingState = self.musicPlaying
		if self.musicPlaying and not (self.popup and sm.exists(self.popup)) then
			self.popup = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Song_popup.layout", true, {
				isHud = true,
				isInteractive = false,
				needsCursor = false,
				hidesHotbar = false,
				isOverlapped = false,
				backgroundAlpha = 0
			})
			self.popup:setOnCloseCallback("cl_startPopupFade")
			self.popup:setColor("VinylVisual", self.songColor)
			self.popup:setImage("PackImage", self.songImage)
			self.popup:setText("SongName", self.currentSongData.name)
			self.popup:setText("SongComposer", translate("songs_created_by").." "..self.currentSongData.composer)
			self.popup:setText("SongOrigin", translate("from").." "..self.currentSongData.origin)
			self.popup:open()
			self.popupCountdown = 200
			self.holdOnFirstJumpFrame = 40
		end
	end
	-- Count down popup time
	if self.popupCountdown > 0 then
		self.popupCountdown = self.popupCountdown - 1
	else
		if self.popup and sm.exists(self.popup) and self.popup:isActive() then
			self.popup:close()
		end
	end
	if self.popupFadeCountdown > 0 then
		self.popupFadeCountdown = self.popupFadeCountdown - 1
	else
		if self.popupFade and sm.exists(self.popupFade) and self.popupFade:isActive() then
			self.popupFade:close()
		end
	end
	if self.holdOnFirstJumpFrame > 0 then
		self.holdOnFirstJumpFrame = self.holdOnFirstJumpFrame - 1
	end
end

function MusicHook:cl_startPopupFade()
	self.popupFade = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Song_popup_fade.layout", true, {
		isHud = true,
		isInteractive = false,
		needsCursor = false,
		hidesHotbar = false,
		isOverlapped = false,
		backgroundAlpha = 0
	})
	self.popupFade:setOnCloseCallback("cl_resetPopupData")
	self.popupFade:setColor("VinylVisual", self.songColor)
	self.popupFade:setImage("PackImage", self.songImage)
	self.popupFade:setText("SongName", self.currentSongData.name)
	self.popupFade:setText("SongComposer", translate("songs_created_by").." "..self.currentSongData.composer)
	self.popupFade:setText("SongOrigin", translate("from").." "..self.currentSongData.origin)
	self.popupFade:open()
	self.popupFadeCountdown = 60
end

function MusicHook:cl_resetPopupData()
	self.vinylJumpFrame = 1
end

local frameFraction = (1 / 60)
function MusicHook:client_onUpdate(dt)
    -- Animate popups
    if self.popup and sm.exists(self.popup) and self.popup:isActive() then
        self.animProgress = self.animProgress + dt
        if self.animProgress >= frameFraction then
			if self.vinylJumpFrame > 25 then
				self.popup:setImage("VinylVisual", "$CONTENT_DATA/Gui/Images/vinyl/vinyl_frame_"..self.frame..".png")
				self.frame = self.frame + 1
				if self.frame > 300 then
					self.frame = 1
				end
			else
				if self.holdOnFirstJumpFrame <= 0 then
					self.popup:setImage("VinylVisual", "$CONTENT_DATA/Gui/Images/vinyl_jump/vinyl_jump_frame_"..self.vinylJumpFrame..".png")
					self.vinylJumpFrame = self.vinylJumpFrame + 1
				else
					self.popup:setImage("VinylVisual", "$CONTENT_DATA/Gui/Images/vinyl_jump/vinyl_jump_frame_1.png")
				end
			end
            self.animProgress = self.animProgress - frameFraction
        end
    end
	if self.popupFade and sm.exists(self.popupFade) and self.popupFade:isActive() then
        self.animProgress = self.animProgress + dt
        if self.animProgress >= frameFraction then
            self.popupFade:setImage("VinylVisual", "$CONTENT_DATA/Gui/Images/vinyl/vinyl_frame_"..self.frame..".png")
            self.frame = self.frame + 1
            if self.frame > 300 then
                self.frame = 1
            end
            self.animProgress = self.animProgress - frameFraction
        end
    end
end