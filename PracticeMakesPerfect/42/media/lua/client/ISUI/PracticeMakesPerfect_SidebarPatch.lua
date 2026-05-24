require "ISUI/ISEquippedItem"
require "ISUI/PracticeMakesPerfect_IconPopup"
require "ISUI/PracticeMakesPerfect_PracticeUI"
require "ISUI/PracticeMakesPerfect_DrillsUI"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.logInfo("SidebarPatch loading - wrapping ISEquippedItem methods (anchor: healthBtn)")

local function Override(obj, method, factory) obj[method] = factory(obj[method]) end

-- Small inter-icon gap to match the visual spacing between vanilla sidebar buttons.
local SLOT_INNER_GAP = 4

local function computePopupPosition(self)
    -- Anchor to the heart (player info) button: our icons sit horizontally to its right.
    -- This is the same pattern cf_home and TrapManager use against zoneBtn, just on a
    -- different vanilla button.
    local anchor = self.healthBtn
    if not anchor then return nil end
    local x = self:getAbsoluteX() + anchor:getX() + anchor:getWidth() + SLOT_INNER_GAP
    local y = self:getAbsoluteY() + anchor:getY()
    return x, y
end

local F = {}

F.initialise = function(orig) return function(self)
    orig(self)
    if self.chr:getPlayerNum() ~= 0 then return end
    if not self.healthBtn then
        PMP.logWarn("ISEquippedItem.initialise: healthBtn not present, skipping PMP icons")
        return
    end
    if self.pmpPopup then return end

    local x, y = computePopupPosition(self)
    if not x then return end

    self.pmpPopup = PMP.IconPopup:new(x, y, self.chr)
    self.pmpPopup:initialise()
    self.pmpPopup:addToUIManager()
    self.pmpPopup:setVisible(true)
    PMP.logInfo("PMP sidebar icons added at (%d,%d) anchored to healthBtn", x, y)
end end

F.prerender = function(orig) return function(self)
    orig(self)
    if not (self.healthBtn and self.pmpPopup) then return end

    -- Keep tracking healthBtn's live position so we stay aligned when the sidebar
    -- shifts (size changes, oscillation effect, layout reflow).
    local x, y = computePopupPosition(self)
    if x then
        self.pmpPopup:setX(x)
        self.pmpPopup:setY(y)
        self.pmpPopup:bringToTop()
    end

    if "Tutorial" == getCore():getGameMode() then self.pmpPopup:setVisible(false) end
end end

F.removeFromUIManager = function(orig) return function(self)
    if self.pmpPopup then
        PMP.logInfo("PMP sidebar icons removed (ISEquippedItem teardown)")
        self.pmpPopup:removeFromUIManager()
        self.pmpPopup = nil
    end
    orig(self)
end end

F.checkSidebarSizeOption = function(orig) return function(self)
    orig(self)
    if self.pmpPopup then self.pmpPopup:reloadSidebarOptions() end
end end

for method, factory in pairs(F) do Override(ISEquippedItem, method, factory) end
