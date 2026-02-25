local mod = RestoredMonsterPack

function mod:chubbyBunnyReplace(type, var, stype)
	if LastJudgement and FFGRACE then return end
	if type == mod.ENTITY_INFO.CHUBBY_BUNNY.ID and var == mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT then

		local t = EntityType.ENTITY_FAT_BAT
		local v = 0

		if LastJudgement then
			t = LastJudgement.ENT.EchoBat.ID
			v = LastJudgement.ENT.EchoBat.Var
		elseif FFGRACE then
			t = FFGRACE.ENT.PUFFBAT.id
			v = FFGRACE.ENT.PUFFBAT.variant
		end
		return {t, v, stype}
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.chubbyBunnyReplace)

if not (LastJudgement and FFGRACE) then return end

local game = Game()
local sfx = SFXManager()

local bal = {
	moveSpeed = 2.5,

	dodgeSpeed = 3,
	dodgeRange = 100,

	ringDuration = 120,
	ringRange = 24,
	shotSpeed = 9,

	ringKnockback = 3.5,

	slownessDuration = 50,
}

local params = ProjectileParams()
params.Variant = ProjectileVariant.PROJECTILE_TEAR
params.Color = Color(1,0.6,0,1,0.4,0.2)
params.FallingAccelModifier = -0.1
params.BulletFlags = ProjectileFlags.BOUNCE

function mod:chubbyBunnyUpdate(npc)
	if npc.Variant ~= mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT then return end
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
	if sprite:IsFinished("Death") then
		FFGRACE:MakeSporeExplosion(npc.Position, npc.SpawnerEntity, .75)
	end
	if npc:HasMortalDamage() then
		npc.State = NpcState.STATE_DEATH
		return
	end
	
	if not d.init then
		d.followVec = RandomVector()
		npc.SplatColor = FFGRACE.ColorSporeSplat

		d.state = "idle"

		d.init = true
	end

	if d.state == "idle" then
		LastJudgement:SpritePlay(sprite, "Idle")

		d.stateTimer = d.stateTimer or 80
		if d.stateTimer <= 0 then
			if npc.FrameCount % 8 == 0 
			and npc.Position:Distance(target.Position) < 240 
			and LastJudgement:RandomInt(1,5) == 1 
			and not LastJudgement:isScareOrConfuse(npc) then
					d.stateTimer = nil
					d.state = "shoot"
			end
		end
	elseif d.state == "shoot" then
		LastJudgement:SpritePlay(sprite, "Attack")

		if sprite:IsEventTriggered("Sound") then
			npc:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1.5, 0, false, 1.5)
		elseif sprite:IsEventTriggered("Shoot") then
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized() * bal.shotSpeed * 1, 0, params)
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1.2)
		elseif sprite:IsEventTriggered("Shoot2") then
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized() * bal.shotSpeed * 1.2, 0, params)
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1.2)
		elseif sprite:IsEventTriggered("Shoot3") then
			npc:FireProjectiles(npc.Position, (target.Position - npc.Position):Normalized() * bal.shotSpeed * 1.4, 0, params)
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1.2)
		elseif sprite:IsEventTriggered("Cough") then
			npc:PlaySound(SoundEffect.SOUND_WHEEZY_COUGH, 1.5, 0, false, 1.2)
			for _, proj in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR)) do
				if proj.SpawnerEntity and GetPtrHash(proj.SpawnerEntity) == GetPtrHash(npc) then
					proj:Remove()
					FFGRACE:MakeSporeExplosion(proj.Position, proj.SpawnerEntity, .6)
				end
			end
		end

		if sprite:IsFinished("Attack") then
			d.state = "idle"
		end
	end
	if d.state == "transform" then
		if sprite:IsPlaying("Transform") then
			npc.Velocity = Vector.Zero
		end
		if sprite:IsFinished("Transform") then
			sprite:Play("Idle", true)
			d.state = "idle"
		end
	else
		LastJudgement:DodgeProjectiles(npc, bal.dodgeRange, bal.dodgeSpeed)

		local spinVec = targetpos + d.followVec:Resized(100):Rotated(npc.FrameCount*4)
		local targetvel = ((spinVec - npc.Position):Resized(bal.moveSpeed))
		if npc.Position:Distance(target.Position) < 50 then
				targetvel = ((targetpos - npc.Position):Resized(bal.moveSpeed))
		end
		if LastJudgement:isScare(npc) then targetvel = -targetvel end
		npc.Velocity = LastJudgement:Lerp(npc.Velocity, targetvel, 0.1)

		if d.stateTimer and d.stateTimer > 0 then d.stateTimer = d.stateTimer - 1 end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.chubbyBunnyUpdate, mod.ENTITY_INFO.CHUBBY_BUNNY.ID)

function mod:chubbyBunnyKill(npc)
	if npc.Variant == mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT then
		FFGRACE:MakeSporeExplosion(npc.Position, npc.SpawnerEntity, .75)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.chubbyBunnyKill, mod.ENTITY_INFO.CHUBBY_BUNNY.ID)

function mod:chubbyBunnyProjectileUpdate(projectile)
	if projectile.SpawnerEntity and projectile.SpawnerType == mod.ENTITY_INFO.CHUBBY_BUNNY.ID 
		and projectile.SpawnerVariant == mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT then
		FFGRACE:MakeSporeTrail(projectile, .75)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, mod.chubbyBunnyProjectileUpdate)

function mod:chubbyBunnyProjectileCollision(projectile)
	if projectile.SpawnerEntity and projectile.SpawnerType == mod.ENTITY_INFO.CHUBBY_BUNNY.ID 
		and projectile.SpawnerVariant == mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT then
		projectile:Remove()
		FFGRACE:MakeSporeExplosion(projectile.Position, projectile.SpawnerEntity, .6)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.chubbyBunnyProjectileCollision, ProjectileVariant.PROJECTILE_TEAR)

mod:AddCallback("POST_SPORE_INFECTION", function(_, npc, explosion)
	if npc.Variant == LastJudgement.ENT.EchoBat.Var then
		npc:ToNPC():PlaySound(SoundEffect.SOUND_VAMP_GULP, 1.25)
		return {mod.ENTITY_INFO.CHUBBY_BUNNY.ID, mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT, npc.Subtype}
	end
end, LastJudgement.ENT.EchoBat.ID)
