local mod = RestoredMonsterPack
local game = Game()

local ENTITY = mod.ENTITY_INFO.SPLIT_RAGE_CREEP

function mod:splitCreepUpdate(entity)
	if entity.Variant ~= ENTITY.VARIANT then return end

	local sprite = entity:GetSprite()

	if entity.State == NpcState.STATE_ATTACK then
		entity.State = NpcState.STATE_ATTACK2
	elseif entity.State == NpcState.STATE_ATTACK2 then

		if not sprite:IsPlaying("Attack") then
			sprite:Play("Attack", true)
		elseif sprite:GetFrame() == 146 then
			entity.State = NpcState.STATE_MOVE
		end

		if sprite:IsEventTriggered("Shoot") then
			local brim = EntityLaser.ShootAngle(LaserVariant.THICK_RED,
												entity.Position,
												entity.SpriteRotation + 90,
												90,
												Vector(0, 10):Rotated(entity.SpriteRotation),
												entity)
			brim:GetData().splitragecreep_brim = true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.splitCreepUpdate, ENTITY.ID)

function mod:splitCreepLaserUpdate(brim)
	if not brim:GetData().splitragecreep_brim then return end

	if brim.FrameCount % 15 == 5 and not brim.Shrink then
		local rng = brim:GetDropRNG()
		local start_pos = brim.Position + Vector(40, 0):Rotated(brim.Angle)
		local brim_vector = brim.EndPoint - start_pos
		local pos_cnt = math.floor(brim_vector:Length() / 40)

		for _ = 1, 3 do
			local pos = start_pos + brim_vector:Resized(40 * rng:RandomInt(pos_cnt + 1))
			local dir = rng:RandomInt(2)
			local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,
									0,
									0,
									pos,
									brim_vector:Resized(7):Rotated(90 - 180 * dir),
									brim.Parent):ToProjectile()
			proj:GetSprite().Color = Color(1, 1, 1, 1, 0.5)
			proj.FallingAccel = 0.01
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.splitCreepLaserUpdate, LaserVariant.THICK_RED)
