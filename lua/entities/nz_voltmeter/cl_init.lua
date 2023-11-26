include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	if self:GetActive() then
		if !self.NextLight or CurTime() > self.NextLight then
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.pos = self:LocalToWorld(Vector(32,0,64))
				dlight.r = 115
				dlight.g = 205
				dlight.b = 220
				dlight.brightness = 2
				dlight.Decay = 1000
				dlight.Size = 256
				dlight.DieTime = CurTime() + 1
			end
			if math.random(300) == 1 then self.NextLight = CurTime() + 0.05 end
		end
	end
end

function ENT:IsTranslucent()
return true
end