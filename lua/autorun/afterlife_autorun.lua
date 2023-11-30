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

local allowedguns = {
	["weapon_afterlife"] = true,
	["nz_revive_morphine"] = true,
	["nz_hellsretriever"] = true,
	["nz_hellsredeemer"] = true
}
hook.Add("PlayerCanPickupWeapon", "AfterlifeWeaponRestrictions", function(ply, weapon)
	if ply:GetNW2Bool("IsInAfterlife") then
		if weapon:GetClass() == "nz_revive_morphine" then
			weapon.WepOwner = ply
			ply:GetWeapon("weapon_afterlife"):Holster(weapon)
		end
		return allowedguns[weapon:GetClass()] != nil
	end
end)

local AfterlifeJumpAccel = 200
local AfterlifeMaxJumpSpeed = 200
local AfterlifeJumpDepletion = 1.25
hook.Add("SetupMove", "AfterlifeSetupMove", function(ply, mv, cmd)
	if ply:GetNW2Bool("IsInAfterlife") then
		if cmd:KeyDown(IN_JUMP) and ply:GetNW2Float("AfterlifeHoverStamina") > 0 then
			local upspeed = math.Clamp(mv:GetUpSpeed() + (AfterlifeJumpAccel*engine.TickInterval()), -600, AfterlifeMaxJumpSpeed)
			mv:SetUpSpeed(upspeed)
			cmd:SetUpMove(upspeed)
			mv:SetVelocity(mv:GetVelocity() + vector_up*upspeed)
			ply:SetNW2Float( "AfterlifeHoverStamina", ply:GetNW2Float("AfterlifeHoverStamina") - (AfterlifeJumpDepletion * engine.TickInterval()) )
		end
	end
end)