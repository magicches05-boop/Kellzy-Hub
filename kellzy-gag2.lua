local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ==========================================
--  PEMBERSIH SCRIPT LAMA (ANTI LAG & JEDAG-JEDUG)
-- ==========================================
pcall(function()
    for _, child in pairs(CoreGui:GetChildren()) do
        if string.find(child.Name, "KellyzESPFolder") or string.find(child.Name, "KellyzUltimateHub") or string.find(child.Name, "KellyzNotifUI") or string.find(child.Name, "KellyzWeatherUI") or string.find(child.Name, "KellyzBackpackUI") then
            child:Destroy()
        end
    end
end)

-- ==========================================
--  SISTEM VERIFIKASI KELLYZ HUB
-- ==========================================
local API_URL = "https://kellzyy-hub.my.id/verify"

local function VerifyKellyzAuth(key)
    if not httpRequest then return false end
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local fetchUrl = API_URL .. "?key=" .. key .. "&hwid=" .. hwid
    local success, res = pcall(function() return httpRequest({ Url = fetchUrl, Method = "GET" }) end)
    if success and res and type(res) == "table" and res.StatusCode == 200 then
        local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if decodeSuccess and decoded and decoded.valid == true then return true end
    end
    return false
end

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if self == LocalPlayer and getnamecallmethod() == "Kick" then return end
        return oldNamecall(self, ...)
    end)
end)

local GameName = "Mendeteksi Map..."
pcall(function()
    local productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then GameName = productInfo.Name else GameName = "Map ID: " .. tostring(game.PlaceId) end
end)

-- ==========================================
--  KONFIGURASI ASET & TEMA
-- ==========================================
local KeyFileName = "KellyzHubKey_Save.txt"
local K_LogoAssetID = "rbxthumb://type=Asset&id=128843396504484&w=150&h=150" 
local AnimeGirlAssetID = "rbxthumb://type=Asset&id=112582597558400&w=420&h=420" 

getgenv().CurrentLang = "en" 
getgenv().ThemeColor = Color3.fromRGB(0, 200, 255) 

getgenv().ThemedElements = { Bgs = {}, Strokes = {}, Texts = {}, Toggles = {}, Checks = {}, ScrollBars = {}, SectionTitles = {} }
getgenv().ActiveTab = nil

local ConfigFileName = "KellyzHubConfig_Save.json"
local function SaveConfig()
    if writefile then
        local conf = { r = math.floor(getgenv().ThemeColor.R * 255), g = math.floor(getgenv().ThemeColor.G * 255), b = math.floor(getgenv().ThemeColor.B * 255), lang = getgenv().CurrentLang }
        pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(conf)) end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFileName) and readfile then
        pcall(function()
            local conf = HttpService:JSONDecode(readfile(ConfigFileName))
            if conf.r and conf.g and conf.b then getgenv().ThemeColor = Color3.fromRGB(conf.r, conf.g, conf.b) end
            if conf.lang then getgenv().CurrentLang = conf.lang end
        end)
    end
end
LoadConfig()

local function ApplyTheme(color)
    getgenv().ThemeColor = color
    SaveConfig()
    for _, bg in pairs(getgenv().ThemedElements.Bgs) do pcall(function() TweenService:Create(bg, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end) end
    for _, stroke in pairs(getgenv().ThemedElements.Strokes) do pcall(function() TweenService:Create(stroke, TweenInfo.new(0.3), {Color = color}):Play() end) end
    for _, txt in pairs(getgenv().ThemedElements.Texts) do pcall(function() TweenService:Create(txt, TweenInfo.new(0.3), {TextColor3 = color}):Play() end) end
    for _, tog in pairs(getgenv().ThemedElements.Toggles) do pcall(function() if tog.state then TweenService:Create(tog.obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end end) end
    for _, chk in pairs(getgenv().ThemedElements.Checks) do pcall(function() TweenService:Create(chk, TweenInfo.new(0.3), {TextColor3 = color}):Play() end) end
    for _, sc in pairs(getgenv().ThemedElements.ScrollBars) do pcall(function() TweenService:Create(sc, TweenInfo.new(0.3), {ScrollBarImageColor3 = color}):Play() end) end
    if getgenv().ActiveTab then pcall(function() TweenService:Create(getgenv().ActiveTab, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end) end
    for _, sec in pairs(getgenv().ThemedElements.SectionTitles) do pcall(function() if sec.state then TweenService:Create(sec.obj, TweenInfo.new(0.3), {TextColor3 = color}):Play() end end) end
end

-- ==========================================
--  SISTEM NOTIFIKASI
-- ==========================================
local NotifUI = Instance.new("ScreenGui")
NotifUI.Name = "KellyzNotifUI"
NotifUI.Parent = CoreGui

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 300, 1, -20)
NotifContainer.Position = UDim2.new(1, -20, 1, -20)
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifUI
local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 12)

local function SendNotification(title, desc, duration)
    local NWrapper = Instance.new("Frame"); NWrapper.Size = UDim2.new(1, 0, 0, 70); NWrapper.BackgroundTransparency = 1; NWrapper.Parent = NotifContainer
    local NFrame = Instance.new("Frame"); NFrame.Size = UDim2.new(1, 0, 1, 0); NFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16); NFrame.BackgroundTransparency = 0.2; NFrame.Position = UDim2.new(1, 50, 0, 0); NFrame.Parent = NWrapper
    Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 8)
    local NAccent = Instance.new("Frame"); NAccent.Size = UDim2.new(0, 3, 1, -20); NAccent.Position = UDim2.new(0, 8, 0, 10); NAccent.BackgroundColor3 = getgenv().ThemeColor; NAccent.BorderSizePixel = 0; NAccent.Parent = NFrame; Instance.new("UICorner", NAccent).CornerRadius = UDim.new(1, 0); table.insert(getgenv().ThemedElements.Bgs, NAccent)
    local NStroke = Instance.new("UIStroke", NFrame); NStroke.Thickness = 1; NStroke.Color = getgenv().ThemeColor; NStroke.Transparency = 0.5; table.insert(getgenv().ThemedElements.Strokes, NStroke)
    local NTitle = Instance.new("TextLabel"); NTitle.Size = UDim2.new(1, -30, 0, 28); NTitle.Position = UDim2.new(0, 20, 0, 6); NTitle.BackgroundTransparency = 1; NTitle.Text = title; NTitle.TextColor3 = getgenv().ThemeColor; NTitle.Font = Enum.Font.GothamBold; NTitle.TextSize = 13; NTitle.TextXAlignment = Enum.TextXAlignment.Left; NTitle.Parent = NFrame; table.insert(getgenv().ThemedElements.Texts, NTitle)
    local NDesc = Instance.new("TextLabel"); NDesc.Size = UDim2.new(1, -30, 0, 24); NDesc.Position = UDim2.new(0, 20, 0, 34); NDesc.BackgroundTransparency = 1; NDesc.Text = desc; NDesc.TextColor3 = Color3.fromRGB(220, 220, 220); NDesc.Font = Enum.Font.Gotham; NDesc.TextSize = 11; NDesc.TextXAlignment = Enum.TextXAlignment.Left; NDesc.TextWrapped = true; NDesc.Parent = NFrame
    local NProgressBG = Instance.new("Frame"); NProgressBG.Size = UDim2.new(1, -40, 0, 2); NProgressBG.Position = UDim2.new(0, 20, 1, -10); NProgressBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255); NProgressBG.BackgroundTransparency = 0.9; NProgressBG.BorderSizePixel = 0; NProgressBG.Parent = NFrame
    local NProgress = Instance.new("Frame"); NProgress.Size = UDim2.new(1, 0, 1, 0); NProgress.BackgroundColor3 = getgenv().ThemeColor; NProgress.BorderSizePixel = 0; NProgress.Parent = NProgressBG; table.insert(getgenv().ThemedElements.Bgs, NProgress)

    TweenService:Create(NFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.spawn(function()
        local waitTime = duration or 4
        TweenService:Create(NProgress, TweenInfo.new(waitTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        task.wait(waitTime)
        local fade = TweenService:Create(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0)})
        fade:Play()
        fade.Completed:Connect(function() 
            local shrink = TweenService:Create(NWrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
            shrink:Play()
            shrink.Completed:Connect(function() NWrapper:Destroy() end)
        end)
    end)
end

-- ==========================================
--  SISTEM UI WEATHER PREDICTOR BASE
-- ==========================================
local WeatherUI = Instance.new("ScreenGui")
WeatherUI.Name = "KellyzWeatherUI"
WeatherUI.Parent = CoreGui
WeatherUI.Enabled = false

local WeatherMain = Instance.new("Frame")
WeatherMain.Size = UDim2.new(0, 420, 0, 70)
WeatherMain.Position = UDim2.new(0.5, -210, 1, -90)
WeatherMain.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
WeatherMain.BackgroundTransparency = 0.2
WeatherMain.BorderSizePixel = 0
WeatherMain.Active = true
WeatherMain.Draggable = true
WeatherMain.Parent = WeatherUI
Instance.new("UICorner", WeatherMain).CornerRadius = UDim.new(0, 10)
local WeatherStroke = Instance.new("UIStroke", WeatherMain)
WeatherStroke.Color = getgenv().ThemeColor
WeatherStroke.Thickness = 1.5
table.insert(getgenv().ThemedElements.Strokes, WeatherStroke)

local WeatherScroll = Instance.new("ScrollingFrame")
WeatherScroll.Size = UDim2.new(1, -10, 1, -10)
WeatherScroll.Position = UDim2.new(0, 5, 0, 5)
WeatherScroll.BackgroundTransparency = 1
WeatherScroll.ScrollBarThickness = 3
WeatherScroll.ScrollingDirection = Enum.ScrollingDirection.X
WeatherScroll.Parent = WeatherMain

local WeatherLayout = Instance.new("UIListLayout", WeatherScroll)
WeatherLayout.FillDirection = Enum.FillDirection.Horizontal
WeatherLayout.SortOrder = Enum.SortOrder.LayoutOrder
WeatherLayout.Padding = UDim.new(0, 8)
WeatherLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    WeatherScroll.CanvasSize = UDim2.new(0, WeatherLayout.AbsoluteContentSize.X, 0, 0)
end)

getgenv().WeatherCards = {}
local function CreateWeatherCard(nama, warna)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0, 110, 1, -10)
    Card.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Card.Parent = WeatherScroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local CStroke = Instance.new("UIStroke", Card)
    CStroke.Color = warna
    CStroke.Thickness = 1.2
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = nama
    Title.TextColor3 = warna
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.Parent = Card
    
    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Size = UDim2.new(1, 0, 0, 20)
    TimerLabel.Position = UDim2.new(0, 0, 0, 25)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Text = "Waiting..."
    TimerLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TimerLabel.Font = Enum.Font.GothamBold
    TimerLabel.TextSize = 12
    TimerLabel.Parent = Card
    
    getgenv().WeatherCards[nama] = {Label = TimerLabel, Stroke = CStroke, ConfigColor = warna}
end

CreateWeatherCard("Bloodmoon", Color3.fromRGB(255, 50, 50))
CreateWeatherCard("Night", Color3.fromRGB(100, 150, 255))
CreateWeatherCard("Rainbowmoon", Color3.fromRGB(255, 100, 255))
CreateWeatherCard("Goldmoon", Color3.fromRGB(255, 215, 0))
CreateWeatherCard("Sunset", Color3.fromRGB(255, 150, 50))

-- ==========================================
--  ULTIMATE UI ENGINE
-- ==========================================
local HubUI = nil
local MainFrame = nil
local UIRegistry = {}

local function RegisterUI(element, texts, elementType, state, setFunc)
    table.insert(UIRegistry, {obj = element, texts = texts, type = elementType, state = state, setFunc = setFunc})
end

