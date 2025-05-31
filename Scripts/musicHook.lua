---@diagnostic disable: undefined-global

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
	self.musicPlaying = false
	self.songProgress = 0
	self.queuedEffectRecreation = false
	self.jumpToEnd = false
end

function MusicHook:cl_buildPlaylist()
	self.playlist = {}
	for _, playlistSong in pairs(sm.customRaidMusic.songData.playlist) do
		for _, pack in pairs(sm.customRaidMusic.musicPacks) do
			for packSongName, _ in pairs(pack.songs) do
				if playlistSong == packSongName then
					self.playlist[#self.playlist+1] = playlistSong
				end
			end
		end
	end
	print("[RAID MUSIC] Built playlist:", self.playlist)
end

function MusicHook:cl_resetJson()
	sm.customRaidMusic.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
	sm.customRaidMusic.songData.playlist = sm.customRaidMusic.songData.playlist or {}
end

function MusicHook:client_onFixedUpdate(dt)
	-- Import raid data we yoinked from the game script
	local raids, sv, curTick = sm.customRaidMusic.raids, sm.customRaidMusic.UM_SvSelf, sm.game.getCurrentTick()
	if not (raids and sv) then return end
	-- Reset variable at a staggered rate to allow for the 0 seconds on the raid timer to pass
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
					self.music:setParameter("CAE_Position", self.songProgress)
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
				for _, pack in ipairs(sm.customRaidMusic.musicPacks) do
					self.currentSongData = pack.songs[self.playlist[1]]
					if self.currentSongData then break end
				end
			end
		end
		-- Recreate effect after it's done to advance the palylist
		if self.queuedEffectRecreation and self.music and sm.exists(self.music) and not self.musicPlaying and not self.music:isPlaying() then
			self.queuedEffectRecreation = false
			self.music:destroy()
			self.music = nil
		end
	else
		-- Create music if somehow missing
		if sm.cae_injected then
			if self.playlist and #self.playlist > 0 then
				self.music = sm.effect.createEffect(self.playlist[1], sm.localPlayer.getPlayer().character)
				for _, pack in ipairs(sm.customRaidMusic.musicPacks) do
					self.currentSongData = pack.songs[self.playlist[1]]
				end
				table.remove(self.playlist, 1)
				if #self.playlist < 1 then
					self:cl_buildPlaylist()
				end
			else
				self:cl_buildPlaylist()
			end
		else
			self.music = sm.effect.createEffect("Vanilla", sm.localPlayer.getPlayer().character)
		end
	end
	-- Set volume all the time because I can't be bothered with checking when it's changed this has literally 0 performance impact, so whatever
	if sm.cae_injected and self.music and sm.exists(self.music) then
		self.music:setParameter("CAE_Volume", sm.customRaidMusic.songData.volume)
	end
end