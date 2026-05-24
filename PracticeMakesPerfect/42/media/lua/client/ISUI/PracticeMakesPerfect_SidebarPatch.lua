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

local function iconGap()
    local mods = getActivatedMods()
    local hasNeighbor = (mods and (mods:contains("cf_home") or mods:contains("TrapManager")))
    return hasNeighbor and 17 or 7
end

local F = {}

F.initialise = function(orig) return function(self)
    orig(self)
    if self.chr:getPlayerNum() ~= 0 then return end
    if not self.zoneBtn then
        PMP.logWarn("ISEquippedItem.initialise: zoneBtn not present, skipping PMP icon")
        return
    end
    if self.pmpPopup then return end

    local width = iconWidth()
    local gap = iconGap()
    local x = self:getAbsoluteX() + self.zoneBtn:getX() + (width * 3) + gap
    local y = self:getAbsoluteY() + self.zoneBtn:getY()

    self.pmpPopup = PMP.IconPopup:new(x, y, self.chr)
    self.pmpPopup:initialise()
    self.pmpPopup:addToUIManager()
    self.pmpPopup:setVisible(true)
    PMP.logInfo("PMP sidebar icon added at (%d,%d) width=%d gap=%d (neighbor mods detected: %s)",
        x, y, width, gap,
        tostring((getActivatedMods() and (getActivatedMods():contains("cf_home") or getActivatedMods():contains("TrapManager"))) or false))
end end

F.prerender = function(orig) return function(self)
    orig(self)
    if not (self.zoneBtn and self.pmpPopup) then return end

    local width = iconWidth()
    local x = self:getAbsoluteX() + self.zoneBtn:getX() + (width * 3) + iconGap()
    local y = self:getAbsoluteY() + self.zoneBtn:getY()
    self.pmpPopup:setX(x)
    self.pmpPopup:setY(y)

    local mainHover = self.pmpPopup:isMainIconHovered()
    local anyHover = self.pmpPopup:isAnyHovered()
    if mainHover or (self.pmpPopup.isExpanded and anyHover) then
        self.pmpPopup.isExpanded = true
        self.pmpPopup:bringToTop()
    else
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
