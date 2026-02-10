RestoredMonsterPack = RegisterMod("Restored Monster Pack", 1)
CutMonsterPack = RestoredMonsterPack
local mod = RestoredMonsterPack
local game = Game()

--[[--------------------------------------------------------
    Enums
--]]--------------------------------------------------------
---@display RestoredMonsterPack Enum Table
---@class RMEnum
---@field ID EntityType
---@field VARIANT integer
---@field SUBTYPE integer

---@param name string
---@param subtype integer | nil
---@return RMEnum
local function makeEnumTable(name, subtype)
	if not subtype then subtype = 0 end
	return {
		ID = Isaac.GetEntityTypeByName(name),
		VARIANT = Isaac.GetEntityVariantByName(name),
		SUBTYPE = REPENTOGON and Isaac.GetEntitySubTypeByName(name) or subtype,
	}
end

-- Monsters
-- To get the information of an entity, type RestoredMonsterPack.ENTITY_INFO.NAME_OF_THE_MONSTER then ID for EntityType, VARIANT for EntityVariant and SUBTYPE for Subtype
RestoredMonsterPack.ENTITY_INFO = {
	RUMPLING = makeEnumTable("Rumpling"),
	SKINLING = makeEnumTable("Skinling"),
	SCABLING = makeEnumTable("Scab"),
	SCORCHLING = makeEnumTable("Scorchling"),
	MORTLING = makeEnumTable("Mortling"),
	TAINTED_RUMPLING = makeEnumTable("Tainted Rumpling"),
	GILDED_RUMPLING = makeEnumTable("Gilded Rumpling"),
	SPORELING = makeEnumTable("Sporeling"),
	-- Already Existing Entities
	FRACTURE = makeEnumTable("​Fracture", 801),
	SWAPPER = makeEnumTable("Swapper"),
	BARFY = makeEnumTable("Barfy"),
	STRIFER = makeEnumTable("​Strifer"),
	FIRE_GRIMACE = makeEnumTable("Fire Grimace"),
	VESSEL = makeEnumTable("Vessel (RM)"),
	VESSEL_ANTIBIRTH = makeEnumTable("​Vessel (Antibirth)"),
	-- New Entity Variants
	NECROMANCER = makeEnumTable("Necromancer"),
	SCREAMER = makeEnumTable("Screamer"),
	RED_TNT = makeEnumTable("Red TNT"),
	CELL = makeEnumTable("Cell"),
	FUSEDCELLS = makeEnumTable("Fused Cells"),
	TISSUE = makeEnumTable("Tissue"),
	GRAVEROBBER = makeEnumTable("Grave Robber"),
	SPLASHY = makeEnumTable("Splashy Long Legs"),
	STICKY = makeEnumTable("Sticky Long Legs"),
	SPLIT_RAGE_CREEP = makeEnumTable("​Split Rage Creep")
	-- Mod Compact Enemies
	CHUBBY_BUNNY = makeEnumTable("Chubby Bunny"),
	BEARD_BAT = makeEnumTable("Beard Bat"),
	FOREVER_FRIEND = makeEnumTable("Forever Friend"),
}


-- Projectile variants
ProjectileVariant.PROJECTILE_STAPLE = 108

-- Effect variants
EffectVariant.SCREAMER_AURA = 867


--[[--------------------------------------------------------
    Util functions
--]]--------------------------------------------------------

function mod:RandomIntBetween(rng, value1, value2)
	return rng:RandomInt(value2 - value1) + value1
end


--[[--------------------------------------------------------
    DSS and savedata should (likely) be loaded first
--]]--------------------------------------------------------

include("scripts.deadseascrolls.save_manager")
include("scripts.deadseascrolls.savedata")
include("scripts.deadseascrolls.dssmain")
include("scripts.deadseascrolls.changelogs")
include("scripts.deadseascrolls.imgui")

--[[--------------------------------------------------------
    External monster files to require
--]]--------------------------------------------------------

include("scripts.cells")
include("scripts.graverobber")
include("scripts.splashyLongLegs")
include("scripts.fireGrimace")
include("scripts.bloodworm")
include("scripts.rumplings")
include("scripts.fracture")
include("scripts.necromancer")
include("scripts.swappers")
include("scripts.barfy")
include("scripts.strifers")
include("scripts.vessel")
include("scripts.screamer")
include("scripts.redTNT")
include("scripts.restoredvessel")
include("scripts.splitRageCreep")

--[[--------------------------------------------------------
    misc
--]]--------------------------------------------------------

include("scripts.revelCompat")
include("scripts.compatibility.retribution.baptismal_preloader")
include("scripts.compatibility.retribution.rm_downgrades")
include("scripts.compatibility.retribution.rm_upgrades")
include("scripts.compatibility.fallfromgrace")
include("scripts.compatibility.thefuture.futurecompact")
if StageAPI then
	include("scripts.compatibility.fiend folio.rm_genders")
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not mod.fiendfolioTablesMixed then
		if FiendFolio then
			mod.MixFiendFolioStuff()
		end
	end
end)

--[[--------------------------------------------------------
    Blacklists
--]]--------------------------------------------------------

local necromancer_blacklist = {
	{EntityType.ENTITY_BONY, -1, mod.ENTITY_INFO.NECROMANCER.VARIANT}, -- Bonys spawned by Necromancers
	{EntityType.ENTITY_LITTLE_HORN, 1, -1}, -- Dark ball
	{EntityType.ENTITY_RAG_MEGA, 1, -1}, -- Purple ball
	{EntityType.ENTITY_BIG_BONY, 10, -1}, -- Bouncing bone
}

-- Add / remove blacklist entry
function mod:RMblacklistentry(blacklist, Type, Variant, SubType, operation)
	-- Error checking
	if blacklist ~= "Necromancer" then
		print("[RM] Error adding / removing blacklist entry:\n   Incorrect blacklist: " .. blacklist)
	end
	if operation ~= "add" and operation ~= "remove" then
		print("[RM] Error adding / removing blacklist entry:\n   Unknown operation: " .. operation)
		return false
	end

	-- Get blacklist
	local checkList = {}
	if blacklist == "Necromancer" then
		checkList = necromancer_blacklist
	end

	-- Add / remove
	for i,entry in pairs(checkList) do
		if operation == "add" then
			if entry[1] == Type and entry[2] == Variant and entry[3] == SubType then
				print("[CMP] Error adding blacklist entry:\n   Entry already exists")
				return false
			end

		elseif operation == "remove" then
			if entry[1] == Type and entry[2] == Variant and entry[3] == SubType then
				table.remove(checkList, i)
				return true
			end
		end
	end

	if operation == "add" then
		table.insert(checkList, {Type, Variant, SubType})
		return true

	elseif operation == "remove" then
		print("[CMP] Error removing blacklist entry:\n   Entry doesn't exist")
		return false
	end
end

-- Check if the entity is in the blacklist or not
function mod:inAMLblacklist(blacklist, checkType, checkVariant, checkSubType)
	if blacklist ~= "Necromancer" then
		print("[CMP] Error checking blacklist:\n   Incorrect blacklist: " .. blacklist)
		return
	end

	local checkList = {}
	if blacklist == "Necromancer" then
		checkList = necromancer_blacklist
	end

	for i,entry in pairs(checkList) do
		if checkType == entry[1] and (entry[2] == -1 or checkVariant == entry[2]) and (entry[3] == -1 or checkSubType == entry[3]) then
			return true
		end
	end
	return false
end

mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.replaceID)

function mod:replaceByDummy(Type, Variant, SubType, _, _, _, Seed)
	if REPENTOGON and Isaac.GetPersistentGameData():Unlocked(Achievement.THE_GATE_IS_OPEN) == false and mod.UnlockReplace[Type.." "..Variant.." "..SubType] or mod.UnlockReplace[Type.." "..Variant] then
		local t = mod.UnlockReplace[Type.." "..Variant.." "..SubType] or mod.UnlockReplace[Type.." "..Variant]
		return {t[1], t[2], t[3], Seed}
	end

	if mod.DummyReplace[Type] then
		if mod.DummyReplace[Type][Variant] then
			return {Type, mod.DummyReplace[Type][Variant], SubType, Seed}
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.replaceByDummy)

mod.DummyReplace = {
	[mod.ENTITY_INFO.VESSEL.ID] = {[0] = mod.ENTITY_INFO.VESSEL_ANTIBIRTH.VARIANT}, --200},
	[EntityType.ENTITY_RAGE_CREEP] = {[1] = Isaac.GetEntityVariantByName("​Split Rage Creep")}, --200},
	[EntityType.ENTITY_WALL_CREEP] = {[2] = Isaac.GetEntityVariantByName("​Rag Creep")}, --200},
	},

-- Replaces Fractures if The Lamb has not been defeated
mod.UnlockReplace = {
	[EntityType.ENTITY_HOPPER.." ".. 1 .." "..RestoredMonsterPack.ENTITY_INFO.FRACTURE.SUBTYPE] = {EntityType.ENTITY_HOPPER, 1, -1}, --trite
	[RestoredMonsterPack.ENTITY_INFO.FRACTURE.SUBTYPE.." ".. 0 .." ".. 0] = {EntityType.ENTITY_HOPPER, 1, -1}, --trite
}

local ign = false
function mod:MostDumbThing(ent)
	local dumb = mod.DumbhackReplace[ent.Type]
	if dumb then
		local ovar,vvar = dumb[1], dumb[2]

		if not ign and ent.Variant == vvar and ent.FrameCount > 1 then
			ign = true
			local spr = ent:GetSprite()
			local pos = ent.Position/1
			local frame = spr:GetFrame()
			ent.Variant = ovar
			if frame > 0 then
				spr:SetFrame(frame-1)
			end
			ent:Update()
			ent.Variant = vvar
			ent.Position = pos
			ign = false
			return true
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, 1000, mod.MostDumbThing)
mod.DumbhackReplace = {
	--[EntityType.ENTITY_RAGE_CREEP] = {1, Isaac.GetEntityVariantByName("​Split Rage Creep")},
	[EntityType.ENTITY_WALL_CREEP] = {2, Isaac.GetEntityVariantByName("​Rag Creep")},
}

---uh thx tt ig???????
function mod:Shuffle(tbl)
	for i = #tbl, 2, -1 do
    local j = mod:RandomInt(1, i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end