nzTools:CreateTool("voltmeter", {
	displayname = "Voltmeter Placer",
	desc = "LMB: Place Voltmeter, RMB: Remove Voltmeter",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_voltmeter" then
			ent = tr.Entity
		else
			ent = nzMapping:Voltmeter(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2],0)+Angle(0,180,0), data.targetname, data.outputs, ply)
		end
		
		ent:SetName = data.targetname
		ent:ClearAllOutputs()
		for k, v in pairs(data.outputs) do
			ent:StoreOutput(v.key, v.value)
			table.insert(ent.Outputs, v)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_voltmeter" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		--Nothing
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Voltmeter Placer",
	desc = "LMB: Place Voltmeter, RMB: Remove Voltmeter",
	icon = "icon16/clock.png",
	weight = 8,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local valz = {}
		valz["Row1"] = data.targetname
		valz["Row2"] = data.outputs

		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )
		
		function DProperties.CompileData()
			local str="0"
			if valz["Row1"] == 0 then
				str=0
				data.flag = false
			else
				str=valz["Row2"]
				data.flag = true
			end
			data.link = str
			
			return data
		end
		
		function DProperties.UpdateData(data)
			nzTools:SendData(data, "voltmeter")
		end

		local Row1 = DProperties:CreateRow( "Voltmeter Placer", "Enable Flag for Doors?" )
		Row1:Setup( "Boolean" )
		Row1:SetValue( valz["Row1"] )
		Row1.DataChanged = function( _, val ) valz["Row1"] = val DProperties.UpdateData(DProperties.CompileData()) end
		local Row2 = DProperties:CreateRow( "Voltmeter Placer", "Flag" )
		Row2:Setup( "Integer" )
		Row2:SetValue( valz["Row2"] )
		Row2.DataChanged = function( _, val ) valz["Row2"] = val DProperties.UpdateData(DProperties.CompileData()) end
		
		local text1 = vgui.Create("DLabel", DProperties)
		text1:SetText("Will power linked door or nearby perk when shocked.")
		text1:SetFont("Trebuchet18")
		text1:SetTextColor( Color(50, 50, 50) )
		text1:SizeToContents()
		text1:SetPos(0, 90)
		text1:CenterHorizontal()
		
		local text3 = vgui.Create("DLabel", DProperties)
		text3:SetText("You still need to place a power switch.")
		text3:SetFont("Trebuchet18")
		text3:SetTextColor( Color(200, 50, 50) )
		text3:SizeToContents()
		text3:SetPos(0, 120)
		text3:CenterHorizontal()
		
		local text4 = vgui.Create("DLabel", DProperties)
		text4:SetText("Otherwise, everything will start powered on.")
		text4:SetFont("Trebuchet18")
		text4:SetTextColor( Color(200, 50, 50) )
		text4:SizeToContents()
		text4:SetPos(0, 135)
		text4:CenterHorizontal()
		
		return DProperties
	end,
	defaultdata = {
		targetname = "",
		outputs = {},
	}
})

nzTools:EnableProperties("voltmeter", "Edit Voltmeter...", "icon16/tag_blue_edit.png", 9010, true, function( self, ent, ply )
	if ( !IsValid( ent ) or !IsValid(ply) ) then return false end
	if ( ent:GetClass() != "nz_voltmeter" ) then return false end
	if !nzRound:InState( ROUND_CREATE ) then return false end
	if ( ent:IsPlayer() ) then return false end
	if ( !ply:IsInCreative() ) then return false end

	return true

end, function(ent)
	return {targetname = ent:GetName(), outputs = ent:GetOutputs()}
end)