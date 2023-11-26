//ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Switchbox"
--ENT.Editable		= true

local gamemode = engine.ActiveGamemode():lower() == "nzombies"

function ENT:Initialize()

	self:SetModel("models/motd/afterlife_switchbox.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
	
end

function ENT:Use(activator, caller)
	--if activator:GetAfterlives() <= 0 or activator:GetInAfterlife() then return end
	if activator:GetNW2Int("Afterlives") <= 0 or activator:GetNW2Bool()
	if gamemode then
		local DownPoints = math.Round(activator:GetPoints()*0.05, -1)
		if DownPoints >= activator:GetPoints() then
			DownPoints = activator:GetPoints()
		end
		
		activator:TakeDamage(500)
		--activator:SetDiedFromShockBox(true)
		activator:SetNWBool("DiedFromShockbox", true)
		self:EmitSound("motd/afterlife/box_activate/box_activate_0"..math.random(0,1)..".ogg")
		activator:GivePoints(DownPoints)
	end
end

if CLIENT then
	function ENT:GetNZTargetText()
		if LocalPlayer():GetInAfterlife() then
			return ""
		else
			if LocalPlayer():GetAfterlives() > 0 then
				return "Press "..string.upper(input.LookupBinding( "+use" )).." to enter Afterlife"
			else
				return "No Afterlife Remaining"
			end
		end
	end
end