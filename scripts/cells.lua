local mod = RestoredMonsterPack
local game = Game()

local Settings = {
	CellSpeed = 4,
	FusedSpeed = 3.5,
	TissueSpeed = 3,
	DirectionChangeTimes = {10, 30},
	AngleOffset = {15, 35},
	FuseCooldown = 45,
	SplitToIdle = 20
}

local States = {
	Dead = 0,
	Moving = 1,
	Split = 2,
	FuseAppear = 3,
	SplitAppear = 4,
	Crash = 5
}



local function getAngleOffset(direction)
	local multiplier = 1
	if (direction == "down") then
		multiplier = -1
	end

	return math.random(Settings.AngleOffset[1], Settings.AngleOffset[2]) * multiplier
end

local function noFriendlyCells(entity)
	if not (entity:HasEntityFlags(EntityFlag.FLAG_CHARM) or entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
		return true
	end
end



function mod:cellsInit(entity)
	if entity.Variant == mod.ENTITY_INFO.CELL.VARIANT or entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT or entity.Variant == mod.ENTITY_INFO.TISSUE.VARIANT then
		local data = entity:GetData()
		local sprite = entity:GetSprite()

		entity:ToNPC()
		data.fuseCooldown = Settings.FuseCooldown
		data.angleCountdown = math.random(Settings.DirectionChangeTimes[1], Settings.DirectionChangeTimes[2])
		data.angleOffset = math.random(Settings.AngleOffset[1], Settings.AngleOffset[2])
		data.angleDirection = "up"
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.cellsInit, mod.ENTITY_INFO.FUSEDCELLS.ID)

function mod:cellsUpdate(entity)
	if entity.Variant == mod.ENTITY_INFO.CELL.VARIANT or entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT or entity.Variant == mod.ENTITY_INFO.TISSUE.VARIANT then
		local sprite = entity:GetSprite()
		local data = entity:GetData()
		local target = entity:GetPlayerTarget()


		if data.state == nil then
			data.state = States.Moving

		-- Chasing
		elseif data.state == States.Moving then
			local speed = Settings.CellSpeed
			if entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT then
				speed = Settings.FusedSpeed
			elseif entity.Variant == mod.ENTITY_INFO.TISSUE.VARIANT then
				speed = Settings.TissueSpeed
			end

			-- Movement
			data.vector = ((target.Position - entity.Position):Normalized() * speed):Rotated(data.angleOffset)
			if entity:HasEntityFlags(EntityFlag.FLAG_FEAR) or entity:HasEntityFlags(EntityFlag.FLAG_SHRINK) then
				data.vector = Vector(-data.vector.X, -data.vector.Y)
			end
			if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
				entity.Pathfinder:MoveRandomly(false)
			else
				entity.Velocity = (entity.Velocity + (data.vector - entity.Velocity) * 0.25)
			end

			-- Change direction
			if data.angleCountdown > 0 then
				data.angleCountdown = data.angleCountdown - 1
			end

			if data.angleCountdown <= 0 then
				if data.angleDirection == "up" then
					data.angleDirection = "down"
				else
					data.angleDirection = "up"
				end
				data.angleOffset = getAngleOffset(data.angleDirection)
				data.angleCountdown = math.random(Settings.DirectionChangeTimes[1], Settings.DirectionChangeTimes[2])
			end

			if not sprite:IsPlaying("Idle") then
				sprite:Play("Idle", true)
			end

			-- Target another cell to fuse with
			if entity.Variant ~= mod.ENTITY_INFO.TISSUE.VARIANT then
				if data.fuseCooldown <= 0 and noFriendlyCells(entity) == true then
					for _,v in pairs(Isaac.GetRoomEntities()) do
						if v.Type == mod.ENTITY_INFO.FUSEDCELLS.ID and v.Variant == entity.Variant and v.Index ~= entity.Index then
							entity.Target = v
						end
					end
				else
					data.fuseCooldown = data.fuseCooldown - 1
				end
			end


		-- Go back to chasing after fusing / splitting
		elseif data.state == States.FuseAppear then
			data.fuseCooldown = Settings.FuseCooldown

			if entity.Variant == mod.ENTITY_INFO.CELL.VARIANT then
				if not sprite:IsPlaying("SplitEnd") then
					sprite:Play("SplitEnd", true)
					entity:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, 1, 1, false, 1)
					entity.Velocity = entity.Velocity * 0.5
				end
				if sprite:GetFrame() == 7 then
					data.state = States.Moving
					entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				end

			else
				entity.Velocity = Vector.Zero
				if not sprite:IsPlaying("Fuse") then
					sprite:Play("Fuse", true)
					entity:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 0.75, 1, false, 1)
				end
				if sprite:GetFrame() == 21 then
					data.state = States.Moving
				end
			end


		-- Flying split cells
		elseif data.state == States.SplitAppear then
			if data.splitDir ~= nil then
				entity.Velocity = data.splitDir
				if not sprite:IsPlaying("SplitLoop") then
					sprite:Play("SplitLoop", true)
				end

				-- Crash into walls
				local room = game:GetRoom()
				data.xStart = room:GetTopLeftPos().X + 15
				data.xEnd = room:GetBottomRightPos().X - 15
				data.yStart = room:GetTopLeftPos().Y + 15
				data.yEnd = room:GetBottomRightPos().Y - 15

				if (entity.Position.X > data.xEnd or entity.Position.X < data.xStart)
				or (entity.Position.Y > data.yEnd or entity.Position.Y < data.yStart) then
					data.state = States.Crash

					if entity.Position.X > data.xEnd then
						sprite.FlipX = true
					elseif entity.Position.Y > data.yEnd then
						sprite.Rotation = -90
						sprite.Offset = Vector(14, 5)
					elseif entity.Position.Y < data.yStart then
						sprite.Rotation = 90
						sprite.Offset = Vector(-14, -5)
					end
				end

				-- Go to chase state
				if data.splitToIdle <= 0 then
					data.state = States.FuseAppear
				else
					data.splitToIdle = data.splitToIdle - 1
				end
			end


		-- Crashed
		elseif data.state == States.Crash then
			entity.Velocity = Vector.Zero
			if not sprite:IsPlaying("Crash") then
				sprite:Play("Crash", true)
				entity:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1.25, 1, false, 1)
			end

			if sprite:GetFrame() == 29 then
				sprite.Rotation = 0
				sprite.FlipX = false
				sprite.Offset = Vector(0,0)
				data.state = States.FuseAppear
			end
		end


		-- Death animation
		if entity:HasMortalDamage() and entity.Variant ~= mod.ENTITY_INFO.CELL.VARIANT then
			entity.State = NpcState.STATE_DEATH
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.cellsUpdate, mod.ENTITY_INFO.FUSEDCELLS.ID)

