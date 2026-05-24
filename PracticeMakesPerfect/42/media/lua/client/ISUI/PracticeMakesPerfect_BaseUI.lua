require "ISUI/ISPanelJoypad"
require "Definitions/PracticeMakesPerfect_Log"

PracticeMakesPerfect_BaseUI = ISPanelJoypad:derive("PracticeMakesPerfect_BaseUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function PracticeMakesPerfect_BaseUI:new(x, y, width, height, player, title, drillTable, actionClass)
    local fontScale = FONT_HGT_SMALL / 15
    width = math.min(width * fontScale, getCore():getScreenWidth() - 150)
    height = height * fontScale
    if y == 0 then
        y = getPlayerScreenTop(player:getPlayerNum()) + (getPlayerScreenHeight(player:getPlayerNum()) - height) / 2 + 200
    end
    if x == 0 then
        x = getPlayerScreenLeft(player:getPlayerNum()) + (getPlayerScreenWidth(player:getPlayerNum()) - width) / 2
    end
    x = math.max(0, math.min(x, getCore():getScreenWidth() - width))

    local o = ISPanelJoypad.new(self, x, y, width, height)
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.9}
    o.titleY = 10
    o.player = player
    o.title = title
    o.drillTable = drillTable
    o.actionClass = actionClass
    o.moveWithMouse = true
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    return o
end

function PracticeMakesPerfect_BaseUI:initialise()
    ISPanelJoypad.initialise(self)
    local btnWid = 100

    self.ok = ISButton:new(UI_BORDER_SPACING + 1, self:getHeight() - BUTTON_HGT - UI_BORDER_SPACING - 1,
        btnWid, BUTTON_HGT, getText("UI_Ok"), self, PracticeMakesPerfect_BaseUI.onClick)
    self.ok.internal = "OK"
    self.ok.anchorTop = false; self.ok.anchorBottom = true
    self.ok:initialise(); self.ok:instantiate()
    self.ok.borderColor = self.buttonBorderColor
    self:addChild(self.ok)

    self.cancel = ISButton:new(self.ok:getRight() + UI_BORDER_SPACING, self.ok.y, btnWid, BUTTON_HGT,
        getText("UI_Cancel"), self, PracticeMakesPerfect_BaseUI.onClick)
    self.cancel.internal = "CANCEL"
    self.cancel.anchorTop = false; self.cancel.anchorBottom = true
    self.cancel:initialise(); self.cancel:instantiate()
    self.cancel.borderColor = self.buttonBorderColor
    self:addChild(self.cancel)

    self.close = ISButton:new(self:getWidth() - btnWid - UI_BORDER_SPACING - 1, self.ok.y, btnWid, BUTTON_HGT,
        getText("UI_Close"), self, PracticeMakesPerfect_BaseUI.onClick)
    self.close.internal = "CLOSE"
    self.close.anchorLeft = false; self.close.anchorRight = true
    self.close.anchorTop = false; self.close.anchorBottom = true
    self.close:initialise(); self.close:instantiate()
    self.close.borderColor = self.buttonBorderColor
    self:addChild(self.close)

    self.drillsList = ISRadioButtons:new(UI_BORDER_SPACING + 1, 50, 220, 20, self, PracticeMakesPerfect_BaseUI.clickedDrill)
    self.drillsList.choicesColor = {r=1, g=1, b=1, a=1}
    self.drillsList:initialise()
    self.drillsList.autoWidth = true
    self:addChild(self.drillsList)
    self:populateDrills()

    local listBottom = self.drillsList:getBottom() + 10

    self.timeLbl = ISLabel:new(self.drillsList.x, listBottom + 5, FONT_HGT_SMALL,
        getText("IGUI_FitnessTime"), 1, 1, 1, 1, UIFont.Small, true)
    self.timeLbl:initialise(); self.timeLbl:instantiate()
    self:addChild(self.timeLbl)

    self.exeTime = ISTextEntryBox:new("10", self.timeLbl.x, self.timeLbl.y + self.timeLbl:getHeight() + 7, BUTTON_HGT, BUTTON_HGT)
    self.exeTime:initialise(); self.exeTime:instantiate()
    self.exeTime.font = UIFont.Medium
    self.exeTime:setOnlyNumbers(true)
    self.exeTime:setEditable(false)
    self:addChild(self.exeTime)

    self.plusBtn = ISButton:new(self.exeTime.x + self.exeTime:getWidth() + UI_BORDER_SPACING, self.exeTime.y,
        BUTTON_HGT, BUTTON_HGT, "+", self, self.onClickTime)
    self.plusBtn:initialise(); self.plusBtn:instantiate()
    self.plusBtn.internal = "TIMEPLUS"
    self:addChild(self.plusBtn)

    self.minusBtn = ISButton:new(self.plusBtn.x + self.plusBtn:getWidth() + UI_BORDER_SPACING, self.exeTime.y,
        BUTTON_HGT, BUTTON_HGT, "-", self, self.onClickTime)
    self.minusBtn:initialise(); self.minusBtn:instantiate()
    self.minusBtn.internal = "TIMEMINUS"
    self:addChild(self.minusBtn)

    self:setHeight(self.minusBtn:getBottom() + 10 + BUTTON_HGT + UI_BORDER_SPACING + 1)

    self.tooltipLbl = ISRichTextPanel:new(self.drillsList.x + self.drillsList:getWidth() + 10, self.drillsList.y,
        self:getWidth() - (self.drillsList.x + self.drillsList:getWidth() + 20), 200)
    self.tooltipLbl:initialise()
    self:addChild(self.tooltipLbl)
    self.tooltipLbl.background = false
    self.tooltipLbl.autosetheight = true
    self.tooltipLbl.clip = true
    self.tooltipLbl.text = ""
    self.tooltipLbl:paginate()

    self:autoSelectFirstEnabled()
    self:selectedNewDrill()

    self:insertNewLineOfButtons(self.drillsList)
    self:insertNewLineOfButtons(self.plusBtn, self.minusBtn)
    self:insertNewLineOfButtons(self.ok, self.cancel, self.close)
