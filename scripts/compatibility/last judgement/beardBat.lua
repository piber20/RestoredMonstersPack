local mod = RestoredMonsterPack

function mod:beardBatReplace(type, var, stype)
	if LastJudgement and FFGRACE then return end
	if type == mod.ENTITY_INFO.BEARD_BAT.ID and var == mod.ENTITY_INFO.BEARD_BAT.VARIANT then

		local t = EntityType.ENTITY_ONE_TOOTH
		local v = 0

		if LastJudgement then
			t = LastJudgement.ENT.BlindBat.ID
			v = LastJudgement.ENT.BlindBat.Var
		elseif FFGRACE then
			t = FFGRACE.ENT.GLUEY.id
			v = FFGRACE.ENT.GLUEY.variant
		end
		return {t, v, stype}
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.beardBatReplace)

if not (LastJudgement and FFGRACE) then return end

local game = Game()
local sfx = SFXManager()

local bal = {
	moveSpeed = 4,
	dashSpeed = 7,
	triggerDistance = 80,
	wakeupTimeOffset = {50, 80}
}

function mod:beardBatUpdate(npc)
	if npc.Variant ~= mod.ENTITY_INFO.BEARD_BAT.VARIANT then return end

	local d = npc:GetData()
	local sprite = npc:GetSprite()
	local target = npc:GetPlayerTarget()
	local targetpos = LastJudgement:confusePos(npc, target.Position)
	local room = game:GetRoom()

	if d.SporeTransformed and not d.Trans then
		sprite:Play("Transform",true)
		d.Trans = true
		d.state = "transform"
	end
	if npc:HasMortalDamage() then
		npc.State = NpcState.STATE_DEATH
		return
	end

	if not d.init then
	d.followVec = RandomVector()
	if room:GetFrameCount() <= 1 and npc.SubType ~= 2 then
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.SplatColor = FFGRACE.ColorSporeSplat
		npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

		if npc.Position.Y <= 240 then
			d.placedHigh = true
			npc.PositionOffset = Vector(0, (180 - npc.Position.Y))
		else
			npc.PositionOffset = Vector(0, -20)
		end
		if npc.SubType == 1 then
			d.state = "sleep2"
		else
			d.state = "sleep1"
		end
	else
		d.state = "chase"
		d.substate = 2
		npc.CanShutDoors = true
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		npc.PositionOffset = Vector(0, -20)
	end
	
	if npc.SubType == 0 then
		for i = 1, 3 do
			local freepos = npc.Position + Vector(LastJudgement:RandomInt(15,45),0):Rotated(LastJudgement:RandomInt(1,360))
			local morebat = Isaac.Spawn(mod.ENTITY_INFO.BEARD_BAT.ID, mod.ENTITY_INFO.BEARD_BAT.VARIANT, 1, freepos, Vector.Zero, npc)
			morebat.Parent = npc
			morebat:Update()
		end
	end

		d.init = true
	end

	if d.state == "sleep1" then
		if d.placedHigh then
			LastJudgement:SpritePlay(sprite, "Idle")
		else
			LastJudgement:SpritePlay(sprite, "IdleInvisible")
		end
		npc.Velocity = Vector.Zero

		if game.ScreenShakeOffset:Length() > 0.01 then
			d.state = "chase"
		else
			for playerNum = 1, game:GetNumPlayers() do
				local p = game:GetPlayer(playerNum)
				if p.Position:Distance(npc.Position) < bal.triggerDistance then
					d.state = "chase"
				end
			end
		end

	elseif d.state == "sleep2" then
		LastJudgement:SpritePlay(sprite, "IdleInvisible")
		npc.Velocity = Vector.Zero

		d.wakeupTimer = d.wakeupTimer or LastJudgement:RandomInt(bal.wakeupTimeOffset[1],bal.wakeupTimeOffset[2])

		if npc.Parent and npc.Parent:Exists() and npc.Parent:GetData().state == "chase" then
			if d.wakeupTimer > 0 then
				d.wakeupTimer = d.wakeupTimer - 1
			else
				d.substate = 1
				LastJudgement:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 1.1 + math.random()*0.2, 0.7)
				d.state = "chase"
			end
		end
	
	elseif d.state == "chase" then
		d.substate = d.substate or 0
		
		if d.substate == 0 then
			if d.placedHigh then
				LastJudgement:SpritePlay(sprite, "Wake")
			else
				LastJudgement:SpritePlay(sprite, "WakeInvisible")
			end

			if sprite:IsFinished("Wake") or sprite:IsFinished("WakeInvisible") then
				npc.CanShutDoors = true
				d.substate = 2
			end
		elseif d.substate == 1 then
			LastJudgement:SpritePlay(sprite, "FlyDown")

			if sprite:IsFinished("FlyDown") then
				npc.CanShutDoors = true
				d.substate = 2
			end
		elseif d.substate == 2 then
			LastJudgement:SpritePlay(sprite, "Fly")
		end

		if sprite:IsEventTriggered("Scream") then
			npc.CanShutDoors = true
			LastJudgement:ShutDoors()
			LastJudgement:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 1.1 + math.random()*0.2)
		end

		if sprite:IsEventTriggered("Land") then
			npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
		end

		if sprite:WasEventTriggered("Scream") then
			npc.PositionOffset.Y = LastJudgement:Lerp(npc.PositionOffset.Y, -20, 0.1)
		end

		if sprite:WasEventTriggered("Land") or d.substate >= 1 then
			npc.PositionOffset.Y = LastJudgement:Lerp(npc.PositionOffset.Y, -20, 0.1)
			local spinVec = targetpos + d.followVec:Resized(100):Rotated(npc.FrameCount*4)
			local targetvel = ((spinVec - npc.Position):Resized(bal.moveSpeed))
			if npc.Position:Distance(target.Position) < 50 then
				targetvel = ((targetpos - npc.Position):Resized(bal.moveSpeed))
			end
			if LastJudgement:isScare(npc) then targetvel = -targetvel end
			npc.Velocity = LastJudgement:Lerp(npc.Velocity, targetvel, 0.1)

			
			d.stateTimer = d.stateTimer or 80
			if d.stateTimer <= 0 then
				if npc.FrameCount % 8 == 0 
				and npc.Position:Distance(target.Position) > 80 
				and npc.Position:Distance(target.Position) < 150 
				and LastJudgement:RandomInt(1,20) == 1 
				and not LastJudgement:isScareOrConfuse(npc) then
					d.stateTimer = nil
					d.state = "dash"
					FFGRACE:MakeSporeExplosion(npc.Position, npc.SpawnerEntity, .5)
					LastJudgement:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 1.1 + math.random()*0.2)
				end
			end
		end
	elseif d.state == "dash" then
		LastJudgement:SpritePlay(sprite, "Dash")
		d.stateTimer = d.stateTimer or 20
		d.dashVel = d.dashVel or (target.Position - npc.Position):Resized(bal.dashSpeed)
		npc.Velocity = d.dashVel
		FFGRACE:MakeSporeTrail(npc, 0.25)

		if d.stateTimer <= 0 or room:GetGridCollisionAtPos(npc.Position+npc.Velocity:Resized(50)) > 0 then
			d.stateTimer = nil
			d.dashVel = nil
			d.state = "chase"
		end
	elseif d.state == "transform" then
		if sprite:IsPlaying("Transform") then
			npc.Velocity = Vector.Zero
		end
		if sprite:IsFinished("Transform") then
			sprite:Play("Fly", true)
			d.state = "chase"
			d.substate = 2
		end
	end

	if d.stateTimer and d.stateTimer > 0 then d.stateTimer = d.stateTimer - 1 end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.beardBatUpdate, mod.ENTITY_INFO.BEARD_BAT.ID)

