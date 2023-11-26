--ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Voltmeter"
--ENT.Editable		= true

ENT.ValidInputs = {
	TurnOn = true,
	TurnOff = true,
	OpenDoorLink = true,
	CloseDoorLink = true,
	Kill = true
}
ENT.Outputs = {}
function ENT:GetOutputs()
	return self.Outputs
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
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

function ENT:AcceptInput(inputName, activator, caller, data)
	if self.ValidInputs[inputName] then
		self[inputName](self, activator, data)
	elseif ( string.Left( inputName, 8 ) == "FireUser" ) then
		self:TriggerOutput("OnUser"..string.Right(inputName, 1))
	end
end
function ENT:KeyValue(k, v)
	if (string.Left(k, 2) == "On") then
		self:StoreOutput(k, v)
		table.insert(self.Outputs, {key = k, value = v})
	end
end


function ENT:TurnOn(activator)
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
	
	self:TriggerOutput("OnActivate", activator)
end

function ENT:TurnOff(activator)
	if !self:GetActive() then return end
	self:SetActive(false)
	
	local sequence = self:LookupSequence("idle")
	self:ResetSequence(sequence)
	self:SetSkin(0)
	
	if !nzElec.IsOn() then
		self:TriggerOutput("OnDeactivate", activator)
	end
end

function ENT:OpenDoorLink(activator, link)
	nzDoors:OpenLinkedDoors(link, activator)
end
function ENT:CloseDoorLink(activator, link)
	nzDoors:CloseLinkedDoors(link, activator)
end

function ENT:Kill()
	SafeRemoveEntity(self)
end


function ENT:OnTakeDamage(dmginfo)
	if bit.band(DMG_SHOCK, dmginfo:GetDamageType()) > 0 then
		self:TurnOn(dmginfo:GetAttacker())
	end
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	self:TurnOff()
end