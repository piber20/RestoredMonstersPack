local entities = {
    {Name="Staple Projectile",Anm2="projectiles/staple_projectile.anm2",HP=10,CollisionMass=8,CollisionRadius=10,ShadowSize=15,NumGridCollisionPoints=8,Type=9,Variant=108,},
    {Name="Rumpling",Anm2="monsters/restored/rumplings/rumpling.anm2",HP=7,StageHP=2,Champion=true,CollisionDamage=1,CollisionMass=3,CollisionRadius=13,Friction="0.95",ShadowSize=12,NumGridCollisionPoints=12,Type=800,Variant=0,GridCollision="walls",HasFloorAlts="true",Portrait=0,Reroll="true",},
    {Name="Skinling",Anm2="monsters/restored/rumplings/skinling.anm2",HP=8,StageHP=2,Champion=true,CollisionDamage=1,CollisionMass=3,CollisionRadius=13,Friction="0.95",ShadowSize=12,NumGridCollisionPoints=12,Type=800,Variant=1,GridCollision="walls",HasFloorAlts="true",Portrait=1,Reroll="true",},
    {Name="Scabling",Anm2="monsters/restored/rumplings/scabling.anm2",HP=10,StageHP=2,Champion=true,CollisionDamage=1,CollisionMass=3,CollisionRadius=13,Friction="0.95",ShadowSize=12,NumGridCollisionPoints=12,Type=800,Variant=2,GridCollision="walls",HasFloorAlts="true",Portrait=2,Reroll="true",},
    {Name="Scorchling",Anm2="monsters/restored/rumplings/scorchling.anm2",HP=7,StageHP=2,Champion=true,CollisionDamage=1,CollisionMass=3,CollisionRadius=13,Friction="0.95",ShadowSize=12,NumGridCollisionPoints=12,Type=800,Variant=3,GridCollision="walls",HasFloorAlts="true",Portrait=3,Reroll="true",},
    {Name="Mortling",Anm2="monsters/restored/rumplings/mortling.anm2",HP=36,CollisionDamage=1,CollisionMass=3,CollisionRadius=16,Friction="0.95",ShadowSize=16,NumGridCollisionPoints=14,Type=800,Variant=4,GridCollision="walls",HasFloorAlts="true",ShieldStrength=5,Portrait=4,Reroll="true",},
    {Name="Tainted Rumpling",Anm2="monsters/restored/rumplings/tainted_rumpling.anm2",HP=70,CollisionDamage=1,CollisionMass=3,CollisionRadius=18,Friction="0.98",ShadowSize=18,NumGridCollisionPoints=14,Type=800,Variant=5,GridCollision="walls",HasFloorAlts="true",ShieldStrength=5,Portrait=5,Reroll="true",},
    {Name="Gilded Rumpling",Anm2="monsters/restored/rumplings/gilded_rumpling.anm2",HP=60,StageHP=2,CollisionDamage=1,CollisionMass=3,CollisionRadius=16,Friction="0.95",ShadowSize=16,NumGridCollisionPoints=14,Type=800,Variant=6,GridCollision="walls",Portrait=6,Reroll="true",},
    {Name="​Fracture",Anm2="monsters/restored/fracture/fracture.anm2",HP=15,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=28,NumGridCollisionPoints=0,Type=29,Variant=1,Subtype=181,Tags="spider",HasFloorAlts="true",Portrait=7,},
    {Name="Necromancer",Anm2="monsters/restored/necromancer/necromancer.anm2",HP=25,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=14,NumGridCollisionPoints=12,Type=200,Variant=2410,Tags="homing_soul",HasFloorAlts="true",Portrait=10,},
    {Name="Swapper",Anm2="monsters/restored/swapper/swapper.anm2",HP=25,Champion=true,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=8,Type=38,Variant=835,GridCollision="walls",Portrait=11,Reroll="true",},
    {Name="Swapper (Gehenna)",Anm2="monsters/restored/swapper/swapper_gehenna.anm2",HP=25,Champion=true,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=8,Type=38,Variant=835,Subtype=1,GridCollision="walls",Portrait=12,Reroll="true",},
    {Name="Barfy",Anm2="monsters/restored/barfy/barfy.anm2",HP=70,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=12,Type=208,Variant=850,Portrait=12,Reroll="true",},
    {Name="Screamer",Anm2="monsters/restored/screamer/screamer.anm2",HP=100,CollisionDamage=2,CollisionMass=950,CollisionRadius=13,ShadowSize=18,NumGridCollisionPoints=12,Type=200,Variant=2411,Portrait=14,},
    {Name="Cell",Anm2="monsters/restored/cells/cell.anm2",HP=16,CollisionDamage=1,CollisionMass=16,CollisionRadius=13,ShadowSize=12,NumGridCollisionPoints=12,Type=200,Variant=2500,GridCollision="walls",Portrait=15,},
    {Name="Fused Cells",Anm2="monsters/restored/cells/fused_cells.anm2",HP=32,CollisionDamage=1,CollisionMass=16,CollisionRadius=16,ShadowSize=20,NumGridCollisionPoints=12,Type=200,Variant=2501,GridCollision="walls",Portrait=16,},
    {Name="Tissue",Anm2="monsters/restored/cells/tissue.anm2",HP=64,CollisionDamage=1,CollisionMass=16,CollisionRadius=19,ShadowSize=24,NumGridCollisionPoints=12,Type=200,Variant=2502,GridCollision="walls",Portrait=17,},
    {Name="Grave Robber",Anm2="monsters/restored/graverobber/graverobber.anm2",HP=15,StageHP=1,CollisionMass=5,CollisionRadius=13,ShadowSize=15,NumGridCollisionPoints=12,Type=200,Variant=2503,Portrait=18,},
    {Name="Splashy Long Legs",Anm2="monsters/restored/longlegs/splashy_long_legs.anm2",HP=16,StageHP=4,CollisionDamage=1,CollisionMass=20,CollisionRadius=20,ShadowSize=44,NumGridCollisionPoints=12,Type=200,Variant=2504,Tags="spider",Portrait=19,Reroll="true",},
    {Name="Sticky Long Legs",Anm2="monsters/restored/longlegs/sticky_long_legs.anm2",HP=20,StageHP=5,CollisionDamage=1,CollisionMass=20,CollisionRadius=20,ShadowSize=44,NumGridCollisionPoints=12,Type=200,Variant=2505,Tags="spider",Portrait=20,Reroll="true",},
    {Name="Red TNT",Anm2="grid/grid_redtnt.anm2",HP=4,CollisionMass=20,CollisionRadius=20,NumGridCollisionPoints=12,Type=292,Variant=3400,Tags="noreroll",ShutDoors="false",Portrait=22,},
    {Name="Screamer Ring",Anm2="monsters/restored/screamer/screamer_ring.anm2",Type=1000,Variant=164,Subtype=867,},
    {Name="Screamer Aura",Anm2="monsters/restored/screamer/screamer_aura.anm2",NumGridCollisionPoints=0,Type=1000,Variant=867,},
    {Name="Fire Grimace",Anm2="monsters/restored/firegrimace/fire_grimace.anm2",HP=10,CollisionMass=100,CollisionRadius=13,ShadowSize=22,NumGridCollisionPoints=0,Type=203,Variant=2500,Tags="noreroll",HasFloorAlts="true",ShutDoors="false",Portrait=22,},
    {Name="Bloodworm",Anm2="monsters/restored/bloodworm/bloodworm.anm2",HP=100,CollisionDamage=1,CollisionMass=100,CollisionRadius=15,NumGridCollisionPoints=12,Type=244,Variant=2500,HasFloorAlts="true",Portrait=23,Reroll="false",},
    {Name="Vessel (RM)",Anm2="monsters/restored/vessel/vessel_rm.anm2",HP=70,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=12,Type=858,Variant=1,Portrait=24,Reroll="true",},
    {Name="Receptacle",Anm2="monsters/restored/vessel/receptacle.anm2",HP=70,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=12,Type=858,Variant=1,Subtype=1,Portrait=25,Reroll="true",},
    {Name="Miasma",Anm2="monsters/restored/vessel/miasma.anm2",HP=70,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=16,NumGridCollisionPoints=12,Type=858,Variant=1,Subtype=2,Portrait=26,Reroll="true",},
    {Name="​Split Rage Creep",Anm2="monsters/restored/splitragecreep/split_rage_creep.anm2",HP=16,Champion=true,CollisionDamage=1,CollisionMass=14,CollisionRadius=13,NumGridCollisionPoints=12,Type=241,Variant=200,Tags="spider brimstone_soul",Portrait=33,},
    {Name="​Rag Creep",Anm2="240.002_rag creep.anm2",HP=17,StageHP=4,CollisionDamage=1,CollisionMass=14,CollisionRadius=13,NumGridCollisionPoints=12,Type=240,Variant=200,Tags="spider homing_soul",Portrait=34,},
    {Name="​Vessel (Antibirth)",Anm2="858.000_vessel.anm2",HP=60,Champion=true,CollisionDamage=1,CollisionMass=10,CollisionRadius=13,ShadowSize=15,NumGridCollisionPoints=12,Type=858,Variant=200,Portrait=36,},
    {Name="​Strifer",Anm2="monsters/restored/strifer/strifer.anm2",HP=25,Champion=true,CollisionDamage=1,CollisionMass=5,CollisionRadius=13,ShadowSize=15,NumGridCollisionPoints=12,Type=839,Variant=200,Portrait=37,},
    {Name="Chubby Bunny",Anm2="monsters/grotto/chubbybunny/chubby_bunny.anm2",HP=20,Champion=true,CollisionDamage=1,CollisionMass=14,CollisionRadius=13,ShadowSize=18,NumGridCollisionPoints=12,Type=200,Variant=2408,GridCollision="walls",Portrait=38,Reroll="true",},
    {Name="Sporeling",Anm2="monsters/grotto/sporeling/sporeling.anm2",HP=7,StageHP=2,Champion=true,CollisionDamage=1,CollisionMass=3,CollisionRadius=13,Friction="0.95",ShadowSize=12,NumGridCollisionPoints=12,Type=800,Variant=7,GridCollision="walls",HasFloorAlts="false",Portrait=39,Reroll="true",},
    {Name="Beard Bat",Anm2="monsters/grotto/beardbat/beard_bat.anm2",HP=10,CollisionDamage=1,CollisionMass=14,CollisionRadius=13,ShadowSize=18,NumGridCollisionPoints=32,Type=803,Variant=201,GridCollision="walls",Portrait=32,},
    {Name="Forever Friend",Anm2="monsters/future/foreverfriend/forever_friend.anm2",HP=20,StageHP=0,Champion=true,CollisionDamage=1,CollisionMass=5,CollisionRadius=13,ShadowSize=15,NumGridCollisionPoints=12,Type=839,Variant=201,Portrait=37,Reroll="true",},
}

---@diagnostic disable
return function(mode)
    if not mode or mode == 1 then
        return entities
    elseif mode == 2 then
        local entities2 = {}
        for _, entry in ipairs(entities) do
            entities2[entry.Name] = entry
        end
        return entities2
    elseif mode == 3 then
        local entities2 = {}
        for _, entry in ipairs(entities) do
            local t = entry.Type or 0
            local v = entry.Variant or 0
            local st = entry.Subtype or 0
            if not entities2[t] then entities2[t] = {} end
            if not entities2[t][v] then entities2[t][v] = {} end
            if not entities2[t][v][st] then entities2[t][v][st] = entry end
        end
        return entities2
    end    
end