function mod:tryWakeBeardBats(pos, radius)
	pos = pos or game:GetRoom():GetCenterPos()
	radius = radius or 1000
	for i, v in pairs(Isaac.FindByType(mod.ENTITY_INFO.BEARD_BAT.ID)) do
		if v.Variant == mod.ENTITY_INFO.BEARD_BAT.VARIANT and v.SubType == 0 and v.Position:Distance(pos) < radius then
			if v:GetData().state == "sleep1" then
			v:GetData().state = "chase"
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	if eff.FrameCount == 1 then
		mod:tryWakeBeardBats(eff.Position, eff.SpriteScale.X * 800)
	end
end, EffectVariant.BOMB_EXPLOSION)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
	if eff.FrameCount == 1 then
		mod:tryWakeBeardBats(eff.Position, 200)
	end
end, EffectVariant.ROCK_EXPLOSION)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
	if npc.Variant == LastJudgement.ENT.EchoBat.Var and npc:GetData().state == "shoot" 
		and npc:GetSprite():IsEventTriggered("Shoot") then
		mod:tryWakeBeardBats(npc.Position, 200)
	end
end, LastJudgement.ENT.EchoBat.ID)

function mod:beardBatKill(npc)
	if npc.Variant == mod.ENTITY_INFO.BEARD_BAT.VARIANT then
		FFGRACE:MakeSporeExplosion(npc.Position, npc.SpawnerEntity, .75)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.beardBatKill, mod.ENTITY_INFO.BEARD_BAT.ID)

mod:AddCallback("POST_SPORE_INFECTION", function(_, npc, explosion)
	if npc.Variant == LastJudgement.ENT.BlindBat.Var then
		npc:ToNPC():PlaySound(SoundEffect.SOUND_VAMP_GULP, 1.25)
		return {mod.ENTITY_INFO.BEARD_BAT.ID, mod.ENTITY_INFO.BEARD_BAT.VARIANT, npc.Subtype}
	end
end, LastJudgement.ENT.BlindBat.ID)