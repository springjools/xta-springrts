
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Unit Build Priority Handler",
    desc      = "Adds a button that sets the build priority for builders",
    author    = "raaar, based on production speed gadget by CAKE",
    date      = "feb 2016",
    license   = "GNU GPL, v2 or later",
    layer     = 3,
    enabled   = true
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--Speed-ups

local spGetUnitDefID    = Spring.GetUnitDefID
local spGetUnitCommands = Spring.GetUnitCommands
local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spSetUnitBuildSpeed = Spring.SetUnitBuildSpeed
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc
local spRemoveUnitCmdDesc = Spring.RemoveUnitCmdDesc
local spGetUnitResources = Spring.GetUnitResources
local spGetTeamResources = Spring.GetTeamResources
local spGetUnitTeam = Spring.GetUnitTeam
local spGetGameFrame = Spring.GetGameFrame
local spGetUnitIsBuilding = Spring.GetUnitIsBuilding

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

CMD_BUILDPRIORITY = 33455

local buildSpeedList = {}
local buildPriorityList = {}
local haltedList = {}
local builderNames = {}

local highPriorityNames = {
	arm_commander = true,
	core_commander = true
}

local buildPriorityCmdDesc = {
	id      = CMD_BUILDPRIORITY,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Production',
	cursor  = 'Production',
	action  = 'Production',
	tooltip = 'Orders: Production Priority',
	params  = { '0', 'Normal', 'High'}
}
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function addBuildPriorityCmdDesc(unitID)
	if (spFindUnitCmdDesc(unitID, CMD_BUILDPRIORITY)) then
		return  -- already exists
	end
	local insertID = 
		spFindUnitCmdDesc(unitID, CMD.CLOAK)      or
		spFindUnitCmdDesc(unitID, CMD.ONOFF)      or
		spFindUnitCmdDesc(unitID, CMD.TRAJECTORY) or
		spFindUnitCmdDesc(unitID, CMD.REPEAT)     or
		spFindUnitCmdDesc(unitID, CMD.MOVE_STATE) or
		spFindUnitCmdDesc(unitID, CMD.FIRE_STATE) or
		123456 -- back of the pack
	buildPriorityCmdDesc.params[1] = '1'
	spInsertUnitCmdDesc(unitID, insertID + 1, buildPriorityCmdDesc)
end


local function updateButton(unitID, statusStr)
	local cmdDescID = spFindUnitCmdDesc(unitID, CMD_BUILDPRIORITY)
	if (cmdDescID == nil) then
		return
	end

	local tooltip
	if (statusStr == '1') then
		tooltip = 'Builder Resource Access: High Priority'
	else
		tooltip = 'Builder Resource Access: Normal priority (halts construction if low on resources)'
	end

	buildPriorityCmdDesc.params[1] = statusStr

	spEditUnitCmdDesc(unitID, cmdDescID, { 
		params  = buildPriorityCmdDesc.params, 
		tooltip = tooltip,
	})
end


local function buildPriorityCommand(unitID, unitDefID, cmdParams, teamID)
	local ud = UnitDefs[unitDefID]
	if (builderNames[ud.name]) then

		local status
		if cmdParams[1] == 1 then
			status = '1'
			-- Spring.Echo("priority HIGH")
			buildPriorityList[unitID] = 1
		else
			status = '0'
			-- Spring.Echo("priority NORMAL")
			buildPriorityList[unitID] = 0
		end
		updateButton(unitID, status)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
	for _,ud in pairs(UnitDefs) do
		if ud.isBuilder then
			builderNames[ud.name] = true	
		end
	end

	gadgetHandler:RegisterCMDID(CMD_BUILDPRIORITY)
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = spGetUnitTeam(unitID)
		local unitDefID = spGetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
  local ud = UnitDefs[unitDefID]
  if (builderNames[ud.name]) then
    buildSpeedList[unitID] = ud.buildSpeed

	-- set starting priority
	local priority = 0
	if highPriorityNames[ud.name] or ud.customParams.iscommander then
		priority = 1
	end
    buildPriorityList[unitID] = priority
    
    addBuildPriorityCmdDesc(unitID)
    updateButton(unitID, ''..priority)
  end
end

function gadget:UnitDestroyed(unitID, _, teamID)
  buildSpeedList[unitID] = nil
  buildPriorityList[unitID] = nil
  haltedList[unitID] = nil
end



function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, _)
	local returnvalue
	if cmdID ~= CMD_BUILDPRIORITY then
		return true
	end
	buildPriorityCommand(unitID, unitDefID, cmdParams, teamID)  
	return false
end

function gadget:Shutdown()
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local cmdDescID = spFindUnitCmdDesc(unitID, CMD_BUILDPRIORITY)
		if (cmdDescID) then
			spRemoveUnitCmdDesc(unitID, cmdDescID)
		end
	end
end

function gadget:GameFrame(n)
	if (n%30 == 0) then
		local stallingM = 0
		local stallingE = 0
		local teamID = 0
		local stallingMByTeam = {}
		local stallingEByTeam = {}
		local metalMake,metalUse,energyMake,energyUse = 0
			
		-- set build speeds according to priority
		for unitID,_ in pairs(buildSpeedList) do
			priority = buildPriorityList[unitID] or 0
			
			stallingM = 0
			stallingE = 0
			teamID = spGetUnitTeam(unitID)
			if stallingMByTeam[teamID] == nil or stallingEByTeam[teamID] == nil then
				local currentLevelM,storageM,_,incomeM,expenseM,_,_,_ = spGetTeamResources(teamID,"metal")
				local currentLevelE,storageE,_,incomeE,expenseE,_,_,_ = spGetTeamResources(teamID,"energy")
				
				if currentLevelM < 50 then -- and incomeM < expenseM then
					stallingM = 1
				end
				if currentLevelE < 400 then -- and incomeE < expenseE then
					stallingE = 1
				end
				stallingMByTeam[teamID] = stallingM
				stallingEByTeam[teamID] = stallingE
			else
				stallingM = stallingMByTeam[teamID] 
				stallingE = stallingEByTeam[teamID]
			end	
	
			-- Spring.Echo(UnitDefs[spGetUnitDefID(unitID)].name.." stallingM="..stallingM.." stallingE="..stallingE)
	
			-- if set to high priority, build normally
			if (priority == 1) then
				spSetUnitBuildSpeed(unitID, buildSpeedList[unitID]*1)
				haltedList[unitID] = nil
			else
				metalMake,metalUse,energyMake,energyUse = spGetUnitResources(unitID)
				
				-- if not, build normally only if not stalling in either energy or metal
				if spGetUnitIsBuilding(unitID) == nil or (stallingM == 0 and stallingE == 0) then
					-- Spring.Echo("unit "..UnitDefs[spGetUnitDefID(unitID)].name.." builds at max rate")
					spSetUnitBuildSpeed(unitID, buildSpeedList[unitID]*1)
					haltedList[unitID] = nil
				else
					-- Spring.Echo("unit "..UnitDefs[spGetUnitDefID(unitID)].name.." stops production")
					spSetUnitBuildSpeed(unitID, buildSpeedList[unitID]*0.01) -- tiny fraction to keep metal usage > 0 and prevent decay
					haltedList[unitID] = 1
				end
			end
		end
	else
		-- this is here halt nano-stream visuals (also lowers resource usage a bit more)
		for unitID,_ in pairs(haltedList) do
			spSetUnitBuildSpeed(unitID, buildSpeedList[unitID]*0.0)
		end		
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
