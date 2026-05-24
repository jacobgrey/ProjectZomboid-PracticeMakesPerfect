require "Definitions/FitnessExercises"

PMP = PMP or {}

local function registerExercise(key, def)
    if not FitnessExercises or not FitnessExercises.exercisesType then
        print("[PMP] FitnessExercises table not found; cannot register " .. key)
        return
    end
    FitnessExercises.exercisesType[key] = def
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

Events.OnGameStart.Add(init)
