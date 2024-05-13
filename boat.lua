local backdrop_border = {
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 8,
  insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local backdrop_background = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  tile = true, tileSize = 16, edgeSize = 8,
  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}  

local boat = CreateFrame("Frame")
boat:RegisterEvent("SPELLCAST_START")
boat:RegisterEvent("SPELLCAST_STOP")
boat:RegisterEvent("SPELLCAST_FAIL")
boat:RegisterEvent("SPELLCAST_INTERRUPTED")
boat:RegisterEvent("VARIABLES_LOADED")
boat:Hide()

boat.spell = "Fishing Boat"
boat.duration = 3600
boat.casting = false

boat:SetScript("OnEvent", function()
  if event == "VARIABLES_LOADED" then
    this.timer.despawn = ShaguBoat_data or 0
    this.timer:Show()
  elseif event == "SPELLCAST_START" and arg1 == this.spell then
    this.casting = true
  elseif event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAIL" then
    this.casting = false
  elseif event == "SPELLCAST_STOP" and this.casting then
    this.delay = GetTime()
    this:Show()
  end
end)

boat:SetScript("OnUpdate", function()
  -- wait up to 0.5 seconds for the spell to fail before
  -- treating it like a successful cast
  if not this.delay or GetTime() < this.delay + 0.5 then return end

  -- delay spell success
  if this.casting then
    this.timer.despawn = GetTime() + this.duration
    ShaguBoat_data = this.timer.despawn
    
    this.casting = false
    this.timer:Show()
  end

  -- reset delay
  this.delay = false
  this:Hide()
end)                                                                                                                                                                                                                         

-- create timer ui
boat.timer = CreateFrame("StatusBar", "ShaguBoatTimer", UIParent)
boat.timer:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
boat.timer:SetStatusBarColor(1, .8, .2, 1)
boat.timer:SetMinMaxValues(0, boat.duration)
boat.timer:SetValue(20)

boat.timer:SetBackdrop(backdrop_background)
boat.timer:SetBackdropColor(0, 0, 0, 1)
boat.timer:SetWidth(200)
boat.timer:SetHeight(10)
boat.timer:SetPoint("CENTER", 0, 0)

boat.timer:EnableMouse(true)
boat.timer:RegisterForDrag("LeftButton")
boat.timer:SetMovable(true)
boat.timer:SetUserPlaced(true)
boat.timer:SetScript("OnDragStart", function() this:StartMoving() end)
boat.timer:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

boat.timer.border = CreateFrame("Frame", nil, boat.timer)
boat.timer.border:SetBackdrop(backdrop_border)
boat.timer.border:SetPoint("TOPLEFT", boat.timer, "TOPLEFT", -2,2)
boat.timer.border:SetPoint("BOTTOMRIGHT", boat.timer, "BOTTOMRIGHT", 2,-2)

boat.timer.text = boat.timer:CreateFontString(nil, "OVERLAY", "GameFontWhite")
boat.timer.text:SetPoint("CENTER", 0, 0)
boat.timer.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")

boat.timer:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
  GameTooltip:AddLine("ShaguBoat - Fishing Boat Timer")
  GameTooltip:AddDoubleLine("|cffffffff<Drag>", "|cffffffffMove the Timer")
  GameTooltip:AddDoubleLine("|cffffffff<Ctrl-Click>", "|cffffffffRemove the Timer")
  GameTooltip:Show()
end)

boat.timer:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

boat.timer:SetScript("OnMouseUp", function()
  if IsControlKeyDown() then
    this.despawn = 0
    ShaguBoat_data = 0
  end
end)

boat.timer:SetScript("OnUpdate", function()
  local timeleft = (this.despawn or 0) - GetTime()

  if timeleft > 0 then
    this.text:SetText(SecondsToTime(timeleft))
    this:SetValue(this.despawn - GetTime())
  else
    this.despawn = 0
    this:Hide()
  end
end)
