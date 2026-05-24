require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.logInfo("Sandbox module loading")

PMP.SandboxDefaults = {
    ExerciseIncreasesBoredom = true,
    BoredomPerMinute = 0.5,
}

function PMP.getSandboxOption(name)
    local sv = SandboxVars and SandboxVars.PracticeMakesPerfect
    if sv and sv[name] ~= nil then
        return sv[name]
    end
    return PMP.SandboxDefaults[name]
end
