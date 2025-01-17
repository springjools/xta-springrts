local unitName = "critter_gull"

unitDef = {
name                = "Goose",
description         = "I fuck in sky",
objectName          = [[critter_gull.s3o]],
script              = [[critter_gull.lua]],
iconType = "blank",
bmcode              = [[1]],

builder             = false,
buildPic            = [[placeholder.png]],
buildTime           = 10,
----cost
buildCostEnergy     = 0,
buildCostMetal      = 1,
----health
maxDamage           = 10,
idleAutoHeal        = 0,
----movement
maxVelocity         = 4,
maxWaterDepth		= 2000,
minWaterDepth       = 0,
acceleration        = 0.2,
brakeRate           = 3.75,
moverate1           = [[3]],
footprintx          = 1,
footprintZ          = 1,
Upright 			= false,
maneuverleashlength = 1280,
collide             = false,
collision 			= false,
steeringmode        = [[1]],
TEDClass            = [[VTOL]],
turnRate            = 500,
turnRadius		  	= 5,
----aircraft related
canFly              = true,
floatOnWater 		= true,
floater 			= true,
cruiseAlt           = 200,
hoverAttack         = true,
airStrafe			= false,
bankscale           = 1,
maxBank				= 0.2,
maxPitch			= 0.2,
stealth 			  = true,
sonarStealth		  = true,
sightDistance       = 0,
canGuard            = true,
canMove             = true,
canPatrol           = true,
canAttack			= true,
canstop             = [[1]],
category            = [[VTOL]],
mass                = 125,
}

return lowerkeys({ [unitName] = unitDef })