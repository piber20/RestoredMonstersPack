local c = include("scripts.compatibility.retribution.rm_entities")
local vc = include("scripts.compatibility.retribution.vanilla_entities")



local data = {
    {c.Rumpling,		vc.Embryo},
    {c.Skinling,		c.Rumpling},
    {c.Scorchling,		c.Rumpling},
    {c.Scabling,		c.Skinling},
    {c.Mortling,		c.Scabling},
    {c.TaintedRumpling,		c.Rumpling},
    {c.FractureRM,          vc.Level2Spider},
    {vc.Ragling,          c.FractureRM},
    {vc.Blister,          c.FractureRM},
    {c.Necromancer,          vc.Fanatic},
    {vc.AngelicBaby,          c.Swapper},
    {c.Barfy,          vc.BigBony},
    {c.Barfy,          vc.Quakey},
    {vc.GuttedFatty,          c.Barfy},
    {c.Screamer,          vc.LooseKnight},
    {c.Screamer,          vc.SelflessKnight},
    {c.Cell,          vc.RedMaw},
    {c.FusedCells,          vc.Embryo},
    {c.Tissue,          c.FusedCells},
    {c.SplashyLongLegs,          vc.CrazyLongLegs},
    {c.StickyLongLegs,          c.SplashyLongLegs},
    {c.VesselRM,          vc.BigBony},
    {vc.GuttedFatty,          c.VesselRM},
    {c.SplitRageCreep,          vc.RageCreep},
    {c.RagCreep,          vc.WallCreep},
    {vc.MazeRoamer,          c.Strifer},
    {c.Strifer,          vc.Cyclopia},
}

for _, dataset in pairs(data) do
    BaptismalPreloader.AddBaptismalData(dataset[1], {BaptismalPreloader.GenerateTransformationDataset(dataset[2])})
end