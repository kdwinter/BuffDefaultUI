-----------------------------------------------------------------------------
-- Constants/Variables                                                     --
-----------------------------------------------------------------------------

local ADDON_NAME = ...

-- Frame positions
local FRAME_POSITIONS = {
    TOP = {
        PLAYER = {X = -400, Y = 400},
        TARGET = {X = -130, Y = 400},
        PARTY  = {X = -700, Y = 400}
    },
    MID = {
        PLAYER = {X = -200, Y = -220},
        TARGET = {X =  200, Y = -220},
        PARTY  = {X = -400, Y =  500}
    }
}

-- SavedVariables defaults
local GLOBAL_DEFAULTS = {
    AutoRepair        = true,
    UseGuildRepair    = false,
    VendorGreys       = true,
    ClassColorHealth  = true,
    ClassIconPortrait = true,
    HideGryphons      = false,
    AddMiddleBars     = true,
}

local CHARACTER_DEFAULTS = {
    FramePosition = "TOP"
}

local CHAT_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_CONVERSATION",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER"
}

local CLASS_NAMES = {
    "DRUID",
    "HUNTER",
    "MAGE",
    "PALADIN",
    "PRIEST",
    "ROGUE",
    "SHAMAN",
    "WARLOCK",
    "WARRIOR"
}

-----------------------------------------------------------------------------
-- Functions                                                               --
-----------------------------------------------------------------------------

local function FixCastingBarVisual()
    CastingBarFrame:SetSize(180, 20)

    CastingBarFrame.Text:ClearAllPoints()
    CastingBarFrame.Text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)

    CastingBarFrame.Icon:Show()
    CastingBarFrame.Icon:SetHeight(22)
    CastingBarFrame.Icon:SetWidth(22)

    CastingBarFrame.Border:SetSize(240, 75)
    CastingBarFrame.Border:Hide()
    CastingBarFrame.BorderShield:Hide()

    CastingBarFrame.Flash:SetSize(240, 75)

    CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
    CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, 0)
    CastingBarFrame.update = .1

    CastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
        if not self.timer then return end
        if self.update and self.update < elapsed then
            if self.casting then
                self.timer:SetText(format("%2.1f/%1.1f", max(self.maxValue - self.value, 0), self.maxValue))
            elseif self.channeling then
                self.timer:SetText(format("%.1f", max(self.value, 0)))
            else
                self.timer:SetText("")
            end
            self.update = .1
        else
            self.update = self.update - elapsed
        end
    end)
end

local function MoveAndScaleFrames()
    local positions = FRAME_POSITIONS[BDUI_CharacterSettings.FramePosition]

    PlayerFrame:SetUserPlaced(true)
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("CENTER", UIParent, "CENTER", positions.PLAYER.X, positions.PLAYER.Y)

    TargetFrame:SetUserPlaced(true)
    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("CENTER", UIParent, "CENTER", positions.TARGET.X, positions.TARGET.Y)

    PartyMemberFrame1:SetUserPlaced(true)
    PartyMemberFrame1:ClearAllPoints()
    PartyMemberFrame1:SetPoint("CENTER", UIParent, "CENTER", positions.PARTY.X, positions.PARTY.Y)

    for _, UnitFrame in pairs ({
        PlayerFrame,
        TargetFrame,
        PartyMemberFrame1,
        PartyMemberFrame2,
        PartyMemberFrame3,
        PartyMemberFrame4
    }) do
        UnitFrame:SetScale(1.15)
    end

    BuffFrame:SetScale(1.15)
    MinimapCluster:SetScale(1.1)
    CastingBarFrame:SetScale(1.1)
    ComboFrame:SetScale(1.2)
    CompactRaidFrameContainer:SetScale(1.1)

    if BDUI_GlobalSettings.HideGryphons then
        MainMenuBarLeftEndCap:Hide()
        MainMenuBarRightEndCap:Hide()
    else
        MainMenuBarLeftEndCap:Show()
        MainMenuBarRightEndCap:Show()
    end
end

local function HideHitIndicators()
    PlayerHitIndicator:SetText(nil)
    PlayerHitIndicator.SetText = function() end

    PetHitIndicator:SetText(nil)
    PetHitIndicator.SetText = function() end
end

