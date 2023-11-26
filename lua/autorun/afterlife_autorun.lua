AddCSLuaFile()

game.AddParticles("particles/motd_afterlife.pcf")
PrecacheParticleSystem("afterlife_playercloud")
PrecacheParticleSystem("afterlife_muzzle")
PrecacheParticleSystem("afterlife_hit")

if SERVER then
	util.AddNetworkString("AfterlifeVis")
end
--[[
local plyMeta = FindMetaTable("Player")

AccessorFunc( plyMeta, "bDiedFromShockBox", "DiedFromShockBox", FORCE_BOOL )
AccessorFunc( plyMeta, "bInAfterlife", "InAfterlife", FORCE_BOOL )
AccessorFunc( plyMeta, "iAfterlives", "Afterlives", FORCE_NUMBER )
AccessorFunc( plyMeta, "fAfterlifeJumpStamina", "AfterlifeJumpStamina", FORCE_NUMBER )
--AccessorFunc( plyMeta, "fAfterlifeIntegrity", "AfterlifeIntegrity", FORCE_NUMBER )
]]

local entMeta = FindMetaTable("Entity")
AccessorFunc( entMeta, "iAfterlifeVis", "AfterlifeVis", FORCE_NUMBER )

hook.Add("ShouldCollide", "AfterlifeCollision", function(ent1, ent2)
    --if ent2:IsPlayer() and ent2:GetInAfterlife() and ent1:GetAfterlifeVis() == 2 then 
	if ent2:IsPlayer() and ent2:GetNW2Bool("IsInAfterlife") and ent1:GetAfterlifeVis() == 2 then 
		return false 
	end
end)

hook.Add("PlayerCanPickupWeapon", "AfterlifeWeaponRestrictions", function(ply, weapon)
	--if ply:GetInAfterlife() then
	if ply:GetNW2Bool("IsInAfterlife") then
		return (weapon:GetClass() == "weapon_afterlife")
	end
end)

local AfterlifeJumpAccel = 200
local AfterlifeMaxJumpSpeed = 200
local AfterlifeJumpDepletion = 1.25
hook.Add("SetupMove", "AfterlifeSetupMove", function(ply, mv, cmd)
	--[[if ply:GetInAfterlife() then
		if ply:GetAfterlifeJumpStamina() > 0 and cmd:KeyDown(IN_JUMP) then
			local upspeed = math.Clamp(mv:GetUpSpeed() + (AfterlifeJumpAccel*engine.TickInterval()), -600, AfterlifeMaxJumpSpeed)
			mv:SetUpSpeed(upspeed)
			mv:SetVelocity(mv:GetVelocity() + vector_up*upspeed)
			ply:SetAfterlifeJumpStamina( ply:GetAfterlifeJumpStamina() - (AfterlifeJumpDepletion * engine.TickInterval()) )
		end
	end]]
	if ply:GetNW2Bool("IsInAfterlife") then
		if ply:GetNW2Float("AfterlifeHoverStamina") > 0 and cmd:KeyDown(IN_JUMP) then
			local upspeed = math.Clamp(mv:GetUpSpeed() + (AfterlifeJumpAccel*engine.TickInterval()), -600, AfterlifeMaxJumpSpeed)
			mv:SetUpSpeed(upspeed)
			mv:SetVelocity(mv:GetVelocity() + vector_up*upspeed)
			ply:SetNW2Float( "AfterlifeHoverStamina", ply:GetNW2Float("AfterlifeHoverStamina") - (AfterlifeJumpDepletion * engine.TickInterval()) )
		end
	end
end)