local mod = RestoredMonsterPack

local DSSModName = "Dead Sea Scrolls (RestoredMonsterPack)"

local DSSCoreVersion = 7

local MenuProvider = {}

local dsssaveManager = SaveManager.GetDeadSeaScrollsSave()

function MenuProvider.SaveSaveData()
    SaveManager.Save()
end

function MenuProvider.GetPaletteSetting()
	return dsssaveManager.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
	dsssaveManager.MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
	if not REPENTANCE then
		return dsssaveManager.HudOffset
	else
		return Options.HUDOffset * 10
	end
end

function MenuProvider.SaveHudOffsetSetting(var)
	if not REPENTANCE then
		dsssaveManager.HudOffset = var
	end
end

function MenuProvider.GetGamepadToggleSetting()
	return dsssaveManager.GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
	dsssaveManager.GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
	return dsssaveManager.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
	dsssaveManager.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
	return dsssaveManager.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
	dsssaveManager.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
	return dsssaveManager.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
	dsssaveManager.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
	return dsssaveManager.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
	dsssaveManager.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
	return dsssaveManager.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
	dsssaveManager.MenusPoppedUp = var
end

local dssmenucore = include("scripts.deadseascrolls.dssmenucore")
local dssmod = dssmenucore.init(DSSModName, MenuProvider)


local restoreddirectory = {
    main = {
        title = 'restored monsters',

        buttons = {
            {str = 'resume game', action = 'resume'},
            {str = 'settings', dest = 'settings',tooltip = {strset = {'---','play around', 'with what', 'you like and', 'do not like', '---'}}},
            dssmod.changelogsButton,
            {str = '', nosel = true},
            {str = 'restored monster pack:',fsize=2, nosel = true},
            {str = 'bringing back your', fsize=2,nosel = true},
            {str = 'favorite foes since 2023', fsize=2,nosel = true},
            {str = '', fsize=2,nosel = true},
            {str = 'play us with', fsize=2,nosel = true},
            {str = 'fiend folio, the future', fsize=2,nosel = true},
            {str = 'revelations, and more!', fsize=2,nosel = true},
        },
        tooltip = dssmod.menuOpenToolTip,
    },

    settings =  {
            title = 'settings',
                buttons = {
                    {str = 'enemies', nosel = true},
                    {str = '----------', fsize=2, nosel = true},
                    {str = 'vessels', nosel = true},
                    {
                        str = 'vessel type',
                        fsize=2,
                        choices = {'normal', 'legacy'},
                        variable = "vesselType",
                        setting = 1,
                        load = function()
                            return RestoredMonsterPack.DSSavedata.vesselType or 1
                        end,
                        store = function(var)
                            RestoredMonsterPack.DSSavedata.vesselType = var
                        end,
                        tooltip = {strset = {'replaces', 'vessels with', 'their legacy', 'version','','disabled by', 'default'}}
        
                    },
                }
    },

}


local restoreddirectorykey = {
    Item = restoreddirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Restored Monsters", {
    Run = dssmod.runMenu,
    Open = dssmod.openMenu,
    Close = dssmod.closeMenu,
    UseSubMenu = false,
    Directory = restoreddirectory,
    DirectoryKey = restoreddirectorykey
})


function mod:IsSettingOn(setting)
	if setting == 1 then
		return true
	else
		return false
	end
end