---@diagnostic disable: undefined-global
dofile("$CHALLENGE_DATA/Scripts/challenge/world_util.lua")

MusicHook = class()

-- Hooking hell, do not touch
sm.customRaidMusic = sm.customRaidMusic or {}
if sm.customRaidMusic.hooked == nil then sm.customRaidMusic.hooked = false end
if not sm.customRaidMusic.hooked then
	local oldBindCommand = sm.game.bindChatCommand

	local function bindCommandHook(command, params, callback, help)
		if not sm.customRaidMusic.hooked then
			dofile("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/Scripts/dofiler.lua")
			print("Hooking Raid Music")
			sm.customRaidMusic.hooked = true
			oldBindCommand("/raidMusic", {}, "cl_onChatCommand", "Opens the Raid Music configuration menu.")
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

		if params[1] == "/raidMusic" then
			sm.event.sendToTool(sm.customRaidMusic.tool, "sv_openGui", params)
		else
			oldWorldEvent(world, callback, params)
		end
	end

	sm.event.sendToWorld = worldEventHook
end

function MusicHook:client_onCreate()
	self.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
	if not sm.cae_injected then
		self.songData.selectedSong = "Vanilla"
	end
	self.music = sm.effect.createEffect(self.songData.selectedSong, sm.localPlayer.getPlayer().character)
	self.musicPlaying = false
	self.songProgress = 0
	sm.customRaidMusic.musicHook = self.tool
end

function MusicHook:cl_resetJsonAndEffect()
	self.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
	self.music:destroy()
	self.music = nil
	self.music = sm.effect.createEffect(self.songData.selectedSong, sm.localPlayer.getPlayer().character)
	self.musicPlaying = false
	self.songProgress = 0
end

function MusicHook:cl_resetJson()
	self.songData = sm.json.open("$CONTENT_f9e17931-93ca-41e9-b9fe-a3ae1d77c01a/song_config.json")
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
		removeFromArray(raid.raiders, function(unit) return not sm.exists(unit) end)
	end
	-- Check attack cells
	if self.songData.selectedSong == "Vanilla" then
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
				if attackTick and curTick >= (attackTick - self.songData.songs[self.songData.selectedSong].loopStart * 40) then
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
		if self.songData.selectedSong == "Vanilla" then
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
			local curSongData = self.songData.songs[self.songData.selectedSong]
			if curSongData then
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
					if self.songProgress >= curSongData.loopEnd then
						self.songProgress = curSongData.loopStart
					end
					-- Force update progress to loop and stuff
					self.music:setParameter("CAE_Position", self.songProgress)
				else
					-- Jump to the end and let it finish playing on it's own
					self.music:setParameter("CAE_Position", curSongData.loopEnd)
					-- Reset progress, since we're just letting the song finish on it's own, it no londer needs forced progress
					self.songProgress = 0
				end
			end
		end
	else
		-- Create music if somehow missing
		if sm.cae_injected then
			self.music = sm.effect.createEffect(self.songData.selectedSong, sm.localPlayer.getPlayer().character)
		else
			self.music = sm.effect.createEffect("Vanilla", sm.localPlayer.getPlayer().character)
		end
	end
	-- Set volume all the time because I can't be bothered with checking when it's changed this has literally 0 performance impact, so whatever
	if sm.cae_injected then
		self.music:setParameter("CAE_Volume", self.songData.volume)
	end
end