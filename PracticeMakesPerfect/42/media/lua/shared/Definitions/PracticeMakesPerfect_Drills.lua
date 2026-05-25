require "Definitions/PracticeMakesPerfect_Log"
require "Definitions/PracticeMakesPerfect_ItemGates"

PMP = PMP or {}
PMP.Drills = PMP.Drills or {}

local Gates = PMP.ItemGates

PMP.logInfo("Drills module loading")

local function levelScaledLoss(baseChance)
    return function(player, perk)
        local lvl = player:getPerkLevel(perk) or 0
        if lvl < 0 then lvl = 0 end
        if lvl > 10 then lvl = 10 end
        local scale = 1 - (lvl / 12)
        if scale < 0.15 then scale = 0.15 end
        return baseChance * scale
    end
end

PMP.Drills.Practice = {

    -- Rates target ~20-40 XP / 10 game min for Tailoring; vanilla squat (Fitness) is ~35
    -- XP / 10 game min for reference. Metabolics chosen to mirror vanilla actions of
    -- similar physical intensity (see Metabolics enum: LightDomestic, LightWork,
    -- MediumWork, HeavyWork, FitnessHeavy).
    knit_unpick = {
        name = "Knit / Unpick",
        perk = Perks.Tailoring,
        anim = "Knitting",
        periodMs = 3400,
        xpPerRep = 2,
        sittable = true,
        levelCap = nil,
        metabolics = Metabolics.LightDomestic,
        gate = Gates.hasKnittingNeedlesAndYarn,
        consume = {
            perRep = levelScaledLoss(0.15),
            item = "Base.Yarn",
        },
    },

    patch_unpatch = {
        name = "Patch / Unpatch",
        perk = Perks.Tailoring,
        anim = "SewingCloth",
        periodMs = 2550,
        xpPerRep = 2,
        sittable = true,
        levelCap = nil,
        metabolics = Metabolics.LightDomestic,
        gate = Gates.hasNeedleThreadAndPatchableClothing,
    },

    load_unload = {
        name = "Load / Unload Magazine",
        perk = Perks.Reloading,
        anim = "InsertBullets",
        animAlternate = "RemoveBullets",
        periodMs = 1500,
        xpPerRep = 1,
        sittable = true,
        levelCap = nil,
        metabolics = Metabolics.LightWork,
        gate = Gates.hasReloadableFirearmOrMagazineWithAmmo,
    },

    field_strip = {
        name = "Field-strip / Reassemble",
        perk = Perks.Maintenance,
        anim = "disassemble",
        periodMs = 2500,
        xpPerRep = 3,
        sittable = true,
        levelCap = nil,
        metabolics = Metabolics.LightWork,
        gate = Gates.hasFirearmAny,
        toolWear = { perRep = 0.005 },
    },

    practice_bandaging = {
        name = "Practice Bandaging",
        perk = Perks.Doctor,
        anim = "Bandage",
        periodMs = 3400,
        xpPerRep = 2,
        sittable = true,
        levelCap = 2,
        metabolics = Metabolics.LightDomestic,
        gate = Gates.hasAnyBandage,
        consume = {
            perRep = levelScaledLoss(0.30),
            transform = { from = "Base.Bandage", to = "Base.BandageDirty" },
        },
    },

    practice_splinting = {
        name = "Practice Splinting",
        perk = Perks.Doctor,
        anim = "Bandage",
        periodMs = 2380,
        xpPerRep = 4,
        sittable = true,
        levelMin = 3,
        levelCap = 6,
        metabolics = Metabolics.LightWork,
        gate = Gates.hasSplintMaterials,
    },

    practice_suturing = {
        name = "Practice Suturing",
        perk = Perks.Doctor,
        anim = "Bandage",
        periodMs = 2550,
        xpPerRep = 5,
        sittable = true,
        levelMin = 7,
        levelCap = nil,
        metabolics = Metabolics.LightWork,
        gate = Gates.hasSutureKitAndSubject,
        consume = {
            perRep = levelScaledLoss(0.04),
            item = "Base.SutureNeedle",
        },
    },

    practice_cast = {
        name = "Practice Cast",
        perk = Perks.Fishing,
        anim = "fishingCast",
        periodMs = 3000,
        xpPerRep = 3,
        sittable = true,
        levelCap = 3,
        metabolics = Metabolics.MediumWork,
        gate = Gates.hasFishingRod,
        toolWear = { perRep = 0.002 },
    },

    -- Pottery: vanilla MakeClayBowl gives 15 XP per ~80-tick craft. Bringing down to
    -- match vanilla rate as a passive in-place loop without producing items.
    work_the_wheel = {
        name = "Work the Wheel",
        perk = Perks.Pottery,
        anim = "Craft_PotteryWheel",
        periodMs = 2000,
        xpPerRep = 2,
        sittable = false,
        levelCap = nil,
        metabolics = Metabolics.MediumWork,
        gate = Gates.hasPotteryWheelAndClay,
        consume = {
            perRep = levelScaledLoss(0.12),
            item = "Base.Clay",
        },
    },

    -- Glass: vanilla MakeGlassJar gives 75 XP / 100-tick craft. As a passive in-place
    -- loop we award a fraction per rep, since no jar is being produced.
    blow_glass = {
        name = "Blow Glass",
        perk = Perks.Glassmaking,
        anim = "BlowGlass",
        periodMs = 2500,
        xpPerRep = 8,
        sittable = false,
        levelCap = nil,
        metabolics = Metabolics.HeavyWork,
        gate = Gates.hasGlassblowingSetup,
        consume = {
            perRep = levelScaledLoss(0.10),
            item = "Base.CeramicCrucibleWithGlass",
        },
    },
}

