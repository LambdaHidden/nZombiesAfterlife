if SERVER then
	util.AddNetworkString("nzAfterlifeUpdateSettings")
	
	net.Receive("nzAfterlifeUpdateSettings", function(length, ply)
		local onoff = net.ReadBool()
		local single = net.ReadUInt(8)
		local multi = net.ReadUInt(7)
		if nzRound:InState(ROUND_CREATE) then
			nzAfterlife:UpdateSettings(onoff, single, multi)
			MsgN(tostring(ply).." changed Afterlife settings: "..(onoff and "Enabled, " or "Disabled, ")..single.." for singleplayer, "..multi.." for multiplayer.")
		else
			MsgN(tostring(ply).." tried to change Afterlife settings, but we're not in Creative Mode.")
		end
	end)
	
	function nzAfterlife:UpdateSettings(onoff, single, multi)
		nzAfterlife.Enabled = onoff
		nzAfterlife.MaxLives.Singleplayer = single
		nzAfterlife.MaxLives.Multiplayer = multi
	
		net.Start("nzAfterlifeUpdateSettings")
			net.WriteBool(onoff)
			net.WriteUInt(single, 8)
			net.WriteUInt(multi, 7)
		net.Broadcast()
	end
	
	gameevent.Listen( "player_activate" )
	hook.Add( "player_activate", "AfterlifeSyncNewPlayers", function(data) 
		net.Start("nzAfterlifeUpdateSettings")
			net.WriteBool(nzAfterlife.Enabled)
			net.WriteUInt(nzAfterlife.MaxLives.Singleplayer, 8)
			net.WriteUInt(nzAfterlife.MaxLives.Multiplayer, 7)
		net.Send(Player(data.userid))
	end)
end

if CLIENT then
	local function UpdateSettingsClientside(length)
		nzAfterlife.Enabled = net.ReadBool()
		nzAfterlife.MaxLives.Singleplayer = net.ReadUInt(8)
		nzAfterlife.MaxLives.Multiplayer = net.ReadUInt(7)
	end
	net.Receive("nzAfterlifeUpdateSettings", UpdateSettingsClientside)
end