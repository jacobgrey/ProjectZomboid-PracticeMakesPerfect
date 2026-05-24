require "ISUI/ISPanel"
require "ISUI/ISToolTip"
require "Definitions/PracticeMakesPerfect_Log"

-- Hover-driven popup that extends horizontally from the heart (player info) button.
-- Modeled directly on TrapManager's TM_TrapPopup: a single ISPanel covering the icon
-- strip, with drawTextureScaled() per icon and onMouseUp() doing relative-X hit-tests.
-- Visibility is controlled by ISEquippedItem:prerender (in SidebarPatch.lua) which
-- shows the panel only when the mouse is inside the combined hover area.

PMP = PMP or {}
PMP.IconSpacing = 4

local function getTextureWidth()
    local core = getCore()
    local size = core:getOptionSidebarSize()
    if size == 6 then size = core:getOptionFontSizeReal() - 1 end
    local TW = 48
    if size == 2 then TW = 64
    elseif size == 3 then TW = 80
    elseif size == 4 then TW = 96
    elseif size == 5 then TW = 128 end
    return TW
end

PMP.IconPopup = PMP.IconPopup or ISPanel:derive("PMP_IconPopup")
local P = PMP.IconPopup

function P:new(x, y, player)
    local TW = getTextureWidth()
    local TH = math.floor(TW * 0.75)
    -- Two icons side by side with one spacing gap between.
    local w = (TW * 2) + PMP.IconSpacing
    local o = ISPanel.new(self, x, y, w, TH)
    o:setAnchorLeft(true); o:setAnchorRight(false)
    o:setAnchorTop(true);  o:setAnchorBottom(false)
    o.background = false
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.player = player
    o.playerNum = player:getPlayerNum()
    o.TEXTURE_WIDTH = TW
    o.TEXTURE_HEIGHT = TH

    o.practiceIcon = getTexture("media/ui/Sidebar/" .. TW .. "/Inventory_On_" .. TW .. ".png")
    o.drillsIcon   = getTexture("media/ui/Sidebar/" .. TW .. "/Build_On_"     .. TW .. ".png")

    o.tooltip = ISToolTip:new()
    o.tooltip:initialise()
    o.tooltip:setVisible(false)
    return o
end

function P:reloadSidebarOptions()
    local TW = getTextureWidth()
    local TH = math.floor(TW * 0.75)
    self.TEXTURE_WIDTH = TW
    self.TEXTURE_HEIGHT = TH
    self:setWidth((TW * 2) + PMP.IconSpacing)
    self:setHeight(TH)
    self.practiceIcon = getTexture("media/ui/Sidebar/" .. TW .. "/Inventory_On_" .. TW .. ".png")
    self.drillsIcon   = getTexture("media/ui/Sidebar/" .. TW .. "/Build_On_"     .. TW .. ".png")
end

local function practiceX(panel) return 0 end
local function drillsX(panel)   return panel.TEXTURE_WIDTH + PMP.IconSpacing end

function P:render()
    local TW, TH = self.TEXTURE_WIDTH, self.TEXTURE_HEIGHT
    if self.practiceIcon then
        self:drawTextureScaled(self.practiceIcon, practiceX(self), 0, TW, TH, 1, 1, 1, 1)
    end
    if self.drillsIcon then
        self:drawTextureScaled(self.drillsIcon,   drillsX(self),   0, TW, TH, 1, 1, 1, 1)
    end
end

function P:showTooltip(text)
    if not text then return end
    self.tooltip.description = text
    if not self.tooltip:getIsVisible() then
        self.tooltip:setVisible(true)
        self.tooltip:addToUIManager()
    end
    self.tooltip:setX(getMouseX() + 16)
    self.tooltip:setY(getMouseY() + 16)
end

function P:hideTooltip()
    if self.tooltip and self.tooltip:getIsVisible() then
        self.tooltip:setVisible(false)
        self.tooltip:removeFromUIManager()
    end
end

function P:onMouseMove(_, _)
    local TW = self.TEXTURE_WIDTH
    local x = self:getMouseX()
    if x >= practiceX(self) and x < practiceX(self) + TW then
        self:showTooltip("Practice (Tailoring, Reloading, First Aid, etc.)")
    elseif x >= drillsX(self) and x < drillsX(self) + TW then
        self:showTooltip("Drills (weapon shadow-swings, dry-fire)")
    else
        self:hideTooltip()
    end
    return true
end

function P:onMouseMoveOutside(_, _)
    self:hideTooltip()
    return true
end

function P:onMouseUp(mx, my)
    self:hideTooltip()
    local TW = self.TEXTURE_WIDTH
    if mx >= practiceX(self) and mx < practiceX(self) + TW then
        PMP.logInfo("Opening Practice UI from sidebar")
        PracticeMakesPerfect_PracticeUI.openFor(self.player)
        return true
    end
    if mx >= drillsX(self) and mx < drillsX(self) + TW then
        PMP.logInfo("Opening Drills UI from sidebar")
        PracticeMakesPerfect_DrillsUI.openFor(self.player)
        return true
    end
    return true
end

-- Whether a PMP-owned UI is currently visible. Used by SidebarPatch to keep the popup
-- on screen while the user is interacting with it.
function P:isAnyOwnedWindowOpen()
    local pUI = PracticeMakesPerfect_PracticeUI and PracticeMakesPerfect_PracticeUI.instance and PracticeMakesPerfect_PracticeUI.instance[self.playerNum + 1]
    local dUI = PracticeMakesPerfect_DrillsUI and PracticeMakesPerfect_DrillsUI.instance and PracticeMakesPerfect_DrillsUI.instance[self.playerNum + 1]
    if pUI and pUI.isVisible and pUI:isVisible() then return true end
    if dUI and dUI.isVisible and dUI:isVisible() then return true end
    return false
end