-- Drills: shadow-swings. periodMs matches a realistic weapon Swingtime (verified in
-- vanilla weapon.txt -- e.g. SpadeHead has Swingtime=4.0 sec; lighter weapons ~2 sec).
-- We pick conservative values rather than reading per-weapon stats at runtime; future
-- pass could read the actual weapon's Swingtime via getScriptItem() if it's exposed.
-- All Drills use FitnessHeavy metabolics, matching vanilla burpees / heavy lifts.
PMP.Drills.Drills = {

    axe_drill = {
        name = "Axe Drill",
        perk = Perks.Axe,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Axe",
        periodMs = 2500,
        xpPerRep = 0.75,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.AXE, "an axe"),
    },

    long_blade_drill = {
        name = "Long Blade Drill",
        perk = Perks.LongBlade,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "LongBlade",
        periodMs = 2200,
        xpPerRep = 0.75,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.LONG_BLADE, "a long blade"),
    },

    short_blade_drill = {
        name = "Short Blade Drill",
        perk = Perks.SmallBlade,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "SmallBlade",
        periodMs = 1500,
        xpPerRep = 0.6,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.SMALL_BLADE, "a short blade"),
    },

    long_blunt_drill = {
        name = "Long Blunt Drill",
        perk = Perks.Blunt,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Blunt",
        periodMs = 2500,
        xpPerRep = 0.75,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.BLUNT, "a long blunt"),
    },

    short_blunt_drill = {
        name = "Short Blunt Drill",
        perk = Perks.SmallBlunt,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "SmallBlunt",
        periodMs = 1800,
        xpPerRep = 0.6,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.SMALL_BLUNT, "a short blunt"),
    },

    spear_drill = {
        name = "Spear Drill",
        perk = Perks.Spear,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Spear",
        periodMs = 2200,
        xpPerRep = 0.75,
        sittable = false,
        metabolics = Metabolics.FitnessHeavy,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.SPEAR, "a spear"),
    },

    dry_fire = {
        name = "Dry-Fire Drill",
        perk = Perks.Aiming,
        secondaryPerk = Perks.Reloading,
        secondaryXp = 0.2,
        anim = "InsertBullets",
        periodMs = 2500,
        xpPerRep = 1.5,
        sittable = false,
        levelCap = 4,
        allowAiming = true,
        metabolics = Metabolics.LightWork,
        gate = Gates.hasEquippedFirearm,
    },
}

function PMP.Drills.getEffectiveLossChance(player, drill)
    if not drill.consume or not drill.consume.perRep then return 0 end
    if type(drill.consume.perRep) == "function" then
        return drill.consume.perRep(player, drill.perk)
    end
    return drill.consume.perRep
end

function PMP.Drills.atOrAboveCap(player, drill)
    if not drill.levelCap then return false end
    return (player:getPerkLevel(drill.perk) or 0) >= drill.levelCap
end

function PMP.Drills.belowMin(player, drill)
    if not drill.levelMin then return false end
    return (player:getPerkLevel(drill.perk) or 0) < drill.levelMin
end

local function countWithNilPerks(t)
    local total, nilPerks = 0, 0
    for _, drill in pairs(t) do
        total = total + 1
        if drill.perk == nil then nilPerks = nilPerks + 1 end
    end
    return total, nilPerks
end

local practiceTotal, practiceNil = countWithNilPerks(PMP.Drills.Practice)
local drillsTotal, drillsNil = countWithNilPerks(PMP.Drills.Drills)
PMP.logInfo("Drills registered: Practice=%d (nil perks: %d), Drills=%d (nil perks: %d)",
    practiceTotal, practiceNil, drillsTotal, drillsNil)
if practiceNil > 0 or drillsNil > 0 then
    PMP.logWarn("Some drills have nil perks - they will be hidden from the UI. Check your PZ build version (mod targets B42.18+).")
end
