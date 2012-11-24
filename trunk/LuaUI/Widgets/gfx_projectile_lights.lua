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

local glPushMatrix				= gl.PushMatrix
local glTranslate				= gl.Translate
local glRotate					= gl.Rotate
local glScale					= gl.Scale
local glPopMatrix				= gl.PopMatrix
local glBeginEnd				= gl.BeginEnd
local glVertex					= gl.Vertex
local glTexCoord				= gl.TexCoord
local glTexture					= gl.Texture
local glColor					= gl.Color
local glDepthMask				= gl.DepthMask
local glDepthTest				= gl.DepthTest
local glCallList				= gl.CallList
local max						= math.max
local floor						= math.floor
local sqrt						= math.sqrt
local deg						= math.deg
local atan2						= math.atan2

local udefTab					= UnitDefs

local list      
local plighttable ={}
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
local pieceprojectilecolor={1.0,1.0,0.5,0.25} -- This is the color of piece projectiles, set to nil to disable

listC = gl.CreateList(function()	-- Cannon light decal texture
	glBeginEnd(GL.QUAD_STRIP,function()  
    --point1
    glTexCoord(0,0)
    glVertex(-4,0,-4)
    --point2                                 
    glTexCoord(0,1)                           
    glVertex(4,0,-4)                   
    --point3
    glTexCoord(1,0)
    glVertex(-4,0,4)
    --point4
    glTexCoord(1,1)
    glVertex(4,0,4)
    end)
end)

listL = gl.CreateList(function()	-- Laser cannon decal texture
	glBeginEnd(GL.QUAD_STRIP,function()  
    --point1
    glTexCoord(0,0)
    glVertex(-2,0,-10)
    --point2                                 
    glTexCoord(0,1)                           
    glVertex(2,0,-10)                   
    --point3
    glTexCoord(1,0)
    glVertex(-2,0,4)
    --point4
    glTexCoord(1,1)
    glVertex(2,0,4)
    end)
end)


function widget:Initialize() -- create lighttable
	local modOptions = Spring.GetModOptions()
	if modOptions and modOptions.lowcpu == "1" then
		Spring.Echo("Low performance mode is on, removing widget")
		widgetHandler:RemoveWidget()
	end

	--The GetProjectileName function returns 'unitname_weaponnname'. EG: armcom_armcomlaser
	-- This is fine with BA, because unitnames dont use '_' characters
	--Spring.Echo('init')
	for u=1,#UnitDefs do
		if UnitDefs[u]['weapons'] and #UnitDefs[u]['weapons']>0 then --only units with weapons
			--These projectiles should have lights:
				--Cannon (projectile size: tempsize = 2.0f + std::min(wd.damages[0] * 0.0025f, wd.damageAreaOfEffect * 0.1f);)
				--EmgCannon (only gorg uses it, and lights dont look so good too close to ground)
				--LaserCannon --only sniper uses it, no need to make shot more visible
				--LightningCannon --projectile is centered on emit point
			--Shouldnt:
				--Dgun
				--MissileLauncher
				--StarburstLauncher
				--AircraftBomb
				--BeamLaser --Beamlasers shouldnt, because they are buggy (GetProjectilePosition returns center of beam, no other info avalable)
				--Melee
				--Shield
				--TorpedoLauncher
				--Flame --a bit iffy cause of long projectile life... too bad it looks great.

			for w=1,#UnitDefs[u]['weapons'] do 
				local size
				--Spring.Echo(UnitDefs[u]['weapons'][w]['weaponDef'])
				weaponID=UnitDefs[u]['weapons'][w]['weaponDef']
				--Spring.Echo(UnitDefs[u]['name']..'_'..WeaponDefs[weaponID]['name'])
				--WeaponDefs[weaponID]['name'] returns: armcom_armcomlaser
				if (WeaponDefs[weaponID]['type'] == 'Cannon' or WeaponDefs[weaponID]['type'] == 'EmgCannon') then
					--Spring.Echo('Cannon',WeaponDefs[weaponID]['name'],'size', WeaponDefs[weaponID]['size'])
					size=WeaponDefs[weaponID]['size']
					plighttable[WeaponDefs[weaponID]['name']]={1.0,1.0,0.5,0.5*((size-0.5)/3.0)}
				
				elseif (WeaponDefs[weaponID]['type'] == 'LaserCannon') then
					local colour = WeaponDefs[weaponID].visuals
					--Spring.Echo(colour)
					plighttable[WeaponDefs[weaponID]['name']]={colour.colorR,colour.colorG,colour.colorB,0.6,true}  --{0,1,0,0.6}
				
				elseif (WeaponDefs[weaponID]['type'] == 'LightningCannon') then
					--Spring.Echo('LightningCannon',WeaponDefs[weaponID]['name'],'size', WeaponDefs[weaponID]['size'])
					--size=WeaponDefs[weaponID]['size']
					plighttable[WeaponDefs[weaponID]['name']]={0.2,0.2,1.0,0.6,true}

				elseif (WeaponDefs[weaponID]['type'] == 'Flame') then
					--local colour = WeaponDefs[weaponID].visuals
					--Spring.Echo(colour)
					plighttable[WeaponDefs[weaponID]['name']]={1.0,0.6,0.3,0.3}  --{0,1,0,0.6}
				--[[
				elseif (WeaponDefs[weaponID]['type'] == 'Dgun') then
					--Spring.Echo('Dgun',WeaponDefs[weaponID]['name'],'size', WeaponDefs[weaponID]['size'])
					--size=WeaponDefs[weaponID]['size']
					plighttable[WeaponDefs[weaponID]['name'] ]={1,1,0.5,0.5}
					
				elseif (WeaponDefs[weaponID]['type'] == 'MissileLauncher') then
					--Spring.Echo('MissileLauncher',WeaponDefs[weaponID]['name'],'size', WeaponDefs[weaponID]['size'])
					size=WeaponDefs[weaponID]['size']
					plighttable[WeaponDefs[weaponID]['name'] ]={1,1,0.8,0.5*((size-1)/3)}
					
				elseif (WeaponDefs[weaponID]['type'] == 'StarburstLauncher') then
					--Spring.Echo('StarburstLauncher',WeaponDefs[weaponID]['name'],'size', WeaponDefs[weaponID]['size'])
					--size=WeaponDefs[weaponID]['size']
					plighttable[WeaponDefs[weaponID]['name'] ]={1,1,0.8,0.5}
				--]]
				end
			
				
			end
		end
	end

