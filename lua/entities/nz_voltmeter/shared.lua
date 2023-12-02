--ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Voltmeter"
--ENT.Editable		= true
--[[
ENT.ValidInputs = {
	TurnOn = true,
	TurnOff = true,
	OpenDoorLink = true,
	CloseDoorLink = true,
	ActivateInRadius = true,
	DeactivateInRadius = true,
	AddOutput = true,
	Kill = true
}]]
ENT.Outputs = {}
function ENT:GetOutputs(pretty)
	if CLIENT then
		net.Start("Afterlife_NWOutputs")
			net.WriteUInt(self:EntIndex(), 14)
		net.SendToServer()
	end
	if pretty then
		local sanitized = {}
		for k, v in pairs(self.Outputs) do
			local args = string.Explode(",", v.value)
			table.insert(sanitized, {name = v.key, target = args[1], action = args[2], parameter = args[3], delay = args[4], refires = args[5]})
		end
		return sanitized
	else
		return self.Outputs
	end
end

net.Receive("Afterlife_NWOutputs", function(length)
	local enti = net.ReadUInt(14)
	local ent = Entity(enti)
	
	if !IsValid(ent) then return end
	if SERVER then
		net.Start("Afterlife_NWOutputs")
			net.WriteUInt(enti, 14)
			net.WriteString("purge")
		net.Broadcast()
		for k, v in pairs(ent.Outputs) do
			net.Start("Afterlife_NWOutputs")
				net.WriteUInt(enti, 14)
				net.WriteString(v.key.." "..v.value)
			net.Broadcast()
		end
	elseif CLIENT then
		local kv = net.ReadString()
		if kv == "purge" then
			table.Empty(ent.Outputs)
			return
		end
		local args = string.Explode(" ", kv)
		table.insert(ent.Outputs, {key = args[1], value = args[2]})
	end
end)

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("String", 0, "Targetname")
end

function ENT:Initialize()
	self:SetModel("models/motd/voltmeter.mdl")
	self.AutomaticFrameAdvance = true
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	--self:DrawShadow(false)
	self:SetActive(false)
end

function ENT:AcceptInput(inputName, activator, caller, data)
	if self[inputName] then
		self[inputName](self, activator, data)
	elseif (string.Left(inputName, 8) == "FireUser") then
		self:TriggerOutput("OnUser"..string.Right(inputName, 1))
	end
end
function ENT:KeyValue(k, v)
	if k == "targetname" then self:SetTargetname(v) end
	if (string.Left(k, 2) == "On") then
		self:StoreOutput(k, v)
		table.insert(self.Outputs, {key = k, value = v})
	end
end
function ENT:AddOutput(activator, input)
	local args = string.Split(input, " ")

	self:StoreOutput(args[1], args[2])
	table.insert(self.Outputs, {key = args[1], value = args[2]})
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
	
	if SERVER then self:TriggerOutput("OnActivate", activator) end
end

function ENT:TurnOff(activator)
	if !self:GetActive() then return end
	self:SetActive(false)
	
	local sequence = self:LookupSequence("idle")
	self:ResetSequence(sequence)
	self:SetSkin(0)
	
	if SERVER and !nzElec.IsOn() then
		self:TriggerOutput("OnDeactivate", activator)
	end
end

function ENT:OpenDoorLink(activator, link)
	nzDoors:OpenLinkedDoors(link, activator)
end
function ENT:CloseDoorLink(activator, link)
	nzDoors:CloseLinkedDoors(link, activator)
end

function ENT:ActivateInRadius(activator, radius)
	for k, v in ipairs(ents.FindInSphere(self:GetPos(), tonumber(radius))) do
		local data = v:GetDoorData()
		if data and data.link then
			nzDoors:OpenLinkedDoors(data.link, activator)
		elseif v.TurnOn then
			v:TurnOn()
		end
	end
end
function ENT:DeactivateInRadius(activator, radius)
	for k, v in ipairs(ents.FindInSphere(self:GetPos(), tonumber(radius))) do
		local data = v:GetDoorData()
		if data and data.link then
			nzDoors:CloseLinkedDoors(data.link, activator)
		elseif v.TurnOff then
			v:TurnOff()
		end
	end
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