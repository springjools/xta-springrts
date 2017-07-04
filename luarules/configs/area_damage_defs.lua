local array = {}

local DAMAGE_PERIOD = 2 -- how often damage is applied

local weapons = {
	whiteriot = { radius = 128, damage = 110, duration = 60, rangeFall = 0.5, timeFall = 0.5},
	rifterboy = { radius = 128, damage = 100, duration = 60, rangeFall = 0.45, timeFall = 0.6}
}

-- radius		- defines size of sphereical area in which damage is dealt
-- damage		- maximun damage over 1 second that can be dealt to a unit
-- duration		- how long the area damage stays around for (in frames)
-- rangeFall	- the proportion of damage not dealt increases linearly with distance from 0 to rangeFall at the radius
-- timeFall		- the proportion of damage not dealt increases linearly with elapsed time from 0 to timeFall at the duration

local presets = {
	--module_napalmgrenade = { radius = 256, damage = 20, duration = 1400, rangeFall = 0.6, timeFall = 0.5 },
}

------------------------
-- Send the Config

for name,data in pairs(WeaponDefNames) do
	if data.customParams.areadamage_preset then
		weapons[name] = Spring.Utilities.CopyTable(presets[data.customParams.areadamage_preset])
	end
	if weapons[name] then
		weapons[name].damage = weapons[name].damage *DAMAGE_PERIOD/30
		weapons[name].timeLoss = weapons[name].damage*weapons[name].timeFall*DAMAGE_PERIOD/weapons[name].duration
		array[data.id] = weapons[name]
	end
end

return DAMAGE_PERIOD, array
