hook.Add("PostGamemodeLoaded", "AfterlifeMappingLoadOrder", function()

nzMapping:AddSaveModule("Voltmeters", {
	savefunc = function()
		local voltmeter = {}
		for _, v in pairs(ents.FindByClass("nz_voltmeter")) do
			table.insert(voltmeter, {
				pos = v:GetPos(),
				angle = v:GetAngles(),
				targetname = v:GetName(),
				outputs = v:GetOutputs()
			})
		end
		return voltmeter
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:Voltmeter(v.pos, v.angle, v.targetname, v.outputs, nil)
		end
	end,
	postrestorefunc = function(data)
		for k,v in pairs(ents.FindByClass("nz_voltmeter")) do
			v:ResetVoltmeter()
		end
	end,
	cleanents = {"nz_voltmeter"}
})
function nzMapping:Voltmeter(pos, ang, name, outputs, ply)

	local entry = ents.Create("nz_voltmeter")
	entry:SetPos(pos)
	entry:SetAngles(ang)
	entry:Spawn()
	entry:PhysicsInit(SOLID_VPHYSICS)
	entry:SetName(name)
	for k, v in pairs(outputs) do
		--entry:StoreOutput(v.key, v.value)
		--table.insert(entry.Outputs, v)
		entry:SetKeyValue(v.key, v.value)
	end

	local phys = entry:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create("Voltmeter")
			undo.SetPlayer(ply)
			undo.AddEntity(entry)
		undo.Finish("Effect (" .. tostring( model ) .. ")")
	end
	return entry
end

nzMapping:AddSaveModule("AFSwitchboxes", {
	savefunc = function()
		local after_switchbox = {}
		for _, v in pairs(ents.FindByClass("nz_afterlife_switchbox")) do
			table.insert(after_switchbox, {
				pos = v:GetPos(),
				angle = v:GetAngles()
			})
		end
		return after_switchbox
	end,
	loadfunc = function(data)
		for k,v in pairs(data) do
			nzMapping:AFSwitchbox(v.pos, v.angle, nil)
		end
	end,
	cleanents = {"nz_afterlife_switchbox"}
})
function nzMapping:AFSwitchbox(pos, ang, ply)

	local entry = ents.Create("nz_afterlife_switchbox")
	entry:SetPos(pos)
	entry:SetAngles(ang)
	entry:Spawn()
	entry:PhysicsInit(SOLID_VPHYSICS)

	local phys = entry:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	if ply then
		undo.Create("Afterlife Switchbox")
			undo.SetPlayer(ply)
			undo.AddEntity(entry)
		undo.Finish("Effect (" .. tostring( model ) .. ")")
	end
	return entry
end

nzMapping:AddSaveModule("AfterlifeSettings", {
	savefunc = function()
		local AfterlifeData = {
			enabled = nzAfterlife.Enabled,
			maxsingle = nzAfterlife.MaxLives.Singleplayer,
			maxmulti = nzAfterlife.MaxLives.Multiplayer
		}
		return AfterlifeData
	end,
	loadfunc = function(data)
		nzAfterlife:UpdateSettings(data.enabled, data.maxsingle, data.maxmulti)
	end,
})

end)