require "TimedActions/ISFitnessAction"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}

PMP.logInfo("FitnessActionPatch loading - wrapping ISFitnessAction:serverStart and :exeLooped")

-- PMP exercise periods AND the vanilla ExerciseType we alias the animation to.
-- Vanilla animation conditions are gated by character variable "ExerciseType". Since we
-- don't ship custom anim XMLs, we reuse a vanilla key so an animation actually plays.
local PMP_EXERCISES = {
    pmp_stationary_jog = { period = 1200, animAlias = "burpees" },  -- whole-body movement loop
    pmp_cross_stepping = { period = 1100, animAlias = "squats"  },  -- legs/balance
    pmp_stealth_drill  = { period = 1500, animAlias = "situp"   },  -- low-impact placeholder
}

local orig_serverStart = ISFitnessAction.serverStart
function ISFitnessAction:serverStart()
    local cfg = PMP_EXERCISES[self.exeDataType]
    if cfg then
        PMP.logInfo("PMP exercise '%s' starting (period=%dms, anim alias='%s')",
            self.exeDataType, cfg.period, cfg.animAlias)
        -- Replicate the parts of vanilla serverStart we need so vanilla exeLooped works:
        self.fitness = self.character:getFitness()
        self.fitness:init()
        -- Use the vanilla exercise key for fitness tracking AND animation, so anims play.
        self.fitness:setCurrentExercise(cfg.animAlias)
        self.character:setVariable("ExerciseType", cfg.animAlias)
        emulateAnimEvent(self.netAction, cfg.period, "ActiveAnimLooped", nil)
        return
    end
    return orig_serverStart(self)
end

local orig_start = ISFitnessAction.start
function ISFitnessAction:start()
    local cfg = PMP_EXERCISES[self.exeDataType]
    if cfg then
        -- Temporarily set self.exercise to the alias so vanilla start() writes the right
        -- ExerciseType character variable. Restore after so PMP-side logic stays unaware.
        local original = self.exercise
        self.exercise = cfg.animAlias
        local ok, err = pcall(orig_start, self)
        self.exercise = original
        if not ok then PMP.logWarn("Aliased start() failed for '%s': %s", self.exeDataType, tostring(err)) end
        return
    end
    return orig_start(self)
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
            PMP.logTrace("Fitness ext rep: +%.2f -> %s (exercise=%s)",
                weight, (perk.getName and perk:getName()) or "?", self.exeDataType)
        end
    end
    if PMP.getSandboxOption and PMP.getSandboxOption("ExerciseIncreasesBoredom") then
        local stats = self.character:getStats()
        if stats and CharacterStat and CharacterStat.BOREDOM then
            local bpm = PMP.getSandboxOption("BoredomPerMinute") or 0.5
            local cfg = PMP_EXERCISES[self.exeDataType]
            local periodMs = (cfg and cfg.period) or 1500
            stats:add(CharacterStat.BOREDOM, bpm * (periodMs / 60000))
        end
    end
end
