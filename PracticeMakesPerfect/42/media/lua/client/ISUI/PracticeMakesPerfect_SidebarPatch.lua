require "ISUI/ISEquippedItem"
require "ISUI/PracticeMakesPerfect_IconPopup"
require "ISUI/PracticeMakesPerfect_PracticeUI"
require "ISUI/PracticeMakesPerfect_DrillsUI"
require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.logInfo("SidebarPatch loading - wrapping ISEquippedItem (anchor: healthBtn, hover popout)")

-- Gap between the heart button and our first icon. Matches the inter-icon spacing
-- used elsewhere so the strip reads as one continuous row when revealed.
local HOVER_GAP = 5

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

local _orig_init = ISEquippedItem.initialise
local _orig_pre  = ISEquippedItem.prerender
local _orig_rm   = ISEquippedItem.removeFromUIManager
local _orig_chk  = ISEquippedItem.checkSidebarSizeOption

function ISEquippedItem:initialise(...)
    _orig_init(self, ...)
    if not self.chr or self.chr:getPlayerNum() ~= 0 then return end
    if not self.healthBtn then
        PMP.logWarn("ISEquippedItem.initialise: healthBtn not present, skipping PMP popup")
        return
    end
    if self.pmpPopup then return end

    local TW = getTextureWidth()
    local absX = self:getAbsoluteX() + self.healthBtn:getX() + TW + HOVER_GAP
    local absY = self:getAbsoluteY() + self.healthBtn:getY()
    self.pmpPopup = PMP.IconPopup:new(absX, absY, self.chr)
    self.pmpPopup.owner = self
    self.pmpPopup:initialise()
    self.pmpPopup:addToUIManager()
    self.pmpPopup:setVisible(false)  -- hidden until hover, just like TrapManager/cf_home
    PMP.logInfo("PMP popup created at (%d,%d) anchored to healthBtn (hidden, hover to reveal)", absX, absY)
end

function ISEquippedItem:prerender(...)
    _orig_pre(self, ...)
    if not (self.pmpPopup and self.healthBtn) then return end

    -- Keep popup positioned next to the (possibly moving) heart button each frame.
    local TW = getTextureWidth()
    local TH = math.floor(TW * 0.75)
    local heartX = self:getAbsoluteX() + self.healthBtn:getX()
    local heartY = self:getAbsoluteY() + self.healthBtn:getY()
    local popupX = heartX + TW + HOVER_GAP
    if self.pmpPopup:getX() ~= popupX or self.pmpPopup:getY() ~= heartY then
        self.pmpPopup:setX(popupX)
        self.pmpPopup:setY(heartY)
    end

    -- Combined hover area: heart button + spacing gap + popup width.
    local areaLeft  = heartX
    local areaRight = popupX + self.pmpPopup:getWidth()
    local areaTop   = heartY
    local areaBot   = heartY + TH
    local mx, my = getMouseX(), getMouseY()
    local insideArea = (mx >= areaLeft and mx < areaRight and my >= areaTop and my < areaBot)

    local sticky = self.pmpPopup.isAnyOwnedWindowOpen and self.pmpPopup:isAnyOwnedWindowOpen()
    local show = (insideArea or sticky) and (getCore():getGameMode() ~= "Tutorial")

    if show ~= self.pmpPopup:isVisible() then
        PMP.logDebug("PMP popup visibility -> %s (hover=%s sticky=%s)",
            tostring(show), tostring(insideArea), tostring(sticky))
    end
    self.pmpPopup:setVisible(show)
    if show then
        self.pmpPopup:bringToTop()
    else
        self.pmpPopup:hideTooltip()
    end
end

function ISEquippedItem:removeFromUIManager(...)
    if self.pmpPopup then
        PMP.logInfo("PMP popup removed (ISEquippedItem teardown)")
        self.pmpPopup:removeFromUIManager()
        self.pmpPopup = nil
    end
    _orig_rm(self, ...)
end

function ISEquippedItem:checkSidebarSizeOption(...)
    _orig_chk(self, ...)
    if self.pmpPopup then self.pmpPopup:reloadSidebarOptions() end
end
