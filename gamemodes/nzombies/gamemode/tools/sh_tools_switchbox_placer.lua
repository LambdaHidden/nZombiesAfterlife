nzTools:CreateTool("after_switchbox", {
	displayname = "Switchbox Placer",
	desc = "LMB: Place Switchbox, RMB: Remove Switchbox",
	condition = function(wep, ply)
		return true
	end,
	PrimaryAttack = function(wep, ply, tr, data)
		local ent
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_afterlife_switchbox" then
			ent = tr.Entity
		else
			local data2 = {}
			ent = nzMapping:AFSwitchbox(tr.HitPos, Angle(0,(tr.HitPos - ply:GetPos()):Angle()[2],0)+Angle(0,180,0), ply, data2)
		end
	end,
	SecondaryAttack = function(wep, ply, tr, data)
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "nz_afterlife_switchbox" then
			tr.Entity:Remove()
		end
	end,
	Reload = function(wep, ply, tr, data)
		
	end,
	OnEquip = function(wep, ply, data)

	end,
	OnHolster = function(wep, ply, data)

	end
}, {
	displayname = "Switchbox Placer",
	desc = "LMB: Place Switchbox, RMB: Remove Switchbox",
	icon = "icon16/clock.png",
	weight = 8,
	condition = function(wep, ply)
		return true
	end,
	interface = function(frame, data)
		local DProperties = vgui.Create( "DProperties", frame )
		DProperties:SetSize( 280, 180 )
		DProperties:SetPos( 10, 10 )
		
		function DProperties.UpdateData(data)
			nzTools:SendData(data, "after_switchbox")
		end
		local text1 = vgui.Create("DLabel", DProperties)
		text1:SetText("A box that lets you use Afterlife")
		text1:SetFont("Trebuchet18")
		text1:SetTextColor( Color(50, 50, 50) )
		text1:SizeToContents()
		text1:SetPos(0, 90)
		text1:CenterHorizontal()
		
		local text2 = vgui.Create("DLabel", DProperties)
		text2:SetText("without losing your perks.")
		text2:SetFont("Trebuchet18")
		text2:SetTextColor( Color(50, 50, 50) )
		text2:SizeToContents()
		text2:SetPos(0, 120)
		text2:CenterHorizontal()
		
		return DProperties
	end
})