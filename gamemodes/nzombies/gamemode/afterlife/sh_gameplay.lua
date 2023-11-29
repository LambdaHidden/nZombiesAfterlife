if !nzRevive then -- Load nzMapping if it wasn't yet, because everything here is built on top of that.
	local revivefiles,_ = file.Find("nzombies/gamemode/revive_system/*", "LUA")
	
	for k, v in pairs(revivefiles) do
		local sep = string.Explode("_", v)
		local name = "nzombies/gamemode/revive_system/"..v
		if sep[1] == "sh" then
			if SERVER then
				AddCSLuaFile(name)
				include(name)
			else
				include(name)
			end
		elseif sep[1] == "sv" then
			if SERVER then include(name) end
		end
	end
end

hook.Add("OnGameBegin", "GiveStartAfterlife", function() 
	if nzAfterlife.Enabled then
		for k, v in pairs(player.GetAllPlaying()) do
			v:SetNW2Bool("IsInAfterlife", false)
			if game.SinglePlayer() then
				v:SetNW2Int("Afterlives", nzAfterlife.MaxLives.Singleplayer)
			else
				v:SetNW2Int("Afterlives", nzAfterlife.MaxLives.Multiplayer)
			end
		end
	end
end)

hook.Add("OnRoundStart", "GiveAfterlife", function(ply)
	if nzAfterlife.Enabled then
		for k, v in pairs(player.GetAllPlaying()) do
			if !v:GetNW2Bool("IsInAfterlife") then
				local maxlives = game.SinglePlayer() and nzAfterlife.MaxLives.Singleplayer or nzAfterlife.MaxLives.Multiplayer
			
				if v:GetNW2Int("Afterlives") < maxlives then
					v:SetNW2Int("Afterlives", v:GetNW2Int("Afterlives") + 1)
					v:EmitSound("motd/afterlife/afterlife_add.ogg")
				end
			end
		end
	else
		for k, v in pairs(player.GetAllPlaying()) do
			v:SetNW2Int("Afterlives", 0)
		end
	end
end)

hook.Add("PlayerDowned", "RespawnWithAfterlife", function(ply)
	if ply:GetNW2Int("Afterlives") > 0 and !ply:HasPerk("whoswho") and !ply:HasPerk("revive") then -- Who's Who and Quick Revive would break this with their timers.
		ply:EmitSound("motd/afterlife/afterlife_death.ogg")
		timer.Simple(3, function() 
			if IsValid(ply) and !ply:GetNotDowned() then -- Same Tombstone check as Who's Who.
				ply:EmitSound("motd/afterlife/afterlife_start.ogg")
				ply:ScreenFade( SCREENFADE.OUT, color_white, 0.5, 0.5 )
				timer.Simple(0.5, function() 
					ply:ScreenFade( SCREENFADE.IN, color_white, 0.5, 0.5 )
					nzAfterlife:CreateAfterlifeClone(ply)
					nzAfterlife:RespawnWithAfterlife(ply)
				end)
			end
		end)
	end
end)

function nzAfterlife:CreateAfterlifeClone(ply, pos)
	local pos = pos or ply:GetPos()

	local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() != "nz_perk_bottle" and ply:GetActiveWeapon():GetClass() or ply.oldwep or nil

	local who = ents.Create("whoswho_downed_clone")
	who:SetPos(pos + Vector(0,0,20))
	who:SetAngles(ply:GetAngles())
	who:Spawn()
	who:GiveWeapon(wep)
	who:SetPerkOwner(ply)
	who:SetModel(ply:GetModel())
	
	local weps = {}
	if ply:GetNW2Bool("HasDiedFromSwitchbox") then
		who.OwnerData.perks = ply.OldPerks or ply:GetPerks()
		for k,v in pairs(ply:GetWeapons()) do
			local temp = {
				class = v:GetClass(),
				ammo1 = v:Ammo1(),
				ammo2 = v:Ammo2(),
				clip1 = v:Clip1(),
				clip2 = v:Clip2(),
				pap = v:HasNZModifier("pap"),
				speed = v:HasNZModifier("speed"),
				dtap = v:HasNZModifier("dtap")
			}
			table.insert(weps, temp)
		end
	else
		who.OwnerData.perks = {}
		for k,v in pairs(ply:GetWeapons()) do
			local temp = {
				class = v:GetClass(),
				ammo1 = v:Ammo1(),
				ammo2 = v:Ammo2(),
				clip1 = v:Clip1(),
				clip2 = v:Clip2(),
				pap = v:HasNZModifier("pap"),
				speed = false,
				dtap = false
			}
			table.insert(weps, temp)
		end
	end
	who.OwnerData.weps = weps
	who.OwnerData.afterlives = math.Clamp(ply:GetNW2Int("Afterlives") - 1, 0, 254)
	--who.OwnerData.money = ply:GetPoints()

	timer.Simple(0.1, function()
		if IsValid(who) then
			local id = who:EntIndex()
			nzRevive.Players[id] = {}
			nzRevive.Players[id].DownTime = CurTime()

			hook.Call("PlayerDowned", nzRevive, who)
		end
	end)

	--ply.AfterlifeClone = who
	ply:SetNW2Entity("AfterlifeClone", who)
	ply.AfterlifeMoney = ply:GetPoints()
	
	net.Start("NZWhosWhoReviving")
		net.WriteEntity(ply)
		net.WriteBool(false)
	net.Broadcast()

	--[[net.Start("nz_WhosWhoActive")
		net.WriteBool(true)
	net.Send(ply)]]