local function UpdateLanguage()
    for _, item in pairs(UIRegistry) do
        pcall(function()
            local textStr = item.texts[getgenv().CurrentLang] or item.texts["en"] or ""
            if item.type == "Label" or item.type == "Button" then 
                item.obj.Text = textStr
            elseif item.type == "Tab" then 
                item.obj.Text = "   " .. textStr
            elseif item.type == "Toggle" then
                local tLbl = item.obj:FindFirstChild("TitleLbl")
                if tLbl then tLbl.Text = textStr else item.obj.Text = "   " .. textStr end
                local dLbl = item.obj:FindFirstChild("DescLbl")
                if dLbl then local descStr = item.texts[getgenv().CurrentLang .. "_desc"] or item.texts["en_desc"] or ""; dLbl.Text = descStr end
            elseif item.type == "Input" then 
                item.obj.PlaceholderText = textStr
            elseif item.type == "MultiDropdown" then
                local selText = (item.state and item.state.selected and #item.state.selected > 0) and table.concat(item.state.selected, ", ") or "None"
                local tLbl = item.obj:FindFirstChild("TitleLbl")
                local vLbl = item.obj:FindFirstChild("ValueLbl")
                if tLbl then tLbl.Text = textStr end
                if vLbl then vLbl.Text = selText end
            elseif item.type == "Dropdown" then
                local selVal = (item.state and item.state.selected) or "None"
                local tLbl = item.obj:FindFirstChild("TitleLbl")
                local vLbl = item.obj:FindFirstChild("ValueLbl")
                if tLbl then tLbl.Text = textStr end
                if vLbl then vLbl.Text = tostring(selVal) end
            end
        end)
    end
end

local function AddHover(element, normalColor, hoverColor)
    element.MouseEnter:Connect(function() TweenService:Create(element, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end)
    element.MouseLeave:Connect(function() if getgenv().ActiveTab ~= element then TweenService:Create(element, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play() end end)
end

local function CreateCustomUI()
    if CoreGui:FindFirstChild("KellyzUltimateHub") then CoreGui.KellyzUltimateHub:Destroy() end

    HubUI = Instance.new("ScreenGui")
    HubUI.Name = "KellyzUltimateHub"
    HubUI.Parent = CoreGui
    HubUI.ResetOnSpawn = false

    local FloatingLogo = Instance.new("ImageButton")
    FloatingLogo.Name = "FloatingIcon"
    FloatingLogo.Size = UDim2.new(0, 60, 0, 60) 
    FloatingLogo.Position = UDim2.new(0.05, 0, 0.1, 0)
    FloatingLogo.BackgroundTransparency = 1
    FloatingLogo.Image = K_LogoAssetID
    FloatingLogo.Active = true
    FloatingLogo.Draggable = true
    FloatingLogo.Visible = false
    FloatingLogo.ZIndex = 50
    FloatingLogo.Parent = HubUI

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 750, 0, 460)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BackgroundTransparency = 0.05 
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = HubUI

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 0.8
    MainStroke.Transparency = 0.85
    
    local MainShadow = Instance.new("ImageLabel")
    MainShadow.Name = "DropShadow"
    MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShadow.BackgroundTransparency = 1
    MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainShadow.Size = UDim2.new(1, 60, 1, 60)
    MainShadow.ZIndex = -1
    MainShadow.Image = "rbxassetid://6015043444"
    MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    MainShadow.ImageTransparency = 0.5
    MainShadow.ScaleType = Enum.ScaleType.Slice
    MainShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    MainShadow.Parent = MainFrame

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    Topbar.BackgroundTransparency = 0.4
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 5
    Topbar.Parent = MainFrame
    
    local TopbarLine = Instance.new("Frame", Topbar)
    TopbarLine.Size = UDim2.new(1, 0, 0, 1)
    TopbarLine.Position = UDim2.new(0, 0, 1, 0)
    TopbarLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopbarLine.BackgroundTransparency = 0.9
    TopbarLine.BorderSizePixel = 0
    
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 24, 0, 24)
    Logo.Position = UDim2.new(0, 12, 0, 8)
    Logo.BackgroundTransparency = 1
    Logo.Image = K_LogoAssetID
    Logo.ZIndex = 5
    Logo.Parent = Topbar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -150, 1, 0)
    Title.Position = UDim2.new(0, 45, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Kellyz Hub | " .. GameName
    Title.TextColor3 = getgenv().ThemeColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.ZIndex = 5
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    table.insert(getgenv().ThemedElements.Texts, Title)

    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 45, 0, 26)
    LangBtn.Position = UDim2.new(1, -175, 0, 7)
    LangBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    LangBtn.Text = (getgenv().CurrentLang == "id") and "ID" or "EN"
    LangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.TextSize = 11
    LangBtn.ZIndex = 6
    LangBtn.Parent = Topbar
    Instance.new("UICorner", LangBtn).CornerRadius = UDim.new(0, 6)
    local LangStroke = Instance.new("UIStroke", LangBtn)
    LangStroke.Color = getgenv().ThemeColor; LangStroke.Thickness = 0.8; LangStroke.Transparency = 0.5
    table.insert(getgenv().ThemedElements.Strokes, LangStroke)
    
    LangBtn.MouseButton1Click:Connect(function()
        getgenv().CurrentLang = (getgenv().CurrentLang == "id") and "en" or "id"
        LangBtn.Text = (getgenv().CurrentLang == "id") and "ID" or "EN"
        UpdateLanguage(); SaveConfig()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 40, 0, 40)
    MinBtn.Position = UDim2.new(1, -120, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.ZIndex = 5
    MinBtn.Parent = Topbar

    local MaxBtn = Instance.new("TextButton")
    MaxBtn.Size = UDim2.new(0, 40, 0, 40)
    MaxBtn.Position = UDim2.new(1, -80, 0, 0)
    MaxBtn.BackgroundTransparency = 1
    MaxBtn.Text = "O"
    MaxBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    MaxBtn.Font = Enum.Font.GothamBold
    MaxBtn.TextSize = 16
    MaxBtn.ZIndex = 5
    MaxBtn.Parent = Topbar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.ZIndex = 5
    CloseBtn.Parent = Topbar

    for _, btn in pairs({MinBtn, MaxBtn, CloseBtn}) do
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.9}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
    end
    CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50), BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(255,255,255)}):Play() end)
    CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,180,180)}):Play() end)

    local ConfirmOverlay = Instance.new("Frame")
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ConfirmOverlay.BackgroundTransparency = 0.5
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 99
    ConfirmOverlay.Active = true
    ConfirmOverlay.Parent = HubUI

    local ConfirmUI = Instance.new("Frame")
    ConfirmUI.Size = UDim2.new(0, 300, 0, 160)
    ConfirmUI.Position = UDim2.new(0.5, 0, 0.5, 0)
    ConfirmUI.AnchorPoint = Vector2.new(0.5, 0.5)
    ConfirmUI.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    ConfirmUI.ZIndex = 100
    ConfirmUI.Parent = ConfirmOverlay
    Instance.new("UICorner", ConfirmUI).CornerRadius = UDim.new(0, 8)
    
    local ConfirmStroke = Instance.new("UIStroke", ConfirmUI)
    ConfirmStroke.Color = Color3.fromRGB(100, 150, 200) 
    ConfirmStroke.Thickness = 1.5
    table.insert(getgenv().ThemedElements.Strokes, ConfirmStroke)

    local ConfirmTitle = Instance.new("TextLabel")
    ConfirmTitle.Size = UDim2.new(1, 0, 0, 30)
    ConfirmTitle.Position = UDim2.new(0, 0, 0, 15)
    ConfirmTitle.BackgroundTransparency = 1
    ConfirmTitle.Text = "Kellyz Window"
    ConfirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmTitle.Font = Enum.Font.GothamBold
    ConfirmTitle.TextSize = 18
    ConfirmTitle.ZIndex = 101
    ConfirmTitle.Parent = ConfirmUI

    local ConfirmDesc = Instance.new("TextLabel")
    ConfirmDesc.Size = UDim2.new(1, 0, 0, 40)
    ConfirmDesc.Position = UDim2.new(0, 0, 0, 45)
    ConfirmDesc.BackgroundTransparency = 1
    ConfirmDesc.Text = "Do you want to close this window?\nYou will not be able to open it again"
    ConfirmDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
    ConfirmDesc.Font = Enum.Font.Gotham
    ConfirmDesc.TextSize = 13
    ConfirmDesc.ZIndex = 101
    ConfirmDesc.Parent = ConfirmUI

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0, 120, 0, 35)
    YesBtn.Position = UDim2.new(0, 20, 0, 100)
    YesBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    YesBtn.Text = "Yes"
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.ZIndex = 101
    YesBtn.Parent = ConfirmUI
    Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0, 120, 0, 35)
    NoBtn.Position = UDim2.new(1, -140, 0, 100)
    NoBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    NoBtn.Text = "Cancel"
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.ZIndex = 101
    NoBtn.Parent = ConfirmUI
    Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
    ResizeHandle.Font = Enum.Font.GothamBold
    ResizeHandle.TextSize = 16
    ResizeHandle.ZIndex = 50
    ResizeHandle.Parent = MainFrame

    local draggingResize = false
    local dragStartResize = nil
    local startSize = nil

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingResize = true
            dragStartResize = input.Position
            startSize = MainFrame.Size
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingResize = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartResize
            local newX = math.clamp(startSize.X.Offset + delta.X, 400, 1200)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 300, 800)
            MainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    local isMaximized = false
    local savedMaximizeSize = UDim2.new(0, 750, 0, 460)

    local function MaximizeUI()
        FloatingLogo.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = isMaximized and UDim2.new(0, 950, 0, 600) or savedMaximizeSize}):Play()
    end

    local function MinimizeUI()
        local shrink = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        shrink:Play()
        shrink.Completed:Connect(function() 
            if MainFrame.Size.X.Offset == 0 then 
                MainFrame.Visible = false 
                FloatingLogo.Visible = true 
            end 
        end)
    end

    MinBtn.MouseButton1Click:Connect(MinimizeUI)
    FloatingLogo.MouseButton1Click:Connect(MaximizeUI)
    
    MaxBtn.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        if isMaximized then
            savedMaximizeSize = MainFrame.Size
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 950, 0, 600)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = savedMaximizeSize}):Play()
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function() ConfirmOverlay.Visible = true end)
    NoBtn.MouseButton1Click:Connect(function() ConfirmOverlay.Visible = false end)
    YesBtn.MouseButton1Click:Connect(function() HubUI:Destroy(); WeatherUI:Destroy() end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 160, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    TabContainer.BackgroundTransparency = 0.3
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    local ProfileBox = Instance.new("Frame"); ProfileBox.Size = UDim2.new(0, 144, 0, 42); ProfileBox.Position = UDim2.new(0, 8, 1, -50); ProfileBox.BackgroundColor3 = Color3.fromRGB(24, 22, 32); ProfileBox.BackgroundTransparency = 0.2; ProfileBox.BorderSizePixel = 0; ProfileBox.ZIndex = 10; ProfileBox.Parent = MainFrame
    Instance.new("UICorner", ProfileBox).CornerRadius = UDim.new(0, 6)
    local ProfileStroke = Instance.new("UIStroke", ProfileBox); ProfileStroke.Color = getgenv().ThemeColor; ProfileStroke.Thickness = 0.6; ProfileStroke.Transparency = 0.5; table.insert(getgenv().ThemedElements.Strokes, ProfileStroke)
    
    local AvatarImg = Instance.new("ImageLabel"); AvatarImg.Size = UDim2.new(0, 26, 0, 26); AvatarImg.Position = UDim2.new(0, 8, 0.5, -13); AvatarImg.BackgroundColor3 = Color3.fromRGB(30, 30, 35); AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"; AvatarImg.ZIndex = 11; AvatarImg.Parent = ProfileBox
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
    
    local pName = LocalPlayer.Name
    local censoredName = (#pName > 2) and (string.sub(pName, 1, 1) .. string.rep("*", #pName - 2) .. string.sub(pName, #pName, #pName)) or pName
    
    local NameLbl = Instance.new("TextLabel"); NameLbl.Size = UDim2.new(1, -44, 1, 0); NameLbl.Position = UDim2.new(0, 42, 0, 0); NameLbl.BackgroundTransparency = 1; NameLbl.Text = censoredName; NameLbl.TextColor3 = Color3.fromRGB(220, 220, 220); NameLbl.Font = Enum.Font.GothamSemibold; NameLbl.TextSize = 12; NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.ZIndex = 11; NameLbl.Parent = ProfileBox

    local TabUIList = Instance.new("UIListLayout", TabContainer)
    TabUIList.SortOrder = Enum.SortOrder.LayoutOrder
    TabUIList.Padding = UDim.new(0, 4)

    local TabSearchFrame = Instance.new("Frame"); TabSearchFrame.Name = "TabSearchBoxContainer"; TabSearchFrame.Size = UDim2.new(1, -16, 0, 30); TabSearchFrame.Position = UDim2.new(0, 8, 0, 0); TabSearchFrame.BackgroundColor3 = Color3.fromRGB(24, 22, 32); TabSearchFrame.BackgroundTransparency = 0.2; TabSearchFrame.LayoutOrder = -100; TabSearchFrame.Parent = TabContainer; Instance.new("UICorner", TabSearchFrame).CornerRadius = UDim.new(0, 6)
    local TabSearchStroke = Instance.new("UIStroke", TabSearchFrame); TabSearchStroke.Color = getgenv().ThemeColor; TabSearchStroke.Thickness = 0.6; TabSearchStroke.Transparency = 0.8; table.insert(getgenv().ThemedElements.Strokes, TabSearchStroke)
    
    local SearchIcon = Instance.new("ImageLabel"); SearchIcon.Size = UDim2.new(0, 14, 0, 14); SearchIcon.Position = UDim2.new(0, 10, 0.5, -7); SearchIcon.BackgroundTransparency = 1; SearchIcon.Image = "rbxassetid://6031154871"; SearchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150); SearchIcon.Parent = TabSearchFrame
    
    local TabSearchBox = Instance.new("TextBox")
    TabSearchBox.Name = "TabSearchBox"
    TabSearchBox.Size = UDim2.new(1, -34, 1, 0)
    TabSearchBox.Position = UDim2.new(0, 30, 0, 0)
    TabSearchBox.BackgroundTransparency = 1
    TabSearchBox.Text = ""
    TabSearchBox.PlaceholderText = "Search..."
    TabSearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    TabSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabSearchBox.TextXAlignment = Enum.TextXAlignment.Left
    TabSearchBox.Font = Enum.Font.GothamSemibold
    TabSearchBox.TextSize = 12
    TabSearchBox.Parent = TabSearchFrame

    local PadFrame = Instance.new("Frame"); PadFrame.Size = UDim2.new(1, 0, 0, 4); PadFrame.BackgroundTransparency = 1; PadFrame.LayoutOrder = -99; PadFrame.Parent = TabContainer

    -- Filter all UI elements recursively when typing in the search box
    TabSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local term = TabSearchBox.Text:lower()
        if term == "" then
            -- Reset all visibility
            for _, child in ipairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then child.Visible = true end
            end
            local ContentContainer = MainFrame:FindFirstChild("ContentContainer", true) or TabContainer.Parent:FindFirstChild("Frame") -- Find ContentContainer
            if ContentContainer then
                for _, scroll in ipairs(ContentContainer:GetChildren()) do
                    if scroll:IsA("ScrollingFrame") then
                        for _, section in ipairs(scroll:GetChildren()) do
                            if section:IsA("Frame") and section.Name == "Section" then
                                section.Visible = true
                                for _, element in ipairs(section:FindFirstChild("SectionContent") and section.SectionContent:GetChildren() or {}) do
                                    if element:IsA("Frame") or element:IsA("TextButton") then element.Visible = true end
                                end
                            end
                        end
                    end
                end
            end
        else
            -- Search globally across all tabs and sections
            for _, child in ipairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then child.Visible = false end -- Hide tabs when searching specific features
            end
            local ContentContainer = MainFrame:FindFirstChild("ContentContainer", true) or TabContainer.Parent:FindFirstChild("Frame")
            if ContentContainer then
                for _, scroll in ipairs(ContentContainer:GetChildren()) do
                    if scroll:IsA("ScrollingFrame") then
                        scroll.Visible = true -- Force all tab contents to be visible temporarily
                        for _, section in ipairs(scroll:GetChildren()) do
                            if section:IsA("Frame") and section.Name == "Section" then
                                local sectionMatches = false
                                local title = section:FindFirstChild("SectionTitle")
                                if title and string.find(title.Text:lower(), term) then sectionMatches = true end
                                
                                local sectionContent = section:FindFirstChild("SectionContent")
                                if sectionContent then
                                    for _, element in ipairs(sectionContent:GetChildren()) do
                                        if element:IsA("Frame") or element:IsA("TextButton") then
                                            local elText = ""
                                            local lbl = element:FindFirstChild("TitleLbl") or element:FindFirstChild("Title") or (element:IsA("TextButton") and element)
                                            if lbl and lbl:IsA("TextLabel") then elText = lbl.Text:lower() elseif lbl and lbl:IsA("TextButton") then elText = lbl.Text:lower() end
                                            
                                            if string.find(elText, term) or sectionMatches then
                                                element.Visible = true
                                                sectionMatches = true
                                            else
                                                element.Visible = false
                                            end
                                        end
                                    end
                                end
                                section.Visible = sectionMatches
                            end
                        end
                    end
                end
            end
        end
    end)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -160, 1, -40)
    ContentContainer.Position = UDim2.new(0, 160, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    local AnimeBg = Instance.new("ImageLabel")
    AnimeBg.Size = UDim2.new(0, 500, 0, 380) 
    AnimeBg.Position = UDim2.new(1, 20, 1, 0) 
    AnimeBg.AnchorPoint = Vector2.new(1, 1) 
    AnimeBg.BackgroundTransparency = 1
    AnimeBg.Image = AnimeGirlAssetID
    AnimeBg.ImageTransparency = 0.10 
    AnimeBg.ScaleType = Enum.ScaleType.Fit
    AnimeBg.ZIndex = 0
    AnimeBg.Parent = ContentContainer

    local WatermarkK = Instance.new("ImageLabel")
    WatermarkK.Size = UDim2.new(0, 300, 0, 380)
    WatermarkK.Position = UDim2.new(1, -300, 1, -80) 
    WatermarkK.AnchorPoint = Vector2.new(1, 1)
    WatermarkK.Image = K_LogoAssetID
    WatermarkK.ImageTransparency = 0.10 
    WatermarkK.BackgroundTransparency = 1
    WatermarkK.ZIndex = 0
    WatermarkK.Parent = ContentContainer

    -- ==========================================
    --  KEY SYSTEM UI
    -- ==========================================
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 0, 0, 0)
    KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    KeyFrame.BackgroundTransparency = 0.15
    KeyFrame.BorderSizePixel = 0
    KeyFrame.ClipsDescendants = true
    KeyFrame.Parent = HubUI
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
    
    local KeyStroke = Instance.new("UIStroke", KeyFrame)
    KeyStroke.Color = Color3.fromRGB(255, 255, 255)
    KeyStroke.Thickness = 0.8
    KeyStroke.Transparency = 0.8
    
    local KeyLogo = Instance.new("ImageLabel")
    KeyLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyLogo.Size = UDim2.new(0, 80, 0, 80)
    KeyLogo.Position = UDim2.new(0.5, 0, 0, 60)
    KeyLogo.BackgroundTransparency = 1
    KeyLogo.Image = K_LogoAssetID
    KeyLogo.Parent = KeyFrame
    
    local BreatheTween = TweenService:Create(KeyLogo, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 88, 0, 88)})
    BreatheTween:Play()

    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Size = UDim2.new(1, 0, 0, 25)
    KeyTitle.Position = UDim2.new(0, 0, 0, 110)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "KELLYZ HUB AUTHENTICATION"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.TextSize = 14
    KeyTitle.Parent = KeyFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.85, 0, 0, 45)
    KeyInput.Position = UDim2.new(0.075, 0, 0, 145)
    KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    KeyInput.BackgroundTransparency = 0.4
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderText = "Paste Premium Key Here..."
    KeyInput.Font = Enum.Font.GothamSemibold
    KeyInput.TextSize = 12
    KeyInput.Text = ""
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = KeyFrame
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
    
    local KeyInputStroke = Instance.new("UIStroke", KeyInput)
    KeyInputStroke.Color = Color3.fromRGB(255, 255, 255)
    KeyInputStroke.Thickness = 1
    KeyInputStroke.Transparency = 0.8

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(0.075, 0, 0, 200)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    GetKeyBtn.BackgroundTransparency = 0.4
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Parent = KeyFrame
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Size = UDim2.new(0.4, 0, 0, 40)
    CheckBtn.Position = UDim2.new(0.525, 0, 0, 200)
    CheckBtn.BackgroundColor3 = getgenv().ThemeColor
    CheckBtn.Text = "Verify"
    CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextSize = 12
    CheckBtn.Parent = KeyFrame
    Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)
    table.insert(getgenv().ThemedElements.Bgs, CheckBtn)

    local invalidKeyAttempts = 0
    local function VerifyKey(input) return VerifyKellyzAuth(input) end
    
    local function InitMainHub()
        local closeLogin = TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        closeLogin:Play()
        closeLogin.Completed:Connect(function() 
            KeyFrame:Destroy()
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 420)}):Play()
            SendNotification("Script Executed!", "Selamat datang di Kellyz Hub Premium.", 5)
        end)
    end

    GetKeyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://discord.gg/Yq9jhScu") end; GetKeyBtn.Text = "Copied!"; task.wait(2); GetKeyBtn.Text = "Get Key" end)
    
    CheckBtn.MouseButton1Click:Connect(function()
        CheckBtn.Text = "Checking..."
        if VerifyKey(KeyInput.Text) then
            invalidKeyAttempts = 0
            CheckBtn.Text = "Success!"; TweenService:Create(CheckBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 200, 80)}):Play()
            if writefile then pcall(function() writefile(KeyFileName, KeyInput.Text .. "|" .. os.date("%Y-%m-%d")) end) end
            task.wait(1); InitMainHub()
        else
            invalidKeyAttempts = invalidKeyAttempts + 1
            if invalidKeyAttempts >= 3 then SendNotification("Keamanan", "Key salah atau HWID tidak cocok!", 6) end
            CheckBtn.Text = "Invalid!"; TweenService:Create(CheckBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
            task.wait(1.5); CheckBtn.Text = "Verify"; TweenService:Create(CheckBtn, TweenInfo.new(0.3), {BackgroundColor3 = getgenv().ThemeColor}):Play()
        end
    end)

    local savedKey = ""
    if getgenv().Key and getgenv().Key ~= "" then savedKey = getgenv().Key elseif isfile and isfile(KeyFileName) then pcall(function() local split = string.split(readfile(KeyFileName), "|"); savedKey = split[1] or "" end) end

    if savedKey ~= "" and VerifyKey(savedKey) then 
        MainFrame.Visible = false
        KeyFrame.Visible = false
        task.spawn(InitMainHub)
    else 
        MainFrame.Visible = false
        TweenService:Create(KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 0, 260)}):Play() 
    end

    -- TAB & CONTENT GENERATOR 
    local Tabs = {}
    local function AddTab(texts)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -16, 0, 35)
        TabBtn.Position = UDim2.new(0, 8, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180) 
        TabBtn.Font = Enum.Font.GothamBlack 
        TabBtn.TextSize = 13
        TabBtn.Text = "   " .. texts.en 
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left 
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        RegisterUI(TabBtn, texts, "Tab", nil)

        local Accent = Instance.new("Frame")
        Accent.Name = "Accent"
        Accent.Size = UDim2.new(0, 3, 0, 0)
        Accent.Position = UDim2.new(0, 0, 0.5, 0)
        Accent.AnchorPoint = Vector2.new(0, 0.5)
        Accent.BackgroundColor3 = getgenv().ThemeColor
        Accent.BorderSizePixel = 0
        Accent.Parent = TabBtn
        Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)
        table.insert(getgenv().ThemedElements.Bgs, Accent)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Name = texts.en .. "_Content"
        Scroll.Size = UDim2.new(1, -20, 1, -20)
        Scroll.Position = UDim2.new(0, 10, 0, 10)
        Scroll.BackgroundTransparency = 1
        Scroll.ScrollBarThickness = 2
        Scroll.ScrollBarImageColor3 = getgenv().ThemeColor
        Scroll.ScrollBarImageTransparency = 0.5
        Scroll.Visible = false
        Scroll.ZIndex = 2
        Scroll.Parent = ContentContainer
        table.insert(getgenv().ThemedElements.ScrollBars, Scroll)

        local ScrollLayout = Instance.new("UIListLayout", Scroll)
        ScrollLayout.Padding = UDim.new(0, 8)
        ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 40) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabContainer:GetChildren()) do 
                if btn:IsA("TextButton") then 
                    TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(180, 180, 180), BackgroundTransparency = 1}):Play() 
                    local acc = btn:FindFirstChild("Accent")
                    if acc then TweenService:Create(acc, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 0)}):Play() end
                end 
            end
            for _, sc in pairs(ContentContainer:GetChildren()) do if sc:IsA("ScrollingFrame") then sc.Visible = false end end
            for _, child in ipairs(MainFrame:GetChildren()) do if child.Name == "DropPanel" then child.Visible = false end end
            
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(30, 30, 35), BackgroundTransparency = 0}):Play()
            TweenService:Create(Accent, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 20)}):Play()
            getgenv().ActiveTab = TabBtn
            Scroll.Visible = true
        end)

        if #Tabs == 0 then 
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Accent.Size = UDim2.new(0, 3, 0, 20)
            getgenv().ActiveTab = TabBtn
            Scroll.Visible = true 
        end
        table.insert(Tabs, TabBtn)

        local function BuildElements(TargetParent)
            local Elements = {}
            
            function Elements:AddLabel(texts)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, 0, 0, 25)
                Lbl.BackgroundTransparency = 1
                Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                Lbl.Font = Enum.Font.GothamBold
                Lbl.TextSize = 13
                Lbl.Text = texts.en 
                Lbl.ZIndex = 3
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = TargetParent
                RegisterUI(Lbl, texts, "Label", nil)
                return Lbl
            end

            function Elements:AddToggle(texts, callback)
                local state = false
                local hasDesc = (texts.id_desc ~= nil) or (texts.en_desc ~= nil)
                
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, hasDesc and 48 or 40)
                Btn.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
                Btn.BackgroundTransparency = 0.2
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.GothamSemibold
                Btn.TextSize = 12
                Btn.Text = "" 
                Btn.ZIndex = 3
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.Parent = TargetParent
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
                
                local BtnStroke = Instance.new("UIStroke", Btn)
                BtnStroke.Color = getgenv().ThemeColor
                BtnStroke.Thickness = 0.6
                BtnStroke.Transparency = 0.8
                table.insert(getgenv().ThemedElements.Strokes, BtnStroke)
                
                AddHover(Btn, Color3.fromRGB(24, 22, 32), Color3.fromRGB(32, 28, 42))

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Name = "TitleLbl"
                TitleLbl.Size = UDim2.new(1, -60, 0, 16)
                TitleLbl.Position = UDim2.new(0, 15, 0, hasDesc and 8 or 12)
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                TitleLbl.Font = Enum.Font.GothamSemibold
                TitleLbl.TextSize = 12
                TitleLbl.Text = texts.en
                TitleLbl.ZIndex = 3
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.Parent = Btn
                
                if hasDesc then
                    local DescLbl = Instance.new("TextLabel")
                    DescLbl.Name = "DescLbl"
                    DescLbl.Size = UDim2.new(1, -60, 0, 14)
                    DescLbl.Position = UDim2.new(0, 15, 0, 26)
                    DescLbl.BackgroundTransparency = 1
                    DescLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
                    DescLbl.Font = Enum.Font.Gotham
                    DescLbl.TextSize = 10
                    DescLbl.ZIndex = 3
                    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
                    DescLbl.Parent = Btn
                end

                local SwitchBG = Instance.new("Frame")
                SwitchBG.Size = UDim2.new(0, 36, 0, 20)
                SwitchBG.Position = UDim2.new(1, -48, 0.5, -10)
                SwitchBG.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
                SwitchBG.ZIndex = 3
                SwitchBG.Parent = Btn
                Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)
                
                local SwitchStroke = Instance.new("UIStroke", SwitchBG)
                SwitchStroke.Color = getgenv().ThemeColor
                SwitchStroke.Thickness = 0.7
                SwitchStroke.Transparency = 0.6
                table.insert(getgenv().ThemedElements.Strokes, SwitchStroke)
                
                local SwitchDot = Instance.new("Frame")
                SwitchDot.Size = UDim2.new(0, 16, 0, 16)
                SwitchDot.Position = UDim2.new(0, 2, 0.5, -8)
                SwitchDot.BackgroundColor3 = Color3.fromRGB(110, 110, 120)
                SwitchDot.ZIndex = 3
                SwitchDot.Parent = SwitchBG
                Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(1, 0)
                
                table.insert(getgenv().ThemedElements.Toggles, {obj = SwitchBG, state = state})

                local function SetState(newState)
                    if state == newState then return end
                    state = newState
                    for _, reg in pairs(UIRegistry) do if reg.obj == Btn then reg.state = state end end
                    for _, tog in pairs(getgenv().ThemedElements.Toggles) do if tog.obj == SwitchBG then tog.state = state end end
                    
                    if state then
                        TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        TweenService:Create(SwitchBG, TweenInfo.new(0.3), {BackgroundColor3 = getgenv().ThemeColor}):Play()
                        SwitchStroke.Transparency = 0.3
                    else
                        TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(110, 110, 120)}):Play()
                        TweenService:Create(SwitchBG, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(18, 18, 25)}):Play()
                        SwitchStroke.Transparency = 0.6
                    end
                    
                    UpdateLanguage()
                    if callback then callback(state) end
                end

                Btn.MouseButton1Click:Connect(function()
                    SetState(not state)
                end)
                
                RegisterUI(Btn, texts, "Toggle", state, SetState)
                return {Set = SetState}
            end

            function Elements:AddMultiDropdown(texts, options, callback)
                local state = {selected = {}}; local isOpen = false
                local DropFrame = Instance.new("Frame"); DropFrame.Size = UDim2.new(1, 0, 0, 40); DropFrame.BackgroundColor3 = Color3.fromRGB(24, 22, 32); DropFrame.BackgroundTransparency = 0.2; DropFrame.ClipsDescendants = false; DropFrame.ZIndex = 3; DropFrame.Parent = TargetParent; Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
                local DropStroke = Instance.new("UIStroke", DropFrame); DropStroke.Color = getgenv().ThemeColor; DropStroke.Thickness = 0.6; DropStroke.Transparency = 0.8; table.insert(getgenv().ThemedElements.Strokes, DropStroke)

                local MainBtn = Instance.new("TextButton"); MainBtn.Size = UDim2.new(1, 0, 0, 40); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; MainBtn.ZIndex = 3; MainBtn.Parent = DropFrame
                local TitleLbl = Instance.new("TextLabel"); TitleLbl.Name = "TitleLbl"; TitleLbl.Size = UDim2.new(0.5, 0, 1, 0); TitleLbl.Position = UDim2.new(0, 15, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLbl.Font = Enum.Font.GothamSemibold; TitleLbl.TextSize = 11; TitleLbl.Text = texts.en; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 3; TitleLbl.Parent = MainBtn
                local ValueLbl = Instance.new("TextLabel"); ValueLbl.Name = "ValueLbl"; ValueLbl.Size = UDim2.new(0.5, -45, 1, 0); ValueLbl.Position = UDim2.new(0.5, 0, 0, 0); ValueLbl.BackgroundTransparency = 1; ValueLbl.TextColor3 = getgenv().ThemeColor; ValueLbl.Font = Enum.Font.GothamSemibold; ValueLbl.TextSize = 11; ValueLbl.Text = "None"; ValueLbl.TextXAlignment = Enum.TextXAlignment.Right; ValueLbl.TextTruncate = Enum.TextTruncate.AtEnd; ValueLbl.ZIndex = 3; ValueLbl.Parent = MainBtn; table.insert(getgenv().ThemedElements.Texts, ValueLbl)
                local Icon = Instance.new("TextLabel"); Icon.Size = UDim2.new(0, 30, 1, 0); Icon.Position = UDim2.new(1, -30, 0, 0); Icon.BackgroundTransparency = 1; Icon.Text = ">"; Icon.TextColor3 = getgenv().ThemeColor; Icon.Font = Enum.Font.GothamBold; Icon.TextSize = 14; Icon.ZIndex = 3; Icon.Parent = MainBtn; table.insert(getgenv().ThemedElements.Texts, Icon)

                local DropPanel = Instance.new("Frame"); DropPanel.Name = "DropPanel"; DropPanel.Size = UDim2.new(0, 200, 1, 0); DropPanel.Position = UDim2.new(1, -210, 0, 0); DropPanel.AnchorPoint = Vector2.new(0, 0); DropPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30); DropPanel.BackgroundTransparency = 0; DropPanel.ClipsDescendants = true; DropPanel.ZIndex = 50; DropPanel.Visible = false; DropPanel.Parent = MainFrame; Instance.new("UICorner", DropPanel).CornerRadius = UDim.new(0, 8)
                local PanelStroke = Instance.new("UIStroke", DropPanel); PanelStroke.Color = Color3.fromRGB(0, 0, 0); PanelStroke.Thickness = 1; PanelStroke.Transparency = 0.5

                local SearchBox = Instance.new("TextBox"); SearchBox.Name = "SearchBox"; SearchBox.Text = ""; SearchBox.Size = UDim2.new(1, -20, 0, 30); SearchBox.Position = UDim2.new(0, 10, 0, 5); SearchBox.BackgroundTransparency = 1; SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); SearchBox.PlaceholderText = "Search"; SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 12; SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ZIndex = 51; SearchBox.Parent = DropPanel
                local Divider = Instance.new("Frame"); Divider.Size = UDim2.new(1, -20, 0, 1); Divider.Position = UDim2.new(0, 10, 0, 35); Divider.BackgroundColor3 = Color3.fromRGB(255,255,255); Divider.BackgroundTransparency = 0.9; Divider.ZIndex = 51; Divider.Parent = DropPanel

                local OptContainer = Instance.new("ScrollingFrame"); OptContainer.Size = UDim2.new(1, 0, 1, -40); OptContainer.Position = UDim2.new(0, 0, 0, 40); OptContainer.BackgroundTransparency = 1; OptContainer.ScrollBarThickness = 2; OptContainer.ScrollBarImageColor3 = getgenv().ThemeColor; OptContainer.ZIndex = 51; OptContainer.Parent = DropPanel; table.insert(getgenv().ThemedElements.ScrollBars, OptContainer)
                local OptLayout = Instance.new("UIListLayout", OptContainer); OptLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptLayout.Padding = UDim.new(0, 2); OptLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() OptContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y + 4) end)

                local OptionBtns = {}
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local term = SearchBox.Text:lower()
                    for _, btn in ipairs(OptionBtns) do btn.Visible = (term == "" or string.find(btn.Name:lower(), term) ~= nil) end
                end)

                MainBtn.MouseButton1Click:Connect(function()
                    for _, child in ipairs(MainFrame:GetChildren()) do if child.Name == "DropPanel" and child ~= DropPanel then child.Visible = false end end
                    isOpen = not isOpen
                    if isOpen then
                        DropPanel.Visible = true; DropPanel.Size = UDim2.new(0, 200, 1, 0); DropPanel.Position = UDim2.new(1, 20, 0, 0)
                        TweenService:Create(TitleLbl, TweenInfo.new(0.45), {TextColor3 = getgenv().ThemeColor}):Play()
                        TweenService:Create(DropPanel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -210, 0, 0)}):Play()
                    else
                        TweenService:Create(TitleLbl, TweenInfo.new(0.45), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        local tw = TweenService:Create(DropPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, 20, 0, 0)})
                        tw:Play(); tw.Completed:Connect(function() if not isOpen then DropPanel.Visible = false end end)
                    end
                    TweenService:Create(Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = isOpen and 90 or 0}):Play()
                end)

                for i, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton"); OptBtn.Name = opt; OptBtn.LayoutOrder = i; OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); OptBtn.BackgroundTransparency = 0; OptBtn.Text = ""; OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200); OptBtn.Font = Enum.Font.GothamSemibold; OptBtn.TextSize = 13; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.ZIndex = 51; OptBtn.Parent = OptContainer; table.insert(OptionBtns, OptBtn); AddHover(OptBtn, Color3.fromRGB(25, 25, 30), Color3.fromRGB(35, 35, 40))
                    local Padding = Instance.new("UIPadding", OptBtn); Padding.PaddingLeft = UDim.new(0, 10)

                    -- Mini toggle indicator
                    local TogBG = Instance.new("Frame"); TogBG.Name = "TogBG"; TogBG.Size = UDim2.new(0, 28, 0, 14); TogBG.Position = UDim2.new(0, 0, 0.5, -7); TogBG.BackgroundColor3 = Color3.fromRGB(40, 38, 50); TogBG.ZIndex = 52; TogBG.Parent = OptBtn; Instance.new("UICorner", TogBG).CornerRadius = UDim.new(1, 0)
                    local TogDot = Instance.new("Frame"); TogDot.Name = "TogDot"; TogDot.Size = UDim2.new(0, 10, 0, 10); TogDot.Position = UDim2.new(0, 2, 0.5, -5); TogDot.BackgroundColor3 = Color3.fromRGB(100, 100, 110); TogDot.ZIndex = 53; TogDot.Parent = TogBG; Instance.new("UICorner", TogDot).CornerRadius = UDim.new(1, 0)
                    local OptLabel = Instance.new("TextLabel"); OptLabel.Name = "OptLabel"; OptLabel.Size = UDim2.new(1, -40, 1, 0); OptLabel.Position = UDim2.new(0, 35, 0, 0); OptLabel.BackgroundTransparency = 1; OptLabel.Text = opt; OptLabel.TextColor3 = Color3.fromRGB(200, 200, 200); OptLabel.Font = Enum.Font.GothamSemibold; OptLabel.TextSize = 13; OptLabel.TextXAlignment = Enum.TextXAlignment.Left; OptLabel.ZIndex = 52; OptLabel.Parent = OptBtn

                    OptBtn.MouseButton1Click:Connect(function()
                        local idx = table.find(state.selected, opt)
                        if idx then
                            table.remove(state.selected, idx)
                            TweenService:Create(OptLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                            TweenService:Create(TogBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 38, 50)}):Play()
                            TweenService:Create(TogDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Color3.fromRGB(100, 100, 110)}):Play()
                        else
                            table.insert(state.selected, opt)
                            TweenService:Create(OptLabel, TweenInfo.new(0.2), {TextColor3 = getgenv().ThemeColor}):Play()
                            TweenService:Create(TogBG, TweenInfo.new(0.2), {BackgroundColor3 = getgenv().ThemeColor}):Play()
                            TweenService:Create(TogDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        end
                        ValueLbl.Text = #state.selected > 0 and table.concat(state.selected, ", ") or "None"
                        UpdateLanguage(); if callback then callback(state.selected) end
                    end)
                end
                
                local function SetState(newSelection)
                    if type(newSelection) == "table" then
                        state.selected = newSelection
                        for _, btn in ipairs(OptionBtns) do
                            local togBG = btn:FindFirstChild("TogBG")
                            local togDot = togBG and togBG:FindFirstChild("TogDot")
                            local optLabel = btn:FindFirstChild("OptLabel")
                            if table.find(state.selected, btn.Name) then
                                if optLabel then TweenService:Create(optLabel, TweenInfo.new(0.2), {TextColor3 = getgenv().ThemeColor}):Play() end
                                if togBG then TweenService:Create(togBG, TweenInfo.new(0.2), {BackgroundColor3 = getgenv().ThemeColor}):Play() end
                                if togDot then TweenService:Create(togDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
                            else
                                if optLabel then TweenService:Create(optLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end
                                if togBG then TweenService:Create(togBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 38, 50)}):Play() end
                                if togDot then TweenService:Create(togDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Color3.fromRGB(100, 100, 110)}):Play() end
                            end
                        end
                        ValueLbl.Text = #state.selected > 0 and table.concat(state.selected, ", ") or "None"
                        UpdateLanguage()
                        if callback then callback(state.selected) end
                    end
                end
                RegisterUI(MainBtn, texts, "MultiDropdown", state, SetState)
            end

            function Elements:AddSingleDropdown(texts, options, callback)
                local state = {selected = options[1] or "None"}; local isOpen = false
                local DropFrame = Instance.new("Frame"); DropFrame.Size = UDim2.new(1, 0, 0, 40); DropFrame.BackgroundColor3 = Color3.fromRGB(24, 22, 32); DropFrame.BackgroundTransparency = 0.2; DropFrame.ClipsDescendants = false; DropFrame.ZIndex = 3; DropFrame.Parent = TargetParent; Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)
                local DropStroke = Instance.new("UIStroke", DropFrame); DropStroke.Color = getgenv().ThemeColor; DropStroke.Thickness = 0.6; DropStroke.Transparency = 0.8; table.insert(getgenv().ThemedElements.Strokes, DropStroke)

                local MainBtn = Instance.new("TextButton"); MainBtn.Size = UDim2.new(1, 0, 0, 40); MainBtn.BackgroundTransparency = 1; MainBtn.Text = ""; MainBtn.ZIndex = 3; MainBtn.Parent = DropFrame
                local TitleLbl = Instance.new("TextLabel"); TitleLbl.Name = "TitleLbl"; TitleLbl.Size = UDim2.new(0.5, 0, 1, 0); TitleLbl.Position = UDim2.new(0, 15, 0, 0); TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLbl.Font = Enum.Font.GothamSemibold; TitleLbl.TextSize = 11; TitleLbl.Text = texts.en; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 3; TitleLbl.Parent = MainBtn
                local ValueLbl = Instance.new("TextLabel"); ValueLbl.Name = "ValueLbl"; ValueLbl.Size = UDim2.new(0.5, -45, 1, 0); ValueLbl.Position = UDim2.new(0.5, 0, 0, 0); ValueLbl.BackgroundTransparency = 1; ValueLbl.TextColor3 = getgenv().ThemeColor; ValueLbl.Font = Enum.Font.GothamSemibold; ValueLbl.TextSize = 11; ValueLbl.Text = tostring(state.selected); ValueLbl.TextXAlignment = Enum.TextXAlignment.Right; ValueLbl.TextTruncate = Enum.TextTruncate.AtEnd; ValueLbl.ZIndex = 3; ValueLbl.Parent = MainBtn; table.insert(getgenv().ThemedElements.Texts, ValueLbl)
                local Icon = Instance.new("TextLabel"); Icon.Size = UDim2.new(0, 30, 1, 0); Icon.Position = UDim2.new(1, -30, 0, 0); Icon.BackgroundTransparency = 1; Icon.Text = ">"; Icon.TextColor3 = getgenv().ThemeColor; Icon.Font = Enum.Font.GothamBold; Icon.TextSize = 14; Icon.ZIndex = 3; Icon.Parent = MainBtn; table.insert(getgenv().ThemedElements.Texts, Icon)

                local DropPanel = Instance.new("Frame"); DropPanel.Name = "DropPanel"; DropPanel.Size = UDim2.new(0, 200, 1, 0); DropPanel.Position = UDim2.new(1, -210, 0, 0); DropPanel.AnchorPoint = Vector2.new(0, 0); DropPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30); DropPanel.BackgroundTransparency = 0; DropPanel.ClipsDescendants = true; DropPanel.ZIndex = 50; DropPanel.Visible = false; DropPanel.Parent = MainFrame; Instance.new("UICorner", DropPanel).CornerRadius = UDim.new(0, 8)
                local PanelStroke = Instance.new("UIStroke", DropPanel); PanelStroke.Color = Color3.fromRGB(0, 0, 0); PanelStroke.Thickness = 1; PanelStroke.Transparency = 0.5

                local SearchBox = Instance.new("TextBox"); SearchBox.Name = "SearchBox"; SearchBox.Text = ""; SearchBox.Size = UDim2.new(1, -20, 0, 30); SearchBox.Position = UDim2.new(0, 10, 0, 5); SearchBox.BackgroundTransparency = 1; SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); SearchBox.PlaceholderText = "Search"; SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150); SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 12; SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ZIndex = 51; SearchBox.Parent = DropPanel
                local Divider = Instance.new("Frame"); Divider.Size = UDim2.new(1, -20, 0, 1); Divider.Position = UDim2.new(0, 10, 0, 35); Divider.BackgroundColor3 = Color3.fromRGB(255,255,255); Divider.BackgroundTransparency = 0.9; Divider.ZIndex = 51; Divider.Parent = DropPanel

                local OptContainer = Instance.new("ScrollingFrame"); OptContainer.Size = UDim2.new(1, 0, 1, -40); OptContainer.Position = UDim2.new(0, 0, 0, 40); OptContainer.BackgroundTransparency = 1; OptContainer.ScrollBarThickness = 2; OptContainer.ScrollBarImageColor3 = getgenv().ThemeColor; OptContainer.ZIndex = 51; OptContainer.Parent = DropPanel; table.insert(getgenv().ThemedElements.ScrollBars, OptContainer)
                local OptLayout = Instance.new("UIListLayout", OptContainer); OptLayout.SortOrder = Enum.SortOrder.LayoutOrder; OptLayout.Padding = UDim.new(0, 2); OptLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() OptContainer.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y + 4) end)

                local OptionBtns = {}
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local term = SearchBox.Text:lower()
                    for _, btn in ipairs(OptionBtns) do btn.Visible = (term == "" or string.find(btn.Name:lower(), term) ~= nil) end
                end)

                MainBtn.MouseButton1Click:Connect(function()
                    for _, child in ipairs(MainFrame:GetChildren()) do if child.Name == "DropPanel" and child ~= DropPanel then child.Visible = false end end
                    isOpen = not isOpen
                    if isOpen then
                        DropPanel.Visible = true; DropPanel.Size = UDim2.new(0, 200, 1, 0); DropPanel.Position = UDim2.new(1, 20, 0, 0)
                        TweenService:Create(TitleLbl, TweenInfo.new(0.45), {TextColor3 = getgenv().ThemeColor}):Play()
                        TweenService:Create(DropPanel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -210, 0, 0)}):Play()
                    else
                        TweenService:Create(TitleLbl, TweenInfo.new(0.45), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        local tw = TweenService:Create(DropPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, 20, 0, 0)})
                        tw:Play(); tw.Completed:Connect(function() if not isOpen then DropPanel.Visible = false end end)
                    end
                    TweenService:Create(Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = isOpen and 90 or 0}):Play()
                end)

                local function PopulateOptions(newOptions)
                    for _, btn in ipairs(OptionBtns) do btn:Destroy() end; OptionBtns = {}
                    for i, opt in ipairs(newOptions) do
                        local OptBtn = Instance.new("TextButton"); OptBtn.Name = opt; OptBtn.LayoutOrder = i; OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30); OptBtn.BackgroundTransparency = 0; OptBtn.Text = opt; OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200); OptBtn.Font = Enum.Font.GothamSemibold; OptBtn.TextSize = 13; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.ZIndex = 51; OptBtn.Parent = OptContainer; table.insert(OptionBtns, OptBtn); AddHover(OptBtn, Color3.fromRGB(25, 25, 30), Color3.fromRGB(35, 35, 40))
                        local Padding = Instance.new("UIPadding", OptBtn); Padding.PaddingLeft = UDim.new(0, 15)
                        OptBtn.MouseButton1Click:Connect(function()
                            state.selected = opt; ValueLbl.Text = tostring(opt); UpdateLanguage(); isOpen = false
                            TweenService:Create(Icon, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                            local tw = TweenService:Create(DropPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, 20, 0, 40)})
                            tw:Play(); tw.Completed:Connect(function() if not isOpen then DropPanel.Visible = false end end)
                            TweenService:Create(TitleLbl, TweenInfo.new(0.45), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                            if callback then callback(opt) end
                        end)
                    end
                end
                PopulateOptions(options)
                
                local function SetState(newOpt)
                    state.selected = tostring(newOpt)
                    ValueLbl.Text = tostring(newOpt)
                    UpdateLanguage()
                    if callback then callback(newOpt) end
                end
                RegisterUI(MainBtn, texts, "Dropdown", state, SetState)
                
                local DropdownAPI = {}
                function DropdownAPI:Refresh(newOptions) PopulateOptions(newOptions); state.selected = #newOptions > 0 and newOptions[1] or "None"; ValueLbl.Text = tostring(state.selected); UpdateLanguage(); if callback then callback(state.selected) end end
                function DropdownAPI:Set(newOpt) SetState(newOpt) end
                return DropdownAPI
            end
            function Elements:AddButton(texts, callback)
                local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.BackgroundColor3 = getgenv().ThemeColor; Btn.BackgroundTransparency = 0.1; Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Btn.Text = texts.en; Btn.ZIndex = 3; Btn.Parent = TargetParent; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
                local BtnStroke = Instance.new("UIStroke", Btn); BtnStroke.Thickness = 1; BtnStroke.Transparency = 0.3; table.insert(getgenv().ThemedElements.Strokes, BtnStroke)
                RegisterUI(Btn, texts, "Button", nil); table.insert(getgenv().ThemedElements.Bgs, Btn)
                Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play(); BtnStroke.Transparency = 0.1 end)
                Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play(); BtnStroke.Transparency = 0.3 end)
                Btn.MouseButton1Click:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.08), {Size = UDim2.new(0.97, 0, 0, 38)}):Play(); task.wait(0.1); TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)}):Play(); pcall(callback) end)
            end

            function Elements:AddSlider(texts, min, max, default, callback)
                local state = {value = default}; local SliderFrame = Instance.new("Frame"); SliderFrame.Size = UDim2.new(1, 0, 0, 55); SliderFrame.BackgroundColor3 = Color3.fromRGB(24, 22, 32); SliderFrame.BackgroundTransparency = 0.2; SliderFrame.ZIndex = 3; SliderFrame.Parent = TargetParent; Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
                local SliderStroke = Instance.new("UIStroke", SliderFrame); SliderStroke.Color = getgenv().ThemeColor; SliderStroke.Thickness = 0.6; SliderStroke.Transparency = 0.8; table.insert(getgenv().ThemedElements.Strokes, SliderStroke)
                local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -15, 0, 20); Title.Position = UDim2.new(0, 15, 0, 8); Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamSemibold; Title.TextSize = 11; Title.Text = texts.en; Title.ZIndex = 3; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = SliderFrame; RegisterUI(Title, texts, "Label", nil)
                local SliderBG = Instance.new("Frame"); SliderBG.Size = UDim2.new(1, -30, 0, 6); SliderBG.Position = UDim2.new(0, 15, 0, 38); SliderBG.BackgroundColor3 = Color3.fromRGB(18, 18, 25); SliderBG.ZIndex = 3; SliderBG.Parent = SliderFrame; Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
                local SliderBGStroke = Instance.new("UIStroke", SliderBG); SliderBGStroke.Color = getgenv().ThemeColor; SliderBGStroke.Thickness = 0.6; SliderBGStroke.Transparency = 0.7; table.insert(getgenv().ThemedElements.Strokes, SliderBGStroke)
                local fillPct = (default - min) / (max - min); local SliderFill = Instance.new("Frame"); SliderFill.Size = UDim2.new(fillPct, 0, 1, 0); SliderFill.BackgroundColor3 = getgenv().ThemeColor; SliderFill.ZIndex = 3; SliderFill.Parent = SliderBG; Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0); table.insert(getgenv().ThemedElements.Bgs, SliderFill)
                local Indicator = Instance.new("Frame"); Indicator.Size = UDim2.new(0, 14, 0, 14); Indicator.Position = UDim2.new(1, -7, 0.5, -7); Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Indicator.ZIndex = 3; Indicator.Parent = SliderFill; Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
                local IndicatorStroke = Instance.new("UIStroke", Indicator); IndicatorStroke.Color = getgenv().ThemeColor; IndicatorStroke.Thickness = 1.5; table.insert(getgenv().ThemedElements.Strokes, IndicatorStroke)
                local SliderBtn = Instance.new("TextButton"); SliderBtn.Size = UDim2.new(1, 0, 1, 0); SliderBtn.BackgroundTransparency = 1; SliderBtn.Text = ""; SliderBtn.ZIndex = 4; SliderBtn.Parent = SliderBG
                local ValueLabel = Instance.new("TextLabel"); ValueLabel.Size = UDim2.new(0, 40, 0, 20); ValueLabel.Position = UDim2.new(1, -55, 0, 8); ValueLabel.BackgroundTransparency = 1; ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255); ValueLabel.Text = tostring(default); ValueLabel.Font = Enum.Font.GothamBold; ValueLabel.TextSize = 12; ValueLabel.ZIndex = 3; ValueLabel.TextXAlignment = Enum.TextXAlignment.Right; ValueLabel.Parent = SliderFrame
                
                local dragging = false
                local function updateSlider(input) local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1); local value = math.floor(min + ((max - min) * pos)); state.value = value; TweenService:Create(SliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play(); ValueLabel.Text = tostring(value); callback(value) end
                SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end end)
                
                local function SetState(newValue)
                    local value = math.clamp(tonumber(newValue) or min, min, max)
                    state.value = value
                    local pos = (value - min) / (max - min)
                    TweenService:Create(SliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                    ValueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end
                RegisterUI(SliderFrame, texts, "Slider", state, SetState)
            end

            function Elements:AddInput(texts, callback)
                local Box = Instance.new("TextBox"); Box.Size = UDim2.new(1, 0, 0, 40); Box.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Box.BackgroundTransparency = 0.2; Box.Text = ""; Box.TextColor3 = Color3.fromRGB(255, 255, 255); Box.PlaceholderText = texts.en; Box.Font = Enum.Font.GothamSemibold; Box.TextSize = 12; Box.ZIndex = 3; Box.ClearTextOnFocus = false; Box.Parent = TargetParent; Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
                local BoxStroke = Instance.new("UIStroke", Box); BoxStroke.Color = getgenv().ThemeColor; BoxStroke.Thickness = 1; BoxStroke.Transparency = 0.5; table.insert(getgenv().ThemedElements.Strokes, BoxStroke)
                local function SetState(newText)
                    Box.Text = tostring(newText)
                    if callback then callback(Box.Text) end
                end
                Box.FocusLost:Connect(function() callback(Box.Text) end)
                RegisterUI(Box, texts, "Input", nil, SetState)
            end

            function Elements:AddSection(texts, defaultOpen)
                local isExpanded = (defaultOpen == true)
                local SectionMain = Instance.new("Frame"); SectionMain.Size = UDim2.new(1, 0, 0, isExpanded and 40 or 35); SectionMain.BackgroundTransparency = 1; SectionMain.Parent = TargetParent
                local SectionBtn = Instance.new("TextButton"); SectionBtn.Size = UDim2.new(1, 0, 0, 35); SectionBtn.BackgroundColor3 = Color3.fromRGB(28, 26, 36); SectionBtn.BackgroundTransparency = 0.5; SectionBtn.Text = ""; SectionBtn.Parent = SectionMain; Instance.new("UICorner", SectionBtn).CornerRadius = UDim.new(0, 6)
                
                local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0); Title.BackgroundTransparency = 1; Title.Text = texts.en; Title.TextColor3 = isExpanded and getgenv().ThemeColor or Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = SectionBtn; RegisterUI(Title, texts, "Label", nil)
                local secData = {obj = Title, state = isExpanded}; table.insert(getgenv().ThemedElements.SectionTitles, secData)
                
                local ArrowIcon = Instance.new("TextLabel"); ArrowIcon.Size = UDim2.new(0, 35, 0, 35); ArrowIcon.Position = UDim2.new(1, -35, 0, 0); ArrowIcon.BackgroundTransparency = 1; ArrowIcon.Text = ">"; ArrowIcon.TextColor3 = getgenv().ThemeColor; ArrowIcon.Font = Enum.Font.GothamBold; ArrowIcon.TextSize = 14; ArrowIcon.Rotation = isExpanded and 90 or 0; ArrowIcon.Parent = SectionBtn; table.insert(getgenv().ThemedElements.Texts, ArrowIcon)
                local SectionContent = Instance.new("Frame"); SectionContent.Size = UDim2.new(1, -6, 0, 0); SectionContent.Position = UDim2.new(0, 6, 0, 40); SectionContent.BackgroundTransparency = 1; SectionContent.ClipsDescendants = not isExpanded; SectionContent.Parent = SectionMain
                local SectionLayout = Instance.new("UIListLayout", SectionContent); SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder; SectionLayout.Padding = UDim.new(0, 6)

                local function UpdateSize() if isExpanded then SectionContent.Size = UDim2.new(1, -6, 0, SectionLayout.AbsoluteContentSize.Y); SectionMain.Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y) end end
                SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

                SectionBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded; secData.state = isExpanded 
                    if isExpanded then
                        TweenService:Create(Title, TweenInfo.new(0.3), {TextColor3 = getgenv().ThemeColor}):Play(); TweenService:Create(ArrowIcon, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 90}):Play(); TweenService:Create(SectionContent, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, SectionLayout.AbsoluteContentSize.Y)}):Play(); TweenService:Create(SectionMain, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y)}):Play()
                        task.delay(0.45, function() if isExpanded then SectionContent.ClipsDescendants = false end end)
                    else
                        SectionContent.ClipsDescendants = true; TweenService:Create(Title, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play(); TweenService:Create(ArrowIcon, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 0}):Play(); TweenService:Create(SectionContent, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -6, 0, 0)}):Play(); TweenService:Create(SectionMain, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    end
                end)
                task.spawn(function() task.wait(0.1) if isExpanded then UpdateSize(); SectionContent.ClipsDescendants = false else SectionContent.Size = UDim2.new(1, -6, 0, 0); SectionMain.Size = UDim2.new(1, 0, 0, 35); SectionContent.ClipsDescendants = true end end)
                return BuildElements(SectionContent)
            end

            function Elements:AddImage(assetID, height)
                local ImgFrame = Instance.new("Frame"); ImgFrame.Size = UDim2.new(1, 0, 0, height); ImgFrame.BackgroundTransparency = 1; ImgFrame.ZIndex = 3; ImgFrame.Parent = TargetParent
                local Img = Instance.new("ImageLabel"); Img.Size = UDim2.new(1, 0, 1, 0); Img.BackgroundTransparency = 1; Img.Image = assetID; Img.ScaleType = Enum.ScaleType.Fit; Img.ZIndex = 3; Img.Parent = ImgFrame; Instance.new("UICorner", Img).CornerRadius = UDim.new(0, 8)
            end

            return Elements
        end
        return BuildElements(Scroll)
    end
    return AddTab
