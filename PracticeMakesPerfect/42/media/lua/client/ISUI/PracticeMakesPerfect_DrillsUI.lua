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
    local clear, dx, dy = PMP.TileCheck.threeByThreeClear(self.player)
    if not clear then
        self.ok.enable = false
        self.ok.tooltip = "Need a clear 3x3 area to swing safely"
        if not self._loggedTileBlock or (dx ~= self._loggedDx) or (dy ~= self._loggedDy) then
            PMP.logDebug("Drills disabled: tile clear check failed at offset (dx=%d, dy=%d)", dx or 0, dy or 0)
            self._loggedTileBlock = true; self._loggedDx = dx; self._loggedDy = dy
        end
    else
        self._loggedTileBlock = false
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
