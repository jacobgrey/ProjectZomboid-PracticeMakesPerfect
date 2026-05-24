require "ISUI/PracticeMakesPerfect_BaseUI"
require "TimedActions/PracticeMakesPerfect_DrillsAction"
require "Util/PracticeMakesPerfect_TileCheck"

PracticeMakesPerfect_DrillsUI = PracticeMakesPerfect_BaseUI:derive("PracticeMakesPerfect_DrillsUI")
PracticeMakesPerfect_DrillsUI.instance = {}

function PracticeMakesPerfect_DrillsUI:new(x, y, width, height, player)
    local o = PracticeMakesPerfect_BaseUI.new(self, x, y, width, height, player,
        "Drills", PMP.Drills.Drills, PracticeMakesPerfect_DrillsAction)
    PracticeMakesPerfect_DrillsUI.instance[player:getPlayerNum() + 1] = o
    return o
end

function PracticeMakesPerfect_DrillsUI:additionalStartChecks()
    local clear = PMP.TileCheck.threeByThreeClear(self.player)
    if not clear then
        self.ok.enable = false
        self.ok.tooltip = "Need a clear 3x3 area to swing safely"
    end
end

function PracticeMakesPerfect_DrillsUI.openFor(player)
    local existing = PracticeMakesPerfect_DrillsUI.instance[player:getPlayerNum() + 1]
    if existing and existing:isVisible() then
        existing:setVisible(false)
        existing:removeFromUIManager()
        PracticeMakesPerfect_DrillsUI.instance[player:getPlayerNum() + 1] = nil
        return
    end
    local ui = PracticeMakesPerfect_DrillsUI:new(0, 0, 700, 400, player)
    ui:initialise()
    ui:addToUIManager()
end
