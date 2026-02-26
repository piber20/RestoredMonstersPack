local mod = RestoredMonsterPack

if not FiendFolio then return end

local function makeGenderTable(name, affliction, subtype)
	local t, v, st
	local capitalized = string.upper(string.gsub(name, "%s", "_"))
	if mod.ENTITY_INFO[capitalized] then
		t = mod.ENTITY_INFO[capitalized].ID
		v = mod.ENTITY_INFO[capitalized].VARIANT
		st = mod.ENTITY_INFO[capitalized].SUBTYPE
	else
		t = Isaac.GetEntityTypeByName(name)
		v = Isaac.GetEntityVariantByName(name)
		st = REPENTOGON and Isaac.GetEntitySubTypeByName(name) or subtype or 0
	end

	return {ID = {t, v, st}, Affliction = affliction}
end

mod.Genders = {
	Nonmale = {
		makeGenderTable("SPLASHY", "Woman"),
		makeGenderTable("STICKY", "Woman"),
		makeGenderTable("TAINTED_RUMPLING", "Woman"),
		makeGenderTable("SCABLING", "Woman"),
		makeGenderTable("MORTLING", "Woman"),
		makeGenderTable("FRACTURE", "Woman"),
		makeGenderTable("SCREAMER", "Women"),
		makeGenderTable("FUSEDCELLS", "Woman"),
		makeGenderTable("GRAVEROBBER", "Woman"),
		makeGenderTable("STRIFER", "Woman"),
		makeGenderTable("VESSEL_ANTIBIRTH", "Woman"),
	},

	LGBTQIA = {
		makeGenderTable("Rumpling", "Non-Binary"),
		makeGenderTable("Mortling", "Non-Binary"),
		makeGenderTable("Gilded Rumpling", "HOLY SHIT THIS GUY'S GAY AS FUUUUUCK"), --bc pandora said they're gay as actual fuck
		makeGenderTable("Sporeling", "3rd Gender"),
		makeGenderTable("Chubby Bunny", "3rd Gender"),
		makeGenderTable("Beard Bat", "3rd Gender"),
	}
}

for name, list in pairs(mod.Genders) do
	if FiendFolio[name] then
		for _, entry in ipairs(list) do
			table.insert(FiendFolio[name], entry)
		end
	end
end
