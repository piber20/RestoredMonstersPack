if not REPENTOGON then return end
local mod = RestoredMonsterPack

-- ImGui menu
if not ImGui.ElementExists("RestoredMods") then
    ImGui.CreateMenu("RestoredMods", "Restored Mods")
end

-- Restored Monsters menu
if not ImGui.ElementExists("rmRestoredMonsters") then
    ImGui.AddElement("RestoredMods", "rmRestoredMonsters", ImGuiElement.MenuItem, "Restored Monsters")
end

-- Restored Monsters window
if not ImGui.ElementExists("rmRestoredMonstersWindow") then
    ImGui.CreateWindow("rmRestoredMonstersWindow", "Restored Monsters")
end
ImGui.LinkWindowToElement("rmRestoredMonstersWindow", "rmRestoredMonsters")

-- Check for existing tab bar
if ImGui.ElementExists("rmRestoredMonstersTabs") then
    ImGui.RemoveElement("rmRestoredMonstersTabs")
end

-- Restred Monsters tab bar
ImGui.AddTabBar("rmRestoredMonstersWindow", "rmRestoredMonstersTabs")

-- Vessels tab
ImGui.AddTab("rmRestoredMonstersTabs", "rmRestoredMonstersTabVessel", "Vessels")

-- Vessel type
ImGui.AddCombobox("rmRestoredMonstersTabVessel", "rmRestoredMonstersTabVesselType", "Vessel type", 
function(index, str)
    mod.DSSavedata.vesselType = index + 1
end, {"Normal", "Legacy"}, 0, true)
ImGui.SetHelpmarker("rmRestoredMonstersTabVesselType", "Replaces vessels with their legacy version.\nDisabled by default.")

-- Echo bats tab
ImGui.AddTab("rmRestoredMonstersTabs", "rmRestoredMonstersTabBlindBat", "Echo bats")

ImGui.AddSliderInteger("rmRestoredMonstersTabBlindBat", "rmRestoredMonstersTabBlindBatScream", "Scream effect",
function(val)
    mod.DSSavedata.blindBatScreamInc = val
end, 3, 1, 5)

ImGui.SetHelpmarker("rmRestoredMonstersTabBlindBatScream", "Changes how strong the blind bat effect is.\nAt 3 by default.")

ImGui.AddCallback("rmRestoredMonstersWindow", ImGuiCallback.Render, function()
    ImGui.UpdateData("rmRestoredMonstersTabVesselType", ImGuiData.Value, mod.DSSavedata.vesselType and mod.DSSavedata.vesselType - 1 or 1)
    ImGui.UpdateData("rmRestoredMonstersTabBlindBatScream", ImGuiData.Value, mod.DSSavedata.blindBatScreamInc or 3)
end)