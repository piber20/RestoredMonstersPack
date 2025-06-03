local mod = RestoredMonsterPack
local game = Game()



-- Fart helper function
local function fart(npc)
	local visible = false
	local player_position = npc:GetPlayerTarget().Position

	-- Dumpling
	if npc.Variant == EntityVariant.DUMPLING then
		visible = true

	-- Skinling
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.SKINLING.VARIANT then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, npc.Position, Vector.Zero, npc) -- green fart

		local partition = EntityPartition.PLAYER
		if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			partition = 40
		elseif npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			partition = EntityPartition.ENEMY
		end

		for i, e in pairs(Isaac.FindInRadius(npc.Position, 70, partition)) do
			if e.Index ~= npc.Index and not e:IsInvincible() then
				local dmg = 5
				local multiplier = 1

				if npc:IsChampion() then
					multiplier = 2
				end
				if e.Type == EntityType.ENTITY_PLAYER then
					dmg = 1
				else
					e:AddPoison(EntityRef(npc), 64, 2)
				end

				e:TakeDamage(dmg * multiplier, DamageFlag.DAMAGE_POISON_BURN, EntityRef(npc), 0)
			end
		end

	-- Scab
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.SCAB.VARIANT then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 1, npc.Position, Vector.Zero, npc) -- red fart

		local params = ProjectileParams()
		params.CircleAngle = 0
		npc:FireProjectiles(npc.Position, Vector(10, 6), 9, params)

	-- Scorchling
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.SCORCHLING.VARIANT then
		visible = true
		local spawned_fire = Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 10, 0, npc.Position, Vector(0,0), npc)
        spawned_fire.HitPoints = 3.0

	-- Mortling
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.MORTLING.VARIANT then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, npc.Position, Vector.Zero, npc) -- green fart

		local params = ProjectileParams()
		params.Scale = 2
		params.BulletFlags = ProjectileFlags.WIGGLE
		npc:FireProjectiles(npc.Position, Vector(3, 3), 9, params) -- in Vector(6, 6), the first 6 is the speed, second 6 is the amount of shots


		local partition = EntityPartition.PLAYER
		if npc:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			partition = 40
		elseif npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			partition = EntityPartition.ENEMY
		end

		for i, e in pairs(Isaac.FindInRadius(npc.Position, 70, partition)) do
			if e.Index ~= npc.Index and not e:IsInvincible() then
				local dmg = 5
				local multiplier = 1

				if npc:IsChampion() then
					multiplier = 2
				end
				if e.Type == EntityType.ENTITY_PLAYER then
					dmg = 1
				else
					e:AddPoison(EntityRef(npc), 64, 2)
				end

				e:TakeDamage(dmg * multiplier, DamageFlag.DAMAGE_POISON_BURN, EntityRef(npc), 0)
			end
		end

        local spawned_cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, npc.Position, Vector(0,0), npc)
        spawned_cloud:ToEffect():SetTimeout(200)

	-- Tainted Dumpling
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.TAINTED_DUMPLING.VARIANT then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, npc.Position, Vector.Zero, npc) -- green fart

        local params = ProjectileParams()
        params.Variant = ProjectileVariant.PROJECTILE_STAPLE
        local staple_projectile = npc:FireBossProjectiles(1, player_position, 0, params)
        local poop_params = ProjectileParams()
        poop_params.Variant = ProjectileVariant.PROJECTILE_PUKE
        npc:FireBossProjectiles(1, player_position, 0, poop_params)
        npc:FireBossProjectiles(2, Vector(0,0), 0, ProjectileParams())

	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT then
	    local rng = npc:GetDropRNG()

		visible = true
	    for var=0,3 do
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, npc.Position, Vector(rng:RandomInt(6)-3,rng:RandomInt(6)-3), npc)
        end
	elseif FFGRACE and npc.Variant == RestoredMonsterPack.ENTITY_INFO.SPORELING.VARIANT then
		FFGRACE:MakeSporeExplosion(npc.Position, npc.SpawnerEntity)
	end

	game:ButterBeanFart(npc.Position, 85, npc, visible, false)