local function RegisterHealthbarColors()
    local function ClassColorHealthbars(statusbar, unit)
        if BDUI_GlobalSettings.ClassColorHealth then
            local _, class, c
            if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
                _, class = UnitClass(unit)
                c = RAID_CLASS_COLORS[class]
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
                --PlayerFrameHealthBar:SetStatusBarColor(0, 1, 0)
            end
        end
    end

    hooksecurefunc("UnitFrameHealthBar_Update", ClassColorHealthbars)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
        ClassColorHealthbars(self, self.unit)
    end)
end

local function SetBarTextures()
    local texture = [[Interface\AddOns\BuffDefaultUI\bar_textures\Cupence]]

    PlayerFrameHealthBar:SetStatusBarTexture(texture)
    PlayerFrameManaBar:SetStatusBarTexture(texture)
    TargetFrameHealthBar:SetStatusBarTexture(texture)
    TargetFrameManaBar:SetStatusBarTexture(texture)
    TargetFrameToT.healthbar:SetStatusBarTexture(texture)
    PetFrameHealthBar:SetStatusBarTexture(texture)
    PartyMemberFrame1HealthBar:SetStatusBarTexture(texture)
    PartyMemberFrame1ManaBar:SetStatusBarTexture(texture)
    PartyMemberFrame2HealthBar:SetStatusBarTexture(texture)
    PartyMemberFrame2ManaBar:SetStatusBarTexture(texture)
    PartyMemberFrame3HealthBar:SetStatusBarTexture(texture)
    PartyMemberFrame3ManaBar:SetStatusBarTexture(texture)
    PartyMemberFrame4HealthBar:SetStatusBarTexture(texture)
    PartyMemberFrame4ManaBar:SetStatusBarTexture(texture)
    MainMenuExpBar:SetStatusBarTexture(texture)
    CastingBarFrame:SetStatusBarTexture(texture)
    MirrorTimer1StatusBar:SetStatusBarTexture(texture)
    MirrorTimer2StatusBar:SetStatusBarTexture(texture)
    MirrorTimer3StatusBar:SetStatusBarTexture(texture)
end

local function RegisterAutoRepairEvents()
    local function RepairItemsAndSellTrash(self, event)
        if (event == "MERCHANT_SHOW") then
            if BDUI_GlobalSettings.VendorGreys then
                local bag, slot
                for bag = 0, 4 do
                    for slot = 0, GetContainerNumSlots(bag) do
                        local link = GetContainerItemLink(bag, slot)
                        if link and (select(3, GetItemInfo(link)) == 0) then
                            UseContainerItem(bag, slot)
                        end
                    end
                end
            end

            if BDUI_GlobalSettings.AutoRepair and CanMerchantRepair() then
                local repairAllCost, canRepair = GetRepairAllCost()
                if canRepair then
                    if repairAllCost <= GetMoney() then
                        local repairFromGuild = IsInGuild() and CanGuildBankRepair() and BDUI_GlobalSettings.UseGuildRepair
                        RepairAllItems(repairFromGuild)
                        DEFAULT_CHAT_FRAME:AddMessage("Your items have been repaired ("..GetCoinText(repairAllCost, ", ")..").", 255, 255, 0)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("Tried to auto-repair, but you don't have enough gold.", 255, 0, 0)
                    end
                end
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("MERCHANT_SHOW")
    f:RegisterEvent("VARIABLES_LOADED")
    f:SetScript("OnEvent", RepairItemsAndSellTrash)
end

local function RegisterPlayerFrameClassIcon()
    hooksecurefunc("UnitFramePortrait_Update", function(self)
        if BDUI_GlobalSettings.ClassIconPortrait then
            if self.unit == "player" or self.unit == "pet" then
                return
            end

            if self.portrait then
                if UnitIsPlayer(self.unit) then
                    local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
                    if t then
                        self.portrait:SetTexture([[Interface\AddOns\BuffDefaultUI\class_icons\UI-Classes-Circles]])
                        --self.portrait:SetTexture([[Interface\TargetingFrame\UI-Classes-Circles]])
                        self.portrait:SetTexCoord(unpack(t))
                    else
                        self.portrait:SetTexCoord(0, 1, 0, 1)
                    end
                else
                    self.portrait:SetTexCoord(0, 1, 0, 1)
                end
            end
        end
    end)
end

