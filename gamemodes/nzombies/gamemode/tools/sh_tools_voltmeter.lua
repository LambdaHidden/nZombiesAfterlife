nzTools:CreateTool("voltmeter", {
	displayname = "Voltmeter Placer",
	desc = "LMB: Place Voltmeter, RMB: Remove Voltmeter",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local actualoutputs = {}
		for k, v in pairs(data.outputs) do
			local orderedoutputs = {
				v.target,
				v.action,
				v.parameter,
				v.delay,
				v.refires
			}
			
			local name = v.name
			--PrintTable(orderedoutputs)
			local concat = table.concat(orderedoutputs, ",")
			--print(concat)
			table.insert(actualoutputs, {key = name, value = concat})
		end
	
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_voltmeter" then
			tr.Entity:SetName(data.targetname)
			tr.Entity:ClearAllOutputs()
			
			for k, v in pairs(actualoutputs) do
				--tr.Entity:StoreOutput(v.key, v.value)
				--table.insert(tr.Entity.Outputs, v)
				tr.Entity:SetKeyValue(v.key, v.value)
			end
		else
			--PrintTable(actualoutputs)
			ent = nzMapping:Voltmeter(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2],0)+Angle(0,180,0), data.targetname, actualoutputs, ply)
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
		valz["Name"] = data.targetname
		valz["Outputs"] = data.outputs
		
		local sheet = vgui.Create( "DPanel", frame )
		sheet:SetSize( frame:GetSize() )
		sheet:SetPos( 0, 0 )

		local DProperties = vgui.Create( "DProperties", sheet )
		DProperties:SetSize( 280, 64 )
		DProperties:SetPos( 10, 10 )
		
		local Row1 = DProperties:CreateRow( "Voltmeter Placer", "Name" )
		Row1:Setup( "Generic" )
		Row1:SetValue( valz["Name"] )
		Row1.DataChanged = function( _, val )
			valz["Name"] = val
			data.targetname = val
			DProperties.UpdateData()
		end
		
		local outlabel = vgui.Create( "DLabel", sheet )
		outlabel:SetTextColor(color_black)
		outlabel:SetFont("Trebuchet18")
		outlabel:SetSize(96, 24)
		outlabel:SetPos(122, 52)
		outlabel:SetText("Outputs")
		
		
		
		local outputlist = vgui.Create("DScrollPanel", sheet)
		outputlist:SetPos(10, 72)
		outputlist:SetSize(280, 160)
		outputlist:SetPaintBackground(true)
		outputlist:SetBackgroundColor( Color(200, 200, 200) )
		
		local Host = vgui.Create( "DProperties", outputlist )
		Host:SetSize( 276, 158 )
		Host:SetPos( 2, 2 )
		
		local hostcontainer = {}
		
		local function RefreshOutputList()
			if hostcontainer[1] then hostcontainer[1]:Remove() end
			table.Empty(hostcontainer)
			
			local Host = vgui.Create( "DProperties", outputlist )
			Host:SetSize( 276, 158 )
			Host:SetPos( 2, 2 )
			table.insert(hostcontainer, Host)
			
			for k, v in pairs(valz["Outputs"]) do
				local name = Host:CreateRow( "Output "..k, "Event" )
				name:Setup( "Combo" )
				name:AddChoice( "OnActivate", "OnActivate" )
				name:AddChoice( "OnDeactivate", "OnDeactivate" )
				name:SetValue(v.name)
				name.DataChanged = function( _, val ) 
					v.name = val
					DProperties.UpdateData()
				end
				
				local target = Host:CreateRow( "Output "..k, "Target" )
				target:Setup( "Generic" )
				target:SetValue(v.target)
				target.DataChanged = function( _, val ) 
					v.target = val
					DProperties.UpdateData()
				end
				
				local action = Host:CreateRow( "Output "..k, "Action" )
				action:Setup( "Generic" )
				action:SetValue(v.action)
				action.DataChanged = function( _, val ) 
					v.action = val
					DProperties.UpdateData()
				end
				
				local parameter = Host:CreateRow( "Output "..k, "Parameter" )
				parameter:Setup( "Generic" )
				parameter:SetValue(v.parameter)
				parameter.DataChanged = function( _, val ) 
					v.parameter = val
					DProperties.UpdateData()
				end
				
				local delay = Host:CreateRow( "Output "..k, "Delay" )
				delay:Setup( "Float", { min = 0, max = 60 } )
				delay:SetValue(0)
				delay:SetValue(v.delay)
				delay.DataChanged = function( _, val ) 
					v.delay = val
					DProperties.UpdateData()
				end
				
				local refires = Host:CreateRow( "Output "..k, "Refires" )
				refires:Setup( "Int", { min = -1, max = 10 } )
				refires:SetValue(-1)
				refires:SetValue(v.refires)
				refires.DataChanged = function( _, val ) 
					v.refires = val
					DProperties.UpdateData()
				end
				
				local delete = Host:CreateRow( "Output "..k, "Delete" )
				delete:Setup( "Generic" )
				
				local delete1 = vgui.Create( "DButton", delete )
				delete1.host = k
				delete1:SetText( "Delete" )
				delete1:SetPos( 120, 2 )
				delete1:SetSize( 48, 16 )
				delete1.DoClick = function()
					if table.Count(valz["Outputs"]) == 1 then return end
					table.remove(valz["Outputs"], delete1.host)
					RefreshOutputList()
					DProperties.UpdateData()
				end
			end
		end
		
		RefreshOutputList()
		
		local add = vgui.Create( "DButton", sheet )
		add:SetText( "Add" )
		add:SetPos( 120, 240 )
		add:SetSize( 50, 20 )
		add.DoClick = function()
			table.insert(valz["Outputs"], {name = "", target = "", action = "", parameter = "", delay = 0, refires = -1})
			RefreshOutputList()
		end
		
		if table.IsEmpty(valz["Outputs"]) then
			add:DoClick()
		end
		
		function DProperties.UpdateData()
			local newdata = {targetname = valz["Name"], outputs = valz["Outputs"]}
			nzTools:SendData(newdata, "voltmeter")
		end
		
		return sheet
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