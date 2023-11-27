if SERVER then
	util.AddNetworkString( "nzombies_afterlife_enabled" )
end

nzTools:CreateTool("afterlife", {
	displayname = "Afterlife Settings",
	desc = "Changes global settings for the Afterlife feature",
	condition = function(wep, ply)
		return true
	end,

	PrimaryAttack = function(wep, ply, tr, data)
		
	end,

	SecondaryAttack = function(wep, ply, tr, data)
		
	end,
	Reload = function(wep, ply, tr, data)
		-- Nothing
	end,
	OnEquip = function(wep, ply, data)
		
	end,
	OnHolster = function(wep, ply, data)
		
	end
}, {
	displayname = "Afterlife Settings",
	desc = "Changes global settings for the Afterlife feature",
	icon = "icon16/weather_clouds.png",
	weight = 25,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		--local data = table.Copy(nzMapping.Settings)
		local valz = {}
		valz["Row1"] = tonumber(data.EnableAfterlife)
		valz["Row2"] = tonumber(data.MaxLivesSingle)
		valz["Row3"] = tonumber(data.MaxLivesMulti)

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )
		
		function DProperties.CompileData()
			data.EnableAfterlife = valz["Row1"]
			data.MaxLivesSingle = valz["Row2"]
			data.MaxLivesMulti = valz["Row3"]
			return data
		end
		
		function DProperties.UpdateData(data)
			nzTools:SendData(data, "afterlife")
		end

		local Row1 = DProperties:CreateRow( "Afterlife", "Enable?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val end
		
		local Row2 = DProperties:CreateRow( "Afterlife", "Max singleplayer lives" )
		Row2:Setup( "Int", { min = 0, max = 10 } )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val end
		
		local Row3 = DProperties:CreateRow( "Afterlife", "Max multiplayer lives" )
		Row3:Setup( "Int", { min = 0, max = 10 } )
		Row3:SetValue( valz["Row3"] )
		Row3.DataChanged = function( _, val ) valz["Row3"] = val end
		
		local function UpdateData() -- Will remain a local function here. There is no need for the context menu to intercept
			net.Start("nzAfterlifeEnabled")
				net.WriteBool(valz["Row1"] > 0)
			net.SendToServer()
			
			net.Start("nzAfterlifeUpdateLimits")
				net.WriteUInt(math.Round(valz["Row2"]), 32)
				net.WriteUInt(math.Round(valz["Row3"]), 32)
			net.SendToServer()
		end

		local DermaButton = vgui.Create( "DButton", DProperties )
		DermaButton:SetText( "Submit" )
		DermaButton:SetPos( 0, 185 )
		DermaButton:SetSize( 260, 30 )
		DermaButton.DoClick = UpdateData

		return DProperties
	end,
	defaultdata = {
		EnableAfterlife = 0,
		MaxLivesSingle = 3,
		MaxLivesMulti = 1
	}
})