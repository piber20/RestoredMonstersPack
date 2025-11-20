SaveManager = include("scripts.deadseascrolls.save_manager")
SaveManager.Init(RestoredMonsterPack)
SaveManager.Load()

RestoredMonsterPack.DSSavedata = SaveManager.GetDeadSeaScrollsSave()

include("scripts.deadseascrolls.defaultSettings")

RestoredMonsterPack:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	Isaac.DebugString("PREGAMEEXITPRESAVE")
    SaveManager.Save()
	Isaac.DebugString("PREGAMEEXITPOSTSAVE")
    RestoredMonsterPack.gamestarted = false
end)

RestoredMonsterPack:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    RestoredMonsterPack.gamestarted = false
end)

RestoredMonsterPack:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    if RestoredMonsterPack.gamestarted then
        SaveManager.Save()
    end
end)