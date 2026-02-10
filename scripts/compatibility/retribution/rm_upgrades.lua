local c = include("scripts.compatibility.retribution.rm_entities")
local vc = include("scripts.compatibility.retribution.vanilla_entities")



local data = {
    {c.Rumpling,		c.Skinling},
    {c.Rumpling,		c.Scorchling},
    {c.Skinling,		c.Scabling},
    {c.Scabling,		c.Mortling},
    {c.Mortling,		c.TaintedRumpling},
    {c.Scorchling,		c.Skinling},
    {vc.Level2Spider,          c.FractureRM},
    {c.FractureRM,          vc.Ragling},
    {c.FractureRM,          vc.Blister},
    {vc.Fanatic,          c.Necromancer},
    {c.Swapper,          vc.AngelicBaby},
    {vc.BigBony,          c.Barfy},
    {vc.Quakey,          c.Barfy},
    {c.Barfy,          vc.GuttedFatty},
    {vc.LooseKnight,          c.Screamer},
    {vc.SelflessKnight,          c.Screamer},
    {c.Cell,          c.FusedCells},
    {c.FusedCells,          vc.Poofer},
    {vc.CrazyLongLegs,          c.SplashyLongLegs},
    {c.SplashyLongLegs,          c.StickyLongLegs},
    {vc.BigBony,          c.VesselRM},
    {c.VesselRM,          vc.GuttedFatty},
    {vc.RageCreep,          c.SplitRageCreep},
    {vc.WallCreep,          c.RagCreep},
    {c.Strifer,          vc.MazeRoamer},
    {vc.Cyclopia,          c.Strifer},
    {c.VesselAntibirth,          c.GildedRumpling},
    
}

for _, dataset in pairs(data) do
    BaptismalPreloader.AddAntibaptismalData(dataset[1], {BaptismalPreloader.GenerateTransformationDataset(dataset[2])})
end