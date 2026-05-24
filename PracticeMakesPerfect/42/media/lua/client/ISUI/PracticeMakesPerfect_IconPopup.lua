require "ISUI/ISPanel"
require "ISUI/ISToolTip"
require "Definitions/PracticeMakesPerfect_Log"

-- Mirror of cf_home / TrapManager pattern: this is an ISPanel that hosts our sidebar
-- icons next to a vanilla button (healthBtn). No hover popout - icons are always
-- visible and individually clickable. The "Popup" name is kept for naming parity with
-- those reference mods even though there is no visible expand.

PMP = PMP or {}
PMP.IconSpacing = 4

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
    o:reloadSidebarOptions()
    return o
end

function P:reloadSidebarOptions()
    local width = getTextureDimension()
    self.iconWidth = width
    self.iconHeight = math.floor(width * 0.75)  -- match vanilla 48x36 / 64x48 etc.
    -- Inventory_On for Practice (items theme), Build_On for Drills (work/combat theme).
    -- These icons are also used elsewhere in vanilla but are placed at different points
    -- on the sidebar so visual collision is minimal at our anchor (next to healthBtn).
    self.practiceIcon = getTexture("media/ui/Sidebar/" .. width .. "/Inventory_On_" .. width .. ".png")
    self.drillsIcon   = getTexture("media/ui/Sidebar/" .. width .. "/Build_On_"     .. width .. ".png")
    -- Two icons side by side.
    self:setWidth((width * 2) + PMP.IconSpacing)
    self:setHeight(self.iconHeight)
end

local function slotX(panel, slot)  -- slot 0 = Practice, slot 1 = Drills
    return slot * (panel.iconWidth + PMP.IconSpacing)
end

function P:isHoveredOverSlot(slot)
    if not self:isVisible() then return false end
    local mx, my = getMouseX(), getMouseY()
    local x = self:getAbsoluteX() + slotX(self, slot)
    local y = self:getAbsoluteY()
    return mx >= x and mx <= x + self.iconWidth and my >= y and my <= y + self.iconHeight
end

function P:render()
    self:drawTexture(self.practiceIcon, slotX(self, 0), 0, 1, 1, 1, 1)
    self:drawTexture(self.drillsIcon,   slotX(self, 1), 0, 1, 1, 1, 1)
    if self:isHoveredOverSlot(0) then self:showTooltip("Practice (Tailoring, Reloading, First Aid, etc.)") end
    if self:isHoveredOverSlot(1) then self:showTooltip("Drills (weapon shadow-swings, dry-fire)") end
end

function P:showTooltip(text)
    if not text then return end
    if not self.tooltip then
        self.tooltip = ISToolTip:new()
        self.tooltip:initialise()
        self.tooltip:instantiate()
        self.tooltip:setOwner(self)
        self.tooltip:setWidth(180)
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
        PMP.logInfo("Opening Practice UI from sidebar icon")
        PracticeMakesPerfect_PracticeUI.openFor(self.player)
        return true
    end
    if self:isHoveredOverSlot(1) then
        PMP.logInfo("Opening Drills UI from sidebar icon")
        PracticeMakesPerfect_DrillsUI.openFor(self.player)
        return true
    end
    return true
end
