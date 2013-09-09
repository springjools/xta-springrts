
function gadget:GetInfo()
  return {
    name      = "Local sounds",
    desc      = "Make sounds local based on LOS",
	version   = "1.41",
    author    = "Jools",
    date      = "Sep, 2013",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true,  --  loaded by default?
  }
end

-- v1.4 
-- add flood limit for created projectile and explosion events to be sent to unsynced

-- shared synced/unsynced globals
LUAUI_DIRNAME							= 'LuaUI/'
local random  = math.random
local abs = math.abs
local Echo = Spring.Echo

local LUAMESSAGE = 	"20121120"

local loopWeapons = {
	Flame = true,
	BeamLaser = true,
}

if gadgetHandler:IsSyncedCode() then
	-----------------
	-- SYNCED PART --
	-----------------

	local SetWatchWeapon 		= Script.SetWatchWeapon
	local IsPosInLos			= Spring.IsPosInLos
	local GetProjectilePosition	= Spring.GetProjectilePosition
	local GetGroundHeight 		= Spring.GetGroundHeight
	local GetPlayerInfo			= Spring.GetPlayerInfo
	local len 					= string.len
	local sub 					= string.sub
	local activeShooters 		= {}
	local activeExplosions		= {}
	local GetGameFrame			= Spring.GetGameFrame
	
	function gadget:Initialize()	
		local modOptions = Spring.GetModOptions()
		
		if modOptions and modOptions.globalsounds == '1' then
			Echo("[" .. (self:GetInfo()).name .. "] local sounds disabled")
			gadgetHandler:RemoveGadget(self)
			return
		end
		
		for id,weaponDef in pairs(WeaponDefs) do
			if weaponDef.customParams then				
				SetWatchWeapon(weaponDef.id, true)
			end
		end
	end
	
	function gadget:ProjectileCreated(projectileID, projectileOwnerID, projectileWeaponDefID)
		-- flood protection to not send too many events to unsynced
		
		local wd = WeaponDefs[projectileWeaponDefID]
		if not wd then return end
		
		local wType = wd.type
		
		if wType then
			if loopWeapons[wType] then
				local frame = GetGameFrame()
				local lastshot = activeShooters[projectileOwnerID]
				
				if lastshot then
					local beamtime = wd.beamtime
					if lastshot+beamtime*30 + 1 < frame then 
						activeShooters[projectileOwnerID] = nil 
					end
				end
				
				lastshot = activeShooters[projectileOwnerID]
				if not lastshot then
					local x,y,z = GetProjectilePosition(projectileID)
					SendToUnsynced("LS_ProjectileCreated", projectileID, projectileOwnerID, projectileWeaponDefID, x,y,z)
					activeShooters[projectileOwnerID] = frame
				end
			else --not loopweapons
				local x,y,z = GetProjectilePosition(projectileID)
				SendToUnsynced("LS_ProjectileCreated", projectileID, projectileOwnerID, projectileWeaponDefID, x,y,z)
			end
		else
			Echo("No wtype for:",wd.name)
		end
	end

	function gadget:Explosion(weaponDefID, posx, posy, posz, ownerID)
		
		if ownerID then
			local frame = GetGameFrame()
			local lastexp = activeExplosions[ownerID]
			
			if lastexp then
				local floodlimit = 3.6 	-- in frames, change according to how metallic you want the dgun to sound :)
										-- but this also affects other weapons such as anni beam (although that has 
										-- no explosion sound ATM)
				
				if lastexp + floodlimit < frame then 
					activeExplosions[ownerID] = nil 
				end
			end
			
			lastexp = activeExplosions[ownerID]
			if not lastexp then
				local h = GetGroundHeight(posx,posz)
				SendToUnsynced("LS_ProjectileExplosion", weaponDefID, posx, posy, posz, ownerID, h)
				activeExplosions[ownerID] = frame
			end
		else
			local h = GetGroundHeight(posx,posz)
			SendToUnsynced("LS_ProjectileExplosion", weaponDefID, posx, posy, posz, ownerID, h)
		end
		
		return false -- noGFX
	end
		
	function gadget:Shutdown()
		for id,weaponDef in pairs(WeaponDefs) do
			if (weaponDef ~= nil) then
				SetWatchWeapon(weaponDef.id, false)
			end
		end
	end
	
	function gadget:PlayerAdded(playerID) 
		Echo("Player added:", playerID) -- doesn't seem to work
	end
	
	function gadget:TeamDied(teamID)
		SendToUnsynced("LS_TeamDied", teamID)
	end
		
