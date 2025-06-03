local mod = RestoredMonsterPack
if FFGRACE then
    local basepath = "gfx/monsters/"


    --boiler
    FFGRACE.StageSkins.Boiler[RestoredMonsterPack.ENTITY_INFO.DUMPLING.ID.." "..0] = {
                {{0}, basepath.."boiler/dumpling_boiler"},
            }

    table.insert(FFGRACE.Rooms.Boiler, include("resources.luarooms.ffg.boiler_rm"))
    table.insert(FFGRACE.Rooms.BoilerChallenge, include("resources.luarooms.ffg.boiler_rm_challenge"))
    table.insert(FFGRACE.Rooms.BoilerWhiteFire, include("resources.luarooms.ffg.boiler_rm_fire"))
    if FiendFolio then
      table.insert(FFGRACE.Rooms.Boiler, include("resources.luarooms.ffg.boiler_rm_ff"))
    end

    StageAPI.GetBossData("FFGRACE Creem").Rooms:AddRooms(require("resources.luarooms.ffg.bosses.boiler_rm_creem"))


    --grotto
    table.insert(FFGRACE.Rooms.Grotto, include("resources.luarooms.ffg.grotto_rm"))
    table.insert(FFGRACE.Rooms.GrottoChallenge, include("resources.luarooms.ffg.grotto_rm_challenge"))
    table.insert(FFGRACE.Rooms.GrottoRailButton, include("resources.luarooms.ffg.grotto_rm_button"))
    table.insert(FFGRACE.Rooms.GrottoMineshaftEntrance, include("resources.luarooms.ffg.grotto_rm_mineshaft_entrance"))
    if FiendFolio then
      table.insert(FFGRACE.Rooms.Grotto, include("resources.luarooms.ffg.grotto_rm_ff"))
    end

    StageAPI.GetBossData("FFGRACE Stub").Rooms:AddRooms(require("resources.luarooms.ffg.bosses.grotto_rm_stub"))
    StageAPI.GetBossData("FFGRACE Ms. Guano").Rooms:AddRooms(require("resources.luarooms.ffg.bosses.grotto_rm_msguano"))
    StageAPI.GetBossData("FFGRACE Plumpod II").Rooms:AddRooms(require("resources.luarooms.ffg.bosses.grotto_rm_plumpod"))


    --if an enemy is transformable by spores in grotto, used for sporelings
    mod.sporeTransformable = {
      {EntityType.ENTITY_ONE_TOOTH, -1, -1},
      {EntityType.ENTITY_FAT_BAT, -1, -1},
      {EntityType.ENTITY_BOOMFLY, 3, -1}, --dragon fly

      {mod.ENTITY_INFO.ECHO_BAT.ID, mod.ENTITY_INFO.ECHO_BAT.VARIANT, 0},
      {mod.ENTITY_INFO.BLIND_BAT.ID, mod.ENTITY_INFO.BEARD_BAT.VARIANT, -1},

      {FFGRACE.ENT.POPCAP_CLUSTER.id, FFGRACE.ENT.POPCAP_CLUSTER.variant, -1},
      {FFGRACE.ENT.MUD_FLY.id, FFGRACE.ENT.MUD_FLY.variant, -1},
      {FFGRACE.ENT.ROBERT.id, FFGRACE.ENT.ROBERT.variant, -1},
      {FFGRACE.ENT.BUMBLEBAT.id, FFGRACE.ENT.BUMBLEBAT.variant, -1},

      {160, 320, -1}, --ff milk tooth, im not adding specific code to check if ff is installed just use the enums
      {666, 40, -1}, --ff foamy

    }

    FFGRACE.SkeeterEntData["RestoredMonsterPack"] = {
      [mod.ENTITY_INFO.STILLBORN.ID.." "..mod.ENTITY_INFO.STILLBORN.VARIANT] = "Hard",
      [EntityType.ENTITY_BRIMSTONE_HEAD.." "..mod.ENTITY_INFO.FIRE_GRIMACE.VARIANT] = "Hard",

      [mod.ENTITY_INFO.STICKY.ID.." "..mod.ENTITY_INFO.STICKY.VARIANT] = "Tar",

      [mod.ENTITY_INFO.DUMPLING.ID.." "..CutMonsterVariants.SCORCHLING] = "Fire",

      [mod.ENTITY_INFO.CHUBBY_BUNNY.ID.." "..mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT] = "Spore",
      [mod.ENTITY_INFO.ECHO_BAT.ID.." "..mod.ENTITY_INFO.ECHO_BAT.VARIANT] = "Spore",
      [mod.ENTITY_INFO.BLIND_BAT.ID.." "..mod.ENTITY_INFO.BEARD_BAT.VARIANT] = "Spore",
      [mod.ENTITY_INFO.DUMPLING.ID.." "..mod.ENTITY_INFO.SPORELING.VARIANT] = "Spore",

      [mod.ENTITY_INFO.RED_TNT.ID.." "..mod.ENTITY_INFO.RED_TNT.VARIANT] = "Blacklisted",
    }
    for key, entry in pairs(FFGRACE.SkeeterEntData["RestoredMonsterPack"]) do
      FFGRACE.SkeeterEntData[key] = entry
    end

  else
    mod.CompatibilityReplace = {
      [mod.ENTITY_INFO.DUMPLING.ID.." "..mod.ENTITY_INFO.SPORELING.VARIANT] = {mod.ENTITY_INFO.DUMPLING.ID, mod.ENTITY_INFO.SKINLING.VARIANT, -1},
      [mod.ENTITY_INFO.ECHO_BAT.ID.." "..mod.ENTITY_INFO.ECHO_BAT.VARIANT.." "..mod.ENTITY_INFO.CHUBBY_BUNNY.VARIANT] = {mod.ENTITY_INFO.ECHO_BAT.ID, mod.ENTITY_INFO.ECHO_BAT.VARIANT, -1},
      [mod.ENTITY_INFO.BLIND_BAT.ID.." "..mod.ENTITY_INFO.BEARD_BAT.VARIANT] = {mod.ENTITY_INFO.BLIND_BAT.ID, mod.ENTITY_INFO.BLIND_BAT.VARIANT, -1},
    }
  end