end   
function widget:DrawWorldPreUnit()
	local sx,sy,px,py=Spring.GetViewGeometry()
	--Spring.Echo('viewport=',sx,sy,px,py)
	local x1=0
	local y1=0
	local cx,cy,p
	local d=0
	local x2=Game.mapSizeX 
	local y2=Game.mapSizeZ
	--[[
	at, bl=Spring.TraceScreenRay(0,0,true,false,false) --bottom left
	--Spring.Echo('bl',at,bl)
	if at=='ground' then
		x1=math.max(x1, bl[1])
		--x2=math.min(x2, tl[1])
		--y1=math.max(y1, bl[3])
		y2=math.min(y2, bl[3])
	end
	at, br=Spring.TraceScreenRay(sx-1,0,true,false,false)
	if at=='ground' then
		--x1=math.max(x1, tl[1])
		x2=math.min(x2, br[1])
		--y1=math.max(y1, tl[3])
		y2=math.min(y2, br[3])
	end
	at, tl=Spring.TraceScreenRay(0,sy-1,true,false,false)
	if at=='ground' then
		x1=math.max(x1, tl[1])
		--x2=math.min(x2, tl[1])
		y1=math.max(y1, tl[3])
		--y2=math.min(y2, tl[3])
	end
	at, tr=Spring.TraceScreenRay(sx-1,sy-1,true,false,false)
	--Spring.Echo('tr',at)
	if at=='ground' then
	--	Spring.Echo('tr',at,tr)
		--x1=math.max(x1, tl[1])
		x2=math.min(x2, tr[1])
		y1=math.max(y1, tr[3])
		--y2=math.min(y2, tl[3])
	end]]--
	local plist
	local at, p=Spring.TraceScreenRay(sx/2,sy/2,true,false,false)
	local outofbounds=0
	if at=='ground' then
		cx=p[1]
		--x2=math.min(x2, tl[1])
		cy=p[3]		--y2=math.min(y2, tl[3])
		
		at, p=Spring.TraceScreenRay(0,0,true,false,false) --bottom left
		if at=='ground' then
			d=max(d,(cx-p[1])*(cx-p[1])+(cy-p[3])*(cy-p[3]))
		else 
			outofbounds=outofbounds+1
		end
		at, p=Spring.TraceScreenRay(sx-1,0,true,false,false) --bottom left
		if at=='ground' then
			d=max(d,(cx-p[1])*(cx-p[1])+(cy-p[3])*(cy-p[3]))
		else 
			outofbounds=outofbounds+1
		end
		at, p=Spring.TraceScreenRay(sx-1,sy-1,true,false,false) --bottom left
		if at=='ground' then
			d=max(d,(cx-p[1])*(cx-p[1])+(cy-p[3])*(cy-p[3]))
		else 
			outofbounds=outofbounds+1
		end
		at, p=Spring.TraceScreenRay(0,sy-1,true,false,false) --bottom left
		if at=='ground' then
			d=max(d,(cx-p[1])*(cx-p[1])+(cy-p[3])*(cy-p[3]))
		else 
			outofbounds=outofbounds+1
		end
		if outofbounds>=3 then
			plist=Spring.GetProjectilesInRectangle(x1,y1,x2,y2,false,false) --todo, only those in view or close:P
		else
			d=sqrt(d)
			plist=Spring.GetProjectilesInRectangle(cx-d,cy-d,cx+d,cy+d,false,false) 
		end
	else -- if we are not pointing at ground, get the whole list.
		plist=Spring.GetProjectilesInRectangle(x1,y1,x2,y2,false,false) --todo, only those in view or close:P
	end
		--todo, only those in view or close:P
	--Spring.GetCameraPosition 
	--Spring.GetCameraPosition() -> number x, number y, number z
	--Spring.GetCameraDirection() -> number forward_x, number forward_y, number forward_z
	--Spring.GetCameraFOV( ) -> number fov
	local nplist = #plist
	--[[
	if #plist > 0 then
		nplist=#plist
	else
		nplist=0
	end
	--]]

	--Spring.Echo('mapview',nplist,outofbounds,d,cx,cy)
	--Spring.Echo('fov',Spring.GetCameraFOV(),Spring.GetCameraPosition())
	if nplist>0 then --dont do anything if there are no projectiles in range of view
		--Spring.Echo('#projectiles:',#plist)
		glTexture('luaui/images/pointlight.tga') --simple white square with alpha white blurred circle
		
		--enabling both test and mask means they wont be drawn over cliffs when obscured
			--but also means that they will flicker cause of z-fighting when scrolling around...
			--and ESPECIALLY when overlapping
		-- mask=false and test=true is perfect, no overlap flicker, no cliff overdraw
			--BUT it clips into cliffs from the side....
		glDepthMask(false)
		--glDepthMask(true)
		glDepthTest(false)
		--glDepthTest(GL.LEQUAL) 
		

		local x,y,z
		local fx,fy 
		gl.Blending("alpha_add") --makes it go into +
		local lightparams
		-- AND NOW FOR THE FUN STUFF!
		for i=1, nplist do
			local pID=plist[i]
			x,y,z=Spring.GetProjectilePosition(pID)
			local wep,piece=Spring.GetProjectileType(pID)
			--Spring.Echo('Proj',pID,'name',Spring.GetProjectileName(pID),' wep/piece',wep,piece,'pos=',math.floor(x),math.floor(y),math.floor(z))
			lightparams=nil
			if piece then
				lightparams={1.0,1.0,0.5,0.3}
			else
				lightparams=plighttable[Spring.GetProjectileName(pID)]
			end
			--[[
			if Spring.GetProjectileName(pID) == 'armllt_arm_lightlaser' then
				Spring.Echo('angle',Spring.GetProjectileSpinAngle(pID),'/',Spring.GetProjectileSpinAngle(pID),'/',Spring.GetProjectileSpinVec(pID),'/',Spring.GetProjectileVelocity(pID))
			end
			--]]
			if (lightparams ~= nil and x and y>0) then -- projectile is above water
				fx = 32
				fy = 32 --footprint
				local height = max(0,spGetGroundHeight(x,z)) --above water projectiles should show on water surface
				local diff = height-y	-- this is usually 5 for land units, 5+cruisehieght for others
										-- the plus 5 is do that itdoesnt clip all ugly like, unneeded with depthtest and mask both false!
										-- diff is negative, cause we need to put the lighting under it
										-- diff defines size and diffusion rate)
				local factor=max(0.01,(100.0+diff)/100.0) --factor=1 at when almost touching ground, factor=0 when above 100 height)
				if (factor >0.01) then 	
					glColor(lightparams[1],lightparams[2],lightparams[3],lightparams[4]*factor*factor*noise[floor(x+z+pID)%10+1]) -- attentuation is x^2
					factor = max(factor,0.3) -- clamp the size
					glPushMatrix()
					glTranslate(x,y+diff+5,z)  -- push in y dir by height (to push it on the ground!), +5 to keep it above surface
					glScale(fx*(1.1-factor),1.0,fy*(1.1-factor)) -- scale it by size
					if lightparams[5] then
						local dx,_,dz = Spring.GetProjectileVelocity(pID)
						glRotate(deg(atan2(dx,dz)),0.0,1.0,0.0)	-- align laser cannon light with projectile direction
						glCallList(listL) -- draw laser cannon light
					else
						glCallList(listC) -- draw cannon light
					end					
					glPopMatrix()
				end
			end
		end

		gl.Texture(false) --be nice, reset stuff 
		gl.Color(1.0,1.0,1.0,1.0)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------