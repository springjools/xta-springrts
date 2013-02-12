--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Projectile lights",
    desc      = "Glows them projectiles!",
    author    = "Beherith, Deadnight Warrior",
    date      = "july 2012",
    license   = "GNU GPL, v2 or later",
    layer     = -1,
    enabled   = true  
  }
end

local spGetUnitViewPosition 	= Spring.GetUnitViewPosition
local spGetUnitDefID			= Spring.GetUnitDefID
local spGetGroundHeight			= Spring.GetGroundHeight
local spGetVectorFromHeading	= Spring.GetVectorFromHeading
local spTraceScreenRay			= Spring.TraceScreenRay
local spGetViewGeometry			= Spring.GetViewGeometry
local spGetProjectilesInRectangle = Spring.GetProjectilesInRectangle
local spGetProjectilePosition	= Spring.GetProjectilePosition
local spGetProjectileType		= Spring.GetProjectileType
local spGetProjectileName		= Spring.GetProjectileName
local spGetProjectileVelocity	= Spring.GetProjectileVelocity
local spGetGameFrame 			= Spring.GetGameFrame

local glPushMatrix		= gl.PushMatrix
local glTranslate		= gl.Translate
local glRotate			= gl.Rotate
local glScale			= gl.Scale
local glPopMatrix		= gl.PopMatrix
local glBeginEnd		= gl.BeginEnd
local glVertex			= gl.Vertex
local glTexCoord		= gl.TexCoord
local glTexture			= gl.Texture
local glColor			= gl.Color
local glDepthMask		= gl.DepthMask
local glDepthTest		= gl.DepthTest
local glCallList		= gl.CallList
local glBlending		= gl.Blending
local max				= math.max
local floor				= math.floor
local sqrt				= math.sqrt
local deg				= math.deg
local atan2				= math.atan2

local list      
local plighttable = {}
local BlackList = include("Configs/gfx_projectile_lights_defs.lua")	-- weapons that shouldn't use projectile lights
local noise = {--this is so that it flashes a bit, should be addressed with (x+z)%10 +1
	1.1,
	1.0,
	0.9,
	1.3,
	1.2,
	0.8,
	0.9,
	1.1,
	1.0,
	0.7,
	}
local pieceprojectilecolor={1.0, 1.0, 0.5, 0.25} -- This is the color of piece projectiles, set to nil to disable

listC = gl.CreateList(function()	-- Cannon light decal texture
	glTexture('luaui/images/pointlight.tga') --simple white square with alpha white blurred circle
	glBeginEnd(GL.QUAD_STRIP,function()  
    --point1
    glTexCoord(0.0,0.0)
    glVertex(-4.0,0.0,-4.0)
    --point2                                 
    glTexCoord(0.0,1.0)                           
    glVertex(4.0,0.0,-4.0)                   
    --point3
    glTexCoord(1.0,0.0)
    glVertex(-4.0,0.0,4.0)
    --point4
    glTexCoord(1.0,1.0)
    glVertex(4.0,0.0,4.0)
    end)
end)

listL = gl.CreateList(function()	-- Laser cannon decal texture
	glTexture('luaui/images/neonlight.tga') --simple white square with alpha white blurred rectangle
	glBeginEnd(GL.QUAD_STRIP,function()  
    --point1
    glTexCoord(0.0,0.0)
    glVertex(-2.0,0.0,-4.0)
    --point2                                 
    glTexCoord(0.0,1.0)                           
    glVertex(2.0,0.0,-4.0)                   
    --point3
    glTexCoord(1.0,0.0)
    glVertex(-2.0,0.0,2.0)
    --point4
    glTexCoord(1.0,1.0)
    glVertex(2.0,0.0,2.0)
    end)
end)


