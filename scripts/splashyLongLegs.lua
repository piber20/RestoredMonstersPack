local mod = RestoredMonsterPack
local game = Game()

local Settings = {
	MoveSpeed = 8,
	DragSpeed = 7,
	Range = 35,
	DragTime = 30
}

local tarBulletColor = Color(0.5,0.5,0.5, 1, 0,0,0)
tarBulletColor:SetColorize(1, 1, 1, 1)



function mod:splashyLongLegsInit(entity)
	if entity.Variant == mod.ENTITY_INFO.SPLASHY.VARIANT or entity.Variant == mod.ENTITY_INFO.STICKY.VARIANT then
		entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.splashyLongLegsInit, mod.ENTITY_INFO.SPLASHY.ID)

function mod:splashyLongLegsUpdate(entity)
	if entity.Variant == mod.ENTITY_INFO.SPLASHY.VARIANT or entity.Variant == mod.ENTITY_INFO.STICKY.VARIANT then
		local sprite = entity:GetSprite()
		local target = entity:GetPlayerTarget()

		-- Enable / Disable hitbox
		if sprite:IsEventTriggered("Splash") then
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			entity:PlaySound(SoundEffect.SOUND_SPIDER_SPIT_ROAR, 0.9, 0, false, 0.9)
			SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 0.9)
			if entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				entity:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
			end

		elseif sprite:IsEventTriggered("Raise") then
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		end

		if entity.FrameCount%30==0 then
			entity:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end


		if entity.State <= 2 then
			entity.State = NpcState.STATE_MOVE

		elseif entity.State == NpcState.STATE_MOVE or entity.State == NpcState.STATE_ATTACK then
			local speed = Settings.MoveSpeed
			local suffix = ""

			if entity.State == NpcState.STATE_ATTACK then
				speed = Settings.DragSpeed
				suffix = "Attack"
			end

			if entity:HasEntityFlags(EntityFlag.FLAG_FEAR) or entity:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
				speed = -speed
			end


			-- Movement
			if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
				entity.Pathfinder:MoveRandomly(false)
			else
				if entity.Pathfinder:HasPathToPos(target.Position) then
					if game:GetRoom():CheckLine(entity.Position, target.Position, 0, 0, false, false) then
						entity.Velocity = (entity.Velocity + ((target.Position - entity.Position):Normalized() * speed - entity.Velocity) * 0.25)

					else
						entity.Pathfinder:FindGridPath(target.Position, speed / 6, 500, false)
					end

				else
					entity.Velocity = (entity.Velocity + (Vector.Zero - entity.Velocity) * 0.25)
				end
			end


			-- Walking animation
			if entity.Velocity:Length() > 0.1 then
				if not sprite:IsPlaying("Walk" .. suffix) then
					sprite:Play("Walk" .. suffix, true)
				end

				-- Tar variant
				if entity.State == NpcState.STATE_ATTACK then
					if entity:IsFrame(3, 0) then
						SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES)

						-- Creep
						local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, entity.Position, Vector.Zero, entity):ToEffect()
						creep.SpriteScale = Vector(1.25, 1.25)
						creep:Update()
					end

					-- Projectiles
					local params = ProjectileParams()
					params.Color = tarBulletColor
					params.FallingAccelModifier = 0.15
					entity:FireBossProjectiles(1, Vector.Zero, 8, params)
				end
			else
				sprite:Play("Idle" .. suffix, true)
			end

			--  Attack
			if entity.State == NpcState.STATE_MOVE and entity.Position:Distance(target.Position) <= Settings.Range then
				entity.State = NpcState.STATE_STOMP
				sprite:Play("Attack", true)

			elseif entity.State == NpcState.STATE_ATTACK then
				if entity.ProjectileCooldown <= 0 then
					entity.State = NpcState.STATE_JUMP
					sprite:Play("Raise", true)
				else
					entity.ProjectileCooldown = entity.ProjectileCooldown - 1
				end
			end


		elseif entity.State == NpcState.STATE_STOMP then
			entity.Velocity = (entity.Velocity + (Vector.Zero - entity.Velocity) * 0.25)

			-- Head slam
			if sprite:IsEventTriggered("Splash") then
				if entity.Variant == mod.ENTITY_INFO.SPLASHY.VARIANT then
					local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 2, entity.Position, Vector.Zero, entity)
					splash.DepthOffset = entity.DepthOffset + 10
					splash:GetSprite():ReplaceSpritesheet(0, "gfx/effects/big_splash02.png")
					splash:GetSprite():LoadGraphics()

					SFXManager():Play(SoundEffect.SOUND_BOSS2_DIVE, 0.8)

					local params = ProjectileParams()
					params.Variant = ProjectileVariant.PROJECTILE_TEAR
					params.FallingAccelModifier = 0.1
					entity:FireBossProjectiles(9, Vector.Zero, 12, params)

				elseif entity.Variant == mod.ENTITY_INFO.STICKY.VARIANT then
					SFXManager():Play(SoundEffect.SOUND_MEAT_JUMPS)

					-- Creep
					local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, entity.Position, Vector.Zero, entity):ToEffect()
					creep.SpriteScale = Vector(1.75, 1.75)
					creep:Update()
				end
			end

			if sprite:IsFinished("Attack") then
				if entity.Variant == mod.ENTITY_INFO.SPLASHY.VARIANT then
					entity.State = NpcState.STATE_MOVE
				elseif entity.Variant == mod.ENTITY_INFO.STICKY.VARIANT then
					entity.State = NpcState.STATE_ATTACK
					entity.ProjectileCooldown = Settings.DragTime
				end
			end


		elseif entity.State == NpcState.STATE_JUMP then
			entity.Velocity = (entity.Velocity + (Vector.Zero - entity.Velocity) * 0.25)

			if sprite:IsEventTriggered("Raise") then
				SFXManager():Play(SoundEffect.SOUND_MEAT_JUMPS)
			end
			if sprite:IsFinished("Raise") then
				entity.State = NpcState.STATE_MOVE
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.splashyLongLegsUpdate, mod.ENTITY_INFO.SPLASHY.ID)

function mod:splashyLongLegsRender(entity)
	if entity.Variant == mod.ENTITY_INFO.SPLASHY.VARIANT or entity.Variant == mod.ENTITY_INFO.STICKY.VARIANT then
		if entity.EntityCollisionClass == EntityCollisionClass.ENTCOLL_ENEMIES
		and entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
			entity:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.splashyLongLegsRender, mod.ENTITY_INFO.SPLASHY.ID)