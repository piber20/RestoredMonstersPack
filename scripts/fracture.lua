local mod = RestoredMonsterPack
local game = Game()

local Settings = {
	SpeedMultiplier = 0.85,
	MaxJumpShots = 5
}

local States = {
	NoSpit = 0,
	JumpSpit = 1,
	StandSpit = 2
}

local FRACTURE = RestoredMonsterPack.ENTITY_INFO.FRACTURE

function mod:fractureInit(entity)
	if entity.Variant == FRACTURE.VARIANT
	and entity.SubType == FRACTURE.SUBTYPE then
		local sprite = entity:GetSprite()
		local level = game:GetLevel()
		local stage = level:GetStage()

		-- Ashpit(Scarred Womb) skins
		if not StageAPI and (stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2) then
			local stype = level:GetStageType()
			if stype == StageType.STAGETYPE_AFTERBIRTH then
				local altSkin = "_scarred_womb"
				if entity:IsChampion() then
					altSkin = altSkin .. "_champion"
				end

				for i = 0, sprite:GetLayerCount() do
					sprite:ReplaceSpritesheet(i, "gfx/monsters/restored/fracture/fracture" .. altSkin .. ".png")
				end
				sprite:LoadGraphics()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.fractureInit, FRACTURE.ID)

function mod:fractureUpdate(entity)
	if entity.Variant == FRACTURE.VARIANT
	and entity.SubType == FRACTURE.SUBTYPE then
		local sprite = entity:GetSprite()
		local data = entity:GetData()
		local level = game:GetLevel()

		entity.Velocity = entity.Velocity * Settings.SpeedMultiplier
		-- 50% chance to do spit attack after jumping
		if sprite:IsPlaying("Hop") and sprite:GetFrame() == 25 then
			if math.random(1, 10) <= 4 then
				sprite:Play("Spit", true)
			end

			entity.Velocity = Vector.Zero
			entity.TargetPosition = entity.Position
		end


		if sprite:IsEventTriggered("SpitBegin") then
			if sprite:IsPlaying("Hop") then
				data.state = States.JumpSpit
				entity.I2 = 0
			else
				data.state = States.StandSpit

				-- Blood effect
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 3, entity.Position, Vector.Zero, entity):GetSprite()
				effect.Offset = Vector(0, -10)

				if level:GetStage() == LevelStage.STAGE1_1 or level:GetStage() == LevelStage.STAGE1_2 then
					if level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
						effect.Color = Color(0.2, 0.8, 0.9, 1, 0.4,0.8,1.6)
					elseif level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B then
						effect.Color = Color(0.4, 1.2, 0.8, 1, 0.15,0.2,0.15)
					end
				end
			end

		elseif sprite:IsEventTriggered("SpitEnd") then
			data.state = States.NoSpit
		end


		-- Projectiles
		if data.state ~= nil then
			local params = ProjectileParams()
			params.FallingSpeedModifier = 2

			-- Different projectile colors for Downpour and Dross
			if level:GetStage() == LevelStage.STAGE1_1 or level:GetStage() == LevelStage.STAGE1_2 then
				if level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
					params.Variant = ProjectileVariant.PROJECTILE_TEAR
				elseif level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B then
					params.Variant = ProjectileVariant.PROJECTILE_PUKE
				end
			end

			if data.state == States.JumpSpit then
				if math.random(0, 1) == 1 and entity.I2 <= Settings.MaxJumpShots then
					entity:FireBossProjectiles(1, entity.TargetPosition, 1.5, params)
					entity.I2 = entity.I2 + 1
				end

			elseif data.state == States.StandSpit then
				entity:FireBossProjectiles(1, Vector.Zero, 7.5, params)
				entity:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 0.8, 0, false, 1)
			end

		else
			data.state = States.NoSpit
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.fractureUpdate, FRACTURE.ID)