end

local AddTab = CreateCustomUI()

local StandardRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Hacked", "OG", "Celestial", "Eternal", "Impossible", "Godly"}
local StandardMutations = {"Diamond", "Plasma", "Void", "Neon", "Enchanted", "Shadows", "Bacon", "No Mutation"}
local ColorThemes = {
    ["Cyan (Light Blue)"] = Color3.fromRGB(0, 200, 255),
    ["Amethyst (Purple)"] = Color3.fromRGB(130, 90, 230),
    ["Ruby (Red)"] = Color3.fromRGB(230, 50, 50),
    ["Sapphire (Blue)"] = Color3.fromRGB(50, 100, 230),
    ["Emerald (Green)"] = Color3.fromRGB(50, 200, 80),
    ["Gold (Yellow)"] = Color3.fromRGB(230, 180, 50),
    ["Pink (Kawaii)"] = Color3.fromRGB(255, 100, 180)
}

-- UNIVERSAL VARIABLES
getgenv().FlySettings = { Enabled = false, Speed = 50 }
getgenv().SpeedhackSettings = { Enabled = false, Speed = 16 }
getgenv().AntiAFK = false

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == Enum.KeyCode.K then
        if HubUI then HubUI.Enabled = not HubUI.Enabled end
    end
end)

-- ==========================================
-- [ GLOBAL TABS SETUP ]
-- ==========================================
local InfoTab = AddTab({id = "Info", en = "Info"})
local MainTab = AddTab({id = "Main", en = "Main"})
local ShopTab = AddTab({id = "Shop", en = "Shop"}) 
local PremiumTab = AddTab({id = "Premium", en = "Premium"}) 
local TradeTab = AddTab({id = "Trade", en = "Trade"})
local OtherTab = AddTab({id = "Other", en = "Other"})
local MiscTab = AddTab({id = "Misc", en = "Misc"})

local InfoSec = InfoTab:AddSection({id = "Profil Hub", en = "Hub Profile"}, true)
InfoSec:AddLabel({id = "Selamat Datang di Kellyz Hub", en = "Welcome to Kellyz Hub"})
InfoSec:AddLabel({id = "Map Saat Ini: " .. GameName, en = "Current Map: " .. GameName})
InfoSec:AddLabel({id = "Script Paling OP, 100% Undetected!", en = "The Most OP Script, 100% Undetected!"})
InfoSec:AddImage(AnimeGirlAssetID, 180) 

local DiscordSec = InfoTab:AddSection({id = "Komunitas", en = "Community"}, true)
DiscordSec:AddLabel({id = "Ayo Gabung Komunitas Discord Kami! ", en = "Join Our Discord Community! "})
DiscordSec:AddButton({id = "Salin Link Discord", en = "Copy Discord Link"}, function() 
    if setclipboard then 
        setclipboard("https://discord.gg/Yq9jhScu") 
        SendNotification("Link Tersalin! ", "Link Discord berhasil disalin ke clipboard!", 5)
    else
        SendNotification("Gagal", "Eksekutormu tidak mendukung fitur setclipboard.", 4)
    end 
end)

local ThemeSec = InfoTab:AddSection({id = "Pengaturan Tema", en = "Theme Settings"}, true)
ThemeSec:AddSingleDropdown({id = "Warna Tema UI", en = "UI Theme Color"}, {"Cyan (Light Blue)", "Amethyst (Purple)", "Ruby (Red)", "Sapphire (Blue)", "Emerald (Green)", "Gold (Yellow)", "Pink (Kawaii)"}, function(opt)
    if ColorThemes[opt] then ApplyTheme(ColorThemes[opt]) end
end)

ThemeSec:AddInput({id = "Custom Warna (Hex: #FFFFFF / RGB: 255,255,255)", en = "Custom Color (Hex: #FFFFFF / RGB: 255,255,255)"}, function(val)
    local input = val:gsub(" ", "")
    local newColor = nil
    if input:find(",") then
        local r, g, b = input:match("(%d+),(%d+),(%d+)")
        if r and g and b then newColor = Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255)) end
    elseif input:sub(1,1) == "#" or #input == 6 then
        local hex = input:gsub("#", "")
        if #hex == 6 and tonumber(hex, 16) then newColor = Color3.fromRGB(tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)) end
    end
    if newColor then ApplyTheme(newColor); SendNotification("Tema Diperbarui", "Warna kustom berhasil diterapkan dengan mulus!", 4)
    else SendNotification("Format Salah!", "Gunakan format RGB (Cth: 255,0,0) atau Hex (Cth: #FF0000).", 4) end
end)

-- ==========================================
-- [ MISCELLANEOUS TAB ]
-- ==========================================
local MoveSec = MiscTab:AddSection({id = "Gerakan Cepat & Terbang", en = "Movement Hacks & Fly Safe"}, false)
MoveSec:AddToggle({id = "Kecepatan Lari (Aman)", en = "Safe Speedhack", id_desc = "Mempercepat lari tanpa terdeteksi", en_desc = "Increase walk speed safely"}, function(Value) getgenv().SpeedhackSettings.Enabled = Value end)
MoveSec:AddSlider({id = "Atur Kecepatan Berjalan", en = "Walk Speed"}, 16, 200, 16, function(Value) getgenv().SpeedhackSettings.Speed = Value end)

MoveSec:AddToggle({id = "Terbang & Tembus Tembok", en = "Fly & NoClip", id_desc = "Terbang bebas ke mana saja", en_desc = "Fly anywhere freely"}, function(Value)
    getgenv().FlySettings.Enabled = Value
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not Value then if hrp:FindFirstChild("HackFlyBV") then hrp.HackFlyBV:Destroy() end if hrp:FindFirstChild("HackFlyBG") then hrp.HackFlyBG:Destroy() end end
end)
MoveSec:AddSlider({id = "Atur Kecepatan Terbang", en = "Fly Speed"}, 10, 300, 50, function(Value) getgenv().FlySettings.Speed = Value end)

local SecSec = MiscTab:AddSection({id = "Fitur Keamanan (Anti-Kick)", en = "Security Utilities"}, false)
SecSec:AddToggle({id = "Anti-AFK (Anti-Keluar)", en = "Anti-AFK (Anti-Disconnect)", id_desc = "Mencegah kick dari game saat diam", en_desc = "Prevents idle kick from the game"}, function(Value) getgenv().AntiAFK = Value if Value then SendNotification("Anti-AFK Aktif", "Anda tidak akan di-kick karena diam.", 4) end end)

-- ==========================================
-- [ CONFIG SECTION (di Tab Misc) ]
-- ==========================================
local ConfigSec = MiscTab:AddSection({id = "Pengaturan Config", en = "Config Settings"}, true)

local ConfigFolderName = "KellzyHub_Configs"
if makefolder and not isfolder(ConfigFolderName) then pcall(function() makefolder(ConfigFolderName) end) end

local function GetSavedConfigs()
    local configs = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(ConfigFolderName)) do
                if file:sub(-5) == ".json" then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(configs, name) end
                end
            end
        end)
    end
    if #configs == 0 then table.insert(configs, "Default") end
    return configs
end

local CurrentConfigName = "Default"
local ConfigDropdownAPI = nil

local function SaveConfig(name)
    if not writefile then return SendNotification("Gagal", "Eksekutor Anda tidak mendukung writefile.", 4) end
    local dataToSave = {}
    for _, reg in pairs(UIRegistry) do
        if reg.texts and reg.texts.en and reg.state ~= nil then
            local val = reg.state
            -- Unwrap complex state: MultiDropdown {selected={...}} → {...}, Slider {value=N} → N
            if type(val) == "table" and val.selected then
                val = val.selected
            elseif type(val) == "table" and val.value ~= nil then
                val = val.value
            end
            dataToSave[reg.texts.en] = val
        end
    end
    pcall(function()
        local jsonData = HttpService:JSONEncode(dataToSave)
        writefile(ConfigFolderName .. "/" .. name .. ".json", jsonData)
        SendNotification("Config Disimpan", "Berhasil menyimpan: " .. name, 4)
    end)
    if ConfigDropdownAPI then ConfigDropdownAPI:Refresh(GetSavedConfigs()) end
end

local function LoadConfig(name)
    if not isfile or not readfile then return end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    if not isfile(path) then return SendNotification("Gagal", "Config " .. name .. " tidak ditemukan.", 4) end
    
    pcall(function()
        local fileData = readfile(path)
        local data = HttpService:JSONDecode(fileData)
        for _, reg in pairs(UIRegistry) do
            if reg.texts and reg.texts.en and reg.setFunc then
                local savedState = data[reg.texts.en]
                if savedState ~= nil then
                    pcall(function() reg.setFunc(savedState) end)
                end
            end
        end
        SendNotification("Config Dimuat", "Berhasil meload pengaturan: " .. name, 4)
    end)
end

ConfigSec:AddInput({id = "Config Name", en = "Config Name"}, function(val)
    if val and val ~= "" then CurrentConfigName = val end
end)

ConfigDropdownAPI = ConfigSec:AddSingleDropdown({id = "Saved Configs", en = "Saved Configs"}, GetSavedConfigs(), function(opt)
    CurrentConfigName = opt
end)

local AutoLoadToggleAPI = ConfigSec:AddToggle({id = "Auto Load", en = "Auto Load"}, function(val)
    if writefile then
        pcall(function() writefile(ConfigFolderName .. "/autoload_enabled.txt", tostring(val)) end)
    end
end)

ConfigSec:AddButton({id = "Save", en = "Save"}, function()
    SaveConfig(CurrentConfigName)
end)

ConfigSec:AddButton({id = "Load Selected Config", en = "Load Selected Config"}, function()
    LoadConfig(CurrentConfigName)
end)

ConfigSec:AddButton({id = "Set as Auto Load", en = "Set as Auto Load"}, function()
    if writefile then
        pcall(function() writefile(ConfigFolderName .. "/autoload.txt", CurrentConfigName) end)
        pcall(function() writefile(ConfigFolderName .. "/autoload_enabled.txt", "true") end)
        if AutoLoadToggleAPI then pcall(function() AutoLoadToggleAPI.Set(true) end) end
        SendNotification("Auto Load Diatur", CurrentConfigName .. " akan dimuat otomatis saat join!", 4)
    end
end)

-- ==========================================
--  AUTO-DETECT ENGINE (HANYA KAELL STORE)
-- ==========================================
local GameID = game.PlaceId
local isKaellStore = false

pcall(function()
    local lowerName = string.lower(GameName)
    if string.find(lowerName, "grow a garden") or (ReplicatedStorage:FindFirstChild("SharedModules") and ReplicatedStorage.SharedModules:FindFirstChild("Networking")) then
        isKaellStore = true
    end
end)

