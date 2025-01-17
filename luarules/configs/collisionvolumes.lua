--[[  from Spring Wiki and source code, info about CollisionVolumeData
Spring.GetUnitCollisionVolumeData ( number unitID ) -> 
	number scaleX, number scaleY, number scaleZ, number offsetX, number offsetY, number offsetZ,
	number volumeType, number testType, number primaryAxis, boolean disabled

Spring.SetUnitCollisionVolumeData ( number unitID, number scaleX, number scaleY, number scaleZ,
					number offsetX, number offsetY, number offsetX,
					number vType, number tType, number Axis ) -> nil

Spring.SetUnitPieceCollisionVolumeData ( number unitID, number pieceIndex, boolean enabled, number scaleX, number scaleY, number scaleZ,
					number offsetX, number offsetY, number offsetZ, number vType, number Axis) -> nil
	per piece collision volumes always use COLVOL_TEST_CONT as tType
	above syntax is for 0.83, for 0.82 compatibility repeat enabled 3 more times
	
   possible vType constants
     DISABLED = -1  disables collision volume and collision detection for that unit, do not use
     ELLIPSOID = 0  no longer supported since 92.0
     CYLINDER =  1  base must be circular since 92.0
     BOX =       2
     SPHERE =    3
     FOOTPRINT = 4  no longer supported since 92.0
                    intersection of sphere and footprint-prism, makes a sphere collision volume, default
	 
   possible tType constants, for non-sphere collision volumes use 1
     COLVOL_TEST_DISC = 0
     COLVOL_TEST_CONT = 1

   possible Axis constants, use non-zero only for Cylinder test
     COLVOL_AXIS_X = 0
     COLVOL_AXIS_Y = 1
     COLVOL_AXIS_Z = 2

   sample collision volume with detailed descriptions
	unitCollisionVolume["arm_advanced_radar_tower"] = {
		on=            -- Unit is active/open/poped-up 
		   {60,80,60,  -- Volume X scale, Volume Y scale, Volume Z scale,
		    0,15,0,    -- Volume X offset, Volume Y offset, Volume Z offset,
		    0,1,0[,    -- vType, tType, axis [,  -- Optional
			0,0,0,     -- Midpoint X offset, Midpoint Y offset, Midpoint Z offset,   -- (from unit coordinate space 0,0,0)	
			0,0,0]}    -- Aimpoint X offset, Aimpoint Y offset, Aimpoint Z offset]}, -- (from unit coordinate space 0,0,0)
		off={32,48,32,0,-10,0,0,1,0},
	}                  -- Aimpoint offsets are relative to unit's base position (aka unit coordiante space)
	pieceCollisionVolume["arm_big_bertha"] = {
		["0"]={true,       -- [pieceIndexNumber]={enabled,
			   48,74,48,   --            Volume X scale, Volume Y scale, Volume Z scale,
		       0,0,0,      --            Volume X offset, Volume Y offset, Volume Z offset,
			   1,1},       --            vType, axis},   
		....               -- All undefined pieces will be treated as disabled for collision detection
	}
	dynamicPieceCollisionVolume["core_viper"] = {	--same as with pieceCollisionVolume only uses "on" and "off" tables
		on = {
			["0"]={true,51,12,53,0,4,0,2,0},
			["5"]={true,25,66,25,0,-14,0,1,1},
			offsets={0,0,0,    -- Midpoint X offset, Midpoint Y offset, Midpoint Z offset (from unit coordinate space 0,0,0)
					 0,35,0}   -- Aimpoint X offset, Aimpoint Y offset, Aimpoint Z offset (from unit coordinate space 0,0,0)
		},                     -- offsets entry is optional 
		off = {
			["0"]={true,51,12,53,0,4,0,2,0},
			offsets={0,8,0}
		}
	}
	
	Q: How am I supposed to guess the piece index number?
	A: Open the model in UpSpring and locate your piece. Count all pieces above it in the piece tree.
	   Piece index number is equal to number of pieces above it in tree. Root piece has index 0. <==== 1 in spring 101
	   Or start counting from tree top till your piece starting from 0. Count lines in Upspring
	   not along the tree hierarchy.
	Q: I defined all per piece volumes in here but unit still uses only one collision volume!
	A: Edit unit's definition file and add:
		usePieceCollisionVolumes=1;    (FBI)
		usePieceCollisionVolumes=true, (LUA)
	Q: The unit always has on/off volume and it never changes
	A: You need to edit the unit script and set ARMORED status to on or off depending on the
	   unit's on/off status, unarmored for on and armored for off
]]--


