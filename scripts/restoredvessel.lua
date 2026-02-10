local mod = RestoredMonsterPack
local game = Game()
local Isaac = Isaac

local VESSEL = mod.ENTITY_INFO.VESSEL

local Settings = {
	MaxMaggots = 12,
	MoveSpeed = 1.5,
	StepMaggotSpawnChance = 0.05,
	AttackTime = {30 * 4, 30 * 5},
	MaggotSpeed = 0.2,
	MaggotCounterChance = 0.7,
	MaggotsToShoot = 3,
	GrowlCountdown = 60,
	CreepsToSpawn = 4,
	MaggotsOnDeath = 8
}

local States = {
  Moving = 1,
  Attacking = 2
}

local function mathrandom(rng, a, b)
	return rng:RandomInt(b-a) + a
end

function mod:restoredvesselInit(vessel)
	if vessel.Variant ~= 1 then
	return
	end
	vessel.SplatColor = Color(0.4,0.8,0.4, 1, 0,0.1,0)
	local sprite = vessel:GetSprite()

	sprite:Play("WalkDown", true)
    vessel:GetData().VesselData = {

        State = States.Moving,
        Maggots = 0,
        AttackCountdown = mathrandom(vessel:GetDropRNG(), Settings.AttackTime[1], Settings.AttackTime[2]),   --math.random(Settings.AttackTime[1], Settings.AttackTime[2]),
        CreepSpawned = 0,
        CreepsToSpawn = 0,
        CreepAngles = {},
        GrowlCountdown = Settings.GrowlCountdown,
		MaggotCountdown = mathrandom(vessel:GetDropRNG(), Settings.AttackTime[1], Settings.AttackTime[2]),
    }
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.restoredvesselInit, VESSEL.ID)



