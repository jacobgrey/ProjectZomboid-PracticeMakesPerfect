require "ISUI/PracticeMakesPerfect_BaseUI"
require "TimedActions/PracticeMakesPerfect_PracticeAction"

PracticeMakesPerfect_PracticeUI = PracticeMakesPerfect_BaseUI:derive("PracticeMakesPerfect_PracticeUI")
PracticeMakesPerfect_PracticeUI.instance = {}

function PracticeMakesPerfect_PracticeUI:new(x, y, width, height, player)
    local o = PracticeMakesPerfect_BaseUI.new(self, x, y, width, height, player,
        "Practice", PMP.Drills.Practice, PracticeMakesPerfect_PracticeAction)
    PracticeMakesPerfect_PracticeUI.instance[player:getPlayerNum() + 1] = o
    return o
end

function PracticeMakesPerfect_PracticeUI.openFor(player)
    local existing = PracticeMakesPerfect_PracticeUI.instance[player:getPlayerNum() + 1]
    if existing and existing:isVisible() then
        existing:setVisible(false)
        existing:removeFromUIManager()
        PracticeMakesPerfect_PracticeUI.instance[player:getPlayerNum() + 1] = nil
        return
    end
    local ui = PracticeMakesPerfect_PracticeUI:new(0, 0, 700, 400, player)
    ui:initialise()
    ui:addToUIManager()
end