local function LoadSettings()
    -- Make sure the variables exist
    if BDUI_GlobalSettings == nil then
        BDUI_GlobalSettings = {}
    end
    if BDUI_CharacterSettings == nil then
        BDUI_CharacterSettings = {}
    end

    local function CopyDefaults(src, dst)
        if type(src) ~= "table" then
            return {}
        end
        if type(dst) ~= "table" then
            dst = {}
        end

        for k, v in pairs(src) do
            if type(v) == "table" then
                dst[k] = CopyDefaults(v, dst[k])
            elseif type(v) ~= type(dst[k]) then
                dst[k] = v
            end
        end

        return dst
    end

    CopyDefaults(GLOBAL_DEFAULTS,    BDUI_GlobalSettings)
    CopyDefaults(CHARACTER_DEFAULTS, BDUI_CharacterSettings)
end

local function RegisterChatImprovements()
    -- Add more chat font sizes
    for i = 1, 23 do
        CHAT_FONT_HEIGHTS[i] = i + 7
    end

    -- URL Replace stuff
    local function FormatUrl(url)
        return "|Hurl:"..tostring(url).."|h|cff0099FF"..tostring("["..url.."]").."|r|h"
    end

    local function UrlFilter(self, event, msg, ...)
        local foundUrl = false

        local msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", function(before, url, after)
            foundUrl = true
            return before..FormatUrl(url)..after
        end)
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end

        if msg2 ~= msg then
            return false, msg2, ...
        end
    end

    for _, event in pairs(CHAT_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, UrlFilter)
    end

    StaticPopupDialogs["BDUI_UrlCopy"] = {
        text = "Press Ctrl-C to copy the URI",
        button1 = "Done",
        button2 = "Cancel",
        hasEditBox = true,
        whileDead = true,
        hideOnEscape = true,
        timeout = 10,
        enterClicksFirstButton = true
    }

    local OriginalChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
    function ChatFrame_OnHyperlinkShow(frame, link, text, button)
        local type, value = link:match("(%a+):(.+)")
        if (type == "url") then
            --local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[frame:GetName().."EditBox"]
            --if eb then
            --    eb:SetText(value)
            --    eb:SetFocus()
            --    eb:HighlightText()
            --end
            local popup = StaticPopup_Show("BDUI_UrlCopy")
            popup.editBox:SetText(value)
            popup.editBox:SetFocus()
            popup.editBox:HighlightText()
        else
            OriginalChatFrame_OnHyperlinkShow(self, link, text, button)
        end
    end

    -- Make arrow keys work without alt in editboxes
    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            local editBox = _G["ChatFrame"..i.."EditBox"]
            editBox:SetAltArrowKeyMode(false)
        end
    end

    -- TODO: chat history support
end

local function RegisterCombatNotifications()
    UIErrorsFrame:Show()

    local function NotifyCombatChange(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            UIErrorsFrame:AddMessage("Entered combat", 0, 100, 255, 3)
        elseif event == "PLAYER_REGEN_ENABLED" then
            UIErrorsFrame:AddMessage("Left combat", 0, 100, 255, 3)
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", NotifyCombatChange)
end

local MiddleHealthBar = CreateFrame("StatusBar", nil, UIParent)
local MiddlePowerBar  = CreateFrame("StatusBar", nil, UIParent)

local function RegisterMiddleBars()
    for i, bar in pairs({MiddleHealthBar, MiddlePowerBar}) do
        bar:SetMovable(false)
        bar:EnableMouse(false)
        bar:SetBackdrop({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]]})
        bar:SetStatusBarTexture([[Interface\AddOns\BuffDefaultUI\bar_textures\Cupence]])
        bar:SetOrientation("HORIZONTAL")
        bar:SetBackdropColor(0, 0, 0, 0.7)

        local fill = bar:GetStatusBarTexture()
        if i == 1 then
            bar:SetPoint("CENTER", 0, -190)
            bar:SetSize(160, 10)
            fill:SetVertexColor(0, 255/255, 0)
        else
            bar:SetPoint("CENTER", 0, -199)
            bar:SetSize(160, 8)
            fill:SetVertexColor(0, 100/255, 240/255)
        end
    end

    MiddleHealthBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_MAXHEALTH" then
            self:SetMinMaxValues(0, UnitHealthMax("player"))
        elseif event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
            self:SetValue(UnitHealth("player"))
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:SetMinMaxValues(0, UnitHealthMax("player"))
            self:SetValue(UnitHealth("player"))
        end
    end)
    MiddleHealthBar:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    MiddleHealthBar:RegisterUnitEvent("UNIT_HEALTH", "player")
    MiddleHealthBar:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    MiddleHealthBar:RegisterUnitEvent("PLAYER_ENTERING_WORLD")

    --[[local function UpdateHealthBar()
        local healthPercentage = UnitHealth("player") / UnitHealthMax("player")
        local totalWidth = MiddleHealthBar:GetWidth()
        MiddleHealthBar:GetStatusBarTexture():SetWidth(healthPercentage * totalWidth)
    end
    MiddleHealthBar:SetScript("OnValueChanged",  UpdateHealthBar)
    MiddleHealthBar:SetScript("OnMinMaxChanged", UpdateHealthBar)]]

    MiddlePowerBar:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_MAXPOWER" then
            self:SetMinMaxValues(0, UnitPowerMax("player"))
        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" then
            self:SetValue(UnitPower("player"))
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:SetMinMaxValues(0, UnitPowerMax("player"))
            self:SetValue(UnitPower("player"))
        end
    end)
    MiddlePowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    MiddlePowerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    MiddlePowerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    MiddlePowerBar:RegisterUnitEvent("PLAYER_ENTERING_WORLD")

    --[[local function UpdatePowerBar()
        local powerPercentage = UnitPower("player") / UnitPowerMax("player")
        local totalWidth = MiddlePowerBar:GetWidth()
        MiddlePowerBar:GetStatusBarTexture():SetWidth(powerPercentage * totalWidth)
    end
    MiddlePowerBar:SetScript("OnValueChanged",  UpdatePowerBar)
    MiddlePowerBar:SetScript("OnMinMaxChanged", UpdatePowerBar)]]