function mod:cellsCollide(entity, target, bool)
	local data = entity:GetData()

	if entity.Variant == mod.ENTITY_INFO.CELL.VARIANT or entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT and bool == true and data.fuseCooldown <= 0 and noFriendlyCells(entity) == true then
		if target.Type == mod.ENTITY_INFO.FUSEDCELLS.ID and target.Variant == entity.Variant and target:GetData().fuseCooldown <= 0 and noFriendlyCells(target) == true then
			target:Remove()
			entity:Morph(mod.ENTITY_INFO.FUSEDCELLS.ID, entity.Variant + 1, 0, -1)
			entity.HitPoints = ((entity.Variant % 10) * 2) * 16
			entity.Position = (entity.Position + (target.Position - entity.Position) * 0.5)
			data.state = States.FuseAppear
			return true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.cellsCollide, mod.ENTITY_INFO.FUSEDCELLS.ID)

-- Don't hurt the cell it's targeting
function mod:cellsHit(target, damageAmount, damageFlags, damageSource, damageCountdownFrames)
	if (target.Variant == mod.ENTITY_INFO.CELL.VARIANT or target.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT) and damageSource.Type == mod.ENTITY_INFO.FUSEDCELLS.ID
	and (damageSource.Variant == mod.ENTITY_INFO.CELL.VARIANT or damageSource.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT)
	and noFriendlyCells(target) == true and noFriendlyCells(damageSource.Entity) == true then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.cellsHit, mod.ENTITY_INFO.FUSEDCELLS.ID)

-- Split on death
function mod:cellsRender(entity)
	local sprite = entity:GetSprite()
	if (entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT or entity.Variant == mod.ENTITY_INFO.TISSUE.VARIANT) and sprite:IsEventTriggered("Explosion") and entity:GetData().state ~= States.Dead then
		entity:GetData().state = States.Dead

		-- Cells
		local spawnedCells = {}
		for i = 0, ((entity.Variant % 10) * 2) - 1 do
			spawnedCells[i + 1] = Isaac.Spawn(mod.ENTITY_INFO.FUSEDCELLS.ID, mod.ENTITY_INFO.CELL.VARIANT, 0, entity.Position, Vector.Zero, entity)
			spawnedCells[i + 1]:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			spawnedCells[i + 1]:GetData().state = States.SplitAppear
			spawnedCells[i + 1]:GetData().splitToIdle = Settings.SplitToIdle
			spawnedCells[i + 1].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		end

		if entity.Variant == mod.ENTITY_INFO.FUSEDCELLS.VARIANT then
			-- Projectiles
			local params = ProjectileParams()
			params.CircleAngle = 0.52
			entity:FireProjectiles(entity.Position, Vector(9, 6), 9, params)

			-- Cell directions
			spawnedCells[1]:GetData().splitDir = Vector(-9,0)
			spawnedCells[2]:GetData().splitDir = Vector(9,0)

		elseif entity.Variant == mod.ENTITY_INFO.TISSUE.VARIANT then
			-- Projectiles
			local params1 = ProjectileParams()
			params1.CircleAngle = 0.45
			entity:FireProjectiles(entity.Position, Vector(9, 8), 9, params1)

			local params2 = ProjectileParams()
			params2.CircleAngle = 0.02
			params2.Scale = 1.5
			entity:FireProjectiles(entity.Position, Vector(5, 4), 9, params2)

			-- Cell directions
			spawnedCells[1]:GetData().splitDir = Vector(-6,-6)
			spawnedCells[2]:GetData().splitDir = Vector(6,-6)
			spawnedCells[3]:GetData().splitDir = Vector(-6,6)
			spawnedCells[4]:GetData().splitDir = Vector(6,6)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.cellsRender, mod.ENTITY_INFO.FUSEDCELLS.ID)