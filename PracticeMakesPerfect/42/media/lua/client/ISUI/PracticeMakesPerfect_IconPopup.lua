require "ISUI/ISPanel"
require "ISUI/ISToolTip"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
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
    return width
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
    o.isExpanded = false
    o:reloadSidebarOptions()
    return o
end

function P:reloadSidebarOptions()
    local width = getTextureDimension()
    self.iconWidth = width
    self.iconHeight = math.floor(width * 0.75)  -- matches vanilla 48x36 / 64x48 etc.
    -- Vanilla icons are 48x36 (etc); a few are 48x48 - pick only 4:3 to stay visually
    -- aligned with vanilla sidebar buttons. Main = Search (magnifying glass, "study").
    self.iconOff = getTexture("media/ui/Sidebar/" .. width .. "/Search_Off_" .. width .. ".png")
    self.iconOn  = getTexture("media/ui/Sidebar/" .. width .. "/Search_On_"  .. width .. ".png")
    self.subIconExercise = getTexture("media/ui/Sidebar/" .. width .. "/Heart_On_"     .. width .. ".png")
    self.subIconPractice = getTexture("media/ui/Sidebar/" .. width .. "/Inventory_On_" .. width .. ".png")
    self.subIconDrills   = getTexture("media/ui/Sidebar/" .. width .. "/Build_On_"     .. width .. ".png")
    -- Always full width: 1 main icon + 3 sub icons + spacing between. Hit-tests cover
    -- the whole strip so hovering off the main icon onto a sub-icon doesn't collapse us.
    self.expandedWidth = (width * 4) + (PMP.PopupSpacing * 3)
    self:setWidth(self.expandedWidth)
    self:setHeight(self.iconHeight)
end

-- Slot 0 is the main icon; slots 1..3 are the sub icons.
local function slotX(panel, slot)
    return slot * (panel.iconWidth + PMP.PopupSpacing)
end

function P:isHoveredOverSlot(slot)
    if not self:isVisible() then return false end
    local mx, my = getMouseX(), getMouseY()
    local x = self:getAbsoluteX() + slotX(self, slot)
    local y = self:getAbsoluteY()
    return mx >= x and mx <= x + self.iconWidth and my >= y and my <= y + self.iconHeight
end

function P:isMainIconHovered() return self:isHoveredOverSlot(0) end

function P:isAnyHovered()
    if not self:isVisible() then return false end
    if self:isHoveredOverSlot(0) then return true end
    if self.isExpanded then
        if self:isHoveredOverSlot(1) or self:isHoveredOverSlot(2) or self:isHoveredOverSlot(3) then
            return true
        end
    end
    return false
end

function P:render()
    -- Always draw the main icon at slot 0.
    self:drawTexture(self.iconOff, slotX(self, 0), 0, 1, 1, 1, 1)
    if self.isExpanded then
        self:drawTexture(self.subIconExercise, slotX(self, 1), 0, 1, 1, 1, 1)
        self:drawTexture(self.subIconPractice, slotX(self, 2), 0, 1, 1, 1, 1)
        self:drawTexture(self.subIconDrills,   slotX(self, 3), 0, 1, 1, 1, 1)
        if self:isHoveredOverSlot(1) then self:showTooltip("Exercise") end
        if self:isHoveredOverSlot(2) then self:showTooltip("Practice") end
        if self:isHoveredOverSlot(3) then self:showTooltip("Drills") end
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

function P:onMouseMove(_, _) return true end
function P:onMouseMoveOutside(_, _) self:hideTooltip(); return true end

function P:onMouseDown(x, y)
    self:hideTooltip()
    if self:isHoveredOverSlot(0) then
        -- Click on main icon: toggle expansion. Hover-expansion still works, this just
        -- provides a click-to-pin path too.
        self.isExpanded = not self.isExpanded
        PMP.logDebug("Main icon click - isExpanded=%s", tostring(self.isExpanded))
        return true
    end
    if not self.isExpanded then
        PMP.logDebug("Sub-icon click ignored (popup not expanded)")
        return true
    end
    if self:isHoveredOverSlot(1) then
        PMP.logInfo("Opening Exercise UI from PMP popup")
        local ui = ISFitnessUI:new(0, 0, 600, 350, self.player)
        ui:initialise()
        ui:addToUIManager()
        ISFitnessUI.instance[self.playerNum + 1] = ui
    elseif self:isHoveredOverSlot(2) then
        PMP.logInfo("Opening Practice UI from PMP popup")
        PracticeMakesPerfect_PracticeUI.openFor(self.player)
    elseif self:isHoveredOverSlot(3) then
        PMP.logInfo("Opening Drills UI from PMP popup")
        PracticeMakesPerfect_DrillsUI.openFor(self.player)
    end
    return true
end