end

local function ToggleMiddleBars()
    if BDUI_GlobalSettings.AddMiddleBars then
        MiddleHealthBar:Show()
        MiddlePowerBar:Show()
    else
        MiddleHealthBar:Hide()
        MiddlePowerBar:Hide()
    end
end

local function DarkenArt()
    for i, v in pairs({
        PlayerFrameTexture, TargetFrameTextureFrameTexture, PetFrameTexture,
        PartyMemberFrame1Texture, PartyMemberFrame2Texture, PartyMemberFrame3Texture,
        PartyMemberFrame4Texture, PartyMemberFrame1PetFrameTexture,
        PartyMemberFrame2PetFrameTexture, PartyMemberFrame3PetFrameTexture,
        PartyMemberFrame4PetFrameTexture, TargetFrameToTTextureFrameTexture,
        BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2,
        BonusActionBarFrameTexture3, BonusActionBarFrameTexture4, MainMenuBarTexture0,
        MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuMaxLevelBar0,
        MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3, MinimapBorder,
        CastingBarFrameBorder, TargetFrameSpellBarBorder,
        MiniMapTrackingButtonBorder, MiniMapLFGFrameBorder, MiniMapBattlefieldBorder,
        MiniMapMailBorder, MinimapBorderTop, select(1, TimeManagerClockButton:GetRegions())
    }) do
        v:SetVertexColor(.4, .4, .4)
    end

    for i, v in pairs({select(2, TimeManagerClockButton:GetRegions())}) do
        v:SetVertexColor(1, 1, 1)
    end
    for i, v in pairs({MainMenuBarLeftEndCap, MainMenuBarRightEndCap}) do
        v:SetVertexColor(.35, .35, .35)
    end
end

-----------------------------------------------------------------------------
-- Options panel                                                           --
-----------------------------------------------------------------------------

local optionsPanelCreated = false
local OptionsPanel = CreateFrame("Frame", "BuffDefaultUIPanel", UIParent)