function widget:Initialize() -- create lighttable
	local modOptions = Spring.GetModOptions()
	if modOptions and modOptions.lowcpu == "1" then
		Spring.Echo('Low performance mode is on, removing "Projectile lights" widget')
		widgetHandler:RemoveWidget()
	end

	for u=1, #UnitDefs do
		if UnitDefs[u]['weapons'] and #UnitDefs[u]['weapons']>0 then --only units with weapons
			--These projectiles should have lights:
				--Cannon (projectile size: tempsize = 2.0f + std::min(wd.damages[0] * 0.0025f, wd.damageAreaOfEffect * 0.1f);)
				--EmgCannon (only gorg uses it, and lights dont look so good too close to ground)
				--LaserCannon --only sniper uses it, no need to make shot more visible
				--LightningCannon --projectile is centered on emit point
				--Flame --a bit iffy cause of long projectile life... too bad it looks great.
			--Shouldn't:
				--Dgun
				--MissileLauncher
				--StarburstLauncher
				--AircraftBomb
				--BeamLaser --Beamlasers shouldnt, because they are buggy (GetProjectilePosition returns center of beam, no other info avalable)
				--Melee
				--Shield
				--TorpedoLauncher
			for w=1, #UnitDefs[u]['weapons'] do 
				weaponID = UnitDefs[u]['weapons'][w]['weaponDef']
				local wdID = WeaponDefs[weaponID]
				if not BlackList[wdID.name] then 
					if (wdID.type == 'Cannon' or wdID.type == 'EmgCannon') then
						plighttable[wdID.name] = {1.0,1.0,0.5,0.5*((wdID.size-0.65)/3.0)}
					elseif (wdID.type == 'LaserCannon') then
						local colour = wdID.visuals
						plighttable[wdID.name] = {
							colour.colorR, colour.colorG, colour.colorB, 0.6,
							wdID.projectilespeed * wdID.duration, colour.thickness^0.33333}
					--elseif (wdID.type == 'LightningCannon' or wdID.type == 'BeamLaser') then
					--	Bugged for Lightning cannon and Beam Lasers
					--	plighttable[wdID.name]={0.2,0.2,1.0,0.6,true}
					elseif (wdID.type == 'Flame') then
						plighttable[wdID.name]={1.0,0.6,0.3,0.3}  --{0,1,0,0.6}
					end
				end
			end	
		end
	end
end

local sx, sy, px, py = spGetViewGeometry()
function widget:ViewResize(viewSizeX, viewSizeY)
	sx, sy, px, py = spGetViewGeometry()
end

