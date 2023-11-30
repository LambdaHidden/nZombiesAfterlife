AddCSLuaFile()

SWEP.Base				= "weapon_base"

SWEP.PrintName			= "Afterlife"
SWEP.Category			= "CoD Zombies"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.SwayScale				= 1
SWEP.BobScale				= 1.5
SWEP.ViewModel				= "models/weapons/black_ops_2/afterlife/v_afterlife.mdl"
SWEP.ViewModelFOV			= 72
SWEP.ViewModelFlip			= false
SWEP.UseHands 				= false
SWEP.WorldModel				= ""
SWEP.HoldType 				= "duel"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= false

if CLIENT then
	SWEP.Author				= "Hidden"
	SWEP.Contact			= "https://steamcommunity.com/id/LambdaHidden/"
	SWEP.Purpose			= "You are now just beyond the veil, be careful not to stay there forever."
	SWEP.Instructions		= string.upper(input.LookupBinding("+attack")).." to zap things, hold "..string.upper(input.LookupBinding("+jump")).." to hover. Don't forget to revive yourself."
	SWEP.WepSelectIcon		= surface.GetTextureID("vgui/afterlife_blue")
	SWEP.BounceWeaponIcon   = false
	
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
end

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Ammo			= "none"

SWEP.FiresUnderwater 		= false

local isnzombies = engine.ActiveGamemode() == "nzombies"

local STATUS_IDLE	= 0
local STATUS_DEPLOY = 1
local STATUS_ATTACK = 2
local STATUS_SPRINT = 3
local STATUS_REVIVE = 4
function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Int", 0, "Status")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	local own = self:GetOwner()
	self.WepOwner = own
	
	self:SendWeaponAnim(ACT_VM_DRAW_DEPLOYED)
	self:SetStatus(STATUS_DEPLOY)
	self:SetNextIdle(CurTime() + self:SequenceDuration())
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	own:EmitSound("motd/afterlife/afterlife_loop.wav", 60, 100, 1, CHAN_VOICE)
	
	self:GiveAbilities(true)
	if game.SinglePlayer() then
		timer.Simple(0.1, function()
			self:CallOnClient("GiveAbilities", "true")
		end)
	end
	return true
end

function SWEP:Holster(nextwep)
	local own = self:GetOwner()
	if nextwep and nextwep:GetClass() == "nz_revive_morphine" then
		nextwep.WepOwner = own
		timer.Simple(0.1, function()
			own:SetActiveWeapon("weapon_afterlife")
			self:SetStatus(STATUS_REVIVE)
			self:SendWeaponAnim(ACT_VM_RELOAD)
			self:EmitSound("motd/afterlife/afterlife_revive_loop.wav")
			self:SetNextIdle(CurTime() + 5)
		end)
		return false
	else
		self:OnRemove()
		return true
	end
end

local dontdamage = {
	["player"] = true,
	["whoswho_downed_clone"] = true
}

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return end
	local own = self:GetOwner()
	local eyetr = own:GetEyeTrace()
	local vm = own:GetViewModel()
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:EmitSound( "motd/ehand/fire"..math.random(0,2)..".ogg" )
	--ParticleEffectAttach( "afterlife_muzzle", PATTACH_POINT_FOLLOW, vm, 1 )
	--ParticleEffectAttach( "afterlife_muzzle", PATTACH_POINT_FOLLOW, vm, 2 )
	
	
	if eyetr.HitPos:DistToSqr(own:GetShootPos()) <= 65536 then
		sound.Play( "motd/ehand/stop/ehand_stop_02.ogg", eyetr.HitPos, 80, 100, 1 )
		util.ParticleTracerEx( "tesla_beam_b", own:GetShootPos()-own:GetRight(), eyetr.HitPos, false, own:EntIndex(), 0 )
		util.ParticleTracerEx( "tesla_beam_b", own:GetShootPos()-own:GetRight()*6, eyetr.HitPos, false, own:EntIndex(), 0 )
		ParticleEffect("afterlife_hit", eyetr.HitPos, angle_zero)
		
		if SERVER and !dontdamage[eyetr.Entity:GetClass()] then
			if eyetr.Entity:IsNextBot() then
				local spot = eyetr.Entity:FindSpot("far",{
					type = "hiding",
					pos = self:GetPos() + Vector(0,0,50),
					radius = 2048,
					stepup = 50,
					stepdown = 50
				})
				if IsValid(spot) then
					eyetr.Entity:SetPos(spot)
				elseif !string.find(eyetr.Entity:GetClass(), "boss", 1) then
					eyetr.Entity:Remove()
				end
			end
			
			local dmg = DamageInfo()
			dmg:SetDamage(50)
			dmg:SetAttacker(own)
			dmg:SetInflictor(self)
			dmg:SetDamageType(DMG_SHOCK)
			dmg:SetDamagePosition(eyetr.HitPos)
			
			eyetr.Entity:TakeDamageInfo(dmg)
		end
	end
	
	self:SetStatus(STATUS_ATTACK)
	self:SetNextPrimaryFire(CurTime()+0.3)
	self:SetNextIdle(CurTime() + 0.65)
end

function SWEP:SecondaryAttack()
	return
end

AfterlifeVisEnts = {}

