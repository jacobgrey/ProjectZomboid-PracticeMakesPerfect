require "Definitions/FitnessExercises"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}

local function registerExercise(key, def)
    if not FitnessExercises or not FitnessExercises.exercisesType then
        PMP.logError("FitnessExercises table not found; cannot register %s", key)
        return
    end
    local resolvedPerks, missing = {}, {}
    for i, p in ipairs(def.pmpAwardPerks or {}) do
        if p then
            table.insert(resolvedPerks, (p.getName and p:getName()) or tostring(p))
        else
            table.insert(missing, tostring(i))
        end
    end
    FitnessExercises.exercisesType[key] = def
    PMP.logInfo("Registered fitness exercise '%s' -> perks: [%s]%s",
        key,
        table.concat(resolvedPerks, ", "),
        (#missing > 0) and (" (nil at indices: " .. table.concat(missing, ",") .. ")") or "")
end

local function init()

    registerExercise("pmp_stationary_jog", {
        type = "pmp_stationary_jog",
        name = "Stationary Jog",
        tooltip = "Run in place to train Sprinting (and trickle Fitness).",
        stiffness = "legs",
        metabolics = Metabolics.Fitness,
        xpMod = 1.0,
        pmpAwardPerks = { Perks.Sprinting, Perks.Fitness },
        pmpAwardWeights = { 1.0, 0.5 },
    })

    registerExercise("pmp_cross_stepping", {
        type = "pmp_cross_stepping",
        name = "Cross Stepping",
        tooltip = "Combat-strafe drill in place. Trains Nimble.",
        stiffness = "legs,abs",
        metabolics = Metabolics.Fitness,
        xpMod = 1.0,
        pmpAwardPerks = { Perks.Nimble },
        pmpAwardWeights = { 1.0 },
    })

    registerExercise("pmp_stealth_drill", {
        type = "pmp_stealth_drill",
        name = "Stealth Drill",
        tooltip = "Slow crouched movement in place. Trains Lightfoot and Sneak at half-rate.",
        stiffness = "legs",
        metabolics = Metabolics.Fitness,
        xpMod = 0.5,
        pmpAwardPerks = { Perks.Lightfoot, Perks.Sneak },
        pmpAwardWeights = { 0.5, 0.5 },
    })
end

Events.OnGameStart.Add(function()
    PMP.logInfo("FitnessExtensions: registering PMP exercises on OnGameStart")
    init()
end)
