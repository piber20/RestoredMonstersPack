local mod = RestoredMonsterPack
local game = Game()

local Settings = {
	MoveSpeed = 4,
	RunSpeed = 8,
	ScareRange = 120,
	FleeTime = 210,
}

local States = {
	Appear = 0,
	Moving = 1,
	Running = 2,
	Escape = 3
}


local getAngleDiv = function(a,b)
	local r1,r2
	if a > b then
		r1,r2 = a-b, b-a+360
	else
		r1,r2 = b-a, a-b+360
	end
	return r1>r2 and r2 or r1
end

---@param entity EntityNPC
function mod:grobberInit(entity)
	if entity.Variant == mod.ENTITY_INFO.GRAVEROBBER.VARIANT then
		local data = entity:GetData()
		local sprite = entity:GetSprite()

		entity:ToNPC()
		entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		entity.SplatColor = Color(0.4,0.4,0.4, 1, 0.1,0.1,0.1)

		data.state = States.Appear
		data.storedPickups = {}
		data.noPickups = false

	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.grobberInit, mod.ENTITY_INFO.GRAVEROBBER.ID)

---@param entity EntityNPC
function mod:grobberUpdate(entity)
	if entity.Variant == mod.ENTITY_INFO.GRAVEROBBER.VARIANT then
		local sprite = entity:GetSprite()
		local data = entity:GetData()
		local max_pickups = entity.SubType >> 7
		local flee_timer = (entity.SubType - max_pickups * 2 ^ 7) * 30
		local storedPickups = data.storedPickups and #data.storedPickups or 0


		if data.state == States.Appear or data.state == nil then
			sprite:SetFrame("WalkDown", 0)
			data.state = States.Moving
			entity.Velocity = Vector.Zero


		elseif data.state == States.Moving or data.state == States.Running then
			-- Entities it should run away from
			if not data.scariest or not data.scariest:Exists() or data.scariest:IsDead() or entity.Position:Distance(data.scariest.Position) > Settings.ScareRange * 1.25 then
				local scaries = {}
				local dist = Settings.ScareRange + 1
				local nearest = nil

				-- Get all potential entities
				for i, scary in pairs(Isaac.FindInRadius(entity.Position, Settings.ScareRange, 57)) do
					if scary.Type == EntityType.ENTITY_PLAYER or scary.Type == EntityType.ENTITY_FAMILIAR or scary.Type == EntityType.ENTITY_BOMB
					or (scary.Type > 9 and scary.Type < 1000 and scary.Index ~= entity.Index and (scary:HasEntityFlags(EntityFlag.FLAG_CHARM) or scary:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then
						table.insert(scaries, scary)
					end
				end

				-- Get nearest one
				for i, scary in pairs(scaries) do
					if entity.Pathfinder:HasPathToPos(scary.Position) and scary.Position:Distance(entity.Position) < dist and scary.Position:Distance(entity.Position) <= Settings.ScareRange then
						dist = scary.Position:Distance(entity.Position)
						nearest = scary
					end
				end

				if nearest ~= nil and (storedPickups >= max_pickups or data.noPickups) then
					data.scariest = nearest
					data.state = States.Running
					data.pickup = nil
					data.fleeTime = 0
					data.WdrChTime = 0
					data.WdrNextPoint = nil
				else
					data.scariest = nil
					data.state = States.Moving
				end
			end


			-- Get a target pickup
			if not data.pickup or not data.pickup:Exists() or data.pickup:ToPickup():CanReroll() == false then
				local dist = 9999
				local nearest = nil
				local count = 0

				for i,v in pairs(Isaac.FindInRadius(entity.Position, 1000, EntityPartition.PICKUP)) do
					if v:ToPickup() ~= nil and v:ToPickup():IsShopItem() == false and v:ToPickup():CanReroll() == true and entity.Pathfinder:HasPathToPos(v.Position) and v.Position:Distance(entity.Position) < dist
					and v.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and v.Variant ~= PickupVariant.PICKUP_HAUNTEDCHEST and not v:GetData().graverobber_ignore then -- There are some things that could be blacklisted but don't really have a reason to because they (most likey) won't ever appear along with grave robbers
						local valid = true

						if mod.CustomChests[tostring(v.Variant)] and mod.CustomChests[tostring(v.Variant)].cond then
							valid = mod.CustomChests[tostring(v.Variant)].valid(v)
						elseif mod.CustomChests[tostring(v.Variant) .. "." .. tostring(v.SubType)]
            				and mod.CustomChests[tostring(v.Variant) .. "." .. tostring(v.SubType)].cond then
             				valid = mod.CustomChests[tostring(v.Variant) .. "." .. tostring(v.SubType)].valid(v)
						end

						if valid == true then
							dist = v.Position:Distance(entity.Position)
							nearest = v
							count = count + 1
						end
					end
				end

				if nearest ~= nil then
					data.noPickups = false
					data.pickup = nearest

					if storedPickups < max_pickups then
						data.escapeTime = nil
					end
				end
				if count <= 0 and data.noPickups == false then
					data.noPickups = true

					if not data.escapeTime then
						data.escapeTime = flee_timer
					end
				end
			end

			-- Pick up item / open chest
			for _, pickup in pairs(Isaac.FindInRadius(entity.Position, 16, EntityPartition.PICKUP)) do
				if not entity:IsDead() and not pickup:ToPickup():IsShopItem() and pickup:ToPickup():CanReroll() == true 
				and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and pickup.Variant ~= PickupVariant.PICKUP_HAUNTEDCHEST then
					pickup:GetData().grobber = entity
				end
			end

			-- Escape timer
			if data.waitTime and data.waitTime > 0 then
				data.waitTime = data.waitTime - 1
			elseif data.escapeTime then
				if data.escapeTime <= 0 then
					data.state = States.Escape
					data.escapeTime = nil
				else
					data.escapeTime = data.escapeTime - 1
				end
			end

			-- Wandering
			if data.noPickups == true then
				if not data.WdrNextPoint then
					local nextpos --= entity.Position
					local ep = entity.Position
					local pp = game:GetNearestPlayer(ep).Position
					local mdist = 0
					for i=1, 10 do
						local p = Isaac.GetRandomPosition()
						if entity.Pathfinder:HasPathToPos(p) then
							p = Isaac.GetFreeNearPosition(p,20) or p
							local pdist = p:Distance(pp)
							if pdist > mdist then
								mdist = pdist
								local a1 = (p - ep):GetAngleDegrees()
								local a2 = (pp - ep):GetAngleDegrees()
								local div = getAngleDiv(a1, a2)
								local dist = p:Distance(ep)
								if div > 60 and dist < 220 then
									nextpos = p
								end
							end
						end
					end
					if nextpos then
						local rng = entity:GetDropRNG()
						nextpos = nextpos + Vector(20*(rng:RandomFloat()-.5), 20*(rng:RandomFloat()-.5))
						data.WdrNextPoint = nextpos
						data.WdrChTime = 20
					end
				else
					--if not data.t then
					--	data.t = Isaac.Spawn(1000, EffectVariant.TARGET,0,data.WdrNextPoint,Vector.Zero,nil)
					--else
					--	data.t.Position = data.WdrNextPoint
					--	data.t:ToEffect().Timeout = 60
					--end
					if data.WdrChTime then
						local ep = entity.Position
						data.WdrChTime = data.WdrChTime - 1
						if data.WdrChTime < 0 then
							data.WdrNextPoint = nil
						end
					end
				end
			end


			-- Movement
			local speed = Settings.MoveSpeed
			local anim = "Walk"

			if data.state == States.Running then
				speed = Settings.RunSpeed
				anim = "Run"
			end
			if data.storedPickups and #data.storedPickups > 0 then
				speed = speed - (#data.storedPickups * 1.25 * (speed / 100))
			end


			if entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
				entity.Pathfinder:MoveRandomly(false)

			elseif data.state == States.Moving then
				if data.pickup then
					-- Go towards target pickup, get a new target if it doesn't exist anymore
					if data.pickup:Exists() then
						if game:GetRoom():CheckLine(entity.Position, data.pickup.Position, 0, 0, false, false) then
							entity.Velocity = (entity.Velocity + ((data.pickup.Position - entity.Position):Normalized() * speed - entity.Velocity) * 0.25)
						else
							entity.Pathfinder:FindGridPath(data.pickup.Position, speed / 6, 500, false)
						end
					else
						data.pickup = nil
					end
				else
					-- Wandering
					--entity.Velocity = (entity.Velocity + (Vector.Zero - entity.Velocity) * 0.25)
					local room = game:GetRoom()
					if data.WdrNextPoint then
						if room:CheckLine(entity.Position, data.WdrNextPoint, 0, 0, false, false) then
							local dist = entity.Position:Distance(data.WdrNextPoint)
							entity.Velocity = (entity.Velocity * 0.85 + (data.WdrNextPoint - entity.Position):Resized(speed * 0.15))
							entity.Velocity = entity.Velocity:Resized(math.min(dist/2.5,entity.Velocity:Length()))
						else
							entity.Pathfinder:FindGridPath(data.WdrNextPoint, speed / 6, 500, false)
						end
						for i=1, 4 do
							local spikepos = Vector.FromAngle(45+90*i):Resized(25)
							local spikecheck = room:GetGridEntityFromPos(entity.Position + spikepos)
							if spikecheck then
								local gridtype = spikecheck:GetType()
								if gridtype == GridEntityType.GRID_SPIKES then
									entity.Velocity = entity.Velocity + spikepos * -0.05
								end
							end
						end
					else
						entity.Velocity = (entity.Velocity + (Vector.Zero - entity.Velocity) * 0.25)
					end
				end

			-- Run away
			elseif data.state == States.Running then
				-- Get position to run to
				local vector = entity.Position + ((entity.Position - data.scariest.Position):Normalized() * Settings.ScareRange)
				vector = game:GetRoom():FindFreePickupSpawnPosition(vector, 40, true, false)

				if not (vector:Distance(data.scariest.Position) >= Settings.ScareRange and entity.Pathfinder:HasPathToPos(vector)) then
					for i = 0, 360, 45 do
						vector = vector + (Vector.FromAngle(i) * Settings.ScareRange)
						vector = game:GetRoom():FindFreePickupSpawnPosition(vector, 40, true, false)
						if vector:Distance(data.scariest.Position) >= Settings.ScareRange and entity.Pathfinder:HasPathToPos(vector)
						and (entity.Position + (vector - entity.Position):Normalized() * 40):Distance(data.scariest.Position) >= Settings.ScareRange then
							break
						end
					end
				end
				entity.TargetPosition = vector

				if entity.Pathfinder:HasPathToPos(entity.TargetPosition) then
					if game:GetRoom():CheckLine(entity.Position, entity.TargetPosition, 0, 0, false, false) then
						entity.Velocity = (entity.Velocity + ((entity.TargetPosition - entity.Position):Normalized() * speed - entity.Velocity) * 0.25)
					else
						entity.Pathfinder:FindGridPath(entity.TargetPosition, speed / 6, 500, false)
					end
				end

				-- Escape
				data.fleeTime = data.fleeTime + 1
				if data.fleeTime >= Settings.FleeTime then
					data.state = States.Escape
				end
			end


			-- Get animation direction
			local angleDegrees = entity.Velocity:GetAngleDegrees()

			if angleDegrees > -45 and angleDegrees < 45 then
				data.facing = "Right"
			elseif angleDegrees >= 45 and angleDegrees <= 135 then
				data.facing = "Down"
			elseif angleDegrees < -45 and angleDegrees > -135 then
				data.facing = "Up"
			else
				data.facing = "Left"
			end

			-- Walking animation
			if entity.Velocity:Length() > 0.15 then
				if not sprite:IsPlaying(anim .. data.facing) then
					sprite:Play(anim .. data.facing, true)
				end
			else
				sprite:SetFrame("WalkDown", 0)
			end


		elseif data.state == States.Escape then
			entity.Velocity = Vector.Zero

			if not sprite:IsPlaying("Escape") then
				sprite:Play("Escape", true)
				entity:PlaySound(SoundEffect.SOUND_LITTLE_HORN_GRUNT_2, 1.4, 1, false, 1.1)
			end

			if sprite:IsEventTriggered("Poof") then
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
			if sprite:GetFrame() == 31 then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 1, entity.Position, Vector.Zero, entity):GetSprite().PlaybackSpeed = 1.5
			elseif sprite:GetFrame() == 40 then
				entity:Remove()
			end
		end


		-- Drop stolen items on death
		if entity:HasMortalDamage() and entity:IsDead() and data.storedPickups then
			for i, pickup in pairs(data.storedPickups) do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup[1], pickup[2], entity.Position, Vector(math.random(-4,4), math.random(-4,4)), entity)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.grobberUpdate, mod.ENTITY_INFO.GRAVEROBBER.ID)

