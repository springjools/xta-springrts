--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function addon:GetInfo()
  return {
    name      = "Engine Taskbar Stuff",
    desc      = 'Icon, name',
    author    = "KingRaptor",
    date      = "13 July 2011",
    license   = "Public Domain",
    layer     = -math.huge,
    enabled   = true,
  }
end

--------------------------------------------------------------------------------
function addon:Initialize()
	local name = Game.modName
	Spring.SetWMIcon("sidepics/arm.bmp")
	Spring.SetWMCaption(name .. " (Spring " .. (Game.version or 'NT') .. ")", name)
end