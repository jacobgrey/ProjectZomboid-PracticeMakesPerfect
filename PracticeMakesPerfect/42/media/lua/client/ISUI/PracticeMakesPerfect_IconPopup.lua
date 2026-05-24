require "ISUI/ISPanel"
require "ISUI/ISToolTip"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.PopupOffset = 5
PMP.PopupSpacing = 4

local function getTextureDimension()
    local core = getCore()
    local size = core:getOptionSidebarSize()
    if size == 6 then size = core:getOptionFontSizeReal() - 1 end
    local width = 48
    if size == 2 then width = 64
    elseif size == 3 then width = 80
    elseif size == 4 then width = 96
    elseif size == 5 then width = 128 end
    return width, width * 0.75
end

PMP.IconPopup = PMP.IconPopup or ISPanel:derive("PMP_IconPopup")
local P = PMP.IconPopup

function P:new(x, y, player)
    local o = ISPanel:new(x, y, 0, 0)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerNum = player:getPlayerNum()
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o:reloadSidebarOptions()
    return o
end

function P:reloadSidebarOptions()
    local width = getTextureDimension()
    self.iconWidth = width
    self.iconOff = getTexture("media/ui/Sidebar/" .. width .. "/Carpentry_Off_" .. width .. ".png")
    self.iconOn  = getTexture("media/ui/Sidebar/" .. width .. "/Carpentry_On_" .. width .. ".png")
    self.subIconExercise = getTexture("media/ui/Sidebar/" .. width .. "/Heart_On_" .. width .. ".png")
    self.subIconPractice = getTexture("media/ui/Sidebar/" .. width .. "/Furniture_Repair_" .. width .. ".png")
        or getTexture("media/ui/Sidebar/" .. width .. "/Carpentry_On_" .. width .. ".png")
    self.subIconDrills = getTexture("media/ui/Sidebar/" .. width .. "/Build_On_" .. width .. ".png")
    self:setWidth(width)
    self:setHeight(width * .75)
    self.expandedWidth = (width + PMP.PopupSpacing) * 4
end

function P:isMainIconHovered()
    if not self:isVisible() then return false end
    local mx = getMouseX()
    local my = getMouseY()
    return mx >= self:getAbsoluteX() and mx <= self:getAbsoluteX() + self.iconWidth
        and my >= self:getAbsoluteY() and my <= self:getAbsoluteY() + self.iconWidth * 0.75
end

function P:isAnyHovered()
    if not self:isVisible() then return false end
    local mx = getMouseX()
    local my = getMouseY()
    return mx >= self:getAbsoluteX() and mx <= self:getAbsoluteX() + self:getWidth()
        and my >= self:getAbsoluteY() and my <= self:getAbsoluteY() + self:getHeight()
end

function P:isHoveredOver(slot)
    local mx = getMouseX()
    local my = getMouseY()
    local x = self:getAbsoluteX() + slot * (self.iconWidth + PMP.PopupSpacing)
    local y = self:getAbsoluteY()
    return mx >= x and mx <= x + self.iconWidth and my >= y and my <= y + self.iconWidth * 0.75
end

function P:prerender()
    if self.isExpanded then
        self:setWidth(self.expandedWidth)
    else
        self:setWidth(self.iconWidth)
    end
end

function P:render()
    self:drawTexture(self.iconOff, 0, 0, 1, 1, 1, 1)
    if self.isExpanded then
        local step = self.iconWidth + PMP.PopupSpacing
        self:drawTexture(self.subIconExercise, step,     0, 1, 1, 1, 1)
        self:drawTexture(self.subIconPractice, step * 2, 0, 1, 1, 1, 1)
        self:drawTexture(self.subIconDrills,   step * 3, 0, 1, 1, 1, 1)

        if self:isHoveredOver(1) then self:showTooltip("Exercise (Fitness, Sprinting, Nimble, Stealth)") end
        if self:isHoveredOver(2) then self:showTooltip("Practice (Tailoring, Reloading, First Aid, etc.)") end
        if self:isHoveredOver(3) then self:showTooltip("Drills (weapon shadow-swings, dry-fire)") end
    elseif self:isMainIconHovered() then
        self:showTooltip("Skill Practice")
    end
end

function P:showTooltip(text)
    if not text then return end
    if not self.tooltip then
        self.tooltip = ISToolTip:new()
        self.tooltip:initialise()
        self.tooltip:instantiate()
        self.tooltip:setOwner(self)
        self.tooltip:setWidth(120)
        self.tooltip:doLayout()
    end
    self.tooltip:setDescription(text)
    self.tooltip:setVisible(true)
    self.tooltip:addToUIManager()
    self.tooltip:bringToTop()
end

function P:hideTooltip()
    if not (self.tooltip and self.tooltip:isVisible()) then return end
    self.tooltip:removeFromUIManager()
    self.tooltip:setVisible(false)
end

function P:onMouseMove(_, _)
    return true
end

function P:onMouseMoveOutside(_, _)
    self:hideTooltip()
    return true
end

function P:onMouseDown(x, y)
    self:hideTooltip()
    if not self.isExpanded then
        PMP.logDebug("IconPopup click ignored (not expanded)")
        return true
    end
    if self:isHoveredOver(1) then
        PMP.logInfo("Opening Exercise UI from PMP popup")
        local ui = ISFitnessUI:new(0, 0, 600, 350, self.player)
        ui:initialise()
        ui:addToUIManager()
        ISFitnessUI.instance[self.playerNum + 1] = ui
    elseif self:isHoveredOver(2) then
        PMP.logInfo("Opening Practice UI from PMP popup")
        PracticeMakesPerfect_PracticeUI.openFor(self.player)
    elseif self:isHoveredOver(3) then
        PMP.logInfo("Opening Drills UI from PMP popup")
        PracticeMakesPerfect_DrillsUI.openFor(self.player)
    end
    return true
end
