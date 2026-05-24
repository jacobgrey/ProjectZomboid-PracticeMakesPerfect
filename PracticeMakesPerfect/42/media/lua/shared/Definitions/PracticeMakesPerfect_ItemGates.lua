require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.ItemGates = PMP.ItemGates or {}
local G = PMP.ItemGates

PMP.logInfo("ItemGates module loading")

local function inv(player) return player:getInventory() end

local function firstItemMatchingRecurse(player, predicate)
    return inv(player):getFirstEvalRecurse(predicate)
end

function G.hasTypeRecurse(player, fullType)
    return inv(player):containsTypeRecurse(fullType)
end

function G.hasTagRecurse(player, tag)
    return inv(player):containsTagRecurse(tag)
end

function G.hasKnittingNeedlesAndYarn(player)
    if not G.hasTagRecurse(player, "knittingneedles") then return false, "Need knitting needles" end
    if not G.hasTypeRecurse(player, "Base.Yarn") then return false, "Need Yarn" end
    return true
end

function G.hasNeedleThreadAndPatchableClothing(player)
    if not (G.hasTypeRecurse(player, "Base.Needle") or G.hasTypeRecurse(player, "Base.SewingNeedle")) then
        return false, "Need a needle"
    end
    if not G.hasTypeRecurse(player, "Base.Thread") then return false, "Need Thread" end
    local fabric = G.hasTypeRecurse(player, "Base.RippedSheets")
        or G.hasTypeRecurse(player, "Base.DenimStrips")
        or G.hasTypeRecurse(player, "Base.LeatherStrips")
        or G.hasTagRecurse(player, "fabricscraps")
    if not fabric then return false, "Need fabric scraps" end
    local clothing = firstItemMatchingRecurse(player, function(it)
        return instanceof(it, "Clothing")
    end)
    if not clothing then return false, "Need clothing to patch" end
    return true
end

local function itemIsFirearm(it)
    if not it then return false end
    if not it.isRanged then return false end
    return it:isRanged()
end

local function itemIsMagazine(it)
    if not it then return false end
    return it:getScriptItem() and it:getScriptItem():getAmmoType() and it:getScriptItem():getMaxAmmo() and it:getScriptItem():getMaxAmmo() > 0 and not itemIsFirearm(it)
end

function G.hasFirearmAny(player)
    if itemIsFirearm(player:getPrimaryHandItem()) then return true end
    if firstItemMatchingRecurse(player, itemIsFirearm) then return true end
    return false, "Need a firearm"
end

function G.hasEquippedFirearm(player)
    if itemIsFirearm(player:getPrimaryHandItem()) then return true end
    return false, "Equip a firearm in your primary hand"
end

function G.hasReloadableFirearmOrMagazineWithAmmo(player)
    local ok = G.hasFirearmAny(player)
    if not ok then return false, "Need a firearm or magazine" end

    local foundCompatibleAmmo = false
    local items = inv(player):getItems()
    for i = 0, items:size() - 1 do
        local it = items:get(i)
        if it:getScriptItem() and it:getScriptItem():getAmmoType() then
            local ammoType = it:getScriptItem():getAmmoType()
            if inv(player):containsTypeRecurse(ammoType) then
                foundCompatibleAmmo = true
                break
            end
        end
    end
    if not foundCompatibleAmmo then return false, "Need matching ammo" end
    return true
end

function G.hasAnyBandage(player)
    if G.hasTypeRecurse(player, "Base.Bandage") then return true end
    if G.hasTypeRecurse(player, "Base.BandageDirty") then return true end
    if G.hasTagRecurse(player, "reusablebandage") then return true end
    if firstItemMatchingRecurse(player, function(it)
        local si = it:getScriptItem()
        return si and si.getCanBandage and si:getCanBandage()
    end) then return true end
    return false, "Need a bandage (clean or dirty)"
end

function G.hasSplintMaterials(player)
    if not G.hasTypeRecurse(player, "Base.RippedSheets") then return false, "Need ripped sheets" end
    if not G.hasTypeRecurse(player, "Base.Plank") then return false, "Need a plank" end
    return true
end

G.SUTURE_SUBJECT_WHITELIST = {
    ["Base.Potato"] = true,
    ["Base.Tomato"] = true,
    ["Base.Apple"] = true,
    ["Base.Orange"] = true,
    ["Base.Peach"] = true,
    ["Base.Pear"] = true,
    ["Base.Eggplant"] = true,
    ["Base.Carrots"] = true,
    ["Base.Banana"] = true,
    ["Base.Lemon"] = true,
}

function G.hasSutureKitAndSubject(player)
    local needle = G.hasTypeRecurse(player, "Base.SutureNeedle")
        or G.hasTypeRecurse(player, "Base.SutureNeedleHolder")
    if not needle then return false, "Need a suture needle" end
    for fullType, _ in pairs(G.SUTURE_SUBJECT_WHITELIST) do
        if G.hasTypeRecurse(player, fullType) then return true end
    end
    return false, "Need a practice subject (potato, apple, tomato, etc.)"
end

function G.hasFishingRod(player)
    local primary = player:getPrimaryHandItem()
    if primary and primary:getFullType() == "Base.FishingRod" then return true end
    if primary and primary:getFullType() == "Base.CraftedFishingRod" then return true end
    if G.hasTypeRecurse(player, "Base.FishingRod") then return false, "Equip your fishing rod in primary hand" end
    if G.hasTypeRecurse(player, "Base.CraftedFishingRod") then return false, "Equip your fishing rod in primary hand" end
    return false, "Need a fishing rod"
end

function G.hasPotteryWheelAndClay(player)
    if not G.hasTypeRecurse(player, "Base.Clay") then return false, "Need Clay" end
    local sq = player:getCurrentSquare()
    if not sq then return false, "Need a pottery wheel nearby" end
    local cell = getCell()
    if not cell then return false, "Need a pottery wheel nearby" end
    for dx = -1, 1 do
        for dy = -1, 1 do
            local s = cell:getGridSquare(math.floor(player:getX()) + dx, math.floor(player:getY()) + dy, math.floor(player:getZ()))
            if s then
                local objs = s:getObjects()
                for i = 0, objs:size() - 1 do
                    local o = objs:get(i)
                    local sprName = o:getSpriteName()
                    if sprName and (sprName:lower():find("pottery") or sprName:lower():find("wheel")) then
                        return true
                    end
                end
            end
        end
    end
    return false, "Need a pottery wheel nearby"
end

function G.hasGlassblowingSetup(player)
    if not G.hasTypeRecurse(player, "Base.GlassBlowingPipe") then return false, "Need a glass-blowing pipe" end
    if not (G.hasTypeRecurse(player, "Base.CeramicCrucibleWithGlass") or G.hasTypeRecurse(player, "Base.Sand") or G.hasTagRecurse(player, "sand")) then
        return false, "Need molten glass or sand"
    end
    return true
end

function G.hasEquippedMeleeOfCategory(categoryKeyOrEnum, displayName)
    local label = displayName or tostring(categoryKeyOrEnum) or "matching"
    return function(player)
        local primary = player:getPrimaryHandItem()
        local need = "Equip a " .. label .. " weapon"
        if not primary then return false, need end
        local si = primary:getScriptItem()
        if not si or not si.containsWeaponCategory then return false, need end
        local category = categoryKeyOrEnum
        if type(category) == "string" and WeaponCategory then
            category = WeaponCategory[category] or category
        end
        if not category then return false, need end
        local ok, hit = pcall(function() return si:containsWeaponCategory(category) end)
        if ok and hit then return true end
        return false, need
    end
end