hook.Add("EntityKeyValue", "AfterlifeVisibilityPrecache", function(ent, k, v) 
	if k == "AfterlifeVis" then
		ent:SetCustomCollisionCheck(true)
		ent:SetAfterlifeVis(tonumber(v))
		
		AfterlifeVisEnts[ent:EntIndex()] = tonumber(v)
		net.Start("AfterlifeVis")
			net.WriteUInt(ent:EntIndex(), 14)
			net.WriteUInt(tonumber(v), 2)
		net.Broadcast()
	end
end)

hook.Add("InitPostEntity", "World_AfterlifeSyncVisEnts", function()
	if SERVER then
		for key, value in pairs(AfterlifeVisEnts) do
			net.Start("AfterlifeVis")
				net.WriteUInt(key, 14)
				net.WriteUInt(value, 2)
			net.Broadcast()
		end
	end
end)

hook.Add("PlayerInitialSpawn", "Player_AfterlifeSyncVisEnts", function(ply, transition)
	for key, value in pairs(AfterlifeVisEnts) do
		net.Start("AfterlifeVis")
			net.WriteUInt(key, 14)
			net.WriteUInt(value, 2)
		net.Send(ply)
	end
end)

hook.Add("NotifyShouldTransmit", "AfterlifeSyncVisEnts", function(entity, shouldtransmit)
	if AfterlifeVisEnts[entity:EntIndex()] then
		local determiner = AfterlifeVisEnts[entity:EntIndex()]
		
		if LocalPlayer():GetInAfterlife() then determiner = determiner - 1 end
		
		if determiner == 1 then
			entity:AddEffects(EF_NODRAW)
		else
			entity:RemoveEffects(EF_NODRAW)
		end
	end
end)

net.Receive("AfterlifeVis", function(length, ply)
	local enti = net.ReadUInt(14)
	local v = net.ReadUInt(2)
	
	AfterlifeVisEnts[enti] = v
	
	local ent = Entity(enti)
	--if !LocalPlayer():GetInAfterlife() and v == 1 and IsValid(ent) then
	if !LocalPlayer():GetNW2Bool("IsInAfterlife") and v == 1 and IsValid(ent) then
		ent:AddEffects(EF_NODRAW)
	end
end)

--local color_invisible = Color(255,255,255,0)
function SWEP:GiveAbilities(giveorstrip)
	local own = self.WepOwner or self:GetOwner()
	if !IsValid(own) then return end
	
	if giveorstrip then
		--print("Giving abilities")
		self.BackupWalkSpeed = own:GetWalkSpeed()
		self.BackupRunSpeed = own:GetRunSpeed()
		
		
		own:SetNW2Float("AfterlifeHoverStamina", 2.0)
		own:SetNW2Bool("IsInAfterlife", true)
		own:SetGravity(0.5)
		own:SetWalkSpeed(320)
		own:SetRunSpeed(500)
		if own.SetMaxRunSpeed then own:SetMaxRunSpeed(500) end
		
		if CLIENT then
			for k, v in pairs(AfterlifeVisEnts) do
				local ent = Entity(k)
				if !IsValid(ent) then continue end
				if v == 2 then
					ent:AddEffects(EF_NODRAW)
					continue
				end
				ent:RemoveEffects(EF_NODRAW)
			end
		end
		
		own:AddEffects(EF_NODRAW)
		own:StopParticles()
		ParticleEffectAttach("afterlife_playercloud", PATTACH_ABSORIGIN_FOLLOW, own, 0)
	else
		--print("Stripping abilities")
		own:SetNW2Bool("IsInAfterlife", false)
		own:SetGravity(1)
		if self.BackupWalkSpeed then
			own:SetWalkSpeed(self.BackupWalkSpeed)
			own:SetRunSpeed(self.BackupRunSpeed)
			if own.SetMaxRunSpeed then own:SetMaxRunSpeed(self.BackupRunSpeed) end
		end
		
		own:StopParticles()
		own:RemoveEffects(EF_NODRAW)
		
		if CLIENT then
			for k, v in pairs(AfterlifeVisEnts) do
				local ent = Entity(k)
				if !IsValid(ent) then continue end
				if v == 2 then
					ent:RemoveEffects(EF_NODRAW)
					continue
				end
				ent:AddEffects(EF_NODRAW)
			end
		end
	end
end

function SWEP:Think()
	local nextidle = self:GetNextIdle()
	local own = self:GetOwner()
	local ct = CurTime()
	
	if self:GetNextIdle() <= ct and self:GetStatus() != STATUS_IDLE then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetStatus(STATUS_IDLE)
	end
	
	if own:IsSprinting() then
		if self:GetStatus() != STATUS_SPRINT then --(ownvel.x + ownvel.y) > own:GetWalkSpeed()
			self:SendWeaponAnim(ACT_VM_SPRINT_IDLE)
			self:SetStatus(STATUS_SPRINT)
		end
		self:SetNextIdle(ct + 0.1)
	end
	
	if own:KeyReleased(IN_USE) and self:GetStatus() == STATUS_REVIVE then
		self:SetNextIdle(CurTime())
	end
	
	if own:OnGround() and SERVER then
		own:SetNW2Float("AfterlifeHoverStamina", math.Clamp(own:GetNW2Float("AfterlifeHoverStamina") + 0.1, 0, 2))
	end
end

function SWEP:OnRemove()
	if IsValid(self.WepOwner) then
		self:GiveAbilities(false)
		self.WepOwner:StopSound("motd/afterlife/afterlife_loop.wav")
	end
end