else
	-------------------
	-- UNSYNCED PART --
	-------------------
	
	local GetLocalPlayerID				= Spring.GetLocalPlayerID
	local SendLuaRulesMsg				= Spring.SendLuaRulesMsg
	local PlaySoundFile					= Spring.PlaySoundFile
	local IsPosInLos					= Spring.IsPosInLos
	local GetLocalAllyTeamID			= Spring.GetLocalAllyTeamID
	local GetSpectatingState			= Spring.GetSpectatingState
	local len 							= string.len
	local tainsert						= table.insert
	local taremove						= table.remove
	local clientIsSpec					
	local GetGameFrame					= Spring.GetGameFrame
	
	local sndwet = {}
	local snddry = {}
	local sndstart = {}
	local sndlava =	{}
	
	local pID
	local allyID
	local Channel 						= 'battle'
	local volume 						= 3.0
	local shallowLimit 					= -25
	local shallowHitLimit				= -5
	local isLava						= false
	
	local nonexplosiveWeapons = {
		LaserCannon = true,
		BeamLaser = true,
		LightningCannon = true,
		DGun = true,
		Flame = true,
	}
	
	local explosiveWeapons = {
		MissileLauncher = true,
		StarburstLauncher = true,
		TorpedoLauncher = true,
		Cannon = true,
		AircraftBomb = true,
	}


	local function LS_ProjectileCreated(_, projectileID, projectileOwnerID, projectileWeaponDefID,x,y,z)		
		local LOS = clientIsSpec or IsPosInLos(x,y,z,allyID)
		if LOS and projectileWeaponDefID and sndstart[projectileWeaponDefID] then
			PlaySoundFile("sounds/"..sndstart[projectileWeaponDefID]..".wav",volume,x,y,z,0,0,0,Channel)
		end
		return true
	end
	
	local function LS_ProjectileExplosion(_, weaponDefID, x, y, z, ownerID, gh)
		-- This part determines what sound the explosion will play. In the following, the variable y is the height coordinate of 
		-- the projectile, whereas gh is that of the ground height. The wet sound is typically a splash sound, but we don't want splash 
		-- sounds in the following cases: i) explosion above water level ii) explosion very deep, like from torpedoes. If something hits 
		-- shallow water, we want both splash and land explosion. 
		
		local LOS = clientIsSpec or IsPosInLos(x,y,z,allyID)
		if LOS and weaponDefID then		
			if gh >= 0 then -- explosion on land
				if snddry[weaponDefID] then PlaySoundFile("sounds/"..snddry[weaponDefID]..".wav",volume,x,y,z,0,0,0,Channel) end
				--Echo("Land")
			else -- explosion on water
				if y > 0 then -- hits something above water level, use dry sounds
					if snddry[weaponDefID] then PlaySoundFile("sounds/"..snddry[weaponDefID]..".wav",volume,x,y,z,0,0,0,Channel) end
					--Echo("On water but above water level")
				else -- hits under or on water surface
					if isLava then
						--Echo("Lava hit",sndlava[weaponDefID])
						if snddry[weaponDefID] then PlaySoundFile("sounds/"..snddry[weaponDefID]..".wav",volume/3,x,y,z,0,0,0,Channel) end
						if sndlava[weaponDefID] then PlaySoundFile("sounds/"..sndlava[weaponDefID]..".wav",volume,x,y,z,0,0,0,Channel) end
					else
						--Echo("water hit",sndwet[weaponDefID])
						if y > shallowHitLimit then -- projectile hits close to surface
							if gh > shallowLimit then -- water is shallow
								--Echo("Shallow water")
								if snddry[weaponDefID] then PlaySoundFile("sounds/"..snddry[weaponDefID]..".wav",volume/2,x,y,z,0,0,0,Channel) end
								if sndwet[weaponDefID] then PlaySoundFile("sounds/"..sndwet[weaponDefID]..".wav",volume/2,x,y,z,0,0,0,Channel) end
								
							else -- hits deep water
								--Echo("Deep water")
								if sndwet[weaponDefID] then PlaySoundFile("sounds/"..sndwet[weaponDefID]..".wav",volume,x,y,z,0,0,0,Channel) end
							end
						else -- projectile hits at a depth, ideally, there would be another type of explosion sound in this case. However,
							-- this is already considered in weapon explosions, for example the wet sound of torpedoes is xplodep2, which is
							-- a deep water sound. We still use standard wet sounds, this division is kept for future needs.
							if sndwet[weaponDefID] then PlaySoundFile("sounds/"..sndwet[weaponDefID]..".wav",volume,x,y,z,0,0,0,Channel) end
						end
					end
				end
			end
		end
		return true
	end
	
	local function TeamDied(_, teamID)
		clientIsSpec = GetSpectatingState()
		return true
	end
	
	function gadget:Initialize()
	
		local modOptions = Spring.GetModOptions()
		
		if modOptions and modOptions.globalsounds == '1' then
			Echo("[" .. (self:GetInfo()).name .. "] local sounds disabled")
			gadgetHandler:RemoveGadget(self)
			return
		end
		
		local waterColour = Game.waterBaseColor
		if waterColour and waterColour[1] > waterColour[3] then -- primitive check: more red than blue means lava
			isLava = true
		end
			
		pID = GetLocalPlayerID()
		allyID = GetLocalAllyTeamID()
		clientIsSpec = GetSpectatingState()
		
		gadgetHandler:AddSyncAction('LS_ProjectileCreated', LS_ProjectileCreated)
		gadgetHandler:AddSyncAction('LS_ProjectileExplosion', LS_ProjectileExplosion)
		gadgetHandler:AddSyncAction('LS_TeamDied', TeamDied)
			
		--get weapon sounds from customparams
		for id, weaponDef in pairs(WeaponDefs) do
			if (weaponDef.customParams ~= nil) then
				local aoe = weaponDef.damageAreaOfEffect
				
				local wType = weaponDef.type
				local vel = weaponDef.startvelocity
				local damage = weaponDef.damages[1]
				
				if isLava then
					if nonexplosiveWeapons[wType] then
						if damage and damage > 100 then
							sndlava[id] = 'lavaloop1'
						end
					elseif explosiveWeapons[wType] then
						if damage and damage > 50 then
							if damage < 80 then
								sndlava[id] = 'magma1'
							elseif damage < 120 then
								sndlava[id] = 'magma2'
							elseif damage < 200 then
								sndlava[id] = 'magma3'
							elseif damage < 350 then
								sndlava[id] = 'magma4'
							elseif damage < 750 then
								sndlava[id] = 'lavaeruption1'
							elseif damage >= 750 then
								sndlava[id] = 'lavaeruption2'
							end
						end
					end
					--Echo("Lava sound for: ", id, weaponDef.name, wType, damage, sndlava[id])
				else
					if weaponDef.customParams.soundhitwet and len(weaponDef.customParams.soundhitwet) > 0 then
						sndwet[id] = weaponDef.customParams.soundhitwet
						--Echo("Wet sound for:", id, weaponDef.name, ":", sndwet[id])
					else
						--Echo("Local sounds: no soundhitwet sound: ", weaponDef.name)
					end
				end
				if weaponDef.customParams.soundhitdry and len(weaponDef.customParams.soundhitdry) > 0 then
					snddry[id] = weaponDef.customParams.soundhitdry
					--Echo("Dry sound for:", id, weaponDef.name, ":", snddry[id])
				else
					--Echo("Local sounds: no soundshitdry sound: ", weaponDef.name)
				end
				if weaponDef.customParams.soundstart and len(weaponDef.customParams.soundstart) > 0 then
					sndstart[id] = weaponDef.customParams.soundstart
					--Echo("Start sound for:", id, weaponDef.name, ":", sndstart[id])
				else
					--Echo("Local sounds: no soundstart sound: ", weaponDef.name)
				end
			end
			--end
		end
		
		--[[ Make a soundcheck of the available sounds
		local vol = 0
		--Echo("Loading sounds:", Spring.LoadSoundDef("gamedata/sounds.lua"))
		for i, snd in pairs(sndstart) do
			--Echo("Testing start sound:",i,snd)
			PlaySoundFile("sounds/" .. snd .. ".wav",vol,0,0,0,0,0,0,Channel)
		end
		for i, snd in pairs(sndwet) do
			--Echo("Testing wet sound:",i,snd)
			PlaySoundFile("sounds/" .. snd .. ".wav",vol,0,0,0,0,0,0,Channel)
		end
		for i, snd in pairs(snddry) do
			--Echo("Testing dry sound:",i,snd)
			PlaySoundFile("sounds/" .. snd .. ".wav",vol,0,0,0,0,0,0,Channel)
		end
		for i, snd in pairs(sndlava) do
			--Echo("Testing lava sound:",i,snd)
			PlaySoundFile("sounds/" .. snd .. ".wav",vol,0,0,0,0,0,0,Channel)
		end
		--]]
		
	end
		
end