end

-- Helper function to apply velocity to and flip a Dumpling's sprite
local function add_velocity_and_flip(npc, velocity)
    npc:AddVelocity(velocity)
    npc:GetSprite().FlipX = (velocity.X < 0)
end



function mod:dumplingUpdate(npc)
    local sprite = npc:GetSprite()
    local player_position = npc:GetPlayerTarget().Position
    local player_angle = (player_position - npc.Position):GetAngleDegrees()
    local feared = npc:HasEntityFlags(EntityFlag.FLAG_FEAR)
	local rng = npc:GetDropRNG()
    local fartData = npc:GetData()["Farting"]


	npc.Visible = true -- fixes some of them becoming invisible

	if npc.State == NpcState.STATE_IDLE then -- if idling
		sprite:Play("Idle")

		if FFGRACE and npc.Variant == RestoredMonsterPack.ENTITY_INFO.SPORELING.VARIANT and not feared then --redefine target for sporeling
			local closestDistance, closestTarget
			for _, enemy in ipairs(Isaac.GetRoomEntities()) do
				if mod:EntityInList(enemy, mod.sporeTransformable) then

					local distanceToSporeling = enemy.Position:Distance(npc.Position)
					if not closestDistance or closestDistance > distanceToSporeling then
						closestTarget = enemy:ToNPC()
						closestDistance = distanceToSporeling
					end
				end
			end

			if closestTarget then
				player_position = closestTarget.Position
				player_angle = (player_position - npc.Position):GetAngleDegrees()
			end

			npc.SplatColor = FFGRACE.ColorSporeSplat
		end


		if player_position:Distance(npc.Position) < 100 then -- if player is close
			npc.State = NpcState.STATE_ATTACK
			sprite:Play("Fart")

		elseif (feared or npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT) and rng:RandomInt(16) == 1 then -- move feared
			npc.State = NpcState.STATE_MOVE
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + 180) * Vector(rng:RandomInt(3)+3, rng:RandomInt(3)+3))
			sprite:Play("Move")

		elseif (npc.Variant == EntityVariant.DUMPLING or npc.Variant == RestoredMonsterPack.ENTITY_INFO.SKINLING.VARIANT or npc.Variant == RestoredMonsterPack.ENTITY_INFO.SCORCHLING.VARIANT or npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT or npc.Variant == RestoredMonsterPack.ENTITY_INFO.SPORELING.VARIANT) and rng:RandomInt(20) == 1 and not feared then -- move toward player slow
			npc.State = NpcState.STATE_MOVE
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(160) - 80)) * Vector(rng:RandomInt(3)+3, rng:RandomInt(3)+3))
			sprite:Play("Move")

		elseif (npc.Variant == RestoredMonsterPack.ENTITY_INFO.SCAB.VARIANT or npc.Variant == RestoredMonsterPack.ENTITY_INFO.MORTLING.VARIANT) and rng:RandomInt(12) == 1 and not feared then -- move towards player
			npc.State = NpcState.STATE_MOVE
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(160) - 80)) * Vector(rng:RandomInt(3)+3, rng:RandomInt(3)+3))
			sprite:Play("Move")

		elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.TAINTED_DUMPLING.VARIANT and rng:RandomInt(3) == 1 and not feared then -- tainted aggressive move towards player
			npc.State = NpcState.STATE_MOVE
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(90) - 45)) * Vector(rng:RandomInt(3)+5, rng:RandomInt(3)+5))
			sprite:Play("Move")

		end


	elseif npc.State == NpcState.STATE_MOVE then -- if moving
		if sprite:IsFinished("Move") then
			npc.State = NpcState.STATE_IDLE
		end


	elseif npc.State == NpcState.STATE_ATTACK then -- if farting
		if sprite:IsEventTriggered("Fart") then
			fart(npc)
			-- print("attack1 fart")
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + 180) * Vector(rng:RandomInt(3)+9, rng:RandomInt(3)+9))

		elseif sprite:IsFinished("Fart") then
			npc.State = NpcState.STATE_IDLE

		elseif fartData >= 0 then --
			npc:GetData()["Farting"] = fartData + 1
			if (fartData % 12 == 0) then
				-- print("attack1 fartdata")
				fart(npc, false)
				add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(120)-60) + 180) * Vector(rng:RandomInt(3)+6, rng:RandomInt(3)+6))
			elseif (fartData % 4 == 0) then
				npc:FireBossProjectiles(1, Vector(0,0), 0, ProjectileParams())
				add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(120)-60) + 180) * Vector(rng:RandomInt(3)+2, rng:RandomInt(3)+2))
			end
		elseif sprite:IsEventTriggered("FartStart") then --
			npc:GetData()["Farting"] = 0
		elseif sprite:IsEventTriggered("FartEnd") then --
			npc:GetData()["Farting"] = -1
		end

	elseif npc.State == NpcState.STATE_ATTACK2 then -- if farting from taken damage
		if sprite:IsEventTriggered("Fart") then
			-- print("attack2 fart")
			fart(npc)
			add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(90)-45) + 180) * Vector(rng:RandomInt(3)+1, rng:RandomInt(3)+1))

		elseif sprite:IsFinished("Fart") then
			npc.State = NpcState.STATE_IDLE

		elseif fartData >= 0 then --
			npc:GetData()["Farting"] = fartData + 1
			if (fartData % 8 == 0) then
				-- print("attack2 fartdata")
				fart(npc, false)
				add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(90)-45) + 180) * Vector(rng:RandomInt(3)+6, rng:RandomInt(3)+6))
			elseif (fartData % 3 == 0) then
				npc:FireBossProjectiles(1, Vector(0,0), 0, ProjectileParams())
				add_velocity_and_flip(npc, Vector.FromAngle(player_angle + (rng:RandomInt(120)-60) + 180) * Vector(rng:RandomInt(3)+2, rng:RandomInt(3)+2))
			end
			npc:GetData()["HurtAttackCooldown"] = rng:RandomInt(3) + 1
		elseif sprite:IsEventTriggered("FartStart") then --
			npc:GetData()["Farting"] = 0
		elseif sprite:IsEventTriggered("FartEnd") then --
			npc:GetData()["Farting"] = -1
		end


	elseif npc.State == NpcState.STATE_INIT then -- if newly spawned
		npc.State = NpcState.STATE_IDLE

		if npc.Variant == RestoredMonsterPack.ENTITY_INFO.SKINLING.VARIANT then
			npc.SplatColor = Color(0.6,0.8,0.6, 1, 0,0.1,0)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.dumplingUpdate, RestoredMonsterPack.ENTITY_INFO.DUMPLING.ID)