-- ==========================================
--  GAME LOGIC: KAELL STORE (GROW A GARDEN)
-- ==========================================
local function LoadKaellStore()
    local SharedModules = ReplicatedStorage:WaitForChild("SharedModules", 5)
    if not SharedModules then return end
    
    local Networking = require(SharedModules:WaitForChild("Networking"))
    local PacketRemote = SharedModules:WaitForChild("Packet"):WaitForChild("RemoteEvent")

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local nativeTimer = "Wait (RNG)"
                for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Visible then
                        if string.match(v.Text, "%d+m %d+s") or string.match(v.Text, "%d+:%d+") then
                            nativeTimer = "In " .. v.Text
                            break
                        end
                    end
                end

                local w_str_tbl = {}
                for name, cardData in pairs(getgenv().WeatherCards) do
                    local isActive = false
                    
                    if name == "Night" then
                        local nv = ReplicatedStorage:FindFirstChild("Night")
                        if nv and nv:IsA("BoolValue") then isActive = nv.Value end
                        if not nv then isActive = (game.Lighting.ClockTime >= 18 or game.Lighting.ClockTime < 6) end
                    elseif name == "Bloodmoon" then
                        isActive = workspace:FindFirstChild("ActiveBloodmoon") ~= nil or workspace:FindFirstChild("BloodmoonBeams") ~= nil
                    elseif name == "Goldmoon" then
                        isActive = workspace:FindFirstChild("Goldmoon") ~= nil or workspace:FindFirstChild("GoldMeteor") ~= nil
                    elseif name == "Rainbowmoon" then
                        isActive = workspace:FindFirstChild("RainbowMoon") ~= nil or workspace:FindFirstChild("RainbowMeteor") ~= nil
                    elseif name == "Sunset" then
                        isActive = (game.Lighting.ClockTime >= 17.5 and game.Lighting.ClockTime < 18)
                    end

                    local icon = "🌙"
                    if name == "Bloodmoon" then icon = "🩸"
                    elseif name == "Goldmoon" then icon = "🌟"
                    elseif name == "Rainbowmoon" then icon = "🌈"
                    elseif name == "Sunset" then icon = "🌇" end

                    if isActive then
                        cardData.Label.Text       = "ACTIVE NOW!"
                        cardData.Label.TextColor3 = Color3.fromRGB(50, 255, 100)
                        cardData.Stroke.Color     = Color3.fromRGB(50, 255, 100)
                        table.insert(w_str_tbl, icon .. " **" .. name .. "** — `ACTIVE NOW`")
                    else
                        if name == "Night" or name == "Sunset" then
                            cardData.Label.Text = nativeTimer
                            table.insert(w_str_tbl, icon .. " **" .. name .. "** — `" .. nativeTimer .. "`")
                        else
                            cardData.Label.Text = "Wait (RNG)"
                            table.insert(w_str_tbl, icon .. " **" .. name .. "** — `Wait (RNG)`")
                        end
                        cardData.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                        cardData.Stroke.Color      = cardData.ConfigColor
                    end
                end
                _G.CurrentWeatherStr = table.concat(w_str_tbl, "\n")
            end)
        end
    end)


    local KODE_SEED  = 0x77
    local KODE_GEAR  = 0x7B
    local KODE_CRATE = 0x79
    local KODE_TANAM = 0x09

    local ListPets = {"All", "Raccoon", "Monkey", "Robin", "Frog", "Bunny", "Deer", "Owl", "Bee", "Unicorn", "Golden Dragonfly", "Black Dragon", "Ice Serpent"}
    local ListSeed = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Apple", "Bamboo", "Corn", "Cactus", "Pineapple", "Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango", "Dragon Fruit", "Acorn", "Cherry", "Sunflower", "Venus Fly Trap", "Pomegranate", "Poison Apple", "Moon Bloom", "Dragon's Breath", "Ghost Pepper", "Poison Ivy", "Baby Cactus", "Glow Mushroom", "Romanesco", "Horned Melon", "Gold", "Rainbow"}
    pcall(function()
        local sd = require(game:GetService("ReplicatedStorage").SharedModules.SeedData)
        local sdByName = {}
        for _, v in pairs(sd) do if type(v) == "table" and v.SeedName then sdByName[v.SeedName] = v end end
        table.sort(ListSeed, function(a, b)
            local orderA = (sdByName[a] and sdByName[a].SeedShopDisplayOrder) or 999999999
            local orderB = (sdByName[b] and sdByName[b].SeedShopDisplayOrder) or 999999999
            if orderA == orderB then 
                local pA = (sdByName[a] and sdByName[a].PurchasePrice) or 999999999
                local pB = (sdByName[b] and sdByName[b].PurchasePrice) or 999999999
                if pA == pB then return a < b end
                return pA < pB
            end
            return orderA < orderB
        end)
    end)
        local ListGear = {"Common Watering Can", "Common Sprinkler", "Sign", "Lantern", "Wheelbarrow", "Uncommon Sprinkler", "Rare Sprinkler", "Legendary Sprinkler", "Super Sprinkler", "Trowel", "Speed Mushroom", "Jump Mushroom", "Gnome", "Shrink Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Teleporter", "Super Watering Can", "Basic Pot", "Flashbang"}
    local ListCrate = {"Arch Crate", "Bear Trap Crate", "Bench Crate", "Bridge Crate", "Conveyor Crate", "Fence Crate", "Ladder Crate", "Light Crate", "Owner Door Crate", "Roleplay Crate", "Seesaw Crate", "Sign Crate", "Spring Crate", "Teleporter Pad Crate"}
    
    local ListPanenBuah = {"All"}
    for _, v in ipairs(ListSeed) do table.insert(ListPanenBuah, v) end
    local ListPanenMutasi = {"Any", "None"}
    pcall(function()
        local mutData = game:GetService("ReplicatedStorage").SharedModules.MutationData
        local muts = {}
        for _, child in ipairs(mutData:GetChildren()) do
            if child:IsA("ModuleScript") then table.insert(muts, child.Name) end
        end
        table.sort(muts)
        for _, m in ipairs(muts) do table.insert(ListPanenMutasi, m) end
    end)
    if #ListPanenMutasi <= 2 then ListPanenMutasi = {"Any", "None", "Gold", "Rainbow"} end
    local ListClaimDrop = {"All", "Items", "Seedpack", "Pet Items"}
    local ListSellMode = {"Sell All", "Daily Deal Only"}

    _G.TargetBuySeed = {}
    _G.TargetBuyGear = {}
    _G.TargetBuyCrate = {}
    _G.TargetPlantSeed = {}
    _G.TargetPanenBuah = {}
    _G.TargetPanenMutasi = {}
    _G.TargetClaim = {}
    _G.TargetPets = {}
    
    _G.TargetSellMode = "Sell All"
    _G.MaxKG = 0
    _G.ModeRandomPot = false 
    _G.CachedPots = {} 
    _G.ActionDelay = 0

    _G.AutoBuySeedAktif = false
    _G.AutoBuyGearAktif = false
    _G.AutoBuyCrateAktif = false
    _G.AutoPlantAktif = false
    _G.AutoHarvestAktif = false
    _G.AutoClaimAktif = false
    _G.AutoStealAktif = false
    _G.AutoSellAktif = false
    _G.AutoDailyDealAktif = false
    _G.AutoTameAktif = false
    _G.AutoServerHopPet = false
    _G.ServerHopDelay = 15
    _G.AutoJoinGlobalPet = false
    _G.ShareDataToGlobal = true 
    _G.AutoBrutalHarvest = false

    local shopSeedNames = {}
    pcall(function()
        local SeedData = require(game:GetService("ReplicatedStorage").SharedModules.SeedData)
        local sdByName = {}
        for _, v in pairs(SeedData) do
            if type(v) == "table" and v.SeedName then
                sdByName[v.SeedName] = v
                if v.RestockShop == true then table.insert(shopSeedNames, v.SeedName) end
            end
        end
        table.sort(shopSeedNames, function(a, b)
            local orderA = (sdByName[a] and sdByName[a].SeedShopDisplayOrder) or 999999999
            local orderB = (sdByName[b] and sdByName[b].SeedShopDisplayOrder) or 999999999
            if orderA == orderB then 
                local pA = (sdByName[a] and sdByName[a].PurchasePrice) or 999999999
                local pB = (sdByName[b] and sdByName[b].PurchasePrice) or 999999999
                if pA == pB then return a < b end
                return pA < pB
            end
            return orderA < orderB
        end)
    end)
    if #shopSeedNames == 0 then shopSeedNames = ListSeed end

    --  1. TAB MAIN (SEMUA FITUR JADI SATU DI SINI) 
    local PlantSec = MainTab:AddSection({id = "Auto Plant", en = "Auto Plant"}, false)
    PlantSec:AddSingleDropdown({id = "Pilih Bibit (Plant)", en = "Select Seed (Plant)"}, shopSeedNames, function(opt) _G.TargetPlantSeed = {opt} end)
    PlantSec:AddToggle({id = "Sniper Plant (Radar 200m)", en = "Sniper Plant (Radar Pot)"}, function(val) _G.ModeRandomPot = val end)
    PlantSec:AddInput({id = "Jeda Tanam (Detik)", en = "Plant Delay (Seconds)"}, function(val) _G.ActionDelay = tonumber(val) or 0 end)
    PlantSec:AddToggle({id = "Auto Plant Aktif", en = "Enable Auto Plant"}, function(val) _G.AutoPlantAktif = val end)

    local HarvestSec = MainTab:AddSection({id = "Auto Harvest", en = "Auto Harvest"}, false)
    HarvestSec:AddMultiDropdown({id = "Pilih Buah (Harvest)", en = "Select Fruit (Harvest)"}, ListPanenBuah, function(opts) _G.TargetPanenBuah = opts end)
    HarvestSec:AddMultiDropdown({id = "Pilih Mutasi (Harvest)", en = "Select Mutation (Harvest)"}, ListPanenMutasi, function(opts) _G.TargetPanenMutasi = opts end)
    HarvestSec:AddInput({id = "Minimum Ukuran (KG)", en = "Minimum Size (KG)"}, function(val) _G.MaxKG = tonumber(val) or 0 end)
    HarvestSec:AddToggle({id = "Auto Harvest Aktif", en = "Enable Auto Harvest"}, function(val) _G.AutoHarvestAktif = val end)

    local ClaimSec = MainTab:AddSection({id = "Ninja Claim Drops", en = "Ninja Claim Drops"}, false)
    ClaimSec:AddSingleDropdown({id = "Target Claim", en = "Target Claim"}, ListClaimDrop, function(val) _G.TargetClaim = {val} end)
    ClaimSec:AddToggle({id = "Auto Claim Aktif", en = "Auto Claim Drop Items"}, function(val) _G.AutoClaimAktif = val end)

    local StealSec = MainTab:AddSection({id = "Auto Steal", en = "Auto Steal"}, false)
    StealSec:AddToggle({id = "Auto Steal (Malam Hari)", en = "Auto Steal (Night Only)"}, function(val) _G.AutoStealAktif = val end)

    local SellSec = MainTab:AddSection({id = "Auto Sell", en = "Auto Sell"}, false)
    SellSec:AddSingleDropdown({id = "Mode Penjualan", en = "Sell Mode"}, ListSellMode, function(opt) _G.TargetSellMode = opt end)
    SellSec:AddToggle({id = "Auto Sell Aktif", en = "Enable Auto Sell"}, function(val) _G.AutoSellAktif = val end)
    SellSec:AddToggle({id = "Auto Daily Deal (x2)", en = "Auto Daily Deal (x2)"}, function(val) _G.AutoDailyDealAktif = val end)

    --  2. TAB SHOP 
    local function MutePurchaseSound() pcall(function() local s = game:GetService("SoundService"):FindFirstChild("Purchase", true); local f = game:GetService("SoundService"):FindFirstChild("Failed", true); local m = (_G.AutoBuySeedAktif or _G.AutoBuyGearAktif or _G.AutoBuyCrateAktif) and 0 or 0.5; if s then s.Volume = m end; if f then f.Volume = m end end) end

    local SeedShopSec = ShopTab:AddSection({id = "Seed Shop", en = "Seed Shop"}, false)
    SeedShopSec:AddMultiDropdown({id = "Pilih Bibit", en = "Select Seeds"}, shopSeedNames, function(opts) _G.TargetBuySeed = opts end)
    SeedShopSec:AddToggle({id = "Auto Buy Seeds Aktif", en = "Auto Buy Seeds"}, function(val) _G.AutoBuySeedAktif = val; MutePurchaseSound() end)
    
    local GearShopSec = ShopTab:AddSection({id = "Gear Shop", en = "Gear Shop"}, false)
    GearShopSec:AddMultiDropdown({id = "Pilih Alat", en = "Select Gears"}, ListGear, function(opts) _G.TargetBuyGear = opts end)
    GearShopSec:AddToggle({id = "Auto Buy Gears Aktif", en = "Auto Buy Gears"}, function(val) _G.AutoBuyGearAktif = val; MutePurchaseSound() end)

    local PropShopSec = ShopTab:AddSection({id = "Prop/Crate Shop", en = "Prop/Crate Shop"}, false)
    PropShopSec:AddMultiDropdown({id = "Pilih Properti", en = "Select Crates"}, ListCrate, function(opts) _G.TargetBuyCrate = opts end)
    PropShopSec:AddToggle({id = "Auto Buy Crates Aktif", en = "Auto Buy Crates"}, function(val) _G.AutoBuyCrateAktif = val; MutePurchaseSound() end)

    local WeatherSec = PremiumTab:AddSection({id = "Weather Forecast", en = "Weather Forecast"}, false)

    -- Build Weather Forecast floating UI
    if CoreGui:FindFirstChild("KellyzWeatherForecastUI") then CoreGui.KellyzWeatherForecastUI:Destroy() end
    local WF_UI = Instance.new("ScreenGui"); WF_UI.Name = "KellyzWeatherForecastUI"; WF_UI.Enabled = false; WF_UI.Parent = CoreGui
    local WF_Main = Instance.new("Frame"); WF_Main.Size = UDim2.new(0, 340, 0, 380); WF_Main.Position = UDim2.new(0, 680, 0.5, -190); WF_Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); WF_Main.BackgroundTransparency = 0.05; WF_Main.Active = true; WF_Main.Draggable = true; WF_Main.Parent = WF_UI
    Instance.new("UICorner", WF_Main).CornerRadius = UDim.new(0, 10)
    local WF_Stroke = Instance.new("UIStroke", WF_Main); WF_Stroke.Color = Color3.fromRGB(100, 150, 255); WF_Stroke.Thickness = 1.5

    -- Header
    local WF_Header = Instance.new("Frame"); WF_Header.Size = UDim2.new(1, 0, 0, 45); WF_Header.BackgroundTransparency = 1; WF_Header.Parent = WF_Main
    local WF_Icon = Instance.new("TextLabel"); WF_Icon.Size = UDim2.new(0, 30, 0, 30); WF_Icon.Position = UDim2.new(0, 12, 0, 8); WF_Icon.BackgroundTransparency = 1; WF_Icon.Text = "🌙"; WF_Icon.TextSize = 20; WF_Icon.Parent = WF_Header
    local WF_Title = Instance.new("TextLabel"); WF_Title.Size = UDim2.new(0.7, 0, 1, 0); WF_Title.Position = UDim2.new(0, 45, 0, 0); WF_Title.BackgroundTransparency = 1; WF_Title.Text = "KELLYZ WEATHER FORECAST"; WF_Title.TextColor3 = Color3.fromRGB(200, 220, 255); WF_Title.Font = Enum.Font.GothamBlack; WF_Title.TextSize = 13; WF_Title.TextXAlignment = Enum.TextXAlignment.Left; WF_Title.Parent = WF_Header
    local WF_Close = Instance.new("TextButton"); WF_Close.Size = UDim2.new(0, 30, 0, 30); WF_Close.Position = UDim2.new(1, -38, 0, 8); WF_Close.BackgroundTransparency = 1; WF_Close.Text = "X"; WF_Close.TextColor3 = Color3.fromRGB(255, 80, 80); WF_Close.Font = Enum.Font.GothamBold; WF_Close.TextSize = 16; WF_Close.Parent = WF_Header
    WF_Close.MouseButton1Click:Connect(function() WF_UI.Enabled = false end)

    local WF_Div1 = Instance.new("Frame"); WF_Div1.Size = UDim2.new(1, -24, 0, 1); WF_Div1.Position = UDim2.new(0, 12, 0, 45); WF_Div1.BackgroundColor3 = Color3.fromRGB(50, 50, 80); WF_Div1.BorderSizePixel = 0; WF_Div1.Parent = WF_Main

    -- Current status
    local WF_CurrentPhase = Instance.new("TextLabel"); WF_CurrentPhase.Size = UDim2.new(1, -24, 0, 22); WF_CurrentPhase.Position = UDim2.new(0, 12, 0, 50); WF_CurrentPhase.BackgroundTransparency = 1; WF_CurrentPhase.Text = "CURRENT: Day"; WF_CurrentPhase.TextColor3 = Color3.fromRGB(255, 255, 100); WF_CurrentPhase.Font = Enum.Font.GothamBlack; WF_CurrentPhase.TextSize = 14; WF_CurrentPhase.TextXAlignment = Enum.TextXAlignment.Left; WF_CurrentPhase.Parent = WF_Main

    local WF_ActiveWeather = Instance.new("TextLabel"); WF_ActiveWeather.Size = UDim2.new(1, -24, 0, 18); WF_ActiveWeather.Position = UDim2.new(0, 12, 0, 72); WF_ActiveWeather.BackgroundTransparency = 1; WF_ActiveWeather.Text = ""; WF_ActiveWeather.TextColor3 = Color3.fromRGB(100, 255, 200); WF_ActiveWeather.Font = Enum.Font.GothamBold; WF_ActiveWeather.TextSize = 11; WF_ActiveWeather.TextXAlignment = Enum.TextXAlignment.Left; WF_ActiveWeather.Parent = WF_Main

    local WF_Countdown = Instance.new("TextLabel"); WF_Countdown.Size = UDim2.new(1, -24, 0, 22); WF_Countdown.Position = UDim2.new(0, 12, 0, 92); WF_Countdown.BackgroundTransparency = 1; WF_Countdown.Text = "NEXT NIGHT IN 00:00"; WF_Countdown.TextColor3 = Color3.fromRGB(150, 200, 255); WF_Countdown.Font = Enum.Font.GothamBlack; WF_Countdown.TextSize = 13; WF_Countdown.TextXAlignment = Enum.TextXAlignment.Left; WF_Countdown.Parent = WF_Main

    local WF_Div2 = Instance.new("Frame"); WF_Div2.Size = UDim2.new(1, -24, 0, 1); WF_Div2.Position = UDim2.new(0, 12, 0, 118); WF_Div2.BackgroundColor3 = Color3.fromRGB(50, 50, 80); WF_Div2.BorderSizePixel = 0; WF_Div2.Parent = WF_Main

    local WF_PredTitle = Instance.new("TextLabel"); WF_PredTitle.Size = UDim2.new(1, -24, 0, 20); WF_PredTitle.Position = UDim2.new(0, 12, 0, 122); WF_PredTitle.BackgroundTransparency = 1; WF_PredTitle.Text = "MOON PREDICTION (Exact RNG):"; WF_PredTitle.TextColor3 = Color3.fromRGB(200, 200, 255); WF_PredTitle.Font = Enum.Font.GothamBold; WF_PredTitle.TextSize = 11; WF_PredTitle.TextXAlignment = Enum.TextXAlignment.Left; WF_PredTitle.Parent = WF_Main

    local WF_Scroll = Instance.new("ScrollingFrame"); WF_Scroll.Size = UDim2.new(1, -24, 0, 230); WF_Scroll.Position = UDim2.new(0, 12, 0, 144); WF_Scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 28); WF_Scroll.BackgroundTransparency = 0.3; WF_Scroll.ScrollBarThickness = 3; WF_Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255); WF_Scroll.BorderSizePixel = 0; WF_Scroll.Parent = WF_Main
    Instance.new("UICorner", WF_Scroll).CornerRadius = UDim.new(0, 6)
    local WF_Layout = Instance.new("UIListLayout", WF_Scroll); WF_Layout.SortOrder = Enum.SortOrder.LayoutOrder; WF_Layout.Padding = UDim.new(0, 4)
    WF_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() WF_Scroll.CanvasSize = UDim2.new(0, 0, 0, WF_Layout.AbsoluteContentSize.Y + 5) end)

    WeatherSec:AddToggle({id = "Tampilkan UI Cuaca (Floating)", en = "Show Weather Forecast UI"}, function(val)
        WF_UI.Enabled = val
        if CoreGui:FindFirstChild("KellyzWeatherUI") then CoreGui.KellyzWeatherUI.Enabled = val end
    end)

    task.spawn(function()
        -- TimeCycleData: Day=450s(Order1), Sunset=30s(Order2), Night=120s(Order3) = 600s total
        -- Night Weathers: Moon=79, Goldmoon=13, Rainbow Moon=6, Bloodmoon=2
        -- RNG: Random.new(cycleCount * 1000 + phaseIndex)
        local CYCLE_TOTAL = 600
        local DAY_DURATION = 450
        local SUNSET_DURATION = 30
        local NIGHT_DURATION = 120
        local NIGHT_WEATHERS = {
            {name = "Moon", chance = 79, color = Color3.fromRGB(180, 180, 220), icon = "🌑"},
            {name = "Goldmoon", chance = 13, color = Color3.fromRGB(255, 215, 0), icon = "🌕"},
            {name = "Rainbow Moon", chance = 6, color = Color3.fromRGB(255, 100, 255), icon = "🌈"},
            {name = "Bloodmoon", chance = 2, color = Color3.fromRGB(255, 50, 50), icon = "🩸"},
        }

        local function predictMoonType(cycleNumber)
            local rng = Random.new(cycleNumber * 1000 + 3) -- phaseIndex 3 = Night
            local totalChance = 0
            for _, w in ipairs(NIGHT_WEATHERS) do totalChance = totalChance + w.chance end
            local roll = rng:NextNumber() * totalChance
            local accumulated = 0
            for _, w in ipairs(NIGHT_WEATHERS) do
                accumulated = accumulated + w.chance
                if roll <= accumulated then return w end
            end
            return NIGHT_WEATHERS[1]
        end

        local WV = ReplicatedStorage:FindFirstChild("WeatherValues")

        while task.wait(0.5) do
            if WF_UI.Enabled then
                pcall(function()
                    local cycleOffset = workspace:GetAttribute("CycleOffset") or 0
                    local now = os.time() + cycleOffset
                    local cycleNumber = math.floor(now / CYCLE_TOTAL)
                    local elapsed = now % CYCLE_TOTAL

                    -- Determine current phase
                    local phase, phaseRemaining
                    if elapsed < DAY_DURATION then
                        phase = "Day"
                        phaseRemaining = DAY_DURATION - elapsed
                    elseif elapsed < (DAY_DURATION + SUNSET_DURATION) then
                        phase = "Sunset"
                        phaseRemaining = (DAY_DURATION + SUNSET_DURATION) - elapsed
                    else
                        phase = "Night"
                        phaseRemaining = CYCLE_TOTAL - elapsed
                    end

                    -- Current weather from workspace
                    local activeWeather = workspace:GetAttribute("ActiveWeather") or phase
                    local phaseColor = Color3.fromRGB(255, 255, 100)
                    if phase == "Night" then phaseColor = Color3.fromRGB(100, 150, 255)
                    elseif phase == "Sunset" then phaseColor = Color3.fromRGB(255, 150, 50) end

                    WF_CurrentPhase.Text = "CURRENT: " .. activeWeather .. " (" .. phase .. ")"
                    WF_CurrentPhase.TextColor3 = phaseColor

                    -- Active weathers from WeatherValues
                    local activeWeathers = {}
                    if WV then
                        for _, attr in ipairs({"Rain", "Lightning", "Rainbow", "Snowfall", "Starfall", "Aurora"}) do
                            if WV:GetAttribute(attr .. "_Playing") then
                                local endT = WV:GetAttribute(attr .. "_EndTime") or 0
                                local rem = math.max(0, endT - os.time())
                                table.insert(activeWeathers, attr .. " (" .. math.floor(rem) .. "s)")
                            end
                        end
                    end
                    if #activeWeathers > 0 then
                        WF_ActiveWeather.Text = "⛅ Active: " .. table.concat(activeWeathers, ", ")
                    else
                        WF_ActiveWeather.Text = "⛅ No weather effects active"
                    end

                    -- Countdown to next night
                    local timeToNight
                    if phase == "Day" then
                        timeToNight = phaseRemaining + SUNSET_DURATION
                    elseif phase == "Sunset" then
                        timeToNight = phaseRemaining
                    else
                        timeToNight = phaseRemaining + DAY_DURATION + SUNSET_DURATION
                    end
                    local ntMin = math.floor(timeToNight / 60)
                    local ntSec = timeToNight % 60
                    
                    if phase == "Night" then
                        WF_Countdown.Text = string.format("🌙 NIGHT ACTIVE! Ends in %02d:%02d", math.floor(phaseRemaining/60), phaseRemaining%60)
                        WF_Countdown.TextColor3 = Color3.fromRGB(100, 255, 150)
                    else
                        WF_Countdown.Text = string.format("NEXT NIGHT IN %02d:%02d", ntMin, ntSec)
                        WF_Countdown.TextColor3 = Color3.fromRGB(150, 200, 255)
                    end

                    -- Predict next 8 moon types
                    for _, v in pairs(WF_Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

                    local startCycle = cycleNumber
                    if phase == "Night" then startCycle = startCycle + 1 end

                    for i = 0, 7 do
                        local targetCycle = startCycle + i
                        local prediction = predictMoonType(targetCycle)
                        local cyclesAway = targetCycle - cycleNumber
                        local timeAway = cyclesAway * CYCLE_TOTAL - elapsed
                        if phase == "Night" then timeAway = timeAway + (CYCLE_TOTAL - elapsed) end
                        timeAway = math.max(0, cyclesAway * CYCLE_TOTAL + (DAY_DURATION + SUNSET_DURATION) - elapsed)

                        local tMin = math.floor(timeAway / 60)
                        local tSec = timeAway % 60

                        local card = Instance.new("Frame")
                        card.Size = UDim2.new(1, -6, 0, 38)
                        card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                        card.LayoutOrder = i
                        card.Parent = WF_Scroll
                        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
                        local cardStroke = Instance.new("UIStroke", card)
                        cardStroke.Color = prediction.color
                        cardStroke.Thickness = 1
                        cardStroke.Transparency = 0.5

                        local prefix = (i == 0) and "NEXT" or ("+" .. cyclesAway)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, -10, 1, 0)
                        lbl.Position = UDim2.new(0, 10, 0, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.RichText = true
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12
                        lbl.Parent = card

                        local timeStr = string.format("%dm %ds", tMin, tSec)
                        local hexColor = string.format("#%02X%02X%02X", math.floor(prediction.color.R*255), math.floor(prediction.color.G*255), math.floor(prediction.color.B*255))
                        lbl.Text = string.format('%s  <font color="%s">%s %s</font>  <font color="#888888">| in %s</font>', prediction.icon, hexColor, prefix, prediction.name, timeStr)
                        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end)
            end
        end
    end)

    -- ==========================================
    --  SEED PREDICTOR
    -- ==========================================
    _G.SeedPredictorTarget = "Dragon's Breath"

    -- Build Seed Predictor floating UI
    if CoreGui:FindFirstChild("KellyzSeedPredictorUI") then CoreGui.KellyzSeedPredictorUI:Destroy() end
    local SP_UI = Instance.new("ScreenGui"); SP_UI.Name = "KellyzSeedPredictorUI"; SP_UI.Enabled = false; SP_UI.Parent = CoreGui
    local SP_Main = Instance.new("Frame"); SP_Main.Size = UDim2.new(0, 320, 0, 400); SP_Main.Position = UDim2.new(0, 20, 0.5, -200); SP_Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); SP_Main.BackgroundTransparency = 0.05; SP_Main.Active = true; SP_Main.Draggable = true; SP_Main.Parent = SP_UI
    Instance.new("UICorner", SP_Main).CornerRadius = UDim.new(0, 10)
    local SP_Stroke = Instance.new("UIStroke", SP_Main); SP_Stroke.Color = Color3.fromRGB(80, 100, 255); SP_Stroke.Thickness = 1.5

    -- Header
    local SP_Header = Instance.new("Frame"); SP_Header.Size = UDim2.new(1, 0, 0, 45); SP_Header.BackgroundTransparency = 1; SP_Header.Parent = SP_Main
    local SP_Icon = Instance.new("TextLabel"); SP_Icon.Size = UDim2.new(0, 30, 0, 30); SP_Icon.Position = UDim2.new(0, 12, 0, 8); SP_Icon.BackgroundTransparency = 1; SP_Icon.Text = "🌱"; SP_Icon.TextSize = 20; SP_Icon.Parent = SP_Header
    local SP_Title = Instance.new("TextLabel"); SP_Title.Size = UDim2.new(0.7, 0, 1, 0); SP_Title.Position = UDim2.new(0, 45, 0, 0); SP_Title.BackgroundTransparency = 1; SP_Title.Text = "KELLYZ SEED PREDICTOR"; SP_Title.TextColor3 = Color3.fromRGB(220, 220, 255); SP_Title.Font = Enum.Font.GothamBlack; SP_Title.TextSize = 14; SP_Title.TextXAlignment = Enum.TextXAlignment.Left; SP_Title.Parent = SP_Header
    local SP_Close = Instance.new("TextButton"); SP_Close.Size = UDim2.new(0, 30, 0, 30); SP_Close.Position = UDim2.new(1, -38, 0, 8); SP_Close.BackgroundTransparency = 1; SP_Close.Text = "X"; SP_Close.TextColor3 = Color3.fromRGB(255, 80, 80); SP_Close.Font = Enum.Font.GothamBold; SP_Close.TextSize = 16; SP_Close.Parent = SP_Header
    SP_Close.MouseButton1Click:Connect(function() SP_UI.Enabled = false end)

    -- Divider
    local SP_Div1 = Instance.new("Frame"); SP_Div1.Size = UDim2.new(1, -24, 0, 1); SP_Div1.Position = UDim2.new(0, 12, 0, 45); SP_Div1.BackgroundColor3 = Color3.fromRGB(50, 50, 80); SP_Div1.BorderSizePixel = 0; SP_Div1.Parent = SP_Main

    -- Countdown label
    local SP_Countdown = Instance.new("TextLabel"); SP_Countdown.Size = UDim2.new(1, -24, 0, 30); SP_Countdown.Position = UDim2.new(0, 12, 0, 50); SP_Countdown.BackgroundTransparency = 1; SP_Countdown.Text = "NEXT RESTOCK IN 00:00"; SP_Countdown.TextColor3 = Color3.fromRGB(50, 255, 150); SP_Countdown.Font = Enum.Font.GothamBlack; SP_Countdown.TextSize = 16; SP_Countdown.TextXAlignment = Enum.TextXAlignment.Left; SP_Countdown.Parent = SP_Main

    -- Stock scroll area
    local SP_StockTitle = Instance.new("TextLabel"); SP_StockTitle.Size = UDim2.new(1, -24, 0, 20); SP_StockTitle.Position = UDim2.new(0, 12, 0, 82); SP_StockTitle.BackgroundTransparency = 1; SP_StockTitle.Text = "CURRENT STOCK:"; SP_StockTitle.TextColor3 = Color3.fromRGB(150, 150, 200); SP_StockTitle.Font = Enum.Font.GothamBold; SP_StockTitle.TextSize = 11; SP_StockTitle.TextXAlignment = Enum.TextXAlignment.Left; SP_StockTitle.Parent = SP_Main

    local SP_Scroll = Instance.new("ScrollingFrame"); SP_Scroll.Size = UDim2.new(1, -24, 0, 170); SP_Scroll.Position = UDim2.new(0, 12, 0, 104); SP_Scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 28); SP_Scroll.BackgroundTransparency = 0.3; SP_Scroll.ScrollBarThickness = 3; SP_Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 100, 255); SP_Scroll.BorderSizePixel = 0; SP_Scroll.Parent = SP_Main
    Instance.new("UICorner", SP_Scroll).CornerRadius = UDim.new(0, 6)
    local SP_Layout = Instance.new("UIListLayout", SP_Scroll); SP_Layout.SortOrder = Enum.SortOrder.LayoutOrder; SP_Layout.Padding = UDim.new(0, 2)
    SP_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SP_Scroll.CanvasSize = UDim2.new(0, 0, 0, SP_Layout.AbsoluteContentSize.Y + 5) end)

    -- Divider 2
    local SP_Div2 = Instance.new("Frame"); SP_Div2.Size = UDim2.new(1, -24, 0, 1); SP_Div2.Position = UDim2.new(0, 12, 0, 280); SP_Div2.BackgroundColor3 = Color3.fromRGB(50, 50, 80); SP_Div2.BorderSizePixel = 0; SP_Div2.Parent = SP_Main

    -- Target tracker area
    local SP_TargetBg = Instance.new("Frame"); SP_TargetBg.Size = UDim2.new(1, -24, 0, 80); SP_TargetBg.Position = UDim2.new(0, 12, 0, 288); SP_TargetBg.BackgroundColor3 = Color3.fromRGB(20, 10, 10); SP_TargetBg.BorderSizePixel = 0; SP_TargetBg.Parent = SP_Main
    Instance.new("UICorner", SP_TargetBg).CornerRadius = UDim.new(0, 6)
    local SP_TargetStroke = Instance.new("UIStroke", SP_TargetBg); SP_TargetStroke.Color = Color3.fromRGB(255, 60, 60); SP_TargetStroke.Thickness = 1

    local SP_TargetIcon = Instance.new("TextLabel"); SP_TargetIcon.Size = UDim2.new(0, 25, 0, 25); SP_TargetIcon.Position = UDim2.new(0, 10, 0, 8); SP_TargetIcon.BackgroundTransparency = 1; SP_TargetIcon.Text = "🎯"; SP_TargetIcon.TextSize = 16; SP_TargetIcon.Parent = SP_TargetBg
    local SP_TargetLabel = Instance.new("TextLabel"); SP_TargetLabel.Name = "TargetLabel"; SP_TargetLabel.Size = UDim2.new(1, -45, 0, 20); SP_TargetLabel.Position = UDim2.new(0, 38, 0, 8); SP_TargetLabel.BackgroundTransparency = 1; SP_TargetLabel.Text = "TARGET TRACKER: Dragon's Breath"; SP_TargetLabel.TextColor3 = Color3.fromRGB(255, 100, 100); SP_TargetLabel.Font = Enum.Font.GothamBlack; SP_TargetLabel.TextSize = 12; SP_TargetLabel.TextXAlignment = Enum.TextXAlignment.Left; SP_TargetLabel.Parent = SP_TargetBg
    local SP_TargetEst = Instance.new("TextLabel"); SP_TargetEst.Name = "TargetEst"; SP_TargetEst.Size = UDim2.new(1, -20, 0, 40); SP_TargetEst.Position = UDim2.new(0, 10, 0, 32); SP_TargetEst.BackgroundTransparency = 1; SP_TargetEst.Text = "Menghitung..."; SP_TargetEst.TextColor3 = Color3.fromRGB(200, 200, 200); SP_TargetEst.Font = Enum.Font.Gotham; SP_TargetEst.TextSize = 11; SP_TargetEst.TextXAlignment = Enum.TextXAlignment.Left; SP_TargetEst.TextWrapped = true; SP_TargetEst.Parent = SP_TargetBg

    -- Seed Predictor Tab controls
    local SeedPredSec = PremiumTab:AddSection({id = "Seed Predictor", en = "Seed Predictor"}, false)

    SeedPredSec:AddToggle({id = "Tampilkan UI Seed Predictor", en = "Show Predict UI"}, function(val)
        SP_UI.Enabled = val
    end)
    SeedPredSec:AddSingleDropdown({id = "Pilih Target Bibit", en = "Select Seed to Track"}, shopSeedNames, function(val)
        _G.SeedPredictorTarget = val
    end)

    -- Predictor update loop
    task.spawn(function()
        local RS = game:GetService("ReplicatedStorage")
        local SeedData = nil
        pcall(function() SeedData = require(RS.SharedModules.SeedData) end)

        -- Build lookup: seedName -> RestockChance
        local seedChances = {}
        local seedRarities = {}
        local rarityColors = {
            Common = Color3.fromRGB(200, 200, 200),
            Uncommon = Color3.fromRGB(80, 210, 80),
            Rare = Color3.fromRGB(80, 180, 255),
            Epic = Color3.fromRGB(180, 80, 255),
            Legendary = Color3.fromRGB(255, 200, 50),
            Mythic = Color3.fromRGB(255, 80, 80),
            Super = Color3.fromRGB(255, 50, 200)
        }
        if SeedData then
            for _, v in pairs(SeedData) do
                if type(v) == "table" and v.SeedName then
                    seedChances[v.SeedName] = v.RestockChance or 0
                    seedRarities[v.SeedName] = v.Rarity or "Common"
                end
            end
        end

        while task.wait(1) do
            if SP_UI.Enabled then
                pcall(function()
                    -- Update countdown
                    local nextRestock = RS.StockValues.SeedShop.UnixNextRestock.Value
                    local now = os.time()
                    local remaining = math.max(0, nextRestock - now)
                    local mins = math.floor(remaining / 60)
                    local secs = remaining % 60
                    SP_Countdown.Text = string.format("NEXT RESTOCK IN %02d:%02d", mins, secs)
                    if remaining <= 30 then SP_Countdown.TextColor3 = Color3.fromRGB(255, 80, 80)
                    elseif remaining <= 60 then SP_Countdown.TextColor3 = Color3.fromRGB(255, 200, 50)
                    else SP_Countdown.TextColor3 = Color3.fromRGB(50, 255, 150) end

                    -- Update current stock
                    local seedShopItems = RS.StockValues.SeedShop:FindFirstChild("Items")
                    if seedShopItems then
                        -- Clear old entries
                        for _, v in pairs(SP_Scroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end

                        local entries = {}
                        for _, item in ipairs(seedShopItems:GetChildren()) do
                            if item:IsA("NumberValue") and item.Value > 0 then
                                table.insert(entries, {name = item.Name, qty = item.Value, chance = seedChances[item.Name] or 0})
                            end
                        end
                        table.sort(entries, function(a, b) return a.chance > b.chance end)

                        if #entries > 0 then
                            for i, entry in ipairs(entries) do
                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.new(1, -10, 0, 18)
                                lbl.BackgroundTransparency = 1
                                lbl.Text = "  • " .. entry.name .. " x" .. tostring(entry.qty)
                                lbl.TextColor3 = rarityColors[seedRarities[entry.name] or "Common"] or Color3.fromRGB(200, 200, 200)
                                lbl.Font = Enum.Font.Gotham
                                lbl.TextSize = 12
                                lbl.TextXAlignment = Enum.TextXAlignment.Left
                                lbl.LayoutOrder = i
                                lbl.Parent = SP_Scroll
                            end
                        else
                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, -10, 0, 18)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = "  Stok habis! Tunggu restock..."
                            lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 11
                            lbl.Parent = SP_Scroll
                        end
                    end

                    -- Update target tracker
                    local target = _G.SeedPredictorTarget or "Dragon's Breath"
                    if type(target) == "table" then target = target[1] or "Dragon's Breath" end
                    SP_TargetLabel.Text = "TARGET TRACKER: " .. tostring(target)
                    local chance = seedChances[target] or 0
                    
                    if chance > 0 then
                        -- exact RNG prediction logic
                        local baseCycle = math.floor(RS.StockValues.SeedShop.UnixNextRestock.Value / 300)
                        local restockShopSeeds = {}
                        for _, v in pairs(SeedData or {}) do
                            if type(v) == "table" and v.RestockShop and v.SeedName then
                                table.insert(restockShopSeeds, {name=v.SeedName, chance=v.RestockChance})
                            end
                        end
                        table.sort(restockShopSeeds, function(a, b) return a.chance > b.chance end)

                        local currentSeed = 0
                        for i = -150, 150 do
                            local s = baseCycle + i
                            local rng = Random.new(s)
                            local gen = {}
                            for _, sd in ipairs(restockShopSeeds) do
                                if (rng:NextNumber() * 100) <= sd.chance then gen[sd.name] = 1 end
                            end
                            local match = true
                            for k, _ in pairs(seedShopItems and seedShopItems:GetChildren() or {}) do
                                if _.Value > 0 and not gen[_.Name] then match = false; break end
                            end
                            for k, _ in pairs(gen) do
                                if not (seedShopItems and seedShopItems:FindFirstChild(k) and seedShopItems[k].Value > 0) then match = false; break end
                            end
                            if match then currentSeed = s; break end
                        end

                        local exactCycles = 0
                        if currentSeed ~= 0 then
                            for searchCycle = currentSeed + 1, currentSeed + 10000 do
                                local rng = Random.new(searchCycle)
                                local found = false
                                for _, sd in ipairs(restockShopSeeds) do
                                    local roll = rng:NextNumber() * 100
                                    if sd.name == target then
                                        if roll <= sd.chance then found = true end
                                    end
                                end
                                if found then exactCycles = searchCycle - currentSeed; break end
                            end
                        end

                        if currentSeed ~= 0 and exactCycles > 0 then
                            local cycleSec = 300 -- 5 minutes per cycle
                            local totalSec = exactCycles * cycleSec
                            local hours = math.floor(totalSec / 3600)
                            local minutes = math.floor((totalSec % 3600) / 60)

                            -- Check if it's currently in stock
                            local inStock = false
                            if seedShopItems and seedShopItems:FindFirstChild(target) then
                                inStock = seedShopItems[target].Value > 0
                            end

                            if inStock then
                                SP_TargetEst.Text = "🟢 ADA DI SHOP SEKARANG! Cepat beli!"
                                SP_TargetEst.TextColor3 = Color3.fromRGB(50, 255, 100)
                                SP_TargetStroke.Color = Color3.fromRGB(50, 255, 100)
                                _G.CurrentSeedPredictorStr = "🟢 **" .. target .. "** — `ADA DI SHOP!`"
                            else
                                SP_TargetEst.Text = string.format("Muncul dlm %d siklus (%d jam, %d menit)\nExact RNG Prediction", exactCycles, hours, minutes)
                                SP_TargetEst.TextColor3 = Color3.fromRGB(200, 200, 200)
                                SP_TargetStroke.Color = Color3.fromRGB(255, 60, 60)
                                _G.CurrentSeedPredictorStr = string.format("⏳ **%s** — `In %d cycles` (%dh %dm)\n└ *Exact RNG Prediction*", target, exactCycles, hours, minutes)
                            end
                        else
                            -- fallback to estimation if RNG seed crack fails
                            local expectedCycles = math.ceil(100 / chance)
                            local cycleSec = 300
                            local totalSec = expectedCycles * cycleSec
                            local hours = math.floor(totalSec / 3600)
                            local minutes = math.floor((totalSec % 3600) / 60)
                            
                            local inStock = false
                            if seedShopItems and seedShopItems:FindFirstChild(target) then
                                inStock = seedShopItems[target].Value > 0
                            end

                            if inStock then
                                SP_TargetEst.Text = "🟢 ADA DI SHOP SEKARANG! Cepat beli!"
                                SP_TargetEst.TextColor3 = Color3.fromRGB(50, 255, 100)
                                SP_TargetStroke.Color = Color3.fromRGB(50, 255, 100)
                                _G.CurrentSeedPredictorStr = "🟢 **" .. target .. "** — `ADA DI SHOP!`"
                            else
                                SP_TargetEst.Text = string.format("Estimasi muncul dlm ~%d siklus (%d jam, %d menit)\nChance per restock: %.3f%%", expectedCycles, hours, minutes, chance)
                                SP_TargetEst.TextColor3 = Color3.fromRGB(200, 200, 200)
                                SP_TargetStroke.Color = Color3.fromRGB(255, 60, 60)
                                _G.CurrentSeedPredictorStr = string.format("⏳ **%s** — `~%d cycles` (%dh %dm)\n└ *Estimasi Chance %.2f%%*", target, expectedCycles, hours, minutes, chance)
                            end
                        end             else
                        SP_TargetEst.Text = "Seed ini tidak tersedia di shop restock."
                        SP_TargetEst.TextColor3 = Color3.fromRGB(150, 150, 150)
                        _G.CurrentSeedPredictorStr = "❌ **" .. target .. "** — `Tdk Tersedia`"
                    end
                end)
            end
        end
    end)

    -- ==========================================


    -- ==========================================
    --  FRUIT PRICE FORECAST (FLOATING UI)
    -- ==========================================
    local FruitPredSec = PremiumTab:AddSection({id = "Fruit Price Forecast", en = "Fruit Price Forecast"}, false)
    
    if CoreGui:FindFirstChild("KellyzFruitForecastUI") then CoreGui.KellyzFruitForecastUI:Destroy() end
    local FF_UI = Instance.new("ScreenGui"); FF_UI.Name = "KellyzFruitForecastUI"; FF_UI.Enabled = false; FF_UI.Parent = CoreGui
    local FF_Main = Instance.new("Frame"); FF_Main.Size = UDim2.new(0, 320, 0, 300); FF_Main.Position = UDim2.new(0, 350, 0.5, -150); FF_Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); FF_Main.BackgroundTransparency = 0.05; FF_Main.Active = true; FF_Main.Draggable = true; FF_Main.Parent = FF_UI
    Instance.new("UICorner", FF_Main).CornerRadius = UDim.new(0, 10)
    local FF_Stroke = Instance.new("UIStroke", FF_Main); FF_Stroke.Color = Color3.fromRGB(80, 255, 150); FF_Stroke.Thickness = 1.5

    -- Header
    local FF_Header = Instance.new("Frame"); FF_Header.Size = UDim2.new(1, 0, 0, 45); FF_Header.BackgroundTransparency = 1; FF_Header.Parent = FF_Main
    local FF_Icon = Instance.new("TextLabel"); FF_Icon.Size = UDim2.new(0, 30, 0, 30); FF_Icon.Position = UDim2.new(0, 12, 0, 8); FF_Icon.BackgroundTransparency = 1; FF_Icon.Text = "🔮"; FF_Icon.TextSize = 20; FF_Icon.Parent = FF_Header
    local FF_Title = Instance.new("TextLabel"); FF_Title.Size = UDim2.new(0.7, 0, 1, 0); FF_Title.Position = UDim2.new(0, 45, 0, 0); FF_Title.BackgroundTransparency = 1; FF_Title.Text = "KELLYZ FRUIT FORECAST"; FF_Title.TextColor3 = Color3.fromRGB(220, 255, 220); FF_Title.Font = Enum.Font.GothamBlack; FF_Title.TextSize = 14; FF_Title.TextXAlignment = Enum.TextXAlignment.Left; FF_Title.Parent = FF_Header
    local FF_Close = Instance.new("TextButton"); FF_Close.Size = UDim2.new(0, 30, 0, 30); FF_Close.Position = UDim2.new(1, -38, 0, 8); FF_Close.BackgroundTransparency = 1; FF_Close.Text = "X"; FF_Close.TextColor3 = Color3.fromRGB(255, 80, 80); FF_Close.Font = Enum.Font.GothamBold; FF_Close.TextSize = 16; FF_Close.Parent = FF_Header
    FF_Close.MouseButton1Click:Connect(function() FF_UI.Enabled = false end)

    -- Divider
    local FF_Div1 = Instance.new("Frame"); FF_Div1.Size = UDim2.new(1, -24, 0, 1); FF_Div1.Position = UDim2.new(0, 12, 0, 45); FF_Div1.BackgroundColor3 = Color3.fromRGB(50, 80, 50); FF_Div1.BorderSizePixel = 0; FF_Div1.Parent = FF_Main

    -- Countdown label
    local FF_Countdown = Instance.new("TextLabel"); FF_Countdown.Size = UDim2.new(1, -24, 0, 30); FF_Countdown.Position = UDim2.new(0, 12, 0, 50); FF_Countdown.BackgroundTransparency = 1; FF_Countdown.Text = "NEXT REFRESH IN 00:00"; FF_Countdown.TextColor3 = Color3.fromRGB(150, 255, 150); FF_Countdown.Font = Enum.Font.GothamBlack; FF_Countdown.TextSize = 16; FF_Countdown.TextXAlignment = Enum.TextXAlignment.Left; FF_Countdown.Parent = FF_Main

    -- Top 5 List Area
    local FF_ListTitle = Instance.new("TextLabel"); FF_ListTitle.Size = UDim2.new(1, -24, 0, 20); FF_ListTitle.Position = UDim2.new(0, 12, 0, 82); FF_ListTitle.BackgroundTransparency = 1; FF_ListTitle.Text = "ESTIMASI MULTIPLIER SIKLUS DEPAN:"; FF_ListTitle.TextColor3 = Color3.fromRGB(200, 200, 200); FF_ListTitle.Font = Enum.Font.GothamBold; FF_ListTitle.TextSize = 11; FF_ListTitle.TextXAlignment = Enum.TextXAlignment.Left; FF_ListTitle.Parent = FF_Main

    local FF_Scroll = Instance.new("ScrollingFrame"); FF_Scroll.Size = UDim2.new(1, -24, 0, 180); FF_Scroll.Position = UDim2.new(0, 12, 0, 104); FF_Scroll.BackgroundColor3 = Color3.fromRGB(18, 28, 18); FF_Scroll.BackgroundTransparency = 0.3; FF_Scroll.ScrollBarThickness = 3; FF_Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 255, 150); FF_Scroll.BorderSizePixel = 0; FF_Scroll.Parent = FF_Main
    Instance.new("UICorner", FF_Scroll).CornerRadius = UDim.new(0, 6)
    local FF_Layout = Instance.new("UIListLayout", FF_Scroll); FF_Layout.SortOrder = Enum.SortOrder.LayoutOrder; FF_Layout.Padding = UDim.new(0, 4)
    FF_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() FF_Scroll.CanvasSize = UDim2.new(0, 0, 0, FF_Layout.AbsoluteContentSize.Y + 5) end)

    FruitPredSec:AddToggle({id = "Tampilkan UI Fruit Market", en = "Show Fruit Forecast UI"}, function(val)
        FF_UI.Enabled = val
    end)
    
    task.spawn(function()
        local Networking = require(ReplicatedStorage.SharedModules.Networking)
        local RS = game:GetService("ReplicatedStorage")
        local SellValueData = require(RS.SharedModules.SellValueData)
        
        local fruits = {}
        for k, _ in pairs(SellValueData) do table.insert(fruits, k) end
        table.sort(fruits)
        
        local liveData = {} -- {fruitName = {multiplier=X, tier="normal/big/mega"}}
        local nextRefresh = os.time() + 600
        local lastRefresh = os.time()
        local cycleSeconds = 600
        local serverOffset = 0
        local lastUpdate = 0
        
        Networking.FruitStock.Snapshot.OnClientEvent:Connect(function(data)
            if type(data) == "table" then
                if type(data.entries) == "table" then
                    liveData = {}
                    for fruitName, info in pairs(data.entries) do
                        if type(info) == "table" then
                            liveData[fruitName] = {
                                multiplier = (type(info.multiplier) == "number") and info.multiplier or 1,
                                tier = (type(info.tier) == "string") and info.tier or "normal"
                            }
                        end
                    end
                end
                if type(data.nextRefreshUnix) == "number" then nextRefresh = data.nextRefreshUnix end
                if type(data.lastRefreshUnix) == "number" then lastRefresh = data.lastRefreshUnix end
                if type(data.cycleSeconds) == "number" and data.cycleSeconds > 0 then cycleSeconds = data.cycleSeconds end
                if type(data.server_now_unix) == "number" then serverOffset = data.server_now_unix - os.time() end
                lastUpdate = os.time()
            end
        end)
        
        -- Request initial data
        pcall(function() Networking.FruitStock.Request:Fire() end)
        
        while task.wait(1) do
            if FF_UI.Enabled then
                pcall(function()
                    -- Countdown
                    local now = os.time() + serverOffset
                    local remaining = math.max(0, nextRefresh - now)
                    local mins = math.floor(remaining / 60)
                    local secs = remaining % 60
                    
                    FF_Countdown.Text = string.format("NEXT REFRESH IN %02d:%02d", mins, secs)
                    if remaining <= 60 then FF_Countdown.TextColor3 = Color3.fromRGB(255, 80, 80)
                    elseif remaining <= 180 then FF_Countdown.TextColor3 = Color3.fromRGB(255, 200, 50)
                    else FF_Countdown.TextColor3 = Color3.fromRGB(150, 255, 150) end
                    
                    -- Sort fruits by multiplier
                    local sorted = {}
                    for _, f in ipairs(fruits) do
                        local info = liveData[f] or {multiplier = 1, tier = "normal"}
                        table.insert(sorted, {name = f, multiplier = info.multiplier, tier = info.tier})
                    end
                    table.sort(sorted, function(a, b) return a.multiplier > b.multiplier end)
                    
                    -- Update list title
                    if next(liveData) then
                        FF_ListTitle.Text = "LIVE MARKET DATA (Server):"
                    else
                        FF_ListTitle.Text = "Waiting for server data... (buka Fruit Price di game)"
                    end
                    
                    -- Render
                    for _, v in pairs(FF_Scroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
                    
                    for i, p in ipairs(sorted) do
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, -10, 0, 22)
                        lbl.BackgroundTransparency = 1
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12
                        lbl.LayoutOrder = i
                        lbl.RichText = true
                        lbl.Parent = FF_Scroll
                        
                        -- Format multiplier like the game does
                        local multVal = math.floor(p.multiplier * 100 + 0.5) / 100
                        local multStr
                        if multVal == math.floor(multVal) then
                            multStr = string.format("X%d", multVal)
                        else
                            multStr = "X" .. string.format("%.2f", multVal):gsub("0+$", ""):gsub("%.$", "")
                        end
                        
                        local tierIcon, tierColor
                        if p.tier == "mega" then
                            tierIcon = "💎"
                            tierColor = "#FF55FF"
                        elseif p.tier == "big" then
                            tierIcon = "🔥"
                            tierColor = "#FFD700"
                        else
                            if p.multiplier > 1 then
                                tierIcon = "📈"
                                tierColor = "#55FF55"
                            else
                                tierIcon = "📉"
                                tierColor = "#AAAAAA"
                            end
                        end
                        
                        lbl.Text = string.format('  %s <font color="%s">%d. %s : %s</font>', tierIcon, tierColor, i, p.name, multStr)
                        if p.tier == "mega" then
                            lbl.TextColor3 = Color3.fromRGB(255, 80, 255)
                        elseif p.tier == "big" then
                            lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                        elseif p.multiplier > 1 then
                            lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
                        else
                            lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
                        end
                    end
                    
                    -- Auto-request data periodically
                    if os.time() - lastUpdate > 30 then
                        pcall(function() Networking.FruitStock.Request:Fire() end)
                        lastUpdate = os.time()
                    end
                end)
            end
        end
    end)

    local PetSec = PremiumTab:AddSection({id = "Kellyz Pet Finder", en = "Kellyz Pet Finder"}, false)
    PetSec:AddMultiDropdown({id = "Pilih Target Pet", en = "Select Target Pets"}, ListPets, function(opts) _G.TargetPets = opts end)
    PetSec:AddToggle({id = "Auto Tame Pet Lokal", en = "Auto Tame Wild Pet (Local)"}, function(val) _G.AutoTameAktif = val end)
    PetSec:AddToggle({id = "Auto Server Hop (Cari Pet)", en = "Auto Server Hop (Find Pet)"}, function(val) _G.AutoServerHopPet = val end)
    PetSec:AddInput({id = "Jeda Server Hop (Detik)", en = "Hop Delay (seconds)"}, function(val) _G.ServerHopDelay = tonumber(val) or 15 end)
    PetSec:AddToggle({id = "Auto Join Global Finder", en = "Auto Join from Global Finder"}, function(val) _G.AutoJoinGlobalPet = val end)
    PetSec:AddButton({id = "Buka Global Pet Finder", en = "Open Global Pet Finder (UI)"}, function() 
        if CoreGui:FindFirstChild("KellyzPetFinderUI") then CoreGui.KellyzPetFinderUI.Enabled = true end
    end)

    local BackpackESPSec = PremiumTab:AddSection({id = "Backpack Tracker", en = "Backpack Tracker"}, false)
    _G.ESPBackpack = false
    BackpackESPSec:AddToggle({id = "Tampilkan UI Harga Tas", en = "Enable Backpack Value UI"}, function(val)
        _G.ESPBackpack = val
        if CoreGui:FindFirstChild("KellyzBackpackUI") then 
            CoreGui.KellyzBackpackUI.Enabled = val 
        end
    end)

    -- AUTO BRUTAL HARVEST
    local BrutalSec = PremiumTab:AddSection({id = "Auto Brutal Harvest", en = "Auto Brutal Harvest"}, false)
    BrutalSec:AddToggle({id = "Auto Brutal Harvest", en = "Auto Brutal Harvest", id_desc = "Panen brutal semua buah secara instan tanpa filter.", en_desc = "Harvest all fruits instantly without filters."}, function(val)
        _G.AutoBrutalHarvest = val
        if val then
            SendNotification("Brutal Mode ON", "Panen gila-gilaan dimulai!", 4)
        end
    end)

    --  4. TAB TRADE & MAILBOX 
    local AllTradeItems = {}
    for _, v in ipairs(ListPets) do if v ~= "All" then table.insert(AllTradeItems, v) end end
    for _, v in ipairs(ListSeed) do table.insert(AllTradeItems, v) end
    for _, v in ipairs(ListGear) do table.insert(AllTradeItems, v) end

    _G.TradeTargetPlayer = ""
    _G.TradeItemName = AllTradeItems[1]
    _G.TradeAmount = 1
    _G.AutoSendTrade = false
    _G.AutoAcceptTrade = false

    _G.MailTargetUser = ""
    _G.MailItemName = AllTradeItems[1]
    _G.MailAmount = 1

    local function GetInventoryItems()
        local items = {}
        local dict = {}
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        local function scanFolder(f)
            if f then
                for _, obj in ipairs(f:GetChildren()) do
                    if obj:IsA("Tool") then
                        local n = obj.Name
                        if not dict[n] then dict[n] = 0; table.insert(items, n) end
                        dict[n] = dict[n] + 1
                    end
                end
            end
        end
        scanFolder(backpack)
        scanFolder(char)
        if #items == 0 then table.insert(items, "Inventory Kosong") end
        return items
    end

    local function GetCategory(name)
        local n = string.lower(name)
        if table.find(ListPets, name) then return "Pets" end
        if table.find(ListSeed, name) then return "Seeds" end
        if string.find(n, "sprinkler") then return "Sprinklers" end
        if string.find(n, "crate") then return "Props" end
        return "Tools" 
    end

    local InitialItems = GetInventoryItems()

    local GiftSec = TradeTab:AddSection({id = "Auto Gifting", en = "Auto Gifting"}, false)
    GiftSec:AddInput({id = "Target Player", en = "Target Player Username"}, function(val) _G.TradeTargetPlayer = val end)
    local GiftDropdown = GiftSec:AddSingleDropdown({id = "Pilih Item", en = "Item Name"}, InitialItems, function(val) _G.TradeItemName = val end)
    GiftSec:AddInput({id = "Jumlah Item", en = "Trade Amount"}, function(val) _G.TradeAmount = tonumber(val) or 1 end)
    GiftSec:AddToggle({id = "Auto Send Trade", en = "Auto Send Trade Enable"}, function(val) _G.AutoSendTrade = val end)
    GiftSec:AddToggle({id = "Auto Accept Trade", en = "Auto Accept Trade"}, function(val) _G.AutoAcceptTrade = val end)

    local MailSec = TradeTab:AddSection({id = "Auto Mailbox", en = "Auto Mailbox"}, false)
    MailSec:AddInput({id = "Target Username", en = "Target Username"}, function(val) _G.MailTargetUser = val end)
    
    local MailDropdown = MailSec:AddSingleDropdown({id = "Pilih Item", en = "Item to Send"}, InitialItems, function(val) _G.MailItemName = val end)
    local MailFruitDropdown = MailSec:AddSingleDropdown({id = "Pilih Fruit", en = "Fruit to Send"}, {"None"}, function(val) _G.MailFruitName = val end)
    
    MailSec:AddInput({id = "Jumlah (Bypass 20 Limit)", en = "Item Amount (Bypass Limit)"}, function(val) _G.MailAmount = tonumber(val) or 1 end)
    
    MailSec:AddButton({id = "Refresh Inventory", en = "Refresh Inventory & Fruits"}, function()
        local freshItems = GetInventoryItems()
        if GiftDropdown and GiftDropdown.Refresh then GiftDropdown:Refresh(freshItems) end
        if MailDropdown and MailDropdown.Refresh then MailDropdown:Refresh(freshItems) end
        
        -- Load Fruits from Backpack
        local freshFruits = {"None"}
        _G.FruitUUIDMap = {}
        
        local NativeCalc = nil
        pcall(function() NativeCalc = require(game:GetService("ReplicatedStorage").SharedModules.FruitValueCalc) end)
        
        local function scanFolderForFruits(folder)
            for _, item in ipairs(folder:GetChildren()) do
                if item:GetAttribute("HarvestedFruit") == true or item:GetAttribute("FruitProxy") == true then
                    local fruitId = item:GetAttribute("Id")
                    if fruitId then
                        local fruitName = item:GetAttribute("Fruit") or item:GetAttribute("FruitName")
                        local mut = item:GetAttribute("Mutation") or "None"
                        local sizeM = item:GetAttribute("SizeMultiplier") or item:GetAttribute("SizeMulti") or 1
                        
                        local price = 0
                        if NativeCalc then pcall(function() price = NativeCalc(fruitName, sizeM, mut, LocalPlayer, 0) end) end
                        
                        local priceStr = "$" .. tostring(math.floor(price))
                        if price >= 1e9 then priceStr = string.format("$%.2fB", price / 1e9)
                        elseif price >= 1e6 then priceStr = string.format("$%.2fM", price / 1e6)
                        elseif price >= 1e3 then priceStr = string.format("$%.2fK", price / 1e3) end
                        
                        local label = "[" .. priceStr .. "] " .. fruitName
                        if mut ~= "None" and mut ~= "" then 
                            label = label .. " [" .. mut .. "]" 
                        end
                        if sizeM then
                            label = label .. " [" .. string.format("%.1f", sizeM) .. "kg]"
                        end
                        
                        -- Ensure unique dropdown keys
                        while _G.FruitUUIDMap[label] do label = label .. " " end
                        _G.FruitUUIDMap[label] = fruitId
                        
                        table.insert(freshFruits, label)
                    end
                end
            end
        end

        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then scanFolderForFruits(bp) end
        if LocalPlayer.Character then scanFolderForFruits(LocalPlayer.Character) end

        if MailFruitDropdown and MailFruitDropdown.Refresh then MailFruitDropdown:Refresh(freshFruits) end
        
        SendNotification("Refreshed", "Berhasil memuat " .. #freshItems .. " item dan " .. (#freshFruits-1) .. " fruit dari tas!", 3)
    end)

    local function ShowMailConfirmationPopup(targetUserId, targetUsername, callback)
        local CoreGui = game:GetService("CoreGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "MailConfirmationPopup_" .. tostring(math.random(1000,9999))
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = CoreGui

        local BG = Instance.new("Frame")
        BG.Size = UDim2.new(1, 0, 1, 0)
        BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BG.BackgroundTransparency = 0.5
        BG.Active = true
        BG.Parent = sg

        local Popup = Instance.new("Frame")
        Popup.Size = UDim2.new(0, 300, 0, 250)
        Popup.Position = UDim2.new(0.5, -150, 0.5, -125)
        Popup.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Popup.BorderSizePixel = 0
        Popup.Parent = BG
        Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Text = "Confirm Send Mail"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = Popup

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 100, 0, 100)
        avatar.Position = UDim2.new(0.5, -50, 0, 45)
        avatar.BackgroundTransparency = 1
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(targetUserId) .. "&w=150&h=150"
        avatar.Parent = Popup
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 40)
        desc.Position = UDim2.new(0, 10, 0, 155)
        desc.BackgroundTransparency = 1
        desc.Text = "Send mail to " .. targetUsername .. "?"
        desc.TextColor3 = Color3.fromRGB(200, 200, 200)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 14
        desc.TextWrapped = true
        desc.Parent = Popup

        local btnYes = Instance.new("TextButton")
        btnYes.Size = UDim2.new(0, 110, 0, 35)
        btnYes.Position = UDim2.new(0.5, -120, 0, 200)
        btnYes.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        btnYes.Text = "YES, SEND"
        btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnYes.Font = Enum.Font.GothamBold
        btnYes.TextSize = 14
        btnYes.Parent = Popup
        Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 6)

        local btnNo = Instance.new("TextButton")
        btnNo.Size = UDim2.new(0, 110, 0, 35)
        btnNo.Position = UDim2.new(0.5, 10, 0, 200)
        btnNo.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        btnNo.Text = "NO, CANCEL"
        btnNo.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnNo.Font = Enum.Font.GothamBold
        btnNo.TextSize = 14
        btnNo.Parent = Popup
        Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 6)

        btnYes.MouseButton1Click:Connect(function()
            sg:Destroy()
            if callback then callback(true) end
        end)

        btnNo.MouseButton1Click:Connect(function()
            sg:Destroy()
            if callback then callback(false) end
        end)
    end

    MailSec:AddButton({id = "Send Mail Sekarang", en = "Send Mail Now"}, function()
        task.spawn(function()
            pcall(function()
                if not _G.MailTargetUser or _G.MailTargetUser == "" then
                    SendNotification("Mailbox Error", "Masukkan Username Target!", 3)
                    return
                end
                
                local targetId = nil
                pcall(function() targetId = Players:GetUserIdFromNameAsync(_G.MailTargetUser) end)
                if not targetId then
                    SendNotification("Mailbox Error", "Username tidak ditemukan di Roblox!", 4)
                    return
                end

                ShowMailConfirmationPopup(targetId, _G.MailTargetUser, function(confirmed)
                    if not confirmed then
                        SendNotification("Batal", "Pengiriman mail dibatalkan.", 3)
                        return
                    end
                    
                    task.spawn(function()
                        pcall(function()
                            local itemsToSend = {}
                            
                            if _G.MailFruitName and _G.MailFruitName ~= "None" and _G.MailFruitName ~= "" then
                                -- SEND FRUIT (Single Fruit selection from dropdown)
                                local uuid = _G.FruitUUIDMap and _G.FruitUUIDMap[_G.MailFruitName]
                                if not uuid then SendNotification("Error", "Pilih fruit yang valid atau tekan Refresh!", 3) return end
                                table.insert(itemsToSend, {Category = "HarvestedFruits", ItemKey = uuid, Count = 1})
                                SendNotification("Mailbox", "Memproses pengiriman 1 Fruit ke " .. _G.MailTargetUser .. "...", 3)
                            else
                                -- SEND REGULAR ITEMS
                                local amt = tonumber(_G.MailAmount) or 1
                                local cat = GetCategory(_G.MailItemName)
                                table.insert(itemsToSend, {ItemKey = _G.MailItemName, Count = amt, Category = cat})
                                SendNotification("Mailbox", "Memproses pengiriman " .. amt .. "x " .. _G.MailItemName .. " ke " .. _G.MailTargetUser .. "...", 3)
                            end
                            
                            -- Chunking Logic for 2000+ bypassing
                            local Networking = require(game:GetService("ReplicatedStorage").SharedModules.Networking)
                            local mb = Networking.Mailbox.SendBatch
                            local chunkSize = 500
                            local totalChunks = math.ceil(#itemsToSend / chunkSize)
                            
                            local sentTotal = 0
                            for i = 1, #itemsToSend, chunkSize do
                                local chunk = {}
                                for j = i, math.min(i + chunkSize - 1, #itemsToSend) do
                                    table.insert(chunk, itemsToSend[j])
                                end
                                
                                if mb.InvokeServer then mb:InvokeServer(targetId, chunk, "Gift from Kellyz Hub")
                                elseif mb.FireServer then mb:FireServer(targetId, chunk, "Gift from Kellyz Hub")
                                else mb:Fire(targetId, chunk, "Gift from Kellyz Hub") end
                                
                            sentTotal = sentTotal + #chunk
                            task.wait(0.5)
                        end
                        
                        SendNotification("Mailbox Sukses", "Berhasil mengirim " .. sentTotal .. " item/fruit ke target!", 5)
                        if _G.WebhookLogMail and getgenv().SendDiscordWebhook then
                            local itemName = (_G.MailFruitName and _G.MailFruitName ~= "None" and _G.MailFruitName ~= "") and _G.MailFruitName or _G.MailItemName
                            getgenv().SendDiscordWebhook("✉️ Mailbox Sent", "**Items Sent:** " .. tostring(sentTotal) .. "x " .. itemName .. "\n**Target:** " .. _G.MailTargetUser, 5814783)
                        end
                    end)
                    end)
                end)
            end)
        end)
    end)

    local WebhookSec = OtherTab:AddSection({id = "Discord Webhook", en = "Discord Webhook"}, false)
    
    _G.WebhookURL = ""
    _G.WebhookMaster = false
    _G._LoggedFruits = _G._LoggedFruits or {}
    _G.CurrentWeatherStr = _G.CurrentWeatherStr or "Menunggu data..."
    _G.CurrentSeedPredictorStr = _G.CurrentSeedPredictorStr or "Menunggu data..."
    
    local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    local function SendDiscordWebhook(title, desc, color)
        if not _G.WebhookURL or _G.WebhookURL == "" then return end
        if not reqFunc then return end
        
        task.spawn(function()
            pcall(function()
                local data = {
                    ["embeds"] = {{
                        ["title"] = title,
                        ["description"] = desc,
                        ["type"] = "rich",
                        ["color"] = color or 5814783,
                        ["fields"] = {
                            {
                                ["name"] = "🔮 Seed Predictor",
                                ["value"] = _G.CurrentSeedPredictorStr or "N/A",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "🌤️ Weather Forecast",
                                ["value"] = _G.CurrentWeatherStr or "N/A",
                                ["inline"] = false
                            }
                        },
                        ["footer"] = { ["text"] = "Kellyz Hub | " .. os.date("%X") }
                    }}
                }
                local encoded = game:GetService("HttpService"):JSONEncode(data)
                reqFunc({
                    Url = _G.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = encoded
                })
            end)
        end)
    end
    getgenv().SendDiscordWebhook = SendDiscordWebhook

    WebhookSec:AddInput({id = "Webhook URL", en = "Webhook URL"}, function(val) _G.WebhookURL = val end)
    -- Initialize with user's specific URL
    _G.WebhookURL = "https://discord.com/api/webhooks/1518734139673542658/scEqM8oqgvjw617Syq36q-2mKZPnp7KSLaVGR-RWZHxDiOj0Of3JisA40UYCGiCikrIV"
    WebhookSec:AddToggle({id = "Enable Master Webhook", en = "Enable Webhook (All In One)"}, function(val) 
        _G.WebhookMaster = val 
        _G.WebhookLogMail = val
        _G.WebhookLogHarvest = val
    end)
    WebhookSec:AddButton({id = "Test Webhook", en = "Test Webhook"}, function()
        SendDiscordWebhook("✅ Webhook Test", "Webhook berhasil terhubung ke Kellyz Hub!", 5814783)
        SendNotification("Webhook", "Test terkirim! Cek Discord kamu.", 3)
    end)
    
    task.spawn(function()
        local lastRestockTime = 0
        while task.wait(5) do
            pcall(function()
                local RS = game:GetService("ReplicatedStorage")
                local sv = RS:FindFirstChild("StockValues")
                if not sv or not sv:FindFirstChild("SeedShop") or not sv.SeedShop:FindFirstChild("UnixNextRestock") then return end
                
                local val = sv.SeedShop.UnixNextRestock.Value
                if lastRestockTime ~= 0 and val ~= lastRestockTime then
                    local foundAny = false
                    for i = 1, 15 do
                        task.wait(1)
                        for _, item in ipairs(sv.SeedShop:GetChildren()) do
                            if item:IsA("IntValue") and item.Value > 0 and item.Name ~= "UnixNextRestock" and item.Name ~= "BaseUnixNextRestock" then
                                foundAny = true
                                break
                            end
                        end
                        if foundAny then break end
                    end
                    task.wait(1) -- safe extra wait
                    
                    if _G.WebhookMaster and getgenv().SendDiscordWebhook then
                        local descLines = {}
                        local SeedData = require(RS.SharedModules.SeedData)
                        local seedRarities = {}
                        for _, v in pairs(SeedData or {}) do
                            if type(v) == "table" and v.SeedName and v.Rarity then
                                seedRarities[v.SeedName] = v.Rarity
                            end
                        end
                        
                        -- Seeds
                        table.insert(descLines, "**🌱 SEED SHOP:**")
                        local seedItems = sv.SeedShop:GetChildren()
                        table.sort(seedItems, function(a, b) return a.Name < b.Name end)
                        local foundSeed = false
                        for _, item in ipairs(seedItems) do
                            if item:IsA("IntValue") and item.Value > 0 and item.Name ~= "UnixNextRestock" and item.Name ~= "BaseUnixNextRestock" then
                                local rarity = seedRarities[item.Name] or "Common"
                                table.insert(descLines, "**" .. item.Name .. "** — " .. tostring(item.Value) .. " Stock\n└ *" .. rarity .. "*")
                                foundSeed = true
                            end
                        end
                        if not foundSeed then table.insert(descLines, "*Kosong*") end
                        
                        -- Gears
                        table.insert(descLines, "\n**🛠️ GEAR SHOP:**")
                        local gearItems = sv:FindFirstChild("GearShop") and sv.GearShop:GetChildren() or {}
                        table.sort(gearItems, function(a, b) return a.Name < b.Name end)
                        local foundGear = false
                        for _, item in ipairs(gearItems) do
                            if item:IsA("IntValue") and item.Value > 0 and item.Name ~= "UnixNextRestock" and item.Name ~= "BaseUnixNextRestock" then
                                table.insert(descLines, "**" .. item.Name .. "** — " .. tostring(item.Value) .. " Stock")
                                foundGear = true
                            end
                        end
                        if not foundGear then table.insert(descLines, "*Kosong*") end
                        
                        -- Props
                        table.insert(descLines, "\n**📦 PROP SHOP:**")
                        local propItems = sv:FindFirstChild("PropShop") and sv.PropShop:GetChildren() or {}
                        table.sort(propItems, function(a, b) return a.Name < b.Name end)
                        local foundProp = false
                        for _, item in ipairs(propItems) do
                            if item:IsA("IntValue") and item.Value > 0 and item.Name ~= "UnixNextRestock" and item.Name ~= "BaseUnixNextRestock" then
                                table.insert(descLines, "**" .. item.Name .. "** — " .. tostring(item.Value) .. " Stock")
                                foundProp = true
                            end
                        end
                        if not foundProp then table.insert(descLines, "*Kosong*") end
                        
                        local desc = table.concat(descLines, "\n")
                        desc = desc .. "\n\n⏳ **Restock again:** in 5 minutes"
                        getgenv().SendDiscordWebhook("🔔 Shop Restock!", desc, 16753920)
                    end
                end
                lastRestockTime = val
            end)
        end
    end)

    local ESPFruitSec = OtherTab:AddSection({id = "Fruit ESP", en = "Fruit ESP"}, false)
    
    _G.ESPFruit = false
    _G.ESPFruit_PlantFilter = "All"
    _G.ESPFruit_PlotFilter = "All"

    local ListFilterFruitESP = {"All"}
    for _, v in ipairs(ListSeed) do table.insert(ListFilterFruitESP, v) end

    ESPFruitSec:AddToggle({id = "Fruit ESP", en = "Enable Fruit ESP"}, function(val) _G.ESPFruit = val end)
    ESPFruitSec:AddSingleDropdown({id = "Filter Tanaman", en = "Plant Filter"}, ListFilterFruitESP, function(val) _G.ESPFruit_PlantFilter = val end)
    ESPFruitSec:AddSingleDropdown({id = "Filter Lahan", en = "Plot Filter"}, {"All", "My Plot"}, function(val) _G.ESPFruit_PlotFilter = val end)

    local ESPPetSec = OtherTab:AddSection({id = "Wild Pet ESP", en = "Wild Pet ESP"}, false)
    
    _G.ESPPet = false
    _G.ESPPet_Filter = "All"

    ESPPetSec:AddToggle({id = "Wild Pet ESP", en = "Enable Wild Pet ESP"}, function(val) _G.ESPPet = val end)
    ESPPetSec:AddSingleDropdown({id = "Filter Pet", en = "Pet Filter"}, ListPets, function(val) _G.ESPPet_Filter = val end)

    -- ==========================================
    --  FPS BOOST SECTION
    -- ==========================================
    local FPSSec = OtherTab:AddSection({id = "FPS Boost", en = "FPS Boost"}, false)
    
    _G.GPUSaver = false
    _G.HideGardensActive = false
    _G.HideGardensTarget = "All"
    _G.HideGardensMode = "Fruit & Plants"
    -- Cache for restoring GPU/Garden state
    local _gpuBackup = {}
    local _gardenBackup = {}

    FPSSec:AddToggle({id = "Mode GPU Saver", en = "GPU Saver"}, function(val)
        _G.GPUSaver = val
        pcall(function()
            local lighting = game:GetService("Lighting")
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if val then
                -- Save original values
                _gpuBackup.Ambient = lighting.Ambient
                _gpuBackup.OutdoorAmbient = lighting.OutdoorAmbient
                _gpuBackup.Brightness = lighting.Brightness
                _gpuBackup.FogColor = lighting.FogColor
                _gpuBackup.FogEnd = lighting.FogEnd
                _gpuBackup.FogStart = lighting.FogStart
                _gpuBackup.GlobalShadows = lighting.GlobalShadows
                _gpuBackup.ClockTime = lighting.ClockTime

                -- Make everything white
                lighting.Ambient = Color3.new(1, 1, 1)
                lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                lighting.Brightness = 2
                lighting.FogColor = Color3.new(1, 1, 1)
                lighting.FogEnd = 200
                lighting.FogStart = 0
                lighting.GlobalShadows = false
                lighting.ClockTime = 12
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

                -- Disable sky/atmosphere/post effects
                for _, v in ipairs(lighting:GetChildren()) do
                    if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Bloom") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                        if not _gpuBackup[v] then _gpuBackup[v] = v.Enabled end
                        v.Enabled = false
                    end
                end
                -- Remove sky completely for white bg
                for _, v in ipairs(lighting:GetChildren()) do
                    if v:IsA("Sky") then v.Parent = nil; _gpuBackup._sky = v end
                end

                -- Terrain
                if terrain then
                    _gpuBackup.WaterWaveSize = terrain.WaterWaveSize
                    _gpuBackup.Decoration = terrain.Decoration
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 0
                    terrain.Decoration = false
                end

                -- Disable particles
                for _, v in ipairs(workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                            v.Enabled = false
                        end
                    end)
                end
                pcall(function() SendNotification("GPU Saver", "Mode layar putih aktif!", 3) end)
            else
                -- Restore everything
                if _gpuBackup.Ambient then lighting.Ambient = _gpuBackup.Ambient end
                if _gpuBackup.OutdoorAmbient then lighting.OutdoorAmbient = _gpuBackup.OutdoorAmbient end
                if _gpuBackup.Brightness then lighting.Brightness = _gpuBackup.Brightness end
                if _gpuBackup.FogColor then lighting.FogColor = _gpuBackup.FogColor end
                if _gpuBackup.FogEnd then lighting.FogEnd = _gpuBackup.FogEnd end
                if _gpuBackup.FogStart then lighting.FogStart = _gpuBackup.FogStart end
                if _gpuBackup.GlobalShadows ~= nil then lighting.GlobalShadows = _gpuBackup.GlobalShadows end
                if _gpuBackup.ClockTime then lighting.ClockTime = _gpuBackup.ClockTime end
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

                for _, v in ipairs(lighting:GetChildren()) do
                    if v:IsA("Atmosphere") or v:IsA("Bloom") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                        if _gpuBackup[v] ~= nil then v.Enabled = _gpuBackup[v] else v.Enabled = true end
                    end
                end
                if _gpuBackup._sky then _gpuBackup._sky.Parent = lighting end

                if terrain then
                    terrain.Decoration = true
                    terrain.WaterWaveSize = _gpuBackup.WaterWaveSize or 0.15
                end
                for _, v in ipairs(workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                            v.Enabled = true
                        end
                    end)
                end
                _gpuBackup = {}
                pcall(function() SendNotification("GPU Saver", "Rendering kembali normal.", 3) end)
            end
        end)
    end)

    FPSSec:AddToggle({id = "Sembunyikan Kebun", en = "Hide Gardens"}, function(val)
        _G.HideGardensActive = val
        if not val then
            pcall(function()
                for obj, origTransparency in pairs(_gardenBackup) do
                    pcall(function()
                        if obj and obj.Parent then
                            obj.Transparency = origTransparency
                        end
                    end)
                end
                _gardenBackup = {}
                pcall(function() SendNotification("Hide Gardens", "Garden ditampilkan kembali.", 3) end)
            end)
        end
    end)
    FPSSec:AddSingleDropdown({id = "Target Kebun", en = "Hide Garden Target"}, {"All", "Me", "Others"}, function(val) _G.HideGardensTarget = val end)
    FPSSec:AddSingleDropdown({id = "Mode Sembunyi", en = "Hide Garden Mode"}, {"Fruit & Plants", "Plants Only"}, function(val) _G.HideGardensMode = val end)

    -- Hide Gardens Loop
    task.spawn(function()
        while task.wait(0.5) do
            if _G.HideGardensActive then
                pcall(function()
                    local gardens = workspace:FindFirstChild("Gardens")
                    if not gardens then return end
                    local myPlotId = LocalPlayer:GetAttribute("PlotId")
                    local myPlotName = myPlotId and ("Plot" .. tostring(myPlotId)) or ""
                    
                    for _, plot in ipairs(gardens:GetChildren()) do
                        local isMyPlot = (plot.Name == myPlotName)
                        local shouldHide = false
                        
                        if _G.HideGardenTarget == "All" then shouldHide = true
                        elseif _G.HideGardenTarget == "Me" then shouldHide = isMyPlot
                        elseif _G.HideGardenTarget == "Others" then shouldHide = not isMyPlot
                        end
                        
                        if shouldHide then
                            for _, obj in ipairs(plot:GetDescendants()) do
                                pcall(function()
                                    if obj:IsA("BasePart") and obj.Transparency < 1 then
                                        local mode = _G.HideGardenMode
                                        local ancestor = obj:FindFirstAncestorWhichIsA("Model")
                                        local hasPlantAttr = ancestor and (ancestor:GetAttribute("PlantType") or ancestor:GetAttribute("PlantId") or ancestor:GetAttribute("SeedId"))
                                        local hasFruitAttr = ancestor and (ancestor:GetAttribute("FruitId") or ancestor:GetAttribute("FruitType"))
                                        local isPlantOrFruit = hasPlantAttr or hasFruitAttr
                                        
                                        local doHide = false
                                        if mode == "Everything" then
                                            doHide = true
                                        elseif mode == "Fruit & Plants" then
                                            doHide = isPlantOrFruit
                                        elseif mode == "Plants Only" then
                                            doHide = hasPlantAttr and not hasFruitAttr
                                        elseif mode == "Fruit Only" then
                                            doHide = hasFruitAttr
                                        end
                                        
                                        if doHide then
                                            if not _gardenBackup[obj] then
                                                _gardenBackup[obj] = obj.Transparency
                                            end
                                            obj.Transparency = 1
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- ==========================================
    --  PERHITUNGAN MATEMATIKA DATA GAME 
    -- ==========================================
    local BaseValues = { Carrot = 5, Strawberry = 3, Tomato = 9, Blueberry = 5, Apple = 12, Pinetree = 100, Bamboo = 800, Pumpkin = 350, Cactus = 40, Pineapple = 30, ["Green Bean"] = 10, Banana = 35, Grape = 45, Mushroom = 13000, Coconut = 60, Mango = 90, ["Thorn Rose"] = 140, ["Dragon Fruit"] = 150, Acorn = 200, Cherry = 350, Sunflower = 1750, ["Venus Fly Trap"] = 3000, Lotus = 6500, Pomegranate = 900, Beanstalk = 2000, ["Poison Apple"] = 900, ["Moon Bloom"] = 9000, ["Dragon's Breath"] = 3400, ["Poison Ivy"] = 1700, ["Glow Mushroom"] = 700, ["Ghost Pepper"] = 2500, ["Horned Melon"] = 200, Corn = 34, ["Baby Cactus"] = 70, Tulip = 60, Romanesco = 1500 }
    local BaseWeights = { ["Ghost Pepper"] = 7.5, ["Mushroom"] = 0.5, ["Pumpkin"] = 10 }

    local NativeCalc
    pcall(function() NativeCalc = require(game:GetService("ReplicatedStorage").SharedModules.FruitValueCalc) end)
    local function PrediksiHargaRaw(pType, sizeM, mut)
        if NativeCalc then
            local success, price = pcall(function() return NativeCalc(pType, sizeM, mut, LocalPlayer, 0) end)
            if success and type(price) == "number" then return price end
        end
        local basePrice = BaseValues[pType] or 10; local exp = 2.65
        if pType == "Mushroom" then exp = 1.9 elseif pType == "Bamboo" then exp = 1.75 end
        local sizeVal = sizeM ^ exp
        if sizeM > 5 and exp > 1.5 then sizeVal = (5 ^ exp) * ((sizeM / 5) ^ 1.5) end
        local mutMulti = (mut == "Bloodlit" and 8) or (mut == "Rainbow" and 10) or (string.find(mut, "Gold") and 5) or (mut == "Frozen" and 6) or 1
        return basePrice * sizeVal * mutMulti
    end

    local function FormatAngka(total)
        if total >= 1e9 then return string.format("$%.2fB", total / 1e9)
        elseif total >= 1e6 then return string.format("$%.2fM", total / 1e6)
        elseif total >= 1e3 then return string.format("$%.1fK", total / 1e3)
        else return "$" .. tostring(math.floor(total)) end
    end

    local function PrediksiHarga(pType, sizeM, mut)
        return FormatAngka(PrediksiHargaRaw(pType, sizeM, mut))
    end

   -- ==========================================
    --  LOOPS: ESP SYSTEM (SUPER AKURAT - FIX FILTER) 
    -- ==========================================
    local KellyzESPFolder = Instance.new("Folder", CoreGui)
    KellyzESPFolder.Name = "KellyzESPFolder_Final"

    task.spawn(function()
        while task.wait(0.4) do 
            pcall(function()
                for _, esp in ipairs(KellyzESPFolder:GetChildren()) do
                    if not esp.Adornee or not esp.Adornee.Parent then 
                        esp:Destroy() 
                    else
                        if string.find(esp.Name, "Fruit_") and not _G.ESPFruit then esp:Destroy() end
                        if string.find(esp.Name, "Pet_") and not _G.ESPPet then esp:Destroy() end
                    end
                end

                if _G.ESPFruit then
                    local gardens = Workspace:FindFirstChild("Gardens")
                    if gardens then
                        for _, plot in ipairs(gardens:GetChildren()) do
                            local plotNum = string.match(plot.Name, "%d+")
                            local isMyPlot = (tostring(plotNum) == tostring(LocalPlayer:GetAttribute("PlotId")))

                            for _, prompt in ipairs(plot:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt:HasTag("HarvestPrompt") then
                                    local harvestPart = prompt.Parent
                                    local fruitModel = harvestPart and harvestPart.Parent
                                    if fruitModel and fruitModel:IsA("Model") then
                                        local pType = fruitModel:GetAttribute("CorePartName")
                                        if not pType then 
                                            local plantModel = fruitModel.Parent and fruitModel.Parent.Parent
                                            if plantModel then pType = plantModel:GetAttribute("SeedName") end 
                                        end
                                        pType = pType or "Unknown"

                                        local mut = fruitModel:GetAttribute("Mutation") or "None"
                                        local cachedKg = fruitModel:GetAttribute("KellyzCachedKG")
                                        local cachedPrice = fruitModel:GetAttribute("KellyzCachedPrice")

                                        if not cachedKg or not cachedPrice then
                                            for _, desc in ipairs(fruitModel:GetDescendants()) do
                                                if desc:IsA("TextLabel") then
                                                    local t = desc.Text
                                                    local tLower = string.lower(t)
                                                    
                                                    local matchKg = string.match(tLower, "([%d%,%.]+)%s*kg")
                                                    if matchKg then 
                                                        cachedKg = matchKg .. " KG"
                                                        fruitModel:SetAttribute("KellyzCachedKG", cachedKg) 
                                                    end
                                                    
                                                    local matchPrice = string.match(t, "%$([%d%,%.%w]+)")
                                                    if matchPrice then 
                                                        cachedPrice = "$" .. matchPrice
                                                        fruitModel:SetAttribute("KellyzCachedPrice", cachedPrice) 
                                                    end
                                                end
                                            end
                                        end

                                        local sizeM = tonumber(fruitModel:GetAttribute("SizeMulti")) or 1
                                        local bWgt = BaseWeights[pType] or 1
                                        if string.find(string.lower(pType), "pepper") then bWgt = 7.5 end
                                        local kgAsli = sizeM * bWgt
                                        
                                        local wgtDisplay = cachedKg or string.format("%.2f KG", kgAsli)
                                        local priceDisplay = cachedPrice or PrediksiHarga(pType, sizeM, mut)
                                        
                                        -- Calculate distance
                                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        local targetPart = harvestPart
                                        local distStr = ""
                                        if hrp and targetPart then
                                            local dist = (hrp.Position - targetPart.Position).Magnitude
                                            distStr = string.format("%.0fm", dist)
                                        end

                                        local show = true
                                        if _G.ESPFruit_PlotFilter == "My Plot" and not isMyPlot then show = false end
                                        if _G.ESPFruit_PlantFilter ~= "All" and not string.find(string.lower(pType), string.lower(_G.ESPFruit_PlantFilter)) then show = false end

                                        local espId = "Fruit_" .. prompt:GetDebugId(10)
                                        local esp = KellyzESPFolder:FindFirstChild(espId)

                                        if harvestPart and show then
                                            if not esp then
                                                esp = Instance.new("BillboardGui", KellyzESPFolder)
                                                esp.Name = espId
                                                esp.Size = UDim2.new(0, 380, 0, 50)
                                                esp.StudsOffset = Vector3.new(0, 4.5, 0)
                                                esp.AlwaysOnTop = true
                                                
                                                local txt = Instance.new("TextLabel", esp)
                                                txt.Name = "Txt"
                                                txt.Size = UDim2.new(1,0,1,0)
                                                txt.BackgroundTransparency = 1
                                                txt.TextSize = 13
                                                txt.Font = Enum.Font.GothamBold
                                                txt.RichText = true 
                                                
                                                local stroke = Instance.new("UIStroke", txt)
                                                stroke.Thickness = 1.5
                                            end
                                            esp.Adornee = harvestPart
                                            
                                            local hexMut = "#FFFFFF" 
                                            local mutLower = string.lower(mut)
                                            if mutLower == "bloodlit" then hexMut = "#FF1A1A" 
                                            elseif mutLower == "rainbow" then hexMut = "#FF66FF" 
                                            elseif string.find(mutLower, "gold") then hexMut = "#FFD700" 
                                            elseif mutLower == "electric" then hexMut = "#FFFF00"
                                            elseif mutLower == "frozen" then hexMut = "#88DDFF"
                                            elseif mutLower == "starstruck" then hexMut = "#E88BFF"
                                            elseif mutLower == "enchained" then hexMut = "#AA00FF"
                                            elseif mutLower == "aurora" then hexMut = "#00FFAA"
                                            elseif mutLower ~= "none" and mutLower ~= "" then hexMut = "#AA55FF" end 
                                            
                                            local titleText = pType
                                            if mutLower ~= "none" and mutLower ~= "" then titleText = pType .. " | " .. mut end

                                            esp.Txt.Text = string.format([[<font color="%s">%s</font>
<font color="#FFFFFF">%s</font> | <font color="#32FF64">%s</font> | <font color="#888888">%s</font>]], hexMut, titleText, wgtDisplay, priceDisplay, distStr)
                                        else
                                            if esp then esp:Destroy() end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if _G.ESPPet then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") then
                            local isPet = false
                            for _, pName in ipairs(ListPets) do
                                if string.lower(obj.Name) == string.lower(pName) or (obj:GetAttribute("PetName") and string.lower(obj:GetAttribute("PetName")) == string.lower(pName)) then
                                    isPet = true; break
                                end
                            end

                            if isPet and not obj:GetAttribute("Owner") and not obj:FindFirstChild("OwnerFolder") and not obj:FindFirstChild("Owner") then
                                local pName = obj:GetAttribute("PetName") or obj.Name
                                local mut = obj:GetAttribute("Mutation") or "None"
                                
                                local show = true
                                if _G.ESPPet_Filter ~= "All" and not string.find(string.lower(pName), string.lower(_G.ESPPet_Filter)) then show = false end

                                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                                local espId = "Pet_" .. pName .. "_" .. tostring(obj:GetDebugId(10))
                                local esp = KellyzESPFolder:FindFirstChild(espId)

                                if part and show then
                                    if not esp then
                                        esp = Instance.new("BillboardGui", KellyzESPFolder)
                                        esp.Name = espId
                                        esp.Size = UDim2.new(0, 300, 0, 30)
                                        esp.StudsOffset = Vector3.new(0, 4, 0)
                                        esp.AlwaysOnTop = true
                                        
                                        local txt = Instance.new("TextLabel", esp)
                                        txt.Name = "Txt"
                                        txt.Size = UDim2.new(1,0,1,0)
                                        txt.BackgroundTransparency = 1
                                        txt.TextSize = 13
                                        txt.TextColor3 = Color3.fromRGB(50, 255, 100)
                                        txt.Font = Enum.Font.GothamBold
                                        local stroke = Instance.new("UIStroke", txt)
                                        stroke.Thickness = 1.5
                                    end
                                    esp.Adornee = part
                                    esp.Txt.Text = string.format(" %s | %s | N/A", pName, mut)
                                else
                                    if esp then esp:Destroy() end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    -- ==========================================
    --  UI GLOBAL PET FINDER (CCTV) 
    -- ==========================================
    if CoreGui:FindFirstChild("KellyzPetFinderUI") then CoreGui.KellyzPetFinderUI:Destroy() end
    local PF_UI = Instance.new("ScreenGui"); PF_UI.Name = "KellyzPetFinderUI"; PF_UI.Enabled = false; PF_UI.Parent = CoreGui
    local PF_Main = Instance.new("Frame"); PF_Main.Size = UDim2.new(0, 450, 0, 520); PF_Main.Position = UDim2.new(0.5, -225, 0.5, -260); PF_Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); PF_Main.Active = true; PF_Main.Draggable = true; PF_Main.Parent = PF_UI; Instance.new("UICorner", PF_Main).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", PF_Main).Color = Color3.fromRGB(80, 100, 255); PF_Main.UIStroke.Thickness = 1.5
    local PF_Top = Instance.new("Frame"); PF_Top.Size = UDim2.new(1, 0, 0, 50); PF_Top.BackgroundTransparency = 1; PF_Top.Parent = PF_Main
    local PF_Title = Instance.new("TextLabel"); PF_Title.Size = UDim2.new(0.5, 0, 1, 0); PF_Title.Position = UDim2.new(0, 15, 0, 0); PF_Title.BackgroundTransparency = 1; PF_Title.Text = "// Kellyz Pet Finder"; PF_Title.TextColor3 = Color3.fromRGB(200, 200, 255); PF_Title.Font = Enum.Font.GothamBold; PF_Title.TextSize = 16; PF_Title.TextXAlignment = Enum.TextXAlignment.Left; PF_Title.Parent = PF_Top
    local PF_Refresh = Instance.new("TextButton"); PF_Refresh.Size = UDim2.new(0, 80, 0, 30); PF_Refresh.Position = UDim2.new(1, -125, 0, 10); PF_Refresh.BackgroundColor3 = Color3.fromRGB(80, 50, 255); PF_Refresh.Text = "Refresh"; PF_Refresh.TextColor3 = Color3.fromRGB(255, 255, 255); PF_Refresh.Font = Enum.Font.GothamBold; PF_Refresh.TextSize = 12; PF_Refresh.Parent = PF_Top; Instance.new("UICorner", PF_Refresh).CornerRadius = UDim.new(0, 6)
    local PF_Close = Instance.new("TextButton"); PF_Close.Size = UDim2.new(0, 30, 0, 30); PF_Close.Position = UDim2.new(1, -35, 0, 10); PF_Close.BackgroundTransparency = 1; PF_Close.Text = "X"; PF_Close.TextColor3 = Color3.fromRGB(255, 80, 80); PF_Close.Font = Enum.Font.GothamBold; PF_Close.TextSize = 18; PF_Close.Parent = PF_Top; PF_Close.MouseButton1Click:Connect(function() PF_UI.Enabled = false end)
    local PF_Scroll = Instance.new("ScrollingFrame"); PF_Scroll.Size = UDim2.new(1, -30, 1, -70); PF_Scroll.Position = UDim2.new(0, 15, 0, 60); PF_Scroll.BackgroundTransparency = 1; PF_Scroll.ScrollBarThickness = 4; PF_Scroll.Parent = PF_Main
    local PFL = Instance.new("UIListLayout", PF_Scroll); PFL.SortOrder = Enum.SortOrder.LayoutOrder; PFL.Padding = UDim.new(0, 8)
    PFL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PF_Scroll.CanvasSize = UDim2.new(0, 0, 0, PFL.AbsoluteContentSize.Y) end)

    task.spawn(function()
        while task.wait(30) do 
            if _G.ShareDataToGlobal and httpRequest then
                pcall(function()
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") then
                            local isPet = false
                            for _, pName in ipairs(ListPets) do
                                if string.lower(obj.Name) == string.lower(pName) or (obj:GetAttribute("PetName") and string.lower(obj:GetAttribute("PetName")) == string.lower(pName)) then
                                    isPet = true; break
                                end
                            end
                            if isPet and not obj:GetAttribute("Owner") and not obj:FindFirstChild("OwnerFolder") and not obj:FindFirstChild("Owner") then
                                local pName = obj:GetAttribute("PetName") or obj.Name
                                httpRequest({Url = "https://kellyz-bot-production.up.railway.app/add-pet", Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({petName = pName, jobId = game.JobId})})
                            end
                        end
                    end
                end)
            end
        end
    end)

    PF_Refresh.MouseButton1Click:Connect(function()
        for _, v in pairs(PF_Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        PF_Refresh.Text = "Loading..."
        local success, res = pcall(function() return httpRequest({ Url = "https://kellyz-bot-production.up.railway.app/get-pets", Method = "GET" }) end)
        PF_Refresh.Text = "Refresh"
        if success and res and res.StatusCode == 200 then
            local decodedSuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if decodedSuccess and type(data) == "table" and #data > 0 then
                for _, petData in ipairs(data) do
                    local isLokal = (petData.jobId == game.JobId)
                    
                    local card = Instance.new("Frame")
                    card.Size = UDim2.new(1, -8, 0, 55)
                    card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                    card.Parent = PF_Scroll
                    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
                    Instance.new("UIStroke", card).Color = isLokal and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 50, 255)
                    
                    local n = Instance.new("TextLabel", card); n.Size = UDim2.new(0.6, 0, 0.5, 0); n.Position = UDim2.new(0, 15, 0, 5); n.BackgroundTransparency = 1; n.Text = petData.petName; n.TextColor3 = Color3.fromRGB(255,255,255); n.Font = Enum.Font.GothamBold; n.TextSize = 15; n.TextXAlignment = Enum.TextXAlignment.Left
                    local r = Instance.new("TextLabel", card); r.Size = UDim2.new(0.6, 0, 0.5, 0); r.Position = UDim2.new(0, 15, 0, 28); r.BackgroundTransparency = 1; r.Text = isLokal and "Di Server Kamu Sekarang!" or "Global Found (Click to Join!)"; r.TextColor3 = isLokal and Color3.fromRGB(255,200,50) or Color3.fromRGB(150,255,150); r.Font = Enum.Font.Gotham; r.TextSize = 11; r.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local joinBtn = Instance.new("TextButton", card)
                    joinBtn.Size = UDim2.new(0, 90, 0, 30)
                    joinBtn.Position = UDim2.new(1, -105, 0.5, -15)
                    joinBtn.BackgroundColor3 = isLokal and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(80, 50, 255)
                    joinBtn.Text = isLokal and "Current" or "Join Server"
                    joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    joinBtn.Font = Enum.Font.GothamBold
                    joinBtn.TextSize = 12
                    Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 6)

                    if not isLokal then
                        joinBtn.MouseButton1Click:Connect(function()
                            joinBtn.Text = "Joining..."
                            joinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, petData.jobId, LocalPlayer)
                        end)
                    end
                end
            else
                local card = Instance.new("Frame"); card.Size = UDim2.new(1, -8, 0, 50); card.BackgroundColor3 = Color3.fromRGB(25, 25, 35); card.Parent = PF_Scroll; Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8); local msg = Instance.new("TextLabel", card); msg.Size = UDim2.new(1, 0, 1, 0); msg.BackgroundTransparency = 1; msg.Text = "Database Kosong. Belum ada CCTV yang lapor!"; msg.TextColor3 = Color3.fromRGB(255, 80, 80); msg.Font = Enum.Font.GothamBold; msg.TextSize = 12
            end
        else
            local card = Instance.new("Frame"); card.Size = UDim2.new(1, -8, 0, 50); card.BackgroundColor3 = Color3.fromRGB(25, 25, 35); card.Parent = PF_Scroll; Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8); local msg = Instance.new("TextLabel", card); msg.Size = UDim2.new(1, 0, 1, 0); msg.BackgroundTransparency = 1; msg.Text = "Gagal terhubung ke Railway Kellyz!"; msg.TextColor3 = Color3.fromRGB(255, 80, 80); msg.Font = Enum.Font.GothamBold; msg.TextSize = 12
        end
    end)


    -- ==========================================
    --  UI BACKPACK FRUIT TRACKER (FULL FIXED DARI NATIVE)
    -- ==========================================
    if CoreGui:FindFirstChild("KellyzBackpackUI") then CoreGui.KellyzBackpackUI:Destroy() end
    local BP_UI = Instance.new("ScreenGui"); BP_UI.Name = "KellyzBackpackUI"; BP_UI.Enabled = false; BP_UI.Parent = CoreGui
    local BP_Main = Instance.new("Frame"); BP_Main.Size = UDim2.new(0, 320, 0, 420); BP_Main.Position = UDim2.new(0, 20, 0.5, -210); BP_Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); BP_Main.BackgroundTransparency = 0.2; BP_Main.Active = true; BP_Main.Draggable = true; BP_Main.Parent = BP_UI
    Instance.new("UICorner", BP_Main).CornerRadius = UDim.new(0, 10)
    local BP_Stroke = Instance.new("UIStroke", BP_Main); BP_Stroke.Color = getgenv().ThemeColor; BP_Stroke.Thickness = 1.5

    local BP_Top = Instance.new("Frame"); BP_Top.Size = UDim2.new(1, 0, 0, 40); BP_Top.BackgroundTransparency = 1; BP_Top.Parent = BP_Main
    local BP_Title = Instance.new("TextLabel"); BP_Title.Size = UDim2.new(1, -40, 1, 0); BP_Title.Position = UDim2.new(0, 15, 0, 0); BP_Title.BackgroundTransparency = 1; BP_Title.Text = " Backpack Tracker"; BP_Title.TextColor3 = Color3.fromRGB(255, 255, 255); BP_Title.Font = Enum.Font.GothamBold; BP_Title.TextSize = 14; BP_Title.TextXAlignment = Enum.TextXAlignment.Left; BP_Title.Parent = BP_Top
    local BP_Close = Instance.new("TextButton"); BP_Close.Size = UDim2.new(0, 30, 0, 30); BP_Close.Position = UDim2.new(1, -35, 0, 5); BP_Close.BackgroundTransparency = 1; BP_Close.Text = "X"; BP_Close.TextColor3 = Color3.fromRGB(255, 80, 80); BP_Close.Font = Enum.Font.GothamBold; BP_Close.TextSize = 16; BP_Close.Parent = BP_Top; BP_Close.MouseButton1Click:Connect(function() BP_UI.Enabled = false; _G.ESPBackpack = false end)

    local BP_TotalBg = Instance.new("Frame"); BP_TotalBg.Size = UDim2.new(1, -30, 0, 35); BP_TotalBg.Position = UDim2.new(0, 15, 0, 45); BP_TotalBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); BP_TotalBg.Parent = BP_Main
    Instance.new("UICorner", BP_TotalBg).CornerRadius = UDim.new(0, 6)
    local BP_TotalLabel = Instance.new("TextLabel"); BP_TotalLabel.Size = UDim2.new(1, 0, 1, 0); BP_TotalLabel.BackgroundTransparency = 1; BP_TotalLabel.Text = "Total Estimasi: $0"; BP_TotalLabel.TextColor3 = Color3.fromRGB(50, 255, 100); BP_TotalLabel.Font = Enum.Font.GothamBold; BP_TotalLabel.TextSize = 14; BP_TotalLabel.Parent = BP_TotalBg

    local BP_Scroll = Instance.new("ScrollingFrame"); BP_Scroll.Size = UDim2.new(1, -20, 1, -100); BP_Scroll.Position = UDim2.new(0, 10, 0, 90); BP_Scroll.BackgroundTransparency = 1; BP_Scroll.ScrollBarThickness = 3; BP_Scroll.ScrollBarImageColor3 = getgenv().ThemeColor; BP_Scroll.Parent = BP_Main
    local BP_Layout = Instance.new("UIListLayout", BP_Scroll); BP_Layout.SortOrder = Enum.SortOrder.LayoutOrder; BP_Layout.Padding = UDim.new(0, 6)
    BP_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() BP_Scroll.CanvasSize = UDim2.new(0, 0, 0, BP_Layout.AbsoluteContentSize.Y) end)

    task.spawn(function()
        while task.wait(3) do
            if _G.ESPBackpack then
                pcall(function()
                    local totalHargaSeluruh = 0
                    local rekapBuah = {}
                    local scanned = {}

                    local function checkItem(item)
                        if scanned[item] then return end
                        scanned[item] = true
                        
                        -- Cek langsung sesuai script FruitProxy.lua yang native:
                        -- Gamenya menandai buah asli dengan atribut "HarvestedFruit" (di Tool) 
                        -- atau "FruitProxy" (di Configuration)
                        local isFruit = item:GetAttribute("HarvestedFruit") == true or item:GetAttribute("FruitProxy") == true
                        
                        if isFruit then
                            local nama = item:GetAttribute("Fruit") or item:GetAttribute("FruitName")
                            if not nama then
                                -- Fallback potong nama asli (e.g., "Mushroom [Gold] [1.5kg]" -> "Mushroom")
                                nama = string.split(item.Name, " [")[1]
                            end
                            
                            if nama and BaseValues[nama] then
                                local mut = item:GetAttribute("Mutation") or "None"
                                local sizeM = item:GetAttribute("SizeMulti") or item:GetAttribute("SizeMultiplier") or 1
                                
                                local hargaMentah = PrediksiHargaRaw(nama, sizeM, mut)
                                totalHargaSeluruh = totalHargaSeluruh + hargaMentah

                                local key = nama .. "_" .. mut
                                if not rekapBuah[key] then
                                    rekapBuah[key] = {Nama = nama, Mutasi = mut, Jumlah = 0, Total = 0}
                                end
                                rekapBuah[key].Jumlah = rekapBuah[key].Jumlah + 1
                                rekapBuah[key].Total = rekapBuah[key].Total + hargaMentah
                            end
                        end
                    end

                    local function scanFolder(folder)
                        if not folder then return end
                        checkItem(folder)
                        for i, item in ipairs(folder:GetDescendants()) do if i % 50 == 0 then task.wait() end
                            checkItem(item)
                        end
                    end

                    -- Cek SEMUA isi Backpack & Character biar proxy fruit nya gak terlewat
                    local tas = LocalPlayer:FindFirstChild("Backpack")
                    scanFolder(tas)
                    if LocalPlayer.Character then scanFolder(LocalPlayer.Character) end

                    BP_TotalLabel.Text = "Total Estimasi: " .. FormatAngka(totalHargaSeluruh)
                    
                    for _, v in pairs(BP_Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

                    local sortedRekap = {}
                    for _, data in pairs(rekapBuah) do table.insert(sortedRekap, data) end
                    table.sort(sortedRekap, function(a, b) return a.Total > b.Total end)

                    for _, data in ipairs(sortedRekap) do
                        local card = Instance.new("Frame")
                        card.Size = UDim2.new(1, -8, 0, 35)
                        card.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
                        card.Parent = BP_Scroll
                        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

                        local txtKiri = Instance.new("TextLabel", card)
                        txtKiri.Size = UDim2.new(0.65, 0, 1, 0)
                        txtKiri.Position = UDim2.new(0, 10, 0, 0)
                        txtKiri.BackgroundTransparency = 1
                        txtKiri.Text = data.Jumlah .. "x " .. data.Nama .. (data.Mutasi ~= "None" and " (" .. data.Mutasi .. ")" or "")
                        
                        local hexMut = Color3.fromRGB(220, 220, 220)
                        if data.Mutasi == "Bloodlit" then hexMut = Color3.fromRGB(255, 26, 26)
                        elseif data.Mutasi == "Rainbow" then hexMut = Color3.fromRGB(255, 102, 255)
                        elseif string.find(data.Mutasi, "Gold") then hexMut = Color3.fromRGB(255, 215, 0)
                        elseif data.Mutasi == "Frozen" then hexMut = Color3.fromRGB(100, 200, 255)
                        elseif data.Mutasi ~= "None" and data.Mutasi ~= "" then hexMut = Color3.fromRGB(170, 85, 255) end
                        
                        txtKiri.TextColor3 = hexMut
                        txtKiri.Font = Enum.Font.GothamSemibold
                        txtKiri.TextSize = 11
                        txtKiri.TextXAlignment = Enum.TextXAlignment.Left

                        local txtKanan = Instance.new("TextLabel", card)
                        txtKanan.Size = UDim2.new(0.35, -10, 1, 0)
                        txtKanan.Position = UDim2.new(0.65, 0, 0, 0)
                        txtKanan.BackgroundTransparency = 1
                        txtKanan.Text = FormatAngka(data.Total)
                        txtKanan.TextColor3 = Color3.fromRGB(50, 255, 100)
                        txtKanan.Font = Enum.Font.GothamBold
                        txtKanan.TextSize = 11
                        txtKanan.TextXAlignment = Enum.TextXAlignment.Right
                    end
                end)
            end
        end
    end)


    -- ==========================================
    -- LOOP LAINNYA (TIDAK DIUBAH)
    -- ==========================================
    local function pegangBenih(namaBenih)
        local char = LocalPlayer.Character
        if not char then return false end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return false end
        local alatDiTangan = char:FindFirstChildOfClass("Tool")
        if alatDiTangan and string.find(string.lower(alatDiTangan.Name), string.lower(namaBenih)) then return true end
        local tas = LocalPlayer:FindFirstChild("Backpack")
        if tas then
            for _, alat in ipairs(tas:GetChildren()) do
                if alat:IsA("Tool") and string.find(string.lower(alat.Name), string.lower(namaBenih)) then
                    hum:EquipTool(alat)
                    return true
                end
            end
        end
        return false 
    end

    local function buatPaketBeli(namaBarang, opcode)
        print('BUAT PAKET BELI:', namaBarang, opcode)
        if not namaBarang or namaBarang == "" then return nil end
        local len = #namaBarang
        local buf = buffer.create(3 + len)
        buffer.writeu8(buf, 0, opcode)
        buffer.writeu8(buf, 1, 0x00)
        buffer.writeu8(buf, 2, len)
        for i = 1, len do buffer.writeu8(buf, 2 + i, string.byte(namaBarang, i, i)) end
        return buf
    end

    local function buatPaketTanam(namaSeed, posisiVector3)
        local len = #namaSeed
        local buf = buffer.create(15 + len)
        buffer.writeu8(buf, 0, KODE_TANAM)
        buffer.writeu8(buf, 1, 0x00)
        buffer.writef32(buf, 2, posisiVector3.X)
        buffer.writef32(buf, 6, posisiVector3.Y)
        buffer.writef32(buf, 10, posisiVector3.Z)
        buffer.writeu8(buf, 14, len)
        for i = 1, len do buffer.writeu8(buf, 14 + i, string.byte(namaSeed, i, i)) end
        return buf
    end

    local function firePlantPacket(namaSeed, posisiVector3)
        local backpackTool = nil
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then backpackTool = bp:FindFirstChild(namaSeed) end
            if not backpackTool then
                local char = LocalPlayer.Character
                if char then backpackTool = char:FindFirstChild(namaSeed) end
            end
        end)
        
        -- Gunakan jalur resmi Networking game (Networking.Plant.PlantSeed)
        pcall(function()
            local Networking = require(game:GetService("ReplicatedStorage").SharedModules.Networking)
            if Networking and Networking.Plant and Networking.Plant.PlantSeed then
                Networking.Plant.PlantSeed:Fire(posisiVector3, namaSeed, backpackTool)
            end
        end)
    end

    task.spawn(function()
        while task.wait(0.2) do
            -- moved autobuy to separate fast loop
        end
    end)

    task.spawn(function()
        local NetShop = nil
        pcall(function() NetShop = require(game:GetService("ReplicatedStorage").SharedModules.Networking) end)
        while task.wait(0.1) do
            if NetShop then
                if _G.AutoBuySeedAktif and type(_G.TargetBuySeed) == "table" then 
                    for _, s in ipairs(_G.TargetBuySeed) do pcall(function() NetShop.SeedShop.PurchaseSeed:Fire(s) end) end 
                end
                if _G.AutoBuyGearAktif and type(_G.TargetBuyGear) == "table" then 
                    for _, g in ipairs(_G.TargetBuyGear) do pcall(function() NetShop.GearShop.PurchaseGear:Fire(g) end) end 
                end
                if _G.AutoBuyCrateAktif and type(_G.TargetBuyCrate) == "table" then 
                    for _, c in ipairs(_G.TargetBuyCrate) do pcall(function() NetShop.CrateShop.PurchaseCrate:Fire(c) end) end 
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if _G.AutoClaimAktif and type(_G.TargetClaim) == "table" then
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local isAll = table.find(_G.TargetClaim, "All") ~= nil
                    local isSeed = isAll or table.find(_G.TargetClaim, "Seedpack") ~= nil
                    local isItem = isAll or table.find(_G.TargetClaim, "Items") ~= nil
                    local isPetItem = isAll or table.find(_G.TargetClaim, "Pet Items") ~= nil

                    if isSeed then
                        local seedFolder = Workspace:FindFirstChild("SeedPackSpawnServerLocations")
                        if seedFolder then
                            for _, pack in ipairs(seedFolder:GetDescendants()) do
                                if pack:IsA("Model") or pack:IsA("BasePart") then
                                    local packId = pack:GetAttribute("Id") or pack.Name
                                    local posPart = pack:IsA("BasePart") and pack or pack.PrimaryPart
                                    if posPart then
                                        hrp.CFrame = posPart.CFrame * CFrame.new(0, 1, 0)
                                        task.wait(0.15) 
                                        if Networking and Networking.SeedPack and Networking.SeedPack.ClickPack then Networking.SeedPack.ClickPack:Fire(packId) end
                                        if Networking and Networking.SeedPackSpawn and Networking.SeedPackSpawn.Claimed then Networking.SeedPackSpawn.Claimed:Fire(packId) end
                                        task.wait(0.15) 
                                    end
                                end
                            end
                        end
                    end

                    if isItem or isPetItem then
                        local function ClaimDariFolder(folder)
                            for _, drop in ipairs(folder:GetChildren()) do
                                if drop:IsA("Tool") or drop:IsA("Model") then
                                    local isPet = string.find(string.lower(drop.Name), "pet")
                                    local mauDiambil = false
                                    if isAll then mauDiambil = true end
                                    if isItem and not isPet then mauDiambil = true end
                                    if isPetItem and isPet then mauDiambil = true end

                                    if mauDiambil then
                                        local handle = drop:FindFirstChild("Handle") or drop:FindFirstChildWhichIsA("BasePart") or drop.PrimaryPart
                                        if handle then
                                            hrp.CFrame = handle.CFrame
                                            task.wait(0.15) 
                                            local promptDitekan = false
                                            for _, prompt in ipairs(drop:GetDescendants()) do
                                                if prompt:IsA('ProximityPrompt') and not string.find(string.lower(prompt.ActionText or ''), 'gift') and not string.find(string.lower(prompt.ObjectText or ''), 'gift') then
                                                    if fireproximityprompt then fireproximityprompt(prompt)
                                                    else prompt:InputHoldBegin() task.wait(0.1) prompt:InputHoldEnd() end
                                                    promptDitekan = true
                                                end
                                            end
                                            if not promptDitekan and firetouchinterest then
                                                firetouchinterest(hrp, handle, 0) task.wait(0.01) firetouchinterest(hrp, handle, 1)
                                            end
                                            task.wait(0.15) 
                                        end
                                    end
                                end
                            end
                        end
                        local dropFolder = Workspace:FindFirstChild("DroppedItems")
                        if dropFolder then ClaimDariFolder(dropFolder) end
                        -- ClaimDariFolder(Workspace) 
                    end
                end)
            end
            
            if _G.AutoStealAktif then
                pcall(function()
                    if not Networking then return end
                    local nightCheck = ReplicatedStorage:FindFirstChild("Night")
                    local isNight = false
                    if nightCheck and nightCheck:IsA("BoolValue") then isNight = nightCheck.Value end
                    if typeof(nightCheck) == "boolean" then isNight = nightCheck end
                    if not nightCheck then isNight = true end 

                    if isNight then 
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for _, prompt in ipairs(Workspace:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt:HasTag("StealPrompt") then
                                    local plantModel = prompt:FindFirstAncestorWhichIsA("Model")
                                    if plantModel then
                                        local uId = plantModel:GetAttribute("UserId")
                                        local pId = plantModel:GetAttribute("PlantId")
                                        local fId = plantModel:GetAttribute("FruitId") or ""
                                        if uId and pId then
                                            hrp.CFrame = plantModel:GetPivot() * CFrame.new(0, 2, 0)
                                            task.wait(0.2)
                                            Networking.Steal.BeginSteal:Fire(tonumber(uId), pId, fId)
                                            task.wait(0.2)
                                            Networking.Steal.CompleteSteal:Fire()
                                            task.wait(0.3)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    task.spawn(function()
        while true do
            local userDelay = _G.ActionDelay or 0
            if _G.AutoPlantAktif and type(_G.TargetPlantSeed) == "table" and #_G.TargetPlantSeed > 0 then
                local seedToPlant = _G.TargetPlantSeed[math.random(1, #_G.TargetPlantSeed)]
                local berhasilPegang = pegangBenih(seedToPlant)
                if berhasilPegang then
                    if _G.ModeRandomPot then
                        if #_G.CachedPots > 0 then
                            for i = 1, (userDelay <= 0 and 3 or 1) do
                                local randomPos = _G.CachedPots[math.random(1, #_G.CachedPots)]
                                firePlantPacket(seedToPlant, randomPos)
                            end
                        end
                    else
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local posisiKaki = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2.5, 0)
                            firePlantPacket(seedToPlant, posisiKaki)
                        end
                    end
                end
            end

            if _G.AutoHarvestAktif and Networking then
                local plotId = LocalPlayer:GetAttribute("PlotId")
                local myGarden = plotId and Workspace:FindFirstChild("Gardens") and Workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
                
                if myGarden then
                    for _, prompt in pairs(myGarden:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt:HasTag("HarvestPrompt") then
                            local plantModel = prompt:FindFirstAncestorWhichIsA("Model")
                            if plantModel then
                                local tipe = plantModel:GetAttribute("SeedName") or plantModel:GetAttribute("PlantType") or plantModel.Name or ""
                                local mutasi = plantModel:GetAttribute("Mutation") or "None"
                                local berat = 0
                                pcall(function()
                                    local FVC = require(game:GetService("Players").LocalPlayer.PlayerScripts.Controllers.FruitVisualizerController)
                                    berat = FVC:CalculateFruitWeight(plantModel)
                                    if not berat then berat = FVC:CalculatePlantWeight(plantModel) end
                                end)
                                berat = tonumber(berat) or 0
                                
                                local passBuah = false
                                if type(_G.TargetPanenBuah) == "table" then
                                    if #_G.TargetPanenBuah == 0 or table.find(_G.TargetPanenBuah, "All") then passBuah = true end
                                    if not passBuah then
                                        for _, f in ipairs(_G.TargetPanenBuah) do
                                            if string.find(string.lower(tostring(tipe)), string.lower(f), 1, true) then passBuah = true; break end
                                        end
                                    end
                                end

                                local passMutasi = false
                                if type(_G.TargetPanenMutasi) == "table" then
                                    if #_G.TargetPanenMutasi == 0 or table.find(_G.TargetPanenMutasi, "Any") then passMutasi = true end
                                    if not passMutasi then
                                        for _, m in ipairs(_G.TargetPanenMutasi) do
                                            if string.lower(tostring(mutasi)) == string.lower(m) then passMutasi = true; break end
                                        end
                                    end
                                end
                                
                                local passKG = (_G.MaxKG <= 0) or (berat <= _G.MaxKG)

                                if passBuah and passMutasi and passKG then
                                    local pId = plantModel:GetAttribute("PlantId")
                                    local fId = plantModel:GetAttribute("FruitId") or ""
                                    if pId then
                                        pcall(function() 
                                            print("[AutoHarvest] Memanen " .. tipe .. " (ID: " .. tostring(pId) .. ") dengan berat: " .. tostring(berat) .. "kg")
                                            Networking.Garden.CollectFruit:Fire(pId, fId) 
                                            if _G.WebhookLogHarvest and getgenv().SendDiscordWebhook and not _G._LoggedFruits[fId] then
                                                if mutasi ~= "None" and mutasi ~= "" then
                                                    _G._LoggedFruits[fId] = true
                                                    getgenv().SendDiscordWebhook("🌱 Rare Harvest!", "**Fruit:** " .. tostring(tipe) .. "\n**Mutation:** " .. tostring(mutasi) .. "\n**Weight:** " .. string.format("%.2f", berat) .. "kg", 16766720)
                                                end
                                            end
                                        end)
                                        if userDelay > 0 then task.wait(userDelay) end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if userDelay <= 0 then task.wait() else task.wait(userDelay) end
        end
    end)

    task.spawn(function()
        while task.wait(2) do
            if Networking and Networking.NPCS then
                if _G.AutoDailyDealAktif then
                    pcall(function() Networking.NPCS.UseDailyDealAll:Fire() end)
                end
                if _G.AutoSellAktif then
                    pcall(function()
                        if _G.TargetSellMode == "Sell All" then Networking.NPCS.SellAll:Fire()
                        elseif _G.TargetSellMode == "Daily Deal Only" then Networking.NPCS.UseDailyDealAll:Fire() end
                    end)
                end
            end
        end
    end)

    -- BRUTAL HARVEST ENGINE (RAW BUFFER EDITION - ULTRA SPEED)
    task.spawn(function()
        -- [MICRO OPTIMIZATION] Pindahkan semua pencarian di luar loop supaya gak memberatkan CPU tiap milidetik
        local PacketRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SharedModules")
        if PacketRemote then PacketRemote = PacketRemote:FindFirstChild("Packet") end
        if PacketRemote then PacketRemote = PacketRemote:FindFirstChild("RemoteEvent") end

        local plotId = LocalPlayer:GetAttribute("PlotId")
        local myGarden = plotId and Workspace:FindFirstChild("Gardens") and Workspace.Gardens:FindFirstChild("Plot" .. tostring(plotId))
        
        -- Tunggu sampai Networking siap
        while not Networking or not Networking.Garden or not Networking.Garden.CollectFruit do
            task.wait(1)
        end
        
        local collectId = Networking.Garden.CollectFruit.Id
        local opHex = string.char(collectId % 256) .. string.char(math.floor(collectId / 256))

        -- Ganti pakai while task.wait() di dalam task.spawn biar gak berat di FPS
        while task.wait() do
            if _G.AutoBrutalHarvest and PacketRemote and myGarden then
                local harvestStr = ""
                local count = 0
                
                -- [PERBAIKAN] Scan seluruh kebun (GetDescendants) supaya Bambu dan pohon lain yang beda folder tetep kena!
                for _, obj in ipairs(myGarden:GetDescendants()) do
                    if not _G.AutoBrutalHarvest then break end
                    
                    local pId = obj:GetAttribute("PlantId")
                    local fId = obj:GetAttribute("FruitId")
                    local age = obj:GetAttribute("Age") or 0
                    local maxAge = obj:GetAttribute("MaxAge") or 99
                    
                    if pId and fId and age >= (maxAge - 0.1) then
                        local pLen = string.char(#pId)
                        local fLen = string.char(#fId)
                        harvestStr = harvestStr .. opHex .. pLen .. pId .. fLen .. fId
                        count = count + 1
                    end
                end
                
                if count > 0 then
                    pcall(function() PacketRemote:FireServer(buffer.fromstring(harvestStr)) end)
                end
            end
        end
    end)

    task.spawn(function()
        local KODE_TAME = 0x4B

        local scanFunc = function()
            local foundPet = nil
            local foundRef = nil
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") then
                        local isPet = false
                        for _, pName in ipairs(ListPets) do
                            if string.lower(obj.Name) == string.lower(pName) or (obj:GetAttribute("PetName") and string.lower(obj:GetAttribute("PetName")) == string.lower(pName)) then
                                isPet = true; break
                            end
                        end
                        if isPet and not obj:GetAttribute("Owner") and not obj:FindFirstChild("OwnerFolder") then
                            local pName = obj:GetAttribute("PetName") or obj.Name
                            local isAll = type(_G.TargetPets) == "table" and (table.find(_G.TargetPets, "All") ~= nil or #_G.TargetPets == 0)
                            local isMatch = false
                            if isAll then isMatch = true else
                                if type(_G.TargetPets) == "table" then
                                    for _, targetPet in ipairs(_G.TargetPets) do
                                        if string.find(string.lower(pName), string.lower(targetPet)) then isMatch = true break end
                                    end
                                end
                            end
                            if isMatch then
                                foundPet = obj
                                -- Find WildPetRef reference
                                pcall(function()
                                    local wildPetRefFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WildPetRef")
                                    if wildPetRefFolder then
                                        for _, ref in ipairs(wildPetRefFolder:GetChildren()) do
                                            if string.find(ref.Name, "WildPet_") then
                                                -- Match by proximity or by pet name in the ref
                                                local refPivot = ref:IsA("Model") and ref:GetPivot().Position or (ref:IsA("BasePart") and ref.Position or nil)
                                                local petPivot = obj:GetPivot().Position
                                                if refPivot and (refPivot - petPivot).Magnitude < 50 then
                                                    foundRef = ref; break
                                                end
                                            end
                                        end
                                        -- Fallback: if no proximity match, just grab any WildPetRef
                                        if not foundRef then
                                            for _, ref in ipairs(wildPetRefFolder:GetChildren()) do
                                                if string.find(ref.Name, "WildPet_") then
                                                    foundRef = ref; break
                                                end
                                            end
                                        end
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end)
            return foundPet, foundRef
        end

        local function tryTame(petObj, petRef)
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Tween ke pet (Jangan TP biar aman)
                    local TweenService = game:GetService("TweenService")
                    local targetCFrame = petObj:GetPivot() * CFrame.new(0, 2, 0)
                    local dist = (hrp.Position - targetCFrame.Position).Magnitude
                    local speed = 65 -- Studs per second
                    local tw = TweenService:Create(hrp, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                    
                    local noclip
                    noclip = game:GetService("RunService").Stepped:Connect(function()
                        if char then
                            for _, v in ipairs(char:GetDescendants()) do
                                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                            end
                        end
                    end)
                    
                    tw:Play()
                    tw.Completed:Wait()
                    if noclip then noclip:Disconnect() end
                    task.wait(0.2)
                    
                    -- Langsung eksekusi ProximityPrompt buat beli/tame (Paling Aman & Valid)
                    local prompt = petObj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    else
                        -- Fallback via PacketRemote jika Prompt belum kerender/ga ada
                        if petRef and PacketRemote then
                            local buf = buffer.create(2)
                            buffer.writeu8(buf, 0, KODE_TAME)
                            buffer.writeu8(buf, 1, 0x00)
                            pcall(function() PacketRemote:FireServer(buf, {petRef}) end)
                        end
                    end
                    
                    local petName = petObj:GetAttribute("PetName") or petObj.Name
                    pcall(function() SendNotification("🐾 Pet Tamed!", "Berhasil tame " .. petName .. "!", 5) end)
                    task.wait(2)
                end
            end)
        end

        while task.wait(1) do
            if _G.AutoTameAktif or _G.AutoServerHopPet then
                local foundPet, foundRef = scanFunc()
                if foundPet then
                    tryTame(foundPet, foundRef)
                elseif _G.AutoServerHopPet and not foundPet then
                    local hopDelay = _G.ServerHopDelay or 15
                    pcall(function() SendNotification("🔍 Scanning Server...", "Pet target tidak ditemukan. Hop dalam " .. tostring(hopDelay) .. " detik...", hopDelay) end)
                    local waited = 0
                    while waited < hopDelay do
                        task.wait(1)
                        waited = waited + 1
                        local recheck, recheckRef = scanFunc()
                        if recheck then tryTame(recheck, recheckRef); waited = -9999; break end
                        if not _G.AutoServerHopPet then waited = -9999; break end
                    end
                    if waited >= hopDelay then
                        pcall(function()
                            pcall(function() SendNotification("🌐 Mencari Server...", "Fetching server list dari Roblox...", 5) end)
                            local servers = {}
                            local success, res = pcall(function()
                                return httpRequest({
                                    Url = "https://games.roblox.com/v1/games/" .. tostring(game.GameId) .. "/servers/0?sortOrder=Asc&limit=100",
                                    Method = "GET"
                                })
                            end)
                            if success and res and res.StatusCode == 200 then
                                local decoded = HttpService:JSONDecode(res.Body)
                                if decoded and decoded.data then
                                    for _, server in ipairs(decoded.data) do
                                        if server.id ~= game.JobId and server.playing and server.playing < server.maxPlayers then
                                            table.insert(servers, server.id)
                                        end
                                    end
                                end
                            end
                            if #servers > 0 then
                                local targetJobId = servers[math.random(1, #servers)]
                                pcall(function() SendNotification("🚀 Server Hop!", "Ditemukan " .. #servers .. " server. Joining server baru...", 5) end)
                                task.wait(2)
                                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
                            else
                                pcall(function() SendNotification("⚠️ Hop Gagal", "Tidak ada server tersedia, retry dalam 10 detik...", 5) end)
                                task.wait(10)
                            end
                        end)
                    end
                end
            end
        end
    end)

    -- Auto Join from Global Pet Finder
    task.spawn(function()
        while task.wait(30) do
            if _G.AutoJoinGlobalPet and httpRequest then
                pcall(function()
                    local success, res = pcall(function()
                        return httpRequest({ Url = "https://kellyz-bot-production.up.railway.app/get-pets", Method = "GET" })
                    end)
                    if success and res and res.StatusCode == 200 then
                        local decoded = HttpService:JSONDecode(res.Body)
                        if type(decoded) == "table" and #decoded > 0 then
                            local isAll = type(_G.TargetPets) == "table" and (table.find(_G.TargetPets, "All") ~= nil or #_G.TargetPets == 0)
                            for _, petData in ipairs(decoded) do
                                if petData.jobId ~= game.JobId then
                                    local petMatch = false
                                    if isAll then petMatch = true else
                                        if type(_G.TargetPets) == "table" then
                                            for _, tp in ipairs(_G.TargetPets) do
                                                if string.find(string.lower(petData.petName or ""), string.lower(tp)) then petMatch = true; break end
                                            end
                                        end
                                    end
                                    if petMatch then
                                        pcall(function() SendNotification("Global Pet Found!", petData.petName .. " ditemukan! Joining...", 5) end)
                                        task.wait(2)
                                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, petData.jobId, LocalPlayer)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- ==========================================
-- EKSKUSI BERDASARKAN MAP
-- ==========================================
if isKaellStore or true then LoadKaellStore() end

-- ENGINE SPEEDHACK & FLY & ANTI AFK 
RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if hum and hrp and getgenv().SpeedhackSettings.Enabled and not getgenv().FlySettings.Enabled then
            if hum.MoveDirection.Magnitude > 0 then
                local targetSpeed = getgenv().SpeedhackSettings.Speed
                if targetSpeed > 16 then
                    local speedOffset = targetSpeed - 16
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (speedOffset * deltaTime))
                end
            end
        end

        if hrp and getgenv().FlySettings.Enabled then
            local bv = hrp:FindFirstChild("HackFlyBV")
            local bg = hrp:FindFirstChild("HackFlyBG")
            if not bv then
                bv = Instance.new("BodyVelocity"); bv.Name = "HackFlyBV"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0, 0, 0); bv.Parent = hrp
            end
            if not bg then
                bg = Instance.new("BodyGyro"); bg.Name = "HackFlyBG"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4; bg.Parent = hrp
            end

            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            bv.Velocity = moveDir * getgenv().FlySettings.Speed
            bg.CFrame = Camera.CFrame
            
            for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
    end)
end)

LocalPlayer.Idled:Connect(function() if getgenv().AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end)

UpdateLanguage()

-- ==========================================
-- [ AUTO LOAD CONFIG SYSTEM ]
-- ==========================================
if isfile and isfile(ConfigFolderName .. "/autoload_enabled.txt") and readfile then
    pcall(function()
        local enabled = readfile(ConfigFolderName .. "/autoload_enabled.txt")
        if enabled == "true" and isfile(ConfigFolderName .. "/autoload.txt") then
            local auto = readfile(ConfigFolderName .. "/autoload.txt")
            if auto ~= "" and isfile(ConfigFolderName .. "/" .. auto .. ".json") then
                task.delay(1.5, function() 
                    LoadConfig(auto)
                    CurrentConfigName = auto
                    if ConfigDropdownAPI then ConfigDropdownAPI:Set(auto) end
                end)
            end
        end
    end)
end