function CreateOptionsPanel()
    if optionsPanelCreated then
        return nil
    end
    optionsPanelCreated = true

    OptionsPanel.name = ADDON_NAME
    OptionsPanel.okay = function(self)
        -- Do something
    end
    OptionsPanel.cancel = function(self)
        -- Do nothing
    end

    local OptionsPanelTitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    local OptionsPanelSubTitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    local OptionsPanelQOLTitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    local AutoRepairCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelAutoRepair", OptionsPanel, "OptionsCheckButtonTemplate")
    local UseGuildRepairCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelUseGuildRepair", OptionsPanel, "OptionsCheckButtonTemplate")
    local VendorGreysCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelVendorGreys", OptionsPanel, "OptionsCheckButtonTemplate")
    local OptionsPanelUFTitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    local ClassColorHealthCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelClassColorHealth", OptionsPanel, "OptionsCheckButtonTemplate")
    local ClassIconPortraitCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelClassIconPortrait", OptionsPanel, "OptionsCheckButtonTemplate")
    local AddMiddleBarsCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelAddMiddleBars", OptionsPanel, "OptionsCheckButtonTemplate")
    local HideGryphonsCheckbox = CreateFrame("CheckButton", ADDON_NAME.."OptionsPanelHideGryphons", OptionsPanel, "OptionsCheckButtonTemplate")
    local FramePositionDropdownLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLeft")
    local FramePositionDropdown = CreateFrame("Frame", ADDON_NAME.."OptionsPanelFramePosition", OptionsPanel, "UIDropDownMenuTemplate")

    OptionsPanelTitle:SetText(ADDON_NAME)
    OptionsPanelTitle:SetPoint("TOPLEFT", 16, -16)

    OptionsPanelSubTitle:SetText("Various improvements to the default User Interface")
    OptionsPanelSubTitle:SetPoint("TOPLEFT", OptionsPanelTitle, "BOTTOMLEFT", 0, -8)

    OptionsPanelQOLTitle:SetText("|cffffffffQuality of Life")
    OptionsPanelQOLTitle:SetPoint("TOPLEFT", OptionsPanelSubTitle, "BOTTOMLEFT", 0, -24)

    _G[ADDON_NAME.."OptionsPanelAutoRepairText"]:SetText("Automatically repair on merchant visit")
    AutoRepairCheckbox:SetChecked(BDUI_GlobalSettings.AutoRepair)
    AutoRepairCheckbox:SetPoint("TOPLEFT", OptionsPanelQOLTitle, "BOTTOMLEFT", 0, -16)
    AutoRepairCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.AutoRepair = self:GetChecked()
        if self:GetChecked() then
            UseGuildRepairCheckbox:Enable()
        else
            UseGuildRepairCheckbox:Disable()
        end
    end)

    _G[ADDON_NAME.."OptionsPanelUseGuildRepairText"]:SetText("Prioritize guild funds to auto repair with")
    UseGuildRepairCheckbox:SetChecked(BDUI_GlobalSettings.UseGuildRepair)
    UseGuildRepairCheckbox:SetPoint("TOPLEFT", AutoRepairCheckbox, "BOTTOMLEFT", 21, 1)
    UseGuildRepairCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.UseGuildRepair = self:GetChecked()
    end)

    _G[ADDON_NAME.."OptionsPanelVendorGreysText"]:SetText("Automatically vendor grey items")
    VendorGreysCheckbox:SetChecked(BDUI_GlobalSettings.VendorGreys)
    VendorGreysCheckbox:SetPoint("TOPLEFT", AutoRepairCheckbox, "BOTTOMLEFT", 0, -24)
    VendorGreysCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.VendorGreys = self:GetChecked()
    end)

    OptionsPanelUFTitle:SetText("|cffffffffFrames")
    OptionsPanelUFTitle:SetPoint("TOPLEFT", VendorGreysCheckbox, "BOTTOMLEFT", 0, -24)

    _G[ADDON_NAME.."OptionsPanelClassColorHealthText"]:SetText("Use class colors in healthbars")
    ClassColorHealthCheckbox:SetChecked(BDUI_GlobalSettings.ClassColorHealth)
    ClassColorHealthCheckbox:SetPoint("TOPLEFT", OptionsPanelUFTitle, "BOTTOMLEFT", 0, -16)
    ClassColorHealthCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.ClassColorHealth = self:GetChecked()
    end)

    _G[ADDON_NAME.."OptionsPanelClassIconPortraitText"]:SetText("Use class icons in portraits")
    ClassIconPortraitCheckbox:SetChecked(BDUI_GlobalSettings.ClassIconPortrait)
    ClassIconPortraitCheckbox:SetPoint("TOPLEFT", ClassColorHealthCheckbox, "BOTTOMLEFT", 0, 0)
    ClassIconPortraitCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.ClassIconPortrait = self:GetChecked()
    end)

    _G[ADDON_NAME.."OptionsPanelAddMiddleBarsText"]:SetText("Add health/power bars in middle of screen")
    AddMiddleBarsCheckbox:SetChecked(BDUI_GlobalSettings.AddMiddleBars)
    AddMiddleBarsCheckbox:SetPoint("TOPLEFT", ClassIconPortraitCheckbox, "BOTTOMLEFT", 0, 0)
    AddMiddleBarsCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.AddMiddleBars = self:GetChecked()
        ToggleMiddleBars()
    end)

    _G[ADDON_NAME.."OptionsPanelHideGryphonsText"]:SetText("Hide action bar gryphons")
    HideGryphonsCheckbox:SetChecked(BDUI_GlobalSettings.HideGryphons)
    HideGryphonsCheckbox:SetPoint("TOPLEFT", AddMiddleBarsCheckbox, "BOTTOMLEFT", 0, 0)
    HideGryphonsCheckbox:SetScript("OnClick", function(self)
        BDUI_GlobalSettings.HideGryphons = self:GetChecked()
        MoveAndScaleFrames()
    end)

    FramePositionDropdownLabel:SetText("Positions")
    FramePositionDropdownLabel:SetPoint("TOPLEFT", HideGryphonsCheckbox, "BOTTOMLEFT", 0, -6)

    FramePositionDropdown:SetPoint("TOPLEFT", FramePositionDropdownLabel, "BOTTOMLEFT", 0, -4)
    UIDropDownMenu_Initialize(FramePositionDropdown, function()
        local function CreateMenuItem(text, value)
            local MenuItem = UIDropDownMenu_CreateInfo()
            MenuItem.owner = FramePositionDropdown
            MenuItem.func = function(self)
                if not InCombatLockdown() then
                    BDUI_CharacterSettings.FramePosition = value
                    UIDropDownMenu_SetSelectedValue(FramePositionDropdown, value)
                    MoveAndScaleFrames()
                end
            end
            MenuItem.text = text
            MenuItem.value = value
            MenuItem.checked = nil
            UIDropDownMenu_AddButton(MenuItem)
        end

        CreateMenuItem("Top", "TOP")
        CreateMenuItem("Middle", "MID")
    end)
    UIDropDownMenu_SetSelectedValue(FramePositionDropdown, BDUI_CharacterSettings.FramePosition)

    InterfaceOptions_AddCategory(OptionsPanel)