function mod:restoredvesselUpdate(vessel)
	if vessel.Variant ~= 1 then
	return
	end

	local vesselData = vessel:GetData().VesselData
    local sprite = vessel:GetSprite()
    local pathfinder = vessel.Pathfinder
    local target = vessel:GetPlayerTarget()
	local angle = vessel.Velocity:GetAngleDegrees()
	local rng = vessel:GetDropRNG()


	if vesselData.State == States.Moving then

		if vessel.SubType == 1
			or vessel.SubType == 2 then
			--[[if angle <= 135 and angle >= 45 then
					sprite:SetAnimation("WalkDown", false)
				elseif angle >= -45 and angle < 45 then
					sprite:SetAnimation("WalkRight", false)
				elseif angle >= -135 and angle < -45 then
					sprite:SetAnimation("WalkUp", false)
				elseif angle < -135 or angle > 135 then
					sprite:SetAnimation("WalkLeft", false)
				end]]
			--vessel.Velocity = vessel.Velocity * 0.05 + (target.Position - vessel.Position):Resized(1.25)
			local spdmult = vessel.SubType == 2 and 2 or 1
			local speed = Settings.MoveSpeed * spdmult
			if vessel:HasEntityFlags(EntityFlag.FLAG_FEAR) or vessel:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
				speed = -speed
			end

			if vessel:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
				pathfinder:MoveRandomly(false)

			else
				if pathfinder:HasPathToPos(target.Position) then
					if game:GetRoom():CheckLine(vessel.Position, target.Position, 0, 0, false, false) then
						vessel.Velocity = (vessel.Velocity + ((target.Position - vessel.Position):Resized(speed) - vessel.Velocity) * 0.175)

					else
						pathfinder:FindGridPath(target.Position, speed / 8, 500, false)
					end

				else
					vessel.Velocity = (vessel.Velocity * 0.75)
				end
			end
		elseif vessel.SubType == 0 then
			--[[if angle <= 135 and angle >= 45 then
					sprite:SetAnimation("WalkDown", false)
				elseif angle >= -45 and angle < 45 then
					sprite:SetAnimation("WalkRight", false)
				elseif angle >= -135 and angle < -45 then
					sprite:SetAnimation("WalkUp", false)
				elseif angle < -135 or angle > 135 then
					sprite:SetAnimation("WalkLeft", false)
				end
			vessel.Velocity = vessel.Velocity * 0.05 + (target.Position - vessel.Position):Resized(1.5)]]

			local speed = Settings.MoveSpeed
			if vessel:HasEntityFlags(EntityFlag.FLAG_FEAR) or vessel:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
				speed = -speed

				if pathfinder:HasPathToPos(target.Position) then
					if game:GetRoom():CheckLine(vessel.Position, target.Position, 0, 0, false, false) then
						vessel.Velocity = (vessel.Velocity + ((target.Position - vessel.Position):Resized(speed) - vessel.Velocity) * 0.25)

					else
						pathfinder:FindGridPath(target.Position, speed / 6, 500, false)
					end

				else
					vessel.Velocity = (vessel.Velocity + (Vector.Zero - vessel.Velocity) * 0.25)
				end
			else
				vessel.Velocity = vessel.Velocity:Resized(speed)
				pathfinder:MoveRandomly(false)
			end
		end
		if angle <= 135 and angle >= 45 or angle == 0 then
            sprite:SetAnimation("WalkDown", false)
        elseif angle >= -45 and angle < 45 then
            sprite:SetAnimation("WalkRight", false)
        elseif angle >= -135 and angle < -45 then
            sprite:SetAnimation("WalkUp", false)
        elseif angle < -135 or angle > 135 then
            sprite:SetAnimation("WalkLeft", false)
        end

		vesselData.AttackCountdown = vesselData.AttackCountdown - 1
		if vesselData.AttackCountdown < 0 then
			vesselData.State = States.Attacking

			local anim =  sprite:GetAnimation()
			if anim == "WalkLeft" then
				sprite:Play("AttackLeft", true)
			elseif anim == "WalkRight" then
                sprite:Play("AttackRight", true)
            else
                sprite:Play("AttackVert", true)
            end

			vessel:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, 1, 0, false, 1)
		end


	elseif vesselData.State == States.Attacking then
		vessel.Velocity = Vector.Zero

        if sprite:IsEventTriggered("Shoot") then
            vesselData.CreepSpawned = 0
            vesselData.CreepAngles = {}

			game:ButterBeanFart(vessel.Position, 100, vessel, false, false) -- fart but don't show
			game:Fart(vessel.Position, 0, vessel)
            vessel:PlaySound(SoundEffect.SOUND_FART, 1, 0, false, 1)

			-- Get creep angles
            for i = 1, Settings.CreepsToSpawn do
                table.insert(vesselData.CreepAngles, mathrandom(rng, 0, 360)) -- math.random(0, 360))
            end

			-- Spawn maggots
            for i = 1, Settings.MaggotsToShoot do
                if vesselData.Maggots < Settings.MaxMaggots then
                    local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(mathrandom(rng, 0, 360)):Resized(mathrandom(rng, 2, 3)), vessel):ToNPC()
                    maggot.V1 = Vector(-10, 10)
                    maggot.I1 = 1
                    maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    maggot.State = NpcState.STATE_SPECIAL
                    vesselData.Maggots = vesselData.Maggots + 1
                else
                    break
                end
            end
        end

		if sprite:IsFinished(sprite:GetAnimation()) then
            vesselData.AttackCountdown = mathrandom(rng, Settings.AttackTime[1], Settings.AttackTime[2])
            vesselData.State = States.Moving

			--vessel.FlipX = false
			sprite:Play("WalkDown")
			vessel:Update()
			return
        end
	end

	if vessel.SubType == 1
		or vessel.SubType == 2 then
		--if sprite:GetFrame() == 16 and math.random() <= Settings.StepMaggotSpawnChance and vesselData.Maggots < Settings.MaxMaggots then

		vesselData.MaggotCountdown = vesselData.MaggotCountdown - 1
		if vesselData.MaggotCountdown < 0    --sprite:GetFrame() == 16 and rng:RandomFloat() <= Settings.StepMaggotSpawnChance*10
		and Isaac.CountEntities(vessel,EntityType.ENTITY_SMALL_MAGGOT) < Settings.MaxMaggots then
			--local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(math.random(0, 360)):Normalized() * math.random(1, 2), vessel):ToNPC()
			local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(rng:RandomInt(361)):Resized(rng:RandomInt(2)+1), vessel):ToNPC()
			maggot.V1 = Vector(-12, 10)
			maggot.I1 = 1
			maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			maggot.State = NpcState.STATE_SPECIAL
			maggotcntdwn_mult = vessel.SubType == 2 and 30 or 0
			vesselData.MaggotCountdown = mathrandom(rng, Settings.AttackTime[1] - maggotcntdwn_mult, Settings.AttackTime[2] - maggotcntdwn_mult)
		end
		if vessel.SubType == 2 and vessel.FrameCount % 8 == 0 then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, vessel.Position, Vector(0, 0), vessel):ToEffect()
			creep.SpriteScale = creep.SpriteScale * 0.5
		end
		--if vessel:IsFrame(math.ceil(8/1), 0) and math.random() <= Settings.StepMaggotSpawnChance and vesselData.Maggots < Settings.MaxMaggots then
		--[[if vessel.FrameCount % 8 == 0 -- vessel:IsFrame(math.ceil(8/1), 0)
		and rng:RandomFloat() <= Settings.StepMaggotSpawnChance*3
		and Isaac.CountEntities(vessel,EntityType.ENTITY_SMALL_MAGGOT) < Settings.MaxMaggots then
			--local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(math.random(0, 360)):Normalized() * math.random(1, 2), vessel):ToNPC()
			local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(rng:RandomInt(361)):Normalized() * (rng:RandomInt(2)+1), vessel):ToNPC()
			maggot.V1 = Vector(-12, 10)
			maggot.I1 = 1
			maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			maggot.State = NpcState.STATE_SPECIAL
		end]]
	end

	vesselData.GrowlCountdown = vesselData.GrowlCountdown - 1

	if vesselData.GrowlCountdown <= 0 then
		vessel:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_1, 1, 0, false, 1)
		vesselData.GrowlCountdown = Settings.GrowlCountdown
	end

	if vessel:IsDead() then
		if vessel.SubType == 0 then
			local phase2 = Isaac.Spawn(VESSEL.ID, 1, 1, vessel.Position, Vector.Zero, vessel):ToNPC()
			phase2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			--[[for i = 1, Settings.CreepsToSpawn do
				table.insert(vesselData.CreepAngles, mathrandom(rng, 0, 360))
			end

			for _, angle in pairs(vesselData.CreepAngles) do
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, (vessel.Position) + Vector.FromAngle(angle):Resized(vesselData.CreepSpawned * 25), Vector(0, 0), vessel)
			if vesselData.CreepSpawned == 1 then
				creep:GetSprite().Scale = Vector(2, 2)
			else
				creep:GetSprite().Scale = Vector(1, 1)
			end]]
		elseif vessel.SubType == 1 then
			local phase3 = Isaac.Spawn(VESSEL.ID, 1, 2, vessel.Position, Vector.Zero, vessel):ToNPC()
			phase3:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			--[[for i = 1, Settings.MaggotsToShoot do
				if Isaac.CountEntities(vessel,EntityType.ENTITY_SMALL_MAGGOT) < Settings.MaxMaggots then
					local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(mathrandom(rng, 0, 360)):Resized(mathrandom(rng, 2, 3)), vessel):ToNPC()
					maggot.V1 = Vector(-10, 10)
					maggot.I1 = 1
					maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					maggot.State = NpcState.STATE_SPECIAL
					vesselData.Maggots = vesselData.Maggots + 1
				else
					break
				end
			end]]
		elseif vessel.SubType == 2 then
			for i = 1, Settings.CreepsToSpawn do
				table.insert(vesselData.CreepAngles, mathrandom(rng, 0, 360))
			end
			vesselData.CreepSpawned = vesselData.CreepSpawned + 1

			for _, angle in pairs(vesselData.CreepAngles) do
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, (vessel.Position) + Vector.FromAngle(angle):Normalized() * (vesselData.CreepSpawned * 25), Vector(0, 0), vessel)
				if vesselData.CreepSpawned == 1 then
					creep:GetSprite().Scale = Vector(2, 2)
				else
					creep:GetSprite().Scale = Vector(1, 1)
				end
			end

		end
	end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.restoredvesselUpdate, VESSEL.ID)

