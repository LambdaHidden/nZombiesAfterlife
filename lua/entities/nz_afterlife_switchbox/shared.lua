//ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Switchbox"
--ENT.Editable		= true

local gamemode = string.lower(engine.ActiveGamemode()) == "nzombies"

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
	if activator:GetNW2Int("Afterlives") > 0 and !activator:GetNW2Bool("IsInAfterlife") then
		if gamemode then
			local DownPoints = math.Round(activator:GetPoints()*0.05, -1)
			if DownPoints >= activator:GetPoints() then
				DownPoints = activator:GetPoints()
			end
			
			activator:TakeDamage(500)
			--activator:SetDiedFromShockBox(true)
			activator:SetNW2Bool("HasDiedFromSwitchbox", true)
			self:EmitSound("motd/afterlife/box_activate/box_activate_0"..math.random(0,1)..".ogg")
			activator:GivePoints(DownPoints)
		end
	end
end

if CLIENT then
	function ENT:GetNZTargetText()
		if LocalPlayer():GetNW2Bool("IsInAfterlife") then
			return ""
		else
			if LocalPlayer():GetNW2Int("Afterlives") > 0 then
				return "Press "..string.upper(input.LookupBinding( "+use" )).." to enter Afterlife"
			else
				return "No Afterlife Remaining"
			end
		end
	end
end