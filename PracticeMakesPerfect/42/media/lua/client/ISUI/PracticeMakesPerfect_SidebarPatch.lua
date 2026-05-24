require "ISUI/ISEquippedItem"
require "ISUI/PracticeMakesPerfect_IconPopup"
require "ISUI/PracticeMakesPerfect_PracticeUI"
require "ISUI/PracticeMakesPerfect_DrillsUI"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.logInfo("SidebarPatch loading - wrapping ISEquippedItem methods")

local function Override(obj, method, factory) obj[method] = factory(obj[method]) end

local function iconWidth()
    local core = getCore()
    local size = core:getOptionSidebarSize()
    if size == 6 then size = core:getOptionFontSizeReal() - 1 end
    if size == 1 then return 48 end
    if size == 2 then return 64 end
    if size == 3 then return 80 end
    if size == 4 then return 96 end
    if size == 5 then return 128 end
    return 48
end

-- Count how many sidebar slots are already occupied between zoneBtn and us, so we land
-- right after them instead of overlapping or leaving a big gap.
-- The convention used by cf_home and TrapManager: each addon occupies one icon-width slot
-- to the right of self.zoneBtn. We sit at slot (1 + active_neighbors).
local function neighborSlotCount()
    local mods = getActivatedMods()
    if not mods then return 0 end
    local n = 0
    if mods:contains("cf_home") then n = n + 1 end
    if mods:contains("TrapManager") then n = n + 1 end
    return n
end

local SLOT_INNER_GAP = 4  -- small gap between adjacent icons

local F = {}

local function computePopupPosition(self)
    local width = iconWidth()
    local neighbors = neighborSlotCount()
    -- Land at slot (1 + neighbors). Slot 0 is zoneBtn itself; slot 1 is one icon-width
    -- to the right, etc.
    local slot = 1 + neighbors
    local x = self:getAbsoluteX() + self.zoneBtn:getX() + slot * (width + SLOT_INNER_GAP)
    local y = self:getAbsoluteY() + self.zoneBtn:getY()
    return x, y, width, neighbors
end

F.initialise = function(orig) return function(self)
    orig(self)
    if self.chr:getPlayerNum() ~= 0 then return end
    if not self.zoneBtn then
        PMP.logWarn("ISEquippedItem.initialise: zoneBtn not present, skipping PMP icon")
        return
    end
    if self.pmpPopup then return end

    local x, y, width, neighbors = computePopupPosition(self)

    self.pmpPopup = PMP.IconPopup:new(x, y, self.chr)
    self.pmpPopup:initialise()
    self.pmpPopup:addToUIManager()
    self.pmpPopup:setVisible(true)
    PMP.logInfo("PMP sidebar icon added at (%d,%d) width=%d neighbors=%d (slot=%d)",
        x, y, width, neighbors, 1 + neighbors)
end end

F.prerender = function(orig) return function(self)
    orig(self)
    if not (self.zoneBtn and self.pmpPopup) then return end

    local x, y = computePopupPosition(self)
    self.pmpPopup:setX(x)
    self.pmpPopup:setY(y)

    -- Hover-driven expansion. Because the popup is always at full expanded width, a hover
    -- anywhere along the icon strip keeps it open - no race between width-grow and hit-test.
    if self.pmpPopup:isAnyHovered() then
        if not self.pmpPopup.isExpanded then
            PMP.logDebug("PMP popup expanding (hover entered)")
        end
        self.pmpPopup.isExpanded = true
        self.pmpPopup:bringToTop()
    else
        if self.pmpPopup.isExpanded then
            PMP.logDebug("PMP popup collapsing (hover exited)")
        end
        self.pmpPopup.isExpanded = false
        self.pmpPopup:hideTooltip()
    end

    if "Tutorial" == getCore():getGameMode() then self.pmpPopup:setVisible(false) end
end end

F.removeFromUIManager = function(orig) return function(self)
    if self.pmpPopup then
        PMP.logInfo("PMP sidebar icon removed (ISEquippedItem teardown)")
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
