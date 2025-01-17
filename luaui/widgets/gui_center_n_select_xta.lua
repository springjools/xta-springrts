function widget:GetInfo()
  return {
    name      = "Select n Center! - XTA",
    desc      = "Selects and centers the Commander at the start of the game.",
    author    = "quantum", --modified by Deadnight Warrior for mission script compatibility
    date      = "22/06/2007",
    license   = "GNU GPL, v2 or later",
    layer     = 5,
    enabled   = true  --  loaded by default?
  }
end
local center = true
local select = true
local unitList = {}
local ZOOMHEIGHT = 1600

local commanders = {
	UnitDefNames["arm_commander"].id,
	UnitDefNames["arm_decoy_commander"].id,
	UnitDefNames["arm_u0commander"].id,
	UnitDefNames["arm_ucommander"].id,
	UnitDefNames["arm_u2commander"].id,
	UnitDefNames["arm_u3commander"].id,
	UnitDefNames["arm_u4commander"].id,
	UnitDefNames["arm_scommander"].id,
	UnitDefNames["arm_base"].id,
	UnitDefNames["arm_nincommander"].id,
	UnitDefNames["core_commander"].id,
	UnitDefNames["core_decoy_commander"].id,
	UnitDefNames["core_u0commander"].id,
	UnitDefNames["core_ucommander"].id,
	UnitDefNames["core_u2commander"].id,
	UnitDefNames["core_u3commander"].id,
	UnitDefNames["core_u4commander"].id,
	UnitDefNames["core_scommander"].id,
	UnitDefNames["core_base"].id,
	UnitDefNames["core_nincommander"].id,
}

function widget:Update()
	local t = Spring.GetGameSeconds()
	if t > 2 then
		widgetHandler:RemoveWidget()
		return
	end
	if center and t > 0 then
		--Spring.Echo("center")
		unitList = Spring.GetTeamUnitsByDefs(Spring.GetMyTeamID(), commanders)
		if #unitList == 0 then
			unitList = Spring.GetTeamUnits(Spring.GetMyTeamID())
		end
		local x, y, z = Spring.GetUnitPosition(unitList[1])
		local camState = Spring.GetCameraState()
		local currentHeight = camState["py"]
		camState["px"] = x
		camState["py"] = y
		camState["pz"] = z
		camState["py"] = ZOOMHEIGHT/2
		camState["name"] = 'ta'
		camState["mode"] = 1
		--if currentHeight > ZOOMHEIGHT then
		Spring.SetCameraState(camState,0.5)
		--end

		center = false
	end
	if select and t > 0 then
		--Spring.Echo("select")
		Spring.SelectUnitArray({unitList[1]})
		select = false
	end
end

function widget:Initialize()
	if Spring.GetSpectatingState() or Spring.IsReplay() then
		widgetHandler:RemoveWidget()
	end
end
