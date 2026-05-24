require "Definitions/PracticeMakesPerfect_ItemGates"

PMP = PMP or {}
PMP.Drills = PMP.Drills or {}

local Gates = PMP.ItemGates

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

    knit_unpick = {
        name = "Knit / Unpick",
        perk = Perks.Tailoring,
        anim = "Knitting",
        periodMs = 200 * 17,
        xpPerRep = 13,
        sittable = true,
        levelCap = nil,
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
        periodMs = 150 * 17,
        xpPerRep = 4,
        sittable = true,
        levelCap = nil,
        gate = Gates.hasNeedleThreadAndPatchableClothing,
    },

    load_unload = {
        name = "Load / Unload Magazine",
        perk = Perks.Reloading,
        anim = "InsertBullets",
        animAlternate = "RemoveBullets",
        periodMs = 1500,
        xpPerRep = 2,
        sittable = true,
        levelCap = nil,
        gate = Gates.hasReloadableFirearmOrMagazineWithAmmo,
    },

    field_strip = {
        name = "Field-strip / Reassemble",
        perk = Perks.Maintenance,
        anim = "disassemble",
        periodMs = 2000,
        xpPerRep = 8,
        sittable = true,
        levelCap = nil,
        gate = Gates.hasFirearmAny,
        toolWear = { perRep = 0.005 },
    },

    practice_bandaging = {
        name = "Practice Bandaging",
        perk = Perks.Doctor,
        anim = "Bandage",
        periodMs = 200 * 17,
        xpPerRep = 5,
        sittable = true,
        levelCap = 2,
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
        periodMs = 140 * 17,
        xpPerRep = 15,
        sittable = true,
        levelMin = 3,
        levelCap = 6,
        gate = Gates.hasSplintMaterials,
    },

    practice_suturing = {
        name = "Practice Suturing",
        perk = Perks.Doctor,
        anim = "Bandage",
        periodMs = 150 * 17,
        xpPerRep = 15,
        sittable = true,
        levelMin = 7,
        levelCap = nil,
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
        xpPerRep = 7,
        sittable = true,
        levelCap = 3,
        gate = Gates.hasFishingRod,
        toolWear = { perRep = 0.002 },
    },

    work_the_wheel = {
        name = "Work the Wheel",
        perk = Perks.Pottery,
        anim = "Craft_PotteryWheel",
        periodMs = 80 * 17,
        xpPerRep = 15,
        sittable = false,
        levelCap = nil,
        gate = Gates.hasPotteryWheelAndClay,
        consume = {
            perRep = levelScaledLoss(0.12),
            item = "Base.Clay",
        },
    },

    blow_glass = {
        name = "Blow Glass",
        perk = Perks.Glassmaking,
        anim = "BlowGlass",
        periodMs = 100 * 17,
        xpPerRep = 75,
        sittable = false,
        levelCap = nil,
        gate = Gates.hasGlassblowingSetup,
        consume = {
            perRep = levelScaledLoss(0.10),
            item = "Base.CeramicCrucibleWithGlass",
        },
    },
}

PMP.Drills.Drills = {

    axe_drill = {
        name = "Axe Drill",
        perk = Perks.Axe,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Axe",
        periodMs = 1000,
        xpPerRep = 0.75,
        sittable = false,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.AXE, "an axe"),
    },

    long_blade_drill = {
        name = "Long Blade Drill",
        perk = Perks.LongBlade,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "LongBlade",
        periodMs = 900,
        xpPerRep = 0.75,
        sittable = false,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.LONG_BLADE, "a long blade"),
    },

    short_blade_drill = {
        name = "Short Blade Drill",
        perk = Perks.SmallBlade,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "SmallBlade",
        periodMs = 800,
        xpPerRep = 0.6,
        sittable = false,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.SMALL_BLADE, "a short blade"),
    },

    long_blunt_drill = {
        name = "Long Blunt Drill",
        perk = Perks.Blunt,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Blunt",
        periodMs = 1100,
        xpPerRep = 0.75,
        sittable = false,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.BLUNT, "a long blunt"),
    },

    short_blunt_drill = {
        name = "Short Blunt Drill",
        perk = Perks.SmallBlunt,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "SmallBlunt",
        periodMs = 900,
        xpPerRep = 0.6,
        sittable = false,
        gate = Gates.hasEquippedMeleeOfCategory(WeaponCategory.SMALL_BLUNT, "a short blunt"),
    },

    spear_drill = {
        name = "Spear Drill",
        perk = Perks.Spear,
        useEquippedWeaponSwingAnim = true,
        weaponCategory = "Spear",
        periodMs = 1100,
        xpPerRep = 0.75,
        sittable = false,
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