local function FFValid(v)
		return v:GetSprite():IsPlaying("Idle")
end

local function FFChest(entity)
  local data = entity:GetData()
	local sprite = entity:GetSprite()
  if sprite:IsPlaying("Idle") then
				data.grobber:GetData().pickup = nil

					--FiendFolio:FFChestOpening(entity, data.grobber) -- Only works with player entities...
					sprite:Play("Open", true)
					entity.SubType = FiendFolio.shopChestStates.Opening
					entity:GetData().Opened = true
					data.grobber:GetData().waitTime = 15
  end
end

local function FFDireChest(entity)
  local data = entity:GetData()
  local sprite = entity:GetSprite()
  if sprite:IsPlaying("Idle") then
				data.grobber:GetData().pickup = nil

  FiendFolio:FFDireChestOpening(entity, data.grobber)
	data.grobber:GetData().waitTime = 60
  end
end

local function FFGlassChest(entity)
  local data = entity:GetData()
  local sprite = entity:GetSprite()
    if sprite:IsPlaying("Idle") then
				data.grobber:GetData().pickup = nil

					sprite:Play("Open", true)
					entity.SubType = FiendFolio.shopChestStates.Opening
					entity:GetData().Opened = true
          FiendFolio:openGlassChest(entity)
					data.grobber:GetData().waitTime = 15
  end
end

local function EPIValid(v)
	return v:GetSprite():IsPlaying("Idle") or v:GetSprite():IsPlaying("Appear")
end

local function EPIChest(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()
	if sprite:IsPlaying("Idle") then
		data.grobber:GetData().pickup = nil
		Epiphany.Pickup.DUSTY_CHEST:OpenChest(entity)
		data.grobber:TakeDamage(15, DamageFlag.DAMAGE_CHEST | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(entity), 0)
		data.grobber:GetData().waitTime = 15
	end

end

local function RRValid(v)
  return v.SubType ~= 1
end

local DummyPlayer = {
  TakeDamage = function (...) end,
  GetPlayerType = function (...) return 1 end,
  HasCollectible = function (...) return false end,
  HasTrinket = function (...) return false end,
  AddWisps = function (...) end,
  Position = Vector(0,0)}

local function RCOpen(entity, func)
local data = entity:GetData()
  if mod.CustomChests[tostring(entity.Variant)].valid(entity) then
    data.grobber:GetData().pickup = nil
    func(entity, DummyPlayer)
    data.grobber:GetData().waitTime = 15
  end
end

local function BFChest(entity)
local data = entity:GetData()
  if mod.CustomChests[tostring(entity.Variant)].valid(entity) then
    data.grobber:GetData().pickup = nil
    battleFantasy:smokyChestPrePickupCollision(entity, Isaac.GetPlayer(0))
    data.grobber:GetData().waitTime = 15
  end
end

mod.CustomChests = {
  ["710"] = {cond = FiendFolio, func = FFChest, valid = FFValid},
  ["711"] = {cond = FiendFolio, func = FFChest, valid = FFValid},
  ["712"] = {cond = FiendFolio, func = FFDireChest, valid = FFValid},
  ["713"] = {cond = FiendFolio, func = FFGlassChest, valid = FFValid},
  [tostring(CARDBOARD_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openCardboardChest) end,
    valid = RRValid},
  [tostring(FILE_CABINET)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openFileCabinet) end,
    valid = RRValid},
  [tostring(SLOT_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openSlotChest) end,
    valid = function (v) return v.SubType ~= 8 end},
  [tostring(TOMB_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openTombChest) end,
    valid = RRValid},
  [tostring(DEVIL_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openDevilChest) end,
    valid = RRValid},
  [tostring(CURSED_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openCursedChest) end,
    valid = RRValid},
  [tostring(BLOOD_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openBloodChest) end,
    valid = function (v) return v.SubType ~= 4 end},
  [tostring(PENITENT_CHEST)] = {cond = RareChests,
    func = function (entity) RCOpen(entity, RareChests.openPenitentChest) end,
    valid = function (v) return v.SubType ~= 8 end},
	["669"] = {cond = Epiphany, func = EPIChest, valid = EPIValid}, --dusty chest
	["590"] = {cond = battleFantasy, func = BFChest, valid = EPIValid}
  }

-- Stolen pickups
function mod:grobberPickup(entity)
	local data = entity:GetData()
	local sprite = entity:GetSprite()

  local key
	if data.grobber then
		local grdata = data.grobber:GetData()
    -- Open chests
		if entity.Variant - (entity.Variant % 10) == 50 or entity.Variant == PickupVariant.PICKUP_LOCKEDCHEST or entity.Variant == PickupVariant.PICKUP_REDCHEST then
			entity:TryOpenChest(nil)
			grdata.pickup = nil
			grdata.waitTime = 15

			if entity:CanReroll() == false then
				-- Take damage from spiked chests
				if entity.Variant == PickupVariant.PICKUP_SPIKEDCHEST then
					data.grobber:TakeDamage(15, DamageFlag.DAMAGE_CHEST, EntityRef(entity), 0)
				end
			end
    elseif mod.CustomChests[tostring(entity.Variant)] then
      key = tostring(entity.Variant)
    elseif mod.CustomChests[tostring(entity.Variant) .. "." .. tostring(entity.SubType)] then
      key = tostring(entity.Variant) .. "." .. tostring(entity.SubType)
		-- Pick up item
		else
			if not sprite:IsPlaying("Collect") then
				local addTo = true
				sprite:Play("Collect", true)
				grdata.pickup = nil
				-- Check if it's not a chest
				if sprite:IsPlaying("Collect") then
					data.grobbed = true

					-- FF compatibility
					if FiendFolio then
						-- Spicy keys
						if entity.Variant == PickupVariant.PICKUP_KEY and entity.SubType >= 179 then
							data.grobber:TakeDamage(10, DamageFlag.DAMAGE_FIRE, EntityRef(entity), 0)

						-- Blood bags
						elseif entity.Variant == 666 then
							FiendFolio:bloodsackburst(entity, true)
							addTo = false
						end
					end
				else
					addTo = false
					entity:GetData().graverobber_ignore = true
				end

				if addTo == true then
					local pData = {entity.Variant, entity.SubType}
					table.insert(grdata.storedPickups, pData)

					if #grdata.storedPickups >= data.grobber.SubType >> 7
						and not grdata.escapeTime then
						grdata.escapeTime = (data.grobber.SubType - (data.grobber.SubType >> 7) * 2 ^ 7) * 30
					end
				end
			end
		end

    -- Custom chests / pickups
    if key then
      if mod.CustomChests[key].cond then
        mod.CustomChests[key].func(entity, Isaac.GetPlayer(0))
      end
    end

		data.grobber = nil
	end

	if data.grobbed then
		if sprite:IsPlaying("Collect") and sprite:GetFrame() == 4 then
			entity:PlayPickupSound()
			entity:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.grobberPickup)