end

-----------------------------------------------------------------------------
-- Load the addon                                                          --
-----------------------------------------------------------------------------

local function Init(self, event)
    if event == "ADDON_LOADED" then
        LoadSettings()
        CreateOptionsPanel()
    elseif event == "PLAYER_LOGIN" then
        FixCastingBarVisual()
        MoveAndScaleFrames()
        HideHitIndicators()
        SetBarTextures()
        RegisterPlayerFrameClassIcon()
        RegisterHealthbarColors()
        RegisterAutoRepairEvents()
        RegisterChatImprovements()
        RegisterCombatNotifications()
        RegisterMiddleBars()
        DarkenArt()

        DEFAULT_CHAT_FRAME:AddMessage("BuffDefaultUI loaded")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", Init)

----------------------------------------------------------------------------
-- Chat commands                                                          --
----------------------------------------------------------------------------

--function SlashCmdList.BDUI_HELP(message, editbox)
SlashCmdList["BDUI_HELP"] = function(message, editbox)
    if message == "reset" then
        BDUI_GlobalSettings        = GLOBAL_DEFAULTS
        BDUI_CharacterSettings = CHARACTER_DEFAULTS
        MoveAndScaleFrames()
        DEFAULT_CHAT_FRAME:AddMessage("BuffDefaultUI settings have been reset to their defaults", 255, 255, 0)
    elseif message == "status" then
        DEFAULT_CHAT_FRAME:AddMessage("BuffDefaultUI Settings:", 255, 255, 0)
        for k, v in pairs(BDUI_GlobalSettings) do
            DEFAULT_CHAT_FRAME:AddMessage(""..tostring(k)..": "..tostring(v))
        end
        for k, v in pairs(BDUI_CharacterSettings) do
            DEFAULT_CHAT_FRAME:AddMessage(""..tostring(k)..": "..tostring(v))
        end
    elseif message == nil or message == "" then
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(OptionsPanel)
    else -- default help message
        DEFAULT_CHAT_FRAME:AddMessage("BuffDefaultUI Usage:", 255, 255, 0)
        DEFAULT_CHAT_FRAME:AddMessage("/bdui", 240, 240, 240)
        DEFAULT_CHAT_FRAME:AddMessage("/bdui reset", 240, 240, 240)
    end
end
SLASH_BDUI_HELP1 = "/bdui"
SLASH_BDUI_HELP2 = "/buffdefaultui"
