require "TimedActions/PracticeMakesPerfect_BaseAction"

PracticeMakesPerfect_PracticeAction = PracticeMakesPerfect_BaseAction:derive("PracticeMakesPerfect_PracticeAction")

function PracticeMakesPerfect_PracticeAction:new(character, drillKey, drill, durationMinutes)
    local o = PracticeMakesPerfect_BaseAction.new(self, character, drillKey, drill, durationMinutes)
    return o
end
