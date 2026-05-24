require "TimedActions/ISBaseTimedAction"

PracticeMakesPerfect_BaseAction = ISBaseTimedAction:derive("PracticeMakesPerfect_BaseAction")

function PracticeMakesPerfect_BaseAction:new(character, drillKey, drill, durationMinutes)
    local o = ISBaseTimedAction.new(self, character)
    o.drillKey = drillKey
    o.drill = drill
    o.durationMinutes = durationMinutes or 10
    o.startMS = getTimestampMs()
    o.endMS = o.startMS + (durationMinutes * 60000)
    o.maxTime = 5000000
    o.stopOnWalk = true
    o.stopOnRun = true
    o.caloriesModifier = 4
    o.repnb = 0
    o.lastBoredomTick = o.startMS
    return o
end

function PracticeMakesPerfect_BaseAction:isValid()
    if getTimestampMs() >= self.endMS then return false end
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
        if not ok then print("[PMP] setActionAnim failed for " .. tostring(anim) .. ": " .. tostring(err)) end
    end
end

function PracticeMakesPerfect_BaseAction:stop()
    ISBaseTimedAction.stop(self)
end

function PracticeMakesPerfect_BaseAction:perform()
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

    if self.character:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > 2 then
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
    if PMP.Drills.atOrAboveCap(self.character, d) then return end
    if PMP.Drills.belowMin(self.character, d) then return end
    addXp(self.character, d.perk, d.xpPerRep)
    if d.secondaryPerk and d.secondaryXp then
        addXp(self.character, d.secondaryPerk, d.secondaryXp)
    end
end

function PracticeMakesPerfect_BaseAction:applyConsumption()
    local d = self.drill
    if not d.consume then return end
    local chance = PMP.Drills.getEffectiveLossChance(self.character, d)
    if chance <= 0 then return end
    if ZombRand(10000) >= math.floor(chance * 10000) then return end

    local inv = self.character:getInventory()
    if d.consume.transform then
        local item = inv:getFirstTypeRecurse(d.consume.transform.from)
        if item then
            inv:Remove(item)
            inv:AddItem(d.consume.transform.to)
        end
        return
    end
    if d.consume.item then
        local item = inv:getFirstTypeRecurse(d.consume.item)
        if item then inv:Remove(item) end
    end
end

function PracticeMakesPerfect_BaseAction:applyBoredomTick()
    if not PMP.getSandboxOption("ExerciseIncreasesBoredom") then return end
    local bd = self.character:getBodyDamage()
    if not bd then return end
    local now = getTimestampMs()
    local elapsedSec = (now - self.lastBoredomTick) / 1000
    self.lastBoredomTick = now
    local bpm = PMP.getSandboxOption("BoredomPerMinute") or 0.5
    bd:setBoredomLevel((bd:getBoredomLevel() or 0) + bpm * (elapsedSec / 60))
end

function PracticeMakesPerfect_BaseAction:update()
    if self.character:isClimbing() then
        self:forceStop()
        return
    end
    if self.character:getVehicle() then
        self:forceStop()
        return
    end
    if not self.drill.allowAiming and self.character:isAiming() then
        self:forceStop()
        return
    end
    if not self.drill.sittable and self.character:isSittingOnFurniture() then
        self:forceStop()
        return
    end
    if self.character:pressedMovement(true) then
        self:forceStop()
        return
    end
    if self.character:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > 2 then
        self:forceStop()
        return
    end
    if getTimestampMs() >= self.endMS then
        self:forceComplete()
        return
    end
end
