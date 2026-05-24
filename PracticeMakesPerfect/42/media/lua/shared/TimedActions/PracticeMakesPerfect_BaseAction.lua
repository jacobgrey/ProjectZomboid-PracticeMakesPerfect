require "TimedActions/ISBaseTimedAction"
require "Definitions/PracticeMakesPerfect_Log"

PracticeMakesPerfect_BaseAction = ISBaseTimedAction:derive("PracticeMakesPerfect_BaseAction")

-- Use in-game time, matching vanilla ISFitnessAction. The duration in the UI is
-- expressed in in-game minutes (10..60), and 60000 ms == 1 in-game minute. Verified
-- against vanilla ISFitnessAction.lua and Fishing/BuildingObjects/FishingNet.lua.
function PracticeMakesPerfect_BaseAction:new(character, drillKey, drill, durationMinutes)
    local o = ISBaseTimedAction.new(self, character)
    o.drillKey = drillKey
    o.drill = drill
    o.durationMinutes = durationMinutes or 10
    o.startMS = getGameTime():getCalender():getTimeInMillis()
    o.endMS = o.startMS + (durationMinutes * 60000)
    o.maxTime = 5000000
    o.stopOnWalk = true
    o.stopOnRun = true
    o.caloriesModifier = 4
    o.repnb = 0
    o.lastBoredomTick = o.startMS
    PMP.logInfo("Action constructed: drill=%s duration=%d gameMin periodMs=%d sittable=%s allowAiming=%s",
        drillKey, o.durationMinutes, drill.periodMs or 1500,
        tostring(drill.sittable), tostring(drill.allowAiming))
    return o
end

function PracticeMakesPerfect_BaseAction:isValid()
    if getGameTime():getCalender():getTimeInMillis() >= self.endMS then return false end
    return true
end

function PracticeMakesPerfect_BaseAction:waitToStart()
    if self.character:isSittingOnFurniture() and not self.drill.sittable then
        self.character:setVariable("forceGetUp", true)
        self.character:setVariable("pressedMovement", true)
        self.character:setVariable("getUpQuick", true)
        return true
    end
    self.character:faceThisObject(self.character)
    return false
end

function PracticeMakesPerfect_BaseAction:resolveAnim()
    if self.drill.useEquippedWeaponSwingAnim then
        local w = self.character:getPrimaryHandItem()
        if w and w.getSwingAnim then
            local swing = w:getSwingAnim()
            if swing and swing ~= "" then return swing end
        end
    end
    return self.drill.anim
end

-- Intentional: we do not write character variables (no PMPDrillType/PMPDrillActive).
-- All drill state lives on the action object itself, which is not persisted across
-- save/load — so a save during a drill leaves no PMP-specific data in the save file.
-- This means the mod can be removed at any time with no orphan state to clean up.

function PracticeMakesPerfect_BaseAction:start()
    local anim = self:resolveAnim()
    if anim then
        local ok, err = pcall(function() self:setActionAnim(anim) end)
        if ok then
            PMP.logDebug("Action.start: drill=%s anim='%s' applied", self.drillKey, anim)
        else
            PMP.logWarn("setActionAnim failed for drill=%s anim='%s': %s", self.drillKey, tostring(anim), tostring(err))
        end
    else
        PMP.logDebug("Action.start: drill=%s no anim resolved", self.drillKey)
    end
end

function PracticeMakesPerfect_BaseAction:stop()
    PMP.logInfo("Action.stop: drill=%s reps=%d", self.drillKey, self.repnb)
    ISBaseTimedAction.stop(self)
end

function PracticeMakesPerfect_BaseAction:perform()
    PMP.logInfo("Action.perform (completed): drill=%s reps=%d duration=%dm", self.drillKey, self.repnb, self.durationMinutes)
    ISBaseTimedAction.perform(self)
end

function PracticeMakesPerfect_BaseAction:serverStart()
    local period = self.drill.periodMs or 1500
    emulateAnimEvent(self.netAction, period, "ActiveAnimLooped", nil)
end

function PracticeMakesPerfect_BaseAction:animEvent(event, parameter)
    local isSinglePlayerMode = (not isClient() and not isServer())
    if isServer() or isSinglePlayerMode then
        if event == "ActiveAnimLooped" and (self:isStarted() or isServer()) then
            self:exeLooped()
        end
    end
end