--Collision volume definitions, ones entered here are for XTA, for other mods modify apropriatly
local unitCollisionVolume = {}			--dynamic collision volume definitions
local pieceCollisionVolume = {}			--per piece collision volume definitions
local dynamicPieceCollisionVolume = {}	--dynamic per piece collision volume definitions

	--[[
	unitCollisionVolume["arm_advanced_radar_tower"] = {
		on={60,80,60,0,15,0,0,1,0},
		off={32,48,32,0,-10,0,0,1,0},
	}
	]]--
	unitCollisionVolume["arm_advanced_sonar_station"] = {
		on={63,70,63,0,-7,0,1,1,1},
		off={24,40,24,0,-5,0,1,1,1},
	}
	unitCollisionVolume["arm_ambusher"] = {
		on={49,45,49,-0.5,0,0,1,1,1,0,0,0,0,20,0},
		off={49,19,49,-0.5,0,0,1,1,1,0,0,0,0,7,0},
	}
	unitCollisionVolume["arm_annihilator"] = {
		on={50,55,50,0,10,0,2,1,0},
		off={50,35,50,0,0,0,2,1,0},
	}
	unitCollisionVolume["arm_kbot_lab"] = {
		on={90,24,95,0,0,0,2,1,0},
		off={95,18,99,0,-3,0,1,1,1},
	}
	unitCollisionVolume["arm_moho_metal_maker"] = {
		on={60,78,60,0,10,0,1,1,1},
		off={60,50,60,0,-4,0,1,1,1},
	}
	unitCollisionVolume["arm_seaplane_platform"] = {
		on={105,66,105,0,33,0,2,1,0},
		off={105,44,105,0,0,0,2,1,0},
	}
	unitCollisionVolume["arm_solar_collector"] = {
		on={80,77,80,0,0,1,1,1,1,0,0,0,0,20,0},
		off={46,77,46,0,0,1,1,1,1,0,0,0,0,20,0},
	}
	unitCollisionVolume["arm_stunner"] = {
		on={61,28,64,0,-6,0,2,1,0},
		off={43,28,64,0,-6,0,2,1,0},
	}
	unitCollisionVolume["arm_targeting_facility"] = {
		on={62,34,62,0,0,0,2,1,0},
		off={55,78,55,0,-19.5,0,1,1,1},
	}
	unitCollisionVolume["arm_vehicle_plant"] = {
		on={120,34,92,0,15,0,2,1,0,0,0,0,0,20,0},
		off={92,74,92,0,-7,0,1,1,2,0,0,0,0,20,0},
	}
	unitCollisionVolume["core_doomsday_machine"] = {
		on={55,116,55,0,15,0,2,1,0},
		off={45,86,45,0,0,0,2,1,0},
	}
	unitCollisionVolume["core_floating_metal_maker"] = {
		on={48,46,48,0,0,0,0,1,0},
		off={48,43,48,0,-16,0,0,1,0},
	}
	unitCollisionVolume["core_moho_metal_maker"] = {
		on={60,60,60,0,0,0,1,1,1},
		off={50,92,50,0,-22.5,0,1,1,1},
	}
	unitCollisionVolume["core_seaplane_platform"] = {
		on={112,60,112,0,30,0,1,1,1},
		off={112,40,112,0,0,0,1,1,1},
	}
	unitCollisionVolume["core_solar_collector"] = {
		on={76,48,76,0,0,0,1,1,1,0,0,0,0,20,0},
		off={65,27,65,0,0,0,1,1,1,0,0,0,0,12,0},
	}
	unitCollisionVolume["core_targeting_facility"] = {
		on={64,20,64,0,0,0,1,1,1},
		off={38,20,38,0,0,0,1,1,1},
	}
	unitCollisionVolume["core_toaster"] = {
		on={44,23,44,0,12,0,2,1,0,0,0,0,0,21,0},
		off={44,8,44,0,4,0,2,1,0,0,0,0,0,4,0},
	}
	
	unitCollisionVolume["lost_whale"] = {
		on=	{
				46,30,95, 			-- scale x,y,z
				0,-8,3,				-- offset x,y,z
				2,1,2,				-- vType, tType, axis
				0,-2,0,				-- midpos x,y,z
				0, 0, 0,			-- aimpos x,y,z
			},
		off={
				46,35,95,
				0,10,3,
				2,1,2,
				0,25,0,
				0,0,0,
			},
	}
	pieceCollisionVolume["arm_big_bertha"] = {
		["base"]={28,74,28,0,34,0,1,1},
		["sleeve"]={15,15,113,0,0,30,1,2},
	}
	--pieceCollisionVolume["arm_commander"] = {
	--	["0"]={true,28,74,28,0,34,0,1,1},
	--}	
--	pieceCollisionVolume["arm_vulcan"] = {
--		["base"]={60,94,60,0,47,-1,1,1},
--		["spindle"]={36,36,106,0,0,27,1,2},
--	}

	dynamicPieceCollisionVolume["arm_advanced_radar_tower"] = {
		on = {
			["base"]={25,45,25,0,22,0,1,1},
			["turret"]={76,29,29,0,3,0,1,0},
		},
		off = {
			["base"]={32,51,32,0,8,1,1,1},
		}
	}
	dynamicPieceCollisionVolume["core_viper"] = {
		on = {
			["base"]={51,12,53,0,4,0,2,0},
			["stand"]={25,66,25,0,-14,0,1,1},
			offsets={0,0,0,0,40,0}
		},
		off = {
			["base"]={51,12,53,0,4,0,2,0},
			offsets={0,0,0,0,8,0}
		}
	}
	dynamicPieceCollisionVolume["core_krogoth_gantry"] = {
		on = {
			["base"]={142,77,136,0,0,0,1,2},
			["crane"]={108,49,108,0,14,36,1,2},
		},
		off = {
			["base"]={142,77,136,0,0,0,1,2},
		}

	}
return unitCollisionVolume, pieceCollisionVolume, dynamicPieceCollisionVolume