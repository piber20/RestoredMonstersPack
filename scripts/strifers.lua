local mod = RestoredMonsterPack
local game = Game()

local Settings = {
	MoveSpeed = 5.35,
	AttackSpeed = 4,
	Cooldown = 60,
	ShotSpeed = 11,
	SideRange = 80,
	TargetRange = 340
}



function StriferTurnAround(entity)
	local data = entity:GetData()

	if data.movetype == "vertical" then
		data.vector = Vector(data.vector.X, -data.vector.Y)
	elseif data.movetype == "horizontal" then
		data.vector = Vector(-data.vector.X, data.vector.Y)
	end

	data.delay = 7
end



function mod:StriferInit(entity)
	local data = entity:GetData()
	local stage = game:GetLevel():GetStage()

	entity:ToNPC()
	entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	entity.Mass = 50
	data.shot = 0
	entity.ProjectileCooldown = math.random(0, Settings.Cooldown - 20) + 20

	data.altSkin = ""
	if (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2) and game:GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE_B
  and entity.Variant == 200 then
		data.altSkin = "_gehenna"
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.StriferInit, mod.ENTITY_INFO.STRIFER.ID)

function mod:StriferUpdate(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()
	local target = entity:GetPlayerTarget()
	local moveto = entity.TargetPosition
	local speed = Settings.MoveSpeed
	local path = entity.Pathfinder
  local room = Game():GetRoom()


	-- Set variant if not set yet
	if data.facing == nil or data.movetype == nil then
		local ret
    --[[
		if entity.Variant == 200 or entity.Variant == mod.ENTITY_INFO.FOREVER_FRIEND.VARIANT then
			ret = entity.Variant
			entity.Variant = entity.SubType
			entity.SubType = 0
		end
    ]]--
		local enterd = game:GetLevel().EnterDoor

		-- Multi directional ones
		-- Left / Right
		if entity.SubType == 4 or (entity.SubType == 6 and enterd % 2 == 0) then -- All left and right doors have an even numbered ID
			if target.Position.X <= entity.Position.X then
				entity.SubType = 0

			else -- >=
				entity.SubType = 2
			end

		-- Up / Down
		elseif entity.SubType == 5 or (entity.SubType == 6 and enterd % 2 ~= 0) then
			if target.Position.Y <= entity.Position.Y then
				entity.SubType = 1

			else -- >=
				entity.SubType = 3
			end
		end


		-- Set movement directions
		if entity.SubType == 0 or entity.SubType == 2 then
			data.movetype = "vertical"
		elseif entity.SubType == 1 or entity.SubType == 3 then
			data.movetype = "horizontal"
		end

		-- Set attack directions
		if     entity.SubType == 0 then data.facing = "Left"
		elseif entity.SubType == 1 then data.facing = "Up"
		elseif entity.SubType == 2 then data.facing = "Right"
		elseif entity.SubType == 3 then data.facing = "Down"
  end

		-- Set spritesheets
		if data.altSkin ~= "" then
			local ischamp = ""
			if entity:IsChampion() == true then
				ischamp = "_champion"
			end

			for i = 0, sprite:GetLayerCount() - 1 do
				sprite:ReplaceSpritesheet(i, "gfx/monsters/restored/strifer/strifer" .. data.altSkin .. ischamp .. ".png")
			end
			sprite:LoadGraphics()
		end

    --[[
		if ret then
			entity.Variant = ret
		end
    ]]--
	end


	-- Sprite
	entity:AnimWalkFrame("WalkHori", "WalkVert", 0.1)

	if data.facing == "Left" then -- Makes sure the head doesn't flip from tear knockback
		sprite.FlipX = true
	elseif data.facing == "Right" then
		sprite.FlipX = false
	end


	-- Set random starting direction if it doesn't have one
	if not data.vector then
		local startDir = 1
		if entity.Index % 2 == 1 then
			startDir = -1
		end

		if data.movetype == "vertical" then
			data.vector = Vector(0, startDir * Settings.MoveSpeed)
		elseif data.movetype == "horizontal" then
			data.vector = Vector(startDir * Settings.MoveSpeed, 0)
		end
	end


	-- Get target position
	if data.movetype == "vertical" then
		moveto = Vector(entity.Position.X, target.Position.Y)
	elseif data.movetype == "horizontal" then
		moveto = Vector(target.Position.X, entity.Position.Y)
	end

  -- Forever Friend target position
  if TheFuture and entity.Variant == mod.ENTITY_INFO.FOREVER_FRIEND.VARIANT then
    if data.movetype == "vertical" and TheFuture.ScreenwrapStatus == TheFuture.WrapType.VERT then
      local sign = 1
      if entity.Position.Y - target.Position.Y > 0 then
        sign = -1
      end
      if math.abs(entity.Position.Y - target.Position.Y) <
      room:GetClampedPosition(Vector(entity.Position.X , entity.Position.Y + (room:GetGridHeight() * 40) * sign),0):Distance( room:GetClampedPosition(Vector(entity.Position.X, target.Position.Y - (room:GetGridHeight() * 40) * sign),0))
      then
        moveto = Vector(entity.Position.X, target.Position.Y)
      else
        moveto = Vector(entity.Position.X, room:GetCenterPos().Y - sign * room:GetCenterPos().Y)
      end
    elseif data.movetype == "horizontal" and TheFuture.ScreenwrapStatus == TheFuture.WrapType.HORI then
      local sign = 1
      if entity.Position.X - target.Position.X > 0 then
        sign = -1
      end
      if math.abs(entity.Position.X - target.Position.X) <
      room:GetClampedPosition(Vector(entity.Position.X + (room:GetGridWidth() * 40) * sign,entity.Position.Y),0):Distance( room:GetClampedPosition(Vector(target.Position.X - (room:GetGridWidth() * 40) * sign,entity.Position.Y),0))
      then
        moveto = Vector(target.Position.X, entity.Position.Y)
      else
        moveto = Vector(room:GetCenterPos().X - sign * room:GetCenterPos().X, entity.Position.Y)
      end
    end
  end


	-- Check if target is close enough
	local function StriferInRange(side, foreverfriend)
		local data = entity:GetData()

		if data.movetype == "vertical" then
			if entity.Position.Y <= moveto.Y + side and entity.Position.Y >= moveto.Y - side then
				if data.facing == "Left" and target.Position.X > (entity.Position.X - Settings.TargetRange) and target.Position.X < entity.Position.X
				or data.facing == "Right" and target.Position.X < (entity.Position.X + Settings.TargetRange) and target.Position.X > entity.Position.X
        or foreverfriend then
					return true
				end
			end

		elseif data.movetype == "horizontal" then
			if entity.Position.X <= moveto.X + side and entity.Position.X >= moveto.X - side then
				if data.facing == "Up" and target.Position.Y > (entity.Position.Y - Settings.TargetRange) and target.Position.Y < entity.Position.Y
				or data.facing == "Down" and target.Position.Y < (entity.Position.Y + Settings.TargetRange) and target.Position.Y > entity.Position.Y
        or foreverfriend then
					return true
				end
			end
		end
	end


	-- Attacking
	if entity.ProjectileCooldown > 0 then
		if not sprite:IsOverlayPlaying("Head" .. data.facing) then
			sprite:PlayOverlay("Head" .. data.facing)
		end
		entity.ProjectileCooldown = entity.ProjectileCooldown - 1

	else
		if StriferInRange(Settings.SideRange,  entity.Variant == mod.ENTITY_INFO.FOREVER_FRIEND.VARIANT)
    and game:GetRoom():CheckLine(entity.Position, target.Position, 3, 0, false, false)
    and room:IsPositionInRoom(entity.Position, -20) then
			if not sprite:IsOverlayPlaying("Attack" .. data.facing) then
				sprite:PlayOverlay("Attack" .. data.facing)
			end
		end

		if sprite:GetOverlayFrame() == 7 then
			entity:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, 1, 1, false, 1)
			speed = Settings.AttackSpeed

		elseif sprite:GetOverlayFrame() == 8 or sprite:GetOverlayFrame() == 12 or sprite:GetOverlayFrame() == 16 or sprite:GetOverlayFrame() == 20 then
			if data.shot ~= sprite:GetOverlayFrame() then -- stops them from shooting twice when slowed
				local shootx = 0
				local shooty = 0

				if     data.facing == "Left"  then shootx = -Settings.ShotSpeed
				elseif data.facing == "Up"    then shooty = -Settings.ShotSpeed
				elseif data.facing == "Right" then shootx =  Settings.ShotSpeed
				elseif data.facing == "Down"  then shooty =  Settings.ShotSpeed
				end
        local params = ProjectileParams()
        if entity.Variant == mod.ENTITY_INFO.FOREVER_FRIEND.VARIANT then

         local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FCUK, 0, entity.Position, Vector(shootx,shooty),entity):ToProjectile()
            proj:AddProjectileFlags(ProjectileFlags.CONTINUUM)
            if data.movetype == "horizontal" then
            proj.FallingAccel = -0.043
            else
            proj.FallingAccel = -0.067
            end
            proj:GetData().ForceDefaultColor = true
        else
          entity:FireProjectiles(entity.Position, Vector(shootx, shooty), 0, params)
        end

				data.shot = sprite:GetOverlayFrame()
			end

		elseif sprite:GetOverlayFrame() == 24 then
			speed = Settings.MoveSpeed
		end

		if sprite:IsOverlayFinished("Attack" .. data.facing) then
			entity.ProjectileCooldown = Settings.Cooldown
		end
	end


	-- Movement
	-- Fix for them getting stuck sometimes
	if entity:CollidesWithGrid() and not data.delay then
			StriferTurnAround(entity)
	end

	if not data.delay then
		-- Move towards target if it's close enough
		if StriferInRange(Settings.TargetRange,  entity.Variant == mod.ENTITY_INFO.FOREVER_FRIEND.VARIANT) == true
    and entity.Position:Distance(moveto) > 10 and not entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
			if entity:HasEntityFlags(EntityFlag.FLAG_FEAR) or entity:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
				data.vector = (moveto - entity.Position):Normalized() * -speed

			else
				data.vector = (moveto - entity.Position):Normalized() * speed
			end
		end

		-- Turn around when colliding with a grid entity
		if entity:CollidesWithGrid() then
			StriferTurnAround(entity)
		end

	else
		data.delay = data.delay - 1
		if data.delay <= 0 then
			data.delay = nil
		end
	end

	entity.Velocity = (entity.Velocity + (data.vector - entity.Velocity) * 0.25)

end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.StriferUpdate, mod.ENTITY_INFO.STRIFER.ID)

function mod:StriferCollision(entity, target, cum)
	local data = entity:GetData()

	-- Turn around when colliding with another enemy
	if not data.delay and target:IsActiveEnemy(false) and target.Type ~= EntityType.ENTITY_GRUDGE then
		StriferTurnAround(entity)

	-- Fix for them not working properly with Grudges
	elseif target.Type == EntityType.ENTITY_GRUDGE then
		entity.Velocity = target.Velocity

		if entity:CollidesWithGrid() then
			entity:Kill()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.StriferCollision, mod.ENTITY_INFO.STRIFER.ID)