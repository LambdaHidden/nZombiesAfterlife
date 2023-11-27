--ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Voltmeter"
--ENT.Editable		= true

ENT.TargetMemory	= {}

local TGTYPE_DOOR = 0
local TGTYPE_PERK = 1
local TGTYPE_PROXIMITY = 2
local TGTYPE_TARGETNAME = 3

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("Int", 0, "TargetType")
	self:NetworkVar("String", 0, "TargetID")
end

function ENT:Initialize()
	self:SetModel("models/motd/voltmeter.mdl")
	self.AutomaticFrameAdvance = true
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	--self:DrawShadow(false)
	self:SetActive(false)
	
	--local phys = self:GetPhysicsObject()
end

function ENT:OnTakeDamage(dmginfo)
	if bit.band(DMG_SHOCK, dmginfo:GetDamageType()) > 0 then
		self:ActivateVoltmeter()
	end
end

function ENT:ActivateVoltmeter()
	if self:GetActive() then return end
	self:SetActive(true)
	
	local sequence = self:LookupSequence("on")
	local sequence2 = self:LookupSequence("idle_on")
	self:ResetSequence(sequence)
	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) then
			self:ResetSequence(sequence2)
		end
	end)
	self:EmitSound("motd/afterlife/after_panel_on.ogg")
	self:SetSkin(1)
	
	
	if self:GetTargetType() == TGTYPE_DOOR then
		nzDoors:OpenLinkedDoors(self:GetTargetID())
	elseif self:GetTargetType() == TGTYPE_PERK then
		if self:GetTargetID() == "wunderfizz" then
			local machines = ents.FindByClass("wunderfizz_machine")
			for k, v in ipairs(machines) do
				v:TurnOn()
				table.insert(self.TargetMemory, v)
			end
		else
			local machines = ents.FindByClass("perk_machine")
			for k, v in ipairs(machines) do
				if v:GetPerkID() == self:GetTargetID() then
					v:TurnOn()
					table.insert(self.TargetMemory, v)
				end
			end
		end
	elseif self:GetTargetType() == TGTYPE_PROXIMITY then
		for k, v in ipairs(ents.FindInSphere(self:GetPos(), tonumber(self:GetTargetID()))) do
			
		end
	elseif self:GetTargetType() == TGTYPE_TARGETNAME then
		for k, v in ipairs(ents.FindByName(self:GetTargetID())) do
			if v.TurnOn then
				v:TurnOn()
				table.insert(self.TargetMemory, v)
			elseif v:GetDoorData() then
				nzDoors:OpenLinkedDoors(self:GetTargetID())
			end
		end
	end
	
	
	
	
	
	
	
	if self:GetDoorLink() != "" then
		nzDoors:OpenLinkedDoors(self:GetDoorLink())
	end
	
	if self:PerkLink() != "" then
		if IsValid(self.TargetMemory) then
			self.TargetMemory:TurnOn()
		else
			if self:GetPerkLink() == "wunderfizz" then
				local machine = ents.FindByClass("wunderfizz_machine")[1]
				--table.insert(self.TargetMemory, machine)
				self.TargetMemory = machine
				machine:TurnOn()
				return
			end
			for k, v in pairs(ents.FindByClass("perk_machine")) do
				if v:GetPerkID() == self:GetPerkLink() then
					--table.insert(self.TargetMemory, v)
					self.TargetMemory = v
					v:TurnOn()
				end
			end
		end
	end
end

function ENT:ResetVoltmeter()
	if !self:GetActive() then return end
	self:SetActive(false)
	
	local sequence = self:LookupSequence("idle")
	self:ResetSequence(sequence)
	self:SetSkin(0)
	
	if nzElec.IsOn() then return end
	
	if self:GetDoorLink() != "" then
		nzDoors:CloseLinkedDoors(self:GetDoorLink())
	end
	
	if self:PerkLink() != "" then
		self.TargetMemory:TurnOff()
	end
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	self:ResetVoltmeter()
end