function mod:dumplingInit(npc)
	local rng = npc:GetDropRNG()
    if npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT then
        npc:GetData()["CoinCounter"] = rng:RandomInt(3)+3
    end
    npc:GetData()["Farting"] = -1
    npc:GetData()["HurtAttackCooldown"] = 0
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.dumplingInit, RestoredMonsterPack.ENTITY_INFO.DUMPLING.ID)

-- Fart on damage
function mod:dumplingDMG(entity, amount, dmg_flags, source)
	local npc = entity:ToNPC()
	local rng = entity:GetDropRNG()
	if amount == 0 then return end
	if npc.Variant == RestoredMonsterPack.ENTITY_INFO.TAINTED_DUMPLING.VARIANT and npc:GetData()["HurtAttackCooldown"] > 0 then -- tainted damage cooldown
        npc:GetData()["HurtAttackCooldown"] = npc:GetData()["HurtAttackCooldown"] - 1
	elseif npc.Variant == RestoredMonsterPack.ENTITY_INFO.SCORCHLING.VARIANT and dmg_flags == DamageFlag.DAMAGE_FIRE then
		return false
	elseif not npc:HasMortalDamage() then
		npc.State = NpcState.STATE_ATTACK2
		entity:GetSprite():Play("Fart")
	end
	if npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT and rng:RandomInt(2) == 1 and npc:GetData()["CoinCounter"] > 0 then -- drop fixed amount of coins
        npc:GetData()["CoinCounter"] = npc:GetData()["CoinCounter"] - 1
        for var=1,rng:RandomInt(2) do -- spawn coins
            if rng:RandomInt(16) == 1 then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, npc.Position, Vector((rng:RandomInt(6)-3)*2,(rng:RandomInt(6)-3)*2), npc) -- 1/16 dime chance
            else
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, npc.Position, Vector((rng:RandomInt(6)-3)*2,(rng:RandomInt(6)-3)*2), npc)
            end
        end
        for var=0,8 do -- spawn gibs
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, npc.Position, Vector((rng:RandomInt(6)-3)*3,(rng:RandomInt(6)-3)*3), npc)
        end
    end

