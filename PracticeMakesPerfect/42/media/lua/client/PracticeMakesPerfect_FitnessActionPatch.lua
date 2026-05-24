require "TimedActions/ISFitnessAction"

PMP = PMP or {}

local PMP_PERIODS = {
    pmp_stationary_jog = 1200,
    pmp_cross_stepping = 1100,
    pmp_stealth_drill = 1500,
}

local orig_serverStart = ISFitnessAction.serverStart
function ISFitnessAction:serverStart()
    local period = PMP_PERIODS[self.exeDataType]
    if period then
        emulateAnimEvent(self.netAction, period, "ActiveAnimLooped", nil)
        return
    end
    return orig_serverStart(self)
end

local orig_exeLooped = ISFitnessAction.exeLooped
function ISFitnessAction:exeLooped()
    orig_exeLooped(self)
    local def = self.exeData
    if not def or not def.pmpAwardPerks then return end
    for i, perk in ipairs(def.pmpAwardPerks) do
        if perk then
            local weight = (def.pmpAwardWeights and def.pmpAwardWeights[i]) or 1.0
            addXp(self.character, perk, weight)
        end
    end
    if PMP.getSandboxOption and PMP.getSandboxOption("ExerciseIncreasesBoredom") then
        local bd = self.character:getBodyDamage()
        if bd then
            local bpm = PMP.getSandboxOption("BoredomPerMinute") or 0.5
            local periodMs = PMP_PERIODS[self.exeDataType] or 1500
            bd:setBoredomLevel((bd:getBoredomLevel() or 0) + bpm * (periodMs / 60000))
        end
    end
end
