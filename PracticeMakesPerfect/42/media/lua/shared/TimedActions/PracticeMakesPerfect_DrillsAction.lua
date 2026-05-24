require "TimedActions/PracticeMakesPerfect_BaseAction"

PracticeMakesPerfect_DrillsAction = PracticeMakesPerfect_BaseAction:derive("PracticeMakesPerfect_DrillsAction")

function PracticeMakesPerfect_DrillsAction:new(character, drillKey, drill, durationMinutes)
    local o = PracticeMakesPerfect_BaseAction.new(self, character, drillKey, drill, durationMinutes)
    return o
end
