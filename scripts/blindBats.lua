local mod = RestoredMonsterPack
local game = Game()
local roomrng = RNG()

local BLIND_BAT = mod.ENTITY_INFO.BLIND_BAT
local BEARD_BAT = mod.ENTITY_INFO.BEARD_BAT

local Settings = {
	NumFollowerBats = 3, -- How many follower bats should spawn alongside the leader bat
	ActivationRange = 110, -- Range that players or monsters must be to trigger the bat
	TrackingRange = 200, -- Range that the bat must be from it to keep track of the player
	AttackTime = {60, 120}, -- The amount of frames between each bat charge
	AttackRange = 80, -- Range players must be in to trigger the bat charging
	ChaseSpeed = 4, -- Velocity of bat following its target
	ChargeSpeed = 7, -- How fast the bat charges
	ChargeTime = 18,  -- How long the bat charges for
	ActivatedChargeTime = 1, -- How long the bat charges for after it first is activated
	DirectionChangeTimes = {10, 30}, -- Amount of frames until the bat changes angle directions
	AngleOffset = {15, 60}, -- The angle offset the bat flies with.
	InitialAlertTime = 30, -- The time it takes for the leader bat to alert the follower bats.
	AlertTime = {0, 18} -- The time in between each follower bat being alerted.
}

local States = {
	Hiding = 1,
	Spotted = 2,
	Chasing = 3,
	Charging = 4,
	Transforming = 5,
}

local nextAlertTime = Settings.InitialAlertTime
local batQueue = {}

local function VecLerp(vec1, vec2, percent)
	return vec1 * (1 - percent) + vec2 * percent
end

local function alarmBats(var)
	for _, bat in pairs(Isaac.FindByType(BLIND_BAT.ID, var, -1, false, false)) do
		local data = bat:GetData().BlindBatData
		if (data ~= nil and data.State == States.Hiding) then
			if bat.SubType ~= 10 then --main bat
				data.State = States.Spotted
				bat:GetSprite():Play("Wake", true)

			elseif bat.SubType == 10 then --secondary bats
				table.insert(batQueue, bat)
			end
		end
	end

	nextAlertTime = Settings.InitialAlertTime
end

local function awakenBats(var)
	for _, bat in ipairs(Isaac.FindByType(BLIND_BAT.ID, var or 200 , -1, false, false)) do
		local batNpc = bat:ToNPC()
		local batSprite = bat:GetSprite()
		local batData = bat:GetData().BlindBatData

		if batNpc.State ~= NpcState.STATE_APPEAR and batData ~= nil and batData.State == States.Hiding and bat.SubType ~= 10 then
			batData.State = States.Spotted
			batSprite:Play("Wake", true)
		end
	end
end

local function getAngleOffset(rng, direction)
	local multiplier = 1
	if (direction == "down") then
		multiplier = -1
	end

	return mod:RandomIntBetween(rng, Settings.AngleOffset[1], Settings.AngleOffset[2]) * multiplier
end



function mod:blindBatInit(bat)
	local sprite = bat:GetSprite()
	local rng = bat:GetDropRNG()
	bat.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	bat:GetData().BlindBatData = {
		AttackCountdown = mod:RandomIntBetween(rng, Settings.AttackTime[1], Settings.AttackTime[2]),
		State = States.Hiding,
		ChargeDirection = Vector.Zero,
		AngleCountdown = mod:RandomIntBetween(rng, Settings.DirectionChangeTimes[1], Settings.DirectionChangeTimes[2]),
		AngleOffset = mod:RandomIntBetween(rng, Settings.AngleOffset[1], Settings.AngleOffset[2]),
		AngleDirection = "up",
		MoveVector = Vector.Zero,
		AttackRange = Settings.AttackRange,
		ChargeTime = Settings.ChargeTime,
	}

	if FFGRACE and bat.Variant == BEARD_BAT.VARIANT then
		bat:GetData().BlindBatData.ChargeTime = Settings.ChargeTime * 2
		bat:GetData().BlindBatData.AttackRange = Settings.AttackRange * 2
		bat.SplatColor = FFGRACE.ColorSporeSplat

		if bat:GetData().SporeTransformed then
			bat:GetData().BlindBatData.State = State.Transforming
			sprite:Play("Transform",true)
			bat:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end

	if bat.SubType ~= 10 then --main bat
		sprite:Play("Idle", true)
		if bat.SubType ~= 0 then
			Settings.NumFollowerBats = bat.SubType
		else
			Settings.NumFollowerBats = 3
		end

		for i = 1, Settings.NumFollowerBats do
			local sbat = Isaac.Spawn(BLIND_BAT.ID, bat.Variant, 10, bat.Position + RandomVector():Resized(mod:RandomIntBetween(rng, 1, 50)), bat.Velocity, bat)
			sbat:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end

	elseif bat.SubType == 10 then --secondary bats
		bat:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		sprite:Play("IdleInvisible", true)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.blindBatInit, BLIND_BAT.ID)