end

function PracticeMakesPerfect_BaseUI:populateDrills()
    self.drillsList:clear()
    self.drillOrder = {}
    local skipped = 0
    for key, drill in pairs(self.drillTable) do
        if drill.perk ~= nil then
            table.insert(self.drillOrder, { key = key, drill = drill })
        else
            skipped = skipped + 1
            PMP.logWarn("UI populate: drill '%s' skipped (perk nil in this PZ build)", key)
        end
    end
    table.sort(self.drillOrder, function(a, b) return a.drill.name < b.drill.name end)
    for _, entry in ipairs(self.drillOrder) do
        self:addDrillToList(entry.key, entry.drill)
    end
    PMP.logInfo("UI '%s' populated: %d drills shown, %d skipped", self.title or "?", #self.drillOrder, skipped)
end

function PracticeMakesPerfect_BaseUI:addDrillToList(key, drill)
    local text = drill.name
    local enabled = true
    local ok, reason = true, nil
    if drill.gate then
        ok, reason = drill.gate(self.player)
    end
    local why = nil
    if not ok then
        enabled = false; why = reason or "unavailable"
        text = text .. " — " .. tostring(why)
    elseif PMP.Drills.belowMin(self.player, drill) then
        enabled = false; why = "level<min(" .. tostring(drill.levelMin) .. ")"
        text = text .. " — Reach level " .. tostring(drill.levelMin) .. " first"
    elseif PMP.Drills.atOrAboveCap(self.player, drill) then
        enabled = false; why = "level>=cap(" .. tostring(drill.levelCap) .. ")"
        text = text .. " — Capped at level " .. tostring(drill.levelCap)
    end
    if enabled then
        PMP.logDebug("  Drill '%s' enabled", key)
    else
        PMP.logDebug("  Drill '%s' disabled: %s", key, tostring(why))
    end
    self.drillsList:addOption(text, key, nil, enabled)
end

function PracticeMakesPerfect_BaseUI:autoSelectFirstEnabled()
    for i = 1, #self.drillOrder do
        local opt = self.drillsList.options and self.drillsList.options[i]
        if opt and opt.enabled then
            self.selectedDrillKey = self.drillOrder[i].key
            return
        end
    end
    self.selectedDrillKey = self.drillOrder[1] and self.drillOrder[1].key or nil
end

function PracticeMakesPerfect_BaseUI:clickedDrill(buttons, index)
    for i = 1, #self.drillsList.options do
        if self.drillsList:isSelected(i) then
            self.selectedDrillKey = self.drillsList:getOptionData(i)
            self:selectedNewDrill()
            return
        end
    end
end

function PracticeMakesPerfect_BaseUI:selectedNewDrill()
    if not self.selectedDrillKey then return end
    self.selectedDrill = self.drillTable[self.selectedDrillKey]
    local d = self.selectedDrill
    local lines = {}
    if d.tooltip then table.insert(lines, d.tooltip) end
    local perkName = "skill"
    if d.perk and d.perk.getName then perkName = d.perk:getName() end
    table.insert(lines, "Perk: " .. perkName)
    if d.levelMin then table.insert(lines, "Available from level " .. d.levelMin) end
    if d.levelCap then table.insert(lines, "XP gain stops at level " .. d.levelCap) end
    if d.consume and d.consume.item then table.insert(lines, "Consumes " .. d.consume.item .. " (skill-scaled loss)") end
    if d.consume and d.consume.transform then table.insert(lines, "Cycles " .. d.consume.transform.from .. " → " .. d.consume.transform.to) end
    if d.sittable then table.insert(lines, "Can be done sitting.") else table.insert(lines, "Must be standing.") end
    self.tooltipLbl.text = table.concat(lines, " <LINE> ")
    self.tooltipLbl:paginate()
end

function PracticeMakesPerfect_BaseUI:onClickTime(button)
    local currentTime = tonumber(self.exeTime:getInternalText())
    if button.internal == "TIMEPLUS" and currentTime < 60 then currentTime = currentTime + 10 end
    if button.internal == "TIMEMINUS" and currentTime > 10 then currentTime = currentTime - 10 end
    self.exeTime:setText(currentTime .. "")
end

function PracticeMakesPerfect_BaseUI:prerender()
    self:drawRect(0, 0, self:getWidth(), self:getHeight(), self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawTextCentre(self.title or "Practice", self:getWidth()/2, self.titleY, 1,1,1,1, UIFont.Medium)
end

function PracticeMakesPerfect_BaseUI:render()
    ISPanelJoypad.render(self)
    self:updateButtons()
end

function PracticeMakesPerfect_BaseUI:updateButtons()
    self.cancel.enable = false
    self.ok.enable = true
    self.ok.tooltip = nil

    local d = self.selectedDrill
    if not d then
        self.ok.enable = false
        self.ok.tooltip = "Select a drill"
        return
    end
    local gateOk, gateReason = true, nil
    if d.gate then gateOk, gateReason = d.gate(self.player) end
    if not gateOk then
        self.ok.enable = false
        self.ok.tooltip = gateReason or "Missing equipment"
    end
    if PMP.Drills.belowMin(self.player, d) then
        self.ok.enable = false
        self.ok.tooltip = "Reach level " .. tostring(d.levelMin) .. " first"
    end
    if PMP.Drills.atOrAboveCap(self.player, d) then
        self.ok.enable = false
        self.ok.tooltip = "Capped at level " .. tostring(d.levelCap)
    end
    if self.player:getMoodles():getMoodleLevel(MoodleType.ENDURANCE) > 2 then
        self.ok.enable = false
        self.ok.tooltip = getText("Tooltip_TooExhaustedFitness")
    end
    if self.player:getMoodles():getMoodleLevel(MoodleType.HEAVY_LOAD) > 2 then
        self.ok.enable = false
        self.ok.tooltip = getText("Tooltip_TooHeavyFitness")
    end
    if not d.sittable and (self.player:getVariableBoolean("sitonground") or self.player:isSittingOnFurniture()) then
        self.ok.enable = false
        self.ok.tooltip = getText("Tooltip_StandStillFitness")
    end
    if self.player:getVehicle() then
        self.ok.enable = false
        self:removeFromUIManager()
    end
    if self.player:getMoodles():getMoodleLevel(MoodleType.PAIN) > 3 then
        self.ok.enable = false
        self.ok.tooltip = getText("Tooltip_TooMuchPainFitness")
    end
    if self.player:isClimbing() then
        self.ok.enable = false
    end
    self:additionalStartChecks()

    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if currentAction and currentAction.drill and currentAction.drillKey then
        self.cancel.enable = true
    end
end

function PracticeMakesPerfect_BaseUI:additionalStartChecks() end

function PracticeMakesPerfect_BaseUI:onClick(button)
    if button.internal == "OK" then
        local d = self.selectedDrill
        if not d then
            PMP.logWarn("OK clicked with no selected drill")
            return
        end
        local mins = tonumber(self.exeTime:getInternalText())
        PMP.logInfo("OK: queuing drill='%s' duration=%dm via %s", self.selectedDrillKey, mins, self.title or "?")
        local action = self.actionClass:new(self.player, self.selectedDrillKey, d, mins)
        ISTimedActionQueue.addGetUpAndThen(self.player, action)
        self:setVisible(false)
        self:removeFromUIManager()
    elseif button.internal == "CLOSE" then
        PMP.logDebug("UI '%s' closed via Close button", self.title or "?")
        self:setVisible(false)
        self:removeFromUIManager()
    elseif button.internal == "CANCEL" then
        local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
        local currentAction = actionQueue.queue[1]
        if currentAction and currentAction.drill then
            PMP.logInfo("Cancel: force-stopping active drill='%s'", currentAction.drillKey or "?")
            currentAction:forceStop()
        end
    end
end
