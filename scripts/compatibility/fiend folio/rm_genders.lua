local mod = RestoredMonsterPack

if FiendFolio then

local subType = {
	["​Fracture"] = 801,
	["Chubby Bunny"] = 0,
}

local function GetSubType(name)
	return REPENTOGON and Isaac.GetEntitySubTypeByName(name) or subType[name]
end

function mod:SpecialEnt(name)
	return {Isaac.GetEntityTypeByName(name), Isaac.GetEntityVariantByName(name), GetSubType(name)}
end


RestoredMonsterPack.Nonmale = {
	{ID = mod:SpecialEnt("Splashy Long Legs"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Sticky Long Legs"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Tainted Rumpling"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Scabling"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Mortling"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("​Fracture"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Screamer"), Affliction = "Women"},
	{ID = mod:SpecialEnt("Fused Cell"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Grave Robber"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("​Strifer"), Affliction = "Woman"},
	{ID = mod:SpecialEnt("Vessel (Antibirth)"), Affliction = "Woman"},
}

RestoredMonsterPack.LGBTQIA = {
	{ID = mod:SpecialEnt("Rumpling"), Affliction = "Non-Binary"},
	{ID = mod:SpecialEnt("Mortling"), Affliction = "Non-Binary"},
	{ID = mod:SpecialEnt("Gilded Rumpling"), Affliction = "HOLY SHIT THIS GUY'S GAY AS FUUUUUCK"}, --bc pandora said they're gay as actual fuck
	{ID = mod:SpecialEnt("Sporeling"), Affliction = "3rd Gender"},
	{ID = mod:SpecialEnt("Chubby Bunny"), Affliction = "3rd Gender"},
	{ID = mod:SpecialEnt("Beard Bat"), Affliction = "3rd Gender"},
}

function mod.MixFiendFolioStuff()
	mod:MixTables(FiendFolio.Nonmale, RestoredMonsterPack.Nonmale)
	mod:MixTables(FiendFolio.LGBTQIA, RestoredMonsterPack.LGBTQIA)
	mod.fiendfolioTablesMixed = true
end

-- mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc)
-- 	for i = 1, #FiendFolio.LGBTQIA do
-- 		if FiendFolio.LGBTQIA[i].ID
-- 		and (npc.Type == FiendFolio.LGBTQIA[i].ID[1])
-- 		and ((not FiendFolio.LGBTQIA[i].ID[2]) or npc.Variant == FiendFolio.LGBTQIA[i].ID[2])
-- 		and ((not FiendFolio.LGBTQIA[i].ID[3]) or npc.SubType == FiendFolio.LGBTQIA[i].ID[3])
-- 		then
-- 			Isaac.RenderText(FiendFolio.LGBTQIA[i].Affliction, Isaac.WorldToScreen(npc.Position).X - 15,Isaac.WorldToScreen(npc.Position).Y-10,1,.3,1,1)
-- 		end
-- 	end
-- 	for i = 1, #FiendFolio.Nonmale do
-- 		if FiendFolio.Nonmale[i].ID
-- 		and (npc.Type == FiendFolio.Nonmale[i].ID[1])
-- 		and ((not FiendFolio.Nonmale[i].ID[2]) or npc.Variant == FiendFolio.Nonmale[i].ID[2])
-- 		and ((not FiendFolio.Nonmale[i].ID[3]) or npc.SubType == FiendFolio.Nonmale[i].ID[3])
-- 		then
-- 			Isaac.RenderText(FiendFolio.Nonmale[i].Affliction, Isaac.WorldToScreen(npc.Position).X - 15,Isaac.WorldToScreen(npc.Position).Y,1,.3,1,1)
-- 		end
-- 	end
-- end)

end