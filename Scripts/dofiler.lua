---@diagnostic disable: undefined-global, duplicate-set-field

local worldClasses = {
    BaseWorld,
    CreativeBaseWorld,
    Overworld,
    WarehouseWorld,
    World,
    CreativeTerrainWorld,
    CreativeFlatWorld,
    CreativeCustomWorld,
    ClassicCreativeTerrainWorld,
}
local raids = {}
sm.customRaidMusic.raids = raids

if not sm.customRaidMusic.hookedWorld then
    for _, v in pairs(worldClasses) do
		local v_sv_e_spawnRaiders = v.sv_e_spawnRaiders
		if v_sv_e_spawnRaiders then
			function v:sv_e_spawnRaiders(params)
				raids[#raids+1] = {
					attackPos = params.attackPos,
					endTick = nil,
					raiders = {}
				}
				local oldCreateUnit = sm.unit.createUnit
				sm.unit.createUnit = function(uuid, feetPos, yaw, data, pitch)
					local currentRaid = raids[#raids]
					table.insert(currentRaid.raiders, oldCreateUnit(uuid, feetPos, yaw, data, pitch))
					if not currentRaid.endTick then
						currentRaid.endTick = data.deathTick
					end
				end
				v_sv_e_spawnRaiders(v, params)
				sm.unit.createUnit = oldCreateUnit
			end
		end
    end
    sm.customRaidMusic.hookedWorld = true
end

if UnitManager then
	--[[
	Client data is useless, since it's just data from the server and not even all of it

	local v_cl_onWorldUpdate = UnitManager.cl_onWorldUpdate
	function UnitManager:cl_onWorldUpdate(worldSelf, deltaTime)
		v_cl_onWorldUpdate(self, worldSelf, deltaTime)
		if not sm.customRaidMusic.UM_ClSelf then
			sm.customRaidMusic.UM_ClSelf = self
		end
	end
	]]
	local v_sv_onFixedUpdate = UnitManager.sv_onFixedUpdate
	function UnitManager:sv_onFixedUpdate()
		v_sv_onFixedUpdate(self)
		if not sm.customRaidMusic.UM_SvSelf then
			sm.customRaidMusic.UM_SvSelf = self
		end
	end
end