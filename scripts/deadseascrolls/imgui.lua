if not REPENTOGON then return end
local mod = RestoredMonsterPack

-- ImGui menu
if not ImGui.ElementExists("tcMods") then
    ImGui.CreateMenu("tcMods", "TC Mods")
end

-- Restored Monsters menu
if not ImGui.ElementExists("tcRestoredMonsters") then
    ImGui.AddElement("tcMods", "tcRestoredMonsters", ImGuiElement.MenuItem, "Restored Monsters")
end

-- Restored Monsters window
if not ImGui.ElementExists("tcRestoredMonstersWindow") then
    ImGui.CreateWindow("tcRestoredMonstersWindow", "Restored Monsters")
end
ImGui.LinkWindowToElement("tcRestoredMonstersWindow", "tcRestoredMonsters")

-- Check for existing tab bar
if ImGui.ElementExists("tcRestoredMonstersTabs") then
    ImGui.RemoveElement("tcRestoredMonstersTabs")
end

-- Restred Monsters tab bar
ImGui.AddTabBar("tcRestoredMonstersWindow", "tcRestoredMonstersTabs")

-- Vessels tab
ImGui.AddTab("tcRestoredMonstersTabs", "tcRestoredMonstersTabVessel", "Vessels")

-- Vessel type
ImGui.AddCombobox("tcRestoredMonstersTabVessel", "tcRestoredMonstersTabVesselType", "Vessel type", 
function(index, str)
    mod.vesselType = index + 1
end, {"Normal", "Legacy"}, 0, true)
ImGui.SetHelpmarker("tcRestoredMonstersTabVesselType", "Replaces vessels with their legacy version.\nDisabled by default.")

-- Echo bats tab
ImGui.AddTab("tcRestoredMonstersTabs", "tcRestoredMonstersTabBlindBat", "Echo bats")

ImGui.AddSliderInteger("tcRestoredMonstersTabBlindBat", "tcRestoredMonstersTabBlindBatScream", "Scream effect",
function(val)
    mod.blindBatScreamInc = val
end, 3, 1, 5)

ImGui.SetHelpmarker("tcRestoredMonstersTabBlindBatScream", "Changes how strong the blind bat effect is.\nAt 3 by default.")

ImGui.AddCallback("tcRestoredMonstersWindow", ImGuiCallback.Render, function()
    ImGui.UpdateData("tcRestoredMonstersTabVesselType", ImGuiData.Value, mod.vesselType - 1)
    ImGui.UpdateData("tcRestoredMonstersTabBlindBatScream", ImGuiData.Value, mod.blindBatScreamInc)
end)