end

function nzAfterlife:RespawnWithAfterlife(ply, pos)
	local pos = pos or nil

	if !pos then
		local plypos = ply:GetPos()
		local maxdist = 1500^2
		local mindist = 64^2
		
		local bestspawn = {pos = vector_origin, distance = maxdist, found = false}
		
		local available = ents.FindByClass("nz_spawn_zombie_special")
		if IsValid(available[1]) then
			for k,v in pairs(available) do
				local dist = plypos:DistToSqr(v:GetPos())
				if v.link == nil or nzDoors:IsLinkOpened( v.link ) then -- Only for rooms that are opened (using links)
					if dist < bestspawn.distance and dist > mindist then -- Within the range we set above
						if v:IsSuitable() then -- And nothing is blocking it
							bestspawn.pos = v:GetPos()
							bestspawn.distance = dist
							bestspawn.found = true
						end
					end
				end
			end
			if !bestspawn.found then
				for k,v in pairs(available) do -- Retry, but without the range check (just use all of them)
					--local dist = plypos:DistToSqr(v:GetPos())
					if v.link == nil or nzDoors:IsLinkOpened( v.link ) then
						if v:IsSuitable() then
							bestspawn.pos = v:GetPos()
							bestspawn.found = true
						end
					end
				end
			end
			if !bestspawn.found then -- Still no open linked ones?! Spawn at a random player spawnpoint
				local pspawns = ents.FindByClass("player_spawns")
				if !IsValid(pspawns[1]) then
					ply:Spawn()
				else
					pos = pspawns[math.random(#pspawns)]:GetPos()
				end
			else
				pos = bestspawn.pos
			end
			
		end
	end
	ply:RevivePlayer()
	ply:StripWeapons()
	--player_manager.RunClass(ply, "Loadout") -- Rearm them
	ply:Give("weapon_afterlife")
	ply:SetTargetPriority(TARGET_PRIORITY_NONE)

	if pos then ply:SetPos(pos) end

end

hook.Add("PostGamemodeLoaded", "AfterlifeDontEndGame", function()
function player.GetAllPlayingAndAlive()
	local result = {}
	for _, ply in pairs( player.GetAllPlaying() ) do
		if ply:Alive() and (ply:GetNotDowned() or ply.HasWhosWho or ply.DownedWithSoloRevive or ply:GetNW2Int("Afterlives") > 0) then -- Who's Who and Afterlife will respawn the player, don't end yet.
			table.insert( result, ply )
		end
	end

	return result
end
end)

hook.Add("GetFallDamage", "Afterlife_Falldmg", function(ply, speed)
	--print(speed)
	if ply:GetNW2Bool("IsInAfterlife") then
		return 0
	end
end)
hook.Add("PlayerShouldTakeDamage", "Afterlife_Nodmg", function(ply, attacker)
	if ply:GetNW2Bool("IsInAfterlife") then
		return false
	end
end)

if CLIENT then
	hook.Add("RenderScreenspaceEffects", "DrawAfterlifeOverlay", function()
		if LocalPlayer():GetNW2Bool("IsInAfterlife") then
			DrawMaterialOverlay("effects/tp_eyefx/tpeye3", 0.03)
		end
	end)
end