function PracticeMakesPerfect_BaseAction:exeLooped()
    self.repnb = self.repnb + 1
    PMP.logDebug("Rep #%d: drill=%s", self.repnb, self.drillKey)

    if self.character:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > 2 then
        PMP.logInfo("Force-stop: endurance moodle > 2 mid-rep (drill=%s rep=%d)", self.drillKey, self.repnb)
        self:forceStop()
        return
    end

    self:beforeAward()
    self:awardXp()
    self:applyConsumption()
    self:applyBoredomTick()
end

function PracticeMakesPerfect_BaseAction:beforeAward() end

function PracticeMakesPerfect_BaseAction:awardXp()
    local d = self.drill
    local perkName = (d.perk and d.perk.getName and d.perk:getName()) or "?"
    local lvl = self.character:getPerkLevel(d.perk) or -1
    if PMP.Drills.atOrAboveCap(self.character, d) then
        PMP.logTrace("XP skipped (capped at level %d): drill=%s perk=%s lvl=%d",
            d.levelCap, self.drillKey, perkName, lvl)
        return
    end
    if PMP.Drills.belowMin(self.character, d) then
        PMP.logTrace("XP skipped (below min level %d): drill=%s perk=%s lvl=%d",
            d.levelMin, self.drillKey, perkName, lvl)
        return
    end
    addXp(self.character, d.perk, d.xpPerRep)
    PMP.logTrace("XP +%.2f -> %s (lvl %d)", d.xpPerRep, perkName, lvl)
    if d.secondaryPerk and d.secondaryXp then
        addXp(self.character, d.secondaryPerk, d.secondaryXp)
        local sName = (d.secondaryPerk.getName and d.secondaryPerk:getName()) or "?"
        PMP.logTrace("XP +%.2f -> %s (secondary)", d.secondaryXp, sName)
    end
end

function PracticeMakesPerfect_BaseAction:applyConsumption()
    local d = self.drill
    if not d.consume then return end
    local chance = PMP.Drills.getEffectiveLossChance(self.character, d)
    if chance <= 0 then return end
    if ZombRand(10000) >= math.floor(chance * 10000) then
        PMP.logTrace("Consumption: no roll hit (chance=%.3f)", chance)
        return
    end

    local inv = self.character:getInventory()
    if d.consume.transform then
        local item = inv:getFirstTypeRecurse(d.consume.transform.from)
        if item then
            inv:Remove(item)
            inv:AddItem(d.consume.transform.to)
            PMP.logDebug("Consumption: transformed %s -> %s (chance=%.3f)",
                d.consume.transform.from, d.consume.transform.to, chance)
        else
            PMP.logDebug("Consumption: roll hit but no %s in inventory", d.consume.transform.from)
        end
        return
    end
    if d.consume.item then
        local item = inv:getFirstTypeRecurse(d.consume.item)
        if item then
            inv:Remove(item)
            PMP.logDebug("Consumption: consumed 1x %s (chance=%.3f)", d.consume.item, chance)
        else
            PMP.logDebug("Consumption: roll hit but no %s in inventory", d.consume.item)
        end
    end
end

function PracticeMakesPerfect_BaseAction:applyBoredomTick()
    if not PMP.getSandboxOption("ExerciseIncreasesBoredom") then return end
    local stats = self.character:getStats()
    if not stats or not CharacterStat or not CharacterStat.BOREDOM then return end
    local now = getGameTime():getCalender():getTimeInMillis()
    local elapsedGameMin = (now - self.lastBoredomTick) / 60000
    self.lastBoredomTick = now
    local bpm = PMP.getSandboxOption("BoredomPerMinute") or 0.5
    stats:add(CharacterStat.BOREDOM, bpm * elapsedGameMin)
end

function PracticeMakesPerfect_BaseAction:cancelWith(reason)
    PMP.logInfo("Force-stop: drill=%s reason=%s rep=%d", self.drillKey, reason, self.repnb)
    self:forceStop()
end

function PracticeMakesPerfect_BaseAction:update()
    if self.character:isClimbing() then return self:cancelWith("climbing") end
    if self.character:getVehicle() then return self:cancelWith("entered_vehicle") end
    if not self.drill.allowAiming and self.character:isAiming() then return self:cancelWith("aiming") end
    if not self.drill.sittable and self.character:isSittingOnFurniture() then return self:cancelWith("sat_down") end
    if self.character:pressedMovement(true) then return self:cancelWith("movement_input") end
    if self.character:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > 2 then return self:cancelWith("endurance_exhausted") end
    if getGameTime():getCalender():getTimeInMillis() >= self.endMS then
        PMP.logInfo("Action complete (timer reached): drill=%s reps=%d", self.drillKey, self.repnb)
        self:forceComplete()
        return
    end
end