local plist = {}
local frame = 0
local x1, y1 = 0, 0
local x2, y2 = Game.mapSizeX, Game.mapSizeZ
function widget:DrawWorldPreUnit()

	if frame < spGetGameFrame() then
		frame = spGetGameFrame()
	
		local at, p = spTraceScreenRay(sx*0.5,sy*0.5,true,false,false)
		if at=='ground' then
			local cx, cy = p[1], p[3]
			local dcxp1, dcxp3
			local outofbounds = 0
			local d = 0
			--x2=math.min(x2, tl[1])
			--y2=math.min(y2, tl[3])
			
			at, p = spTraceScreenRay(0, 0, true, false, false) --bottom left
			if at=='ground' then
				dcxp1, dcxp3 = cx-p[1], cy-p[3]
				d = max(d, dcxp1*dcxp1 + dcxp3*dcxp3)
			else 
				outofbounds = outofbounds+1
			end
			at, p = spTraceScreenRay(sx-1, 0, true, false, false) --bottom left
			if at=='ground' then
				dcxp1, dcxp3 = cx-p[1], cy-p[3]
				d = max(d, dcxp1*dcxp1 + dcxp3*dcxp3)
			else 
				outofbounds = outofbounds+1
			end
			at, p = spTraceScreenRay(sx-1, sy-1, true, false, false) --bottom left
			if at=='ground' then
				dcxp1, dcxp3 = cx-p[1], cy-p[3]
				d = max(d, dcxp1*dcxp1 + dcxp3*dcxp3)
			else 
				outofbounds = outofbounds+1
			end
			at, p = spTraceScreenRay(0, sy-1, true, false, false) --bottom left
			if at=='ground' then
				dcxp1, dcxp3 = cx-p[1], cy-p[3]
				d = max(d, dcxp1*dcxp1 + dcxp3*dcxp3)
			else 
				outofbounds = outofbounds+1
			end
			if outofbounds>=3 then
				plist = spGetProjectilesInRectangle(x1, y1, x2, y2, false, false) --todo, only those in view or close:P
			else
				d = sqrt(d)
				plist = spGetProjectilesInRectangle(cx-d, cy-d, cx+d, cy+d, false, false) 
			end
		else -- if we are not pointing at ground, get the whole list.
			plist = spGetProjectilesInRectangle(x1, y1, x2, y2, false, false) --todo, only those in view or close:P
		end
	end
		--todo, only those in view or close:P
	--Spring.GetCameraPosition 
	--Spring.GetCameraPosition() -> number x, number y, number z
	--Spring.GetCameraDirection() -> number forward_x, number forward_y, number forward_z
	--Spring.GetCameraFOV( ) -> number fov

	--Spring.Echo('mapview',nplist,outofbounds,d,cx,cy)
	--Spring.Echo('fov',Spring.GetCameraFOV(),Spring.GetCameraPosition())
	if #plist>0 then --dont do anything if there are no projectiles in range of view
		--Spring.Echo('#projectiles:',#plist)
		
		--enabling both test and mask means they wont be drawn over cliffs when obscured
			--but also means that they will flicker cause of z-fighting when scrolling around...
			--and ESPECIALLY when overlapping
		-- mask=false and test=true is perfect, no overlap flicker, no cliff overdraw
			--BUT it clips into cliffs from the side....
		glDepthMask(false)
		--glDepthMask(true)
		glDepthTest(false)
		--glDepthTest(GL.LEQUAL) 
		
		local x, y, z, dx, dz
		--local fx, fy = 32, 32	--footprint
		glBlending("alpha_add") --makes it go into +
		local lightparams
		-- AND NOW FOR THE FUN STUFF!
		for i=1, #plist do
			local pID = plist[i]
			x, y, z = spGetProjectilePosition(pID)
			local wep, piece = spGetProjectileType(pID)
			if piece then
				lightparams = {1.0, 1.0, 0.5, 0.3}
			else
				lightparams = plighttable[spGetProjectileName(pID)]
			end
			if (lightparams and x and y>0) then -- projectile is above water
				--fx = 32
				--fy = 32 --footprint
				local height = max(0, spGetGroundHeight(x, z)) --above water projectiles should show on water surface
				--local diff = height-y	-- this is usually 5 for land units, 5+cruisehieght for others
										-- the plus 5 is do that it doesn't clip all ugly like, unneeded with depthtest and mask both false!
										-- diff is negative, cause we need to put the lighting under it
										-- diff defines size and diffusion rate)
				local factor = max(0.01, (100.0+height-y)*0.01) --factor=1 at when almost touching ground, factor=0 when above 100 height)
				if (factor >= 0.01 and factor < 1.0) then
					glColor(lightparams[1], lightparams[2], lightparams[3], lightparams[4]*factor*factor*noise[floor(x+z+pID)%10+1]) -- attentuation is x^2
					factor = 32*(1.1-max(factor, 0.3)) -- clamp the size
					glPushMatrix()
					glTranslate(x, height+5, z)  -- push in y dir by height (to push it on the ground!), +5 to keep it above surface
					if lightparams[5] then
						dx, _, dz = spGetProjectileVelocity(pID)
						glRotate(deg(atan2(dx,dz)), 0.0, 1.0, 0.0)	-- align laser cannon light with projectile direction
						glScale(factor*lightparams[6], 1.0, factor*lightparams[5]) -- scale it by size
						glCallList(listL) -- draw laser cannon light
					else
						glScale(factor, 1.0, factor) -- scale it by size
						glCallList(listC) -- draw cannon light
					end					
					glPopMatrix()
				end
			end
		end

		glTexture(false) --be nice, reset stuff 
		glColor(1.0, 1.0, 1.0, 1.0)
		glBlending(false)
		glDepthTest(true)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------