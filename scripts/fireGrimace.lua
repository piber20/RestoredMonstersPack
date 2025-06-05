local mod = RestoredMonsterPack
local FIRE_GRIMACE = mod.ENTITY_INFO.FIRE_GRIMACE



function mod:fireGrimaceUpdate(entity)
	if entity.Variant == 2500 then
		local sprite = entity:GetSprite()

		if sprite:IsEventTriggered("FireStart") then
			entity.I1 = 1

		elseif sprite:IsEventTriggered("FireStop") then
			entity.I1 = 0
			SFXManager():Play(SoundEffect.SOUND_FLAMETHROWER_END, 1.25)

		elseif sprite:IsEventTriggered("Sound") then
			if entity.State == NpcState.STATE_ATTACK then
				SFXManager():Play(SoundEffect.SOUND_FLAMETHROWER_START, 1.25)
			else
				SFXManager():Play(SoundEffect.SOUND_STEAM_HALFSEC)
			end
		end


		-- Cooldown
		if sprite:IsFinished(sprite:GetAnimation()) then
			entity.ProjectileCooldown = 45
		end

		if entity.ProjectileCooldown <= 0 then
			entity.State = NpcState.STATE_ATTACK

		else
			if entity.State == NpcState.STATE_ATTACK then
				entity.State = NpcState.STATE_IDLE
			end
			entity.ProjectileCooldown = entity.ProjectileCooldown - 1
		end


		-- Attack
		if sprite:IsPlaying("CloseEyes") then
			entity.I1 = 0
		end

		if entity.I1 == 1 then
			if entity.I2 <= 0 then
				local params = ProjectileParams()
				params.BulletFlags = (ProjectileFlags.FIRE | ProjectileFlags.HIT_ENEMIES)
				params.Variant = ProjectileVariant.PROJECTILE_FIRE
				params.Color = Color(2,1.8,1.8, 1, 0,-1,-1)
				params.FallingSpeedModifier = 2

				local offset = Vector(-10, 18)
				if entity.SubType == 1 then
					offset = Vector(0, 10)
					params.DepthOffset = entity.DepthOffset - 5
				elseif entity.SubType == 2 then
					offset = Vector(10, 18)
				elseif entity.SubType == 3 then
					offset = Vector(0, 10)
				end

				entity:FireProjectiles(entity.Position + offset, Vector.FromAngle(180 + (entity.SubType * 90) + math.random(-5, 5)) * 9, 0, params)
				entity.I2 = 1

			else
				entity.I2 = entity.I2 - 1
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.fireGrimaceUpdate, EntityType.ENTITY_BRIMSTONE_HEAD)

function mod:fireGrimaceProjectileCollision(projectile, target, bool)
	if projectile.SpawnerType == EntityType.ENTITY_BRIMSTONE_HEAD and projectile.SpawnerVariant == FIRE_GRIMACE.VARIANT and target:ToNPC() then
		if (target.Type == EntityType.ENTITY_GAPER and target.Variant == 1)
		or ((target.Type == EntityType.ENTITY_CLOTTY or target.Type == EntityType.ENTITY_HOPPER or target.Type == EntityType.ENTITY_FATTY
		or target.Type == EntityType.ENTITY_ROCK_SPIDER or target.Type == EntityType.ENTITY_GYRO) and target.Variant == 0) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0, target.Position, Vector.Zero, projectile.SpawnerEntity)
		end

		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.fireGrimaceProjectileCollision, ProjectileVariant.PROJECTILE_FIRE)