function mod:restoredvesselDeath(vessel)
	if vessel.Variant ~= 1 or vessel.SubType ~= 2 then
		return
	end
	local rng = vessel:GetDropRNG()
    for i = 1, Settings.MaggotsOnDeath do
        local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, Vector.FromAngle(mathrandom(rng, 0, 360)):Resized(mathrandom(rng, 1, 2)), vessel):ToNPC()
        maggot.V1 = Vector(-12, 10)
        maggot.I1 = 1
        maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        maggot.State = NpcState.STATE_SPECIAL
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.restoredvesselDeath, VESSEL.ID)

function mod:restoredvesselDamage(vessel, damageAmount, damageFlags, damageSource, damageCountdownFrames)
	local vesselData = vessel:GetData().VesselData
	local targetPos = damageSource.Entity
	if vessel.Variant ~= 1 or vessel.SubType >= 1 or damageAmount == 0 then
		return
	end


	if Isaac.CountEntities(vessel,EntityType.ENTITY_SMALL_MAGGOT) >= Settings.MaxMaggots
	or vessel:GetDropRNG():RandomFloat() < Settings.MaggotCounterChance then return end

	if not damageSource.Entity then
        local rng = vessel:GetDropRNG()
        targetPos = vessel.Position + Vector(rng:RandomInt(80)-40, rng:RandomInt(80)-40)
    elseif damageSource.Entity.Spawner == nil then
        targetPos = damageSource.Entity.Position
    else
        targetPos = damageSource.Entity.Spawner.Position
    end

    local maggot = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT, 0, 0, vessel.Position, (targetPos - vessel.Position):Resized(7), vessel):ToNPC()
    maggot.V1 = Vector(-8, 10)
    maggot.I1 = 1
    maggot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    maggot.State = NpcState.STATE_SPECIAL
	vesselData.Maggots = vesselData.Maggots + 1
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.restoredvesselDamage, VESSEL.ID)


function mod:maggotDeathrestored(maggot)
	if maggot.SpawnerEntity then
		local spawner = maggot.SpawnerEntity
		local vesselData = spawner:GetData().VesselData

		if spawner.Type == VESSEL.ID and spawner.Variant == 1 and vesselData.Maggots then
			vesselData.Maggots = vesselData.Maggots - 1
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.maggotDeathrestored, EntityType.ENTITY_SMALL_MAGGOT)