end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.dumplingDMG, RestoredMonsterPack.ENTITY_INFO.DUMPLING.ID)

-- Fart on death
function mod:dumplingDeath(entity)
    local rng = entity:GetDropRNG()
	local npc = entity:ToNPC()
    if npc.Variant == RestoredMonsterPack.ENTITY_INFO.TAINTED_DUMPLING.VARIANT then -- tainted explosion
        game:ButterBeanFart(npc.Position, 100, npc, true, true)
        game:Fart(npc.Position, 100, npc, 2)
        local params = ProjectileParams()
        params.Variant = ProjectileVariant.PROJECTILE_STAPLE
        local staple_projectile = npc:FireBossProjectiles(2, Vector(0,0), 0, params)
        npc:FireBossProjectiles(10, Vector(0,0), 0, ProjectileParams())
        local poop_params = ProjectileParams()
        poop_params.Variant = ProjectileVariant.PROJECTILE_PUKE
        npc:FireBossProjectiles(8, Vector(0,0), 0, poop_params)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector(0, 0), npc)
        entity:PlaySound(SoundEffect.SOUND_MOTHER_WRIST_EXPLODE, 2, 0, false, 1)
	else
		-- print("death")
		fart(entity)
	end
	if npc.Variant == RestoredMonsterPack.ENTITY_INFO.GILDED_DUMPLING.VARIANT then -- if also gilded, spawn coins
        for var=0,rng:RandomInt(3)+1 do -- spawn coins
            if rng:RandomInt(16) == 1 then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, npc.Position, Vector((rng:RandomInt(6)-3)*2,(rng:RandomInt(6)-3)*2), npc) -- 1/16 dime chance
            else
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, npc.Position, Vector((rng:RandomInt(6)-3)*2,(rng:RandomInt(6)-3)*2), npc)
            end
        end
        for var=0,12 do -- spawn gibs
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, npc.Position, Vector((rng:RandomInt(6)-3)*6,(rng:RandomInt(6)-3)*6), npc)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.dumplingDeath, RestoredMonsterPack.ENTITY_INFO.DUMPLING.ID)

function mod:NPCProjectileInit(projectile_npc)
    local rng = projectile_npc:GetDropRNG()
    local sprite = projectile_npc:GetSprite()
    if rng:RandomInt(2) == 1 then
        sprite:Play("MoveBig")
    else
        sprite:Play("MoveSmall")
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, mod.NPCProjectileInit, ProjectileVariant.PROJECTILE_STAPLE)

function mod:NPCProjectileDeath(projectile_npc)
    local rng = projectile_npc:GetDropRNG()
    if (projectile_npc.Variant == ProjectileVariant.PROJECTILE_STAPLE) then
        for var=0,2 do -- spawn nail gibs
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.NAIL_PARTICLE, 0, projectile_npc.Position, Vector(rng:RandomInt(6)-3,rng:RandomInt(6)-3), projectile_npc)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.NPCProjectileDeath, 9)