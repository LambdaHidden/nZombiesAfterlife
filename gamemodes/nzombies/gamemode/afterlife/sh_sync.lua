if SERVER then
	util.AddNetworkString("nzAfterlifeEnabled")
	util.AddNetworkString("nzAfterlifeUpdateLimits")
	
	net.Receive("nzAfterlifeEnabled", function(length, ply)
		if nzRound:InState(ROUND_CREATE) then
			local onoff = net.ReadBool()
			nzAfterlife:Toggle(onoff)
			if onoff then
				Msg(ply.." enabled Afterlife.")
			else
				Msg(ply.." disabled Afterlife.")
			end
		else
			Msg(ply.." tried to toggle the availability of Afterlife, but we're not in Creative Mode.")
		end
	end)
	net.Receive("nzAfterlifeUpdateLimits", function(length, ply)
		local single = net.ReadUInt(32)
		local multi = net.ReadUInt(32)
		if nzRound:InState(ROUND_CREATE) then
			nzAfterlife:ChangeMaxLives(single, multi)
			Msg(ply.." changed max afterlives: "..single.." for singleplayer, "..multi.." for multiplayer.")
		else
			Msg(ply.." tried to change max Afterlives, but we're not in Creative Mode.")
		end
	end)
	
	function nzAfterlife:Toggle(onoff)
		nzAfterlife.Enabled = onoff
		net.Start("nzAfterlifeEnabled")
			net.WriteBool(onoff)
		net.Broadcast()
	end
	function nzAfterlife:ChangeMaxLives(single, multi)
		nzAfterlife.MaxLives.Singleplayer = single
		nzAfterlife.MaxLives.Multiplayer = multi
	
		net.Start("nzAfterlifeUpdateLimits")
			net.WriteUInt(single, 32)
			net.WriteUInt(multi, 32)
		net.Broadcast()
	end
end

if CLIENT then
	local function ReceiveAfterlifeUpdate(length)
		nzAfterlife.Enabled = net.ReadBool()
	end
	net.Receive("nzAfterlifeEnabled", ReceiveAfterlifeUpdate)
	
	local function ReceiveAfterlifeNewLimits(length)
		nzAfterlife.MaxLives.Singleplayer = net.ReadUInt(32)
		nzAfterlife.MaxLives.Multiplayer = net.ReadUInt(32)
	end
	net.Receive("nzAfterlifeUpdateLimits", ReceiveAfterlifeNewLimits)
end