function mod:blindBatUpdate(bat)
	local sprite = bat:GetSprite()
	local batData = bat:GetData().BlindBatData
	local batPos = bat.Position
	local target = bat:GetPlayerTarget()
	local rng = bat:GetDropRNG()

	if FFGRACE and bat.Variant == BEARD_BAT.VARIANT then
		if bat:GetData().SporeTransformed and not batData.Trans then
			sprite:Play("Transform",true)
			batData.Trans = true
			batData.State = States.Transforming
		end
		if bat:HasMortalDamage() then
			bat.State = NpcState.STATE_DEATH
		end
	end

	if batData.State == States.Hiding and bat.FrameCount > 1 then
		if bat.SubType ~= 10 then --main bat
			if game:GetNearestPlayer(bat.Position).Position:Distance(batPos) <= Settings.ActivationRange then
				batData.State = States.Spotted
				sprite:Play("Wake", true)
			end

		elseif bat.SubType == 10 then --secondary bats
			sprite:Play("IdleInvisible", true)

			-- local noMainBats = true --theres probably a more efficient way to do this
			-- for  _, ibat in ipairs(Isaac.FindByType(BLIND_BAT.ID, bat.Variant, -1, false, false)) do
			-- 	if ibat.SubType ~= 10 then
			-- 		noMainBats = false
			-- 	end
			-- end
			if Isaac.CountEntities(nil, BLIND_BAT.ID, bat.Variant, -1) <= 0 then --if no main bats exist
				bat:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1.2)
				sprite:Play("FlyDown", true)
				batData.State = States.Spotted
			end
		end


	elseif batData.State == States.Spotted then
		if sprite:IsEventTriggered("Scream") then
			bat:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1.2)
			alarmBats(bat.Variant)
		elseif sprite:IsEventTriggered("Land") then
			bat.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			sprite:Play("Fly", true)
			sprite.Offset = Vector(0,-14)

			batData.AttackCountdown = Settings.ActivatedChargeTime
			batData.ChargeDirection = (target.Position - batPos):Normalized()
			batData.State = States.Charging
		end


	elseif batData.State == States.Chasing then
		batData.MoveVector = VecLerp(((target.Position - batPos):Normalized() * Settings.ChaseSpeed):Rotated(batData.AngleOffset), batData.MoveVector, .2)
		if bat:HasEntityFlags(EntityFlag.FLAG_FEAR) then
			batData.MoveVector = Vector(-batData.MoveVector.X, -batData.MoveVector.Y)
		end

		if bat:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or game:GetNearestPlayer(bat.Position).Position:Distance(batPos) > Settings.TrackingRange then
			bat.Pathfinder:MoveRandomly(false)
			if bat.Velocity:Length() > Settings.ChaseSpeed then
				bat.Velocity = bat.Velocity:Resized(Settings.ChaseSpeed)
			end
		else
			bat.Velocity = (bat.Velocity + (batData.MoveVector - bat.Velocity) * 0.25)
		end

		batData.AttackCountdown = batData.AttackCountdown - 1
		batData.AngleCountdown = batData.AngleCountdown - 1

		if batData.AttackCountdown <= 0 and target.Position:Distance(batPos) <= batData.AttackRange and target.Velocity:Length() > .1 then
			batData.AttackCountdown = batData.ChargeTime
			batData.ChargeDirection = (target.Position - batPos):Normalized()
			batData.State = States.Charging
			sprite:Play("Dash", true)
			bat:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1.2)
			if bat.Variant == BEARD_BAT.VARIANT and FFGRACE then
				FFGRACE:MakeSporeExplosion(bat.Position, bat.SpawnerEntity, .5)
				bat.Velocity = batData.ChargeDirection * Settings.ChargeSpeed * 2
			end
		end

		if batData.AngleCountdown <= 0 then
			if batData.AngleDirection == "up" then
				batData.AngleDirection = "down"
			else
				batData.AngleDirection = "up"
			end
			batData.AngleOffset = getAngleOffset(rng, batData.AngleDirection)
			batData.AngleCountdown = mod:RandomIntBetween(rng, Settings.DirectionChangeTimes[1], Settings.DirectionChangeTimes[2])
		end


	elseif batData.State == States.Charging then

		if bat.Variant == BEARD_BAT.VARIANT and FFGRACE then
			FFGRACE:MakeSporeTrail(bat, 0.25)

			batData.ChargeDirection = VecLerp(batData.ChargeDirection, (target.Position - batPos):Normalized(), .15)
			bat.Velocity = VecLerp(bat.Velocity, batData.ChargeDirection * Settings.ChargeSpeed, .4)
		else
			bat.Velocity = batData.ChargeDirection * Settings.ChargeSpeed
		end
		batData.AttackCountdown = batData.AttackCountdown - 1;

		if batData.AttackCountdown <= 0 then
			batData.AttackCountdown = mod:RandomIntBetween(rng, Settings.AttackTime[1], Settings.AttackTime[2])
			batData.State = States.Chasing
			sprite:Play("Fly", true)
		end


	elseif batData.State == States.Transforming then
		if sprite:IsPlaying("Transform") then
			bat.Velocity = Vector.Zero
		end
		if sprite:IsFinished("Transform") then
			sprite:Play("Fly", true)
			batData.State = States.Chasing
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.blindBatUpdate, BLIND_BAT.ID)

function mod:onBatUpdate()
	nextAlertTime = nextAlertTime - 1

	if nextAlertTime <= 0 then
		if #batQueue > 0 then
			local bat = batQueue[1]
			local batData = bat:GetData().BlindBatData

			if batData ~= nil and batData.State == States.Hiding then
				bat:ToNPC():PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 0, false, 1.2)
				bat:GetSprite():Play("FlyDown", true)
				batData.State = States.Spotted
				roomrng:SetSeed(bat.InitSeed, 35)
			end
		end

		table.remove(batQueue, 1)
		nextAlertTime = mod:RandomIntBetween(roomrng, Settings.AlertTime[1], Settings.AlertTime[2]) or Settings.AlertTime[1]
	end


	local offset = game.ScreenShakeOffset
	local sfx = SFXManager()

	if (offset.X ~= 0 or offset.Y ~= 0)
	or (sfx:IsPlaying(SoundEffect.SOUND_BOSS1_EXPLOSIONS) or sfx:IsPlaying(SoundEffect.SOUND_EXPLOSION_STRONG)
	or sfx:IsPlaying(SoundEffect.SOUND_ROCKET_EXPLOSION) or sfx:IsPlaying(Isaac.GetSoundIdByName("Nightwatch Alert"))
	or sfx:IsPlaying(Isaac.GetSoundIdByName("Screamer Scream"))) then
		awakenBats()
		awakenBats(BEARD_BAT.VARIANT)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onBatUpdate)

function mod:batRemoval(bat)
	for i = 1, #batQueue do
		if GetPtrHash(batQueue[i]) == GetPtrHash(bat) then
			table.remove(batQueue, i)
			break
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.batRemoval, BLIND_BAT.ID)

function mod:batKill(bat)
	if bat.Variant == BEARD_BAT.VARIANT and FFGRACE then
		FFGRACE:MakeSporeExplosion(bat.Position, bat.SpawnerEntity, .75)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.batKill, BLIND_BAT.ID)


-- FFG compatibility
if FFGRACE then
	mod:AddCallback("POST_SPORE_INFECTION", function(_, npc, explosion)
		if npc.Variant ~= BEARD_BAT.VARIANT then
			npc:ToNPC():PlaySound(SoundEffect.SOUND_VAMP_GULP, 1.25)
			return {BLIND_BAT.ID, BEARD_BAT.VARIANT, npc.Subtype}
		end
	end, BLIND_BAT.ID)
end