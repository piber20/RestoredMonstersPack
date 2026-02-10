local mod = RestoredMonsterPack
local game = Game()

---@param ta table
---@param tb table
---@param recurse? boolean
local function MixTables(ta, tb, recurse) --from Revelations
	if ta == nil then
        error("mixin: ta nil", 2)
    elseif tb == nil then
        error("mixin: tb nil", 2)
    end

    for k, v in pairs(tb) do
        if recurse
        and type(ta[k]) == "table"
        and type(v) == "table"
        then
			MixTables(ta[k], v, true)
        else
            ta[k] = v
        end
    end
end

mod.Rooms = {
  {Name = "Glacier", Rooms = require("resources.luarooms.revelations.glacier_rm")},
  {Name = "GlacierSpecial", Rooms = require("resources.luarooms.revelations.glacier_special_rm")},
  {Name = "GlacierChallenge", Rooms = require("resources.luarooms.revelations.glacier_challenge_rm")},
}

mod.BossRooms = {
  {Name = "Stalagmight", Rooms = require("resources.luarooms.revelations.glacier_boss_rm")},
  {Name = "Prong", Rooms = require("resources.luarooms.revelations.glacier_boss_rm")},
  {Name = "Freezer Burn", Rooms = require("resources.luarooms.revelations.glacier_boss_rm")},
  {Name = "Wendy", Rooms = require("resources.luarooms.revelations.glacier_boss_rm")},
  {Name = "Williwaw", Rooms = require("resources.luarooms.revelations.glacier_boss_rm")},

  {Name = "Chuck", Rooms = require("resources.luarooms.revelations.glacier_chuck_rm")},

  {Name = "Punker", Rooms = require("resources.luarooms.revelations.punker_rm")},
  {Name = "Raging Long Legs", Rooms = require("resources.luarooms.revelations.raging_long_legs_rm")},
}

function mod.RoomInit()
	if REVEL then
    -- Add non-boss rooms
  for _,roomlist in ipairs(mod.Rooms) do
  REVEL.RoomLists[roomlist.Name]:AddRooms({Name = "[RM] " .. roomlist.Name, Rooms = roomlist.Rooms})
    -- Add boss rooms
  end
  for _,bossrooms in ipairs(mod.BossRooms) do
    StageAPI.GetBossData(bossrooms.Name).Rooms:AddRooms(bossrooms.Rooms)
  end

mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,mod.RoomInit)
end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE ,mod.RoomInit)

mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, function ()
	if not REVEL then return end
	MixTables(REVEL.EntityReplacements["Glacier"].Replacements, {

		[EntityType.ENTITY_HOPPER] = {
			[1] = {
				[RestoredMonsterPack.ENTITY_INFO.FRACTURE.SUBTYPE] = {
					SPRITESHEET = {
						[0] = "fracture_glacier",
					}
				}
			}
		},
        [mod.ENTITY_INFO.GRAVEROBBER.ID] = {
            [mod.ENTITY_INFO.GRAVEROBBER.VARIANT] = {
                SPRITESHEET = {
                    [0] = "graverobber_body_glacier",
                    [1] = "graverobber_body_glacier",
                    [2] = "graverobber_glacier",
                    [3] = "graverobber_glacier",
                }
            }
        },
        [800] = {
            [0] = {
                SPRITESHEET = {
                    [0] = "rumpling_glacier",
                }
            },
        },
	}, true)

    MixTables(REVEL.EntityReplacements["Tomb"].Replacements, {

        [800] = {
            [0] = {
                SPRITESHEET = {
                    [0] = "rumpling_tomb",
                }
            },
            [1] = {
                SPRITESHEET = {
                    [0] = "skinling_tomb",
                }
            }
        },
    }, true)

end)

-- Ice Hazards
function mod:RumplingIceHazards(npc)
  if npc.Variant == RestoredMonsterPack.ENTITY_INFO.RUMPLING.ID then
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    if not data.RevIceHazard then
        data.RevIceHazard = math.random(0,2)
    end
    sprite:SetLayerFrame(1, data.RevIceHazard)
  end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.RumplingIceHazards, 481)

function mod:RemoveIceHazards(npc)
  if npc.Variant == RestoredMonsterPack.ENTITY_INFO.RUMPLING.ID then
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    if npc.FrameCount < 5 then
        return
    end
    if data.RevIceHazard then
        local entity = Isaac.Spawn(RestoredMonsterPack.ENTITY_INFO.RUMPLING.ID,0, 0, npc.Position, Vector(0,0), npc.SpawnerEntity or npc):ToNPC()
        entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        entity:Update()
        data.FromIceHazard = true

        if REVEL and REVEL.WasRoomClearFromStart() then
            npc:GetData().IceHazardKeepDoorsClosed = true
          if not REVEL.GlacierDoorCloseDoneThisRoom then
            REVEL.room:SetClear(false)
            REVEL.ShutDoors()
            REVEL.GlacierDoorCloseDoneThisRoom = true
          end
        end
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.RemoveIceHazards, 481)

