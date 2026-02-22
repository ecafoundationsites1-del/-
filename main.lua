-- [ ECA V4 PREMIUM - 통합 및 업그레이드 버전 ] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 변수] -----------------------------------------------
local uiName = "ECA_V4_Complete_Edition"
local Blacklist = { "EOQY8" } 
local correctKey = "ECA-9123"
local visionEnabled = false

-- 이미지 에셋 ID
local MAIN_LOGO = "rbxassetid://88458059835503"
local LOADING_LOGO = "rbxassetid://129650208804431"

-- 열화상 효과 설정
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-- [2. 드래그 기능 함수 (PC & 모바일 공용)] -------------------------
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [3. ESP 업데이트 함수] -------------------------------------------
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local highlight = player.Character:FindFirstChild("ECA_ESP")
            if not highlight then
                highlight = Instance.new("Highlight", player.Character)
                highlight.Name = "ECA_ESP"
            end
            highlight.Enabled = visionEnabled
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-------------------------------------------------------
-- [4. 메인 메뉴 (사이드바 및 탭 시스템)]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.DisplayOrder = 20000

    -- 메인 프레임
    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 500, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    MakeDraggable(mainFrame)

    -- 상단바 (로고 및 X버튼)
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", topBar)
    
    local topLogo = Instance.new("ImageLabel", topBar)
    topLogo.Size = UDim2.new(0, 30, 0, 30)
    topLogo.Position = UDim2.new(0, 10, 0, 5)
    topLogo.Image = MAIN_LOGO
    topLogo.BackgroundTransparency = 1
    
    local topTitle = Instance.new("TextLabel", topBar)
    topTitle.Text = "ECA V4 PREMIUM"
    topTitle.Position = UDim2.new(0, 50, 0, 0)
    topTitle.Size = UDim2.new(0, 200, 1, 0)
    topTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.Font = Enum.Font.SourceSansBold
    topTitle.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextSize = 20
    closeBtn.BackgroundTransparency = 1

    -- 사이드바
    local sideBar = Instance.new("Frame", mainFrame)
    sideBar.Position = UDim2.new(0, 0, 0, 40)
    sideBar.Size = UDim2.new(0, 130, 1, -40)
    sideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sideBar.BorderSizePixel = 0

    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Position = UDim2.new(0, 140, 0, 50)
    contentFrame.Size = UDim2.new(1, -150, 1, -60)
    contentFrame.BackgroundTransparency = 1

    -- 탭 콘텐츠 렌더링 함수
    local function ShowTab(tabName)
        contentFrame:ClearAllChildren()
        if tabName == "Vision" then
            local toggle = Instance.new("TextButton", contentFrame)
            toggle.Size = UDim2.new(1, 0, 0, 60)
            toggle.Text = visionEnabled and "열화상 & 벽뚫: ON" or "열화상 & 벽뚫: OFF"
            toggle.BackgroundColor3 = visionEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle.TextSize = 20
            Instance.new("UICorner", toggle)
            
            toggle.MouseButton1Click:Connect(function()
                visionEnabled = not visionEnabled
                thermalEffect.Enabled = visionEnabled
                toggle.Text = visionEnabled and "열화상 & 벽뚫: ON" or "열화상 & 벽뚫: OFF"
                toggle.BackgroundColor3 = visionEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
                if visionEnabled then
                    task.spawn(function()
                        while visionEnabled do UpdateESP() task.wait(1) end
                    end)
                end
            end)
        elseif tabName == "Profile" then
            local pImg = Instance.new("ImageLabel", contentFrame)
            pImg.Size = UDim2.new(0, 80, 0, 80)
            pImg.Position = UDim2.new(0.5, -40, 0, 10)
            pImg.Image = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            Instance.new("UICorner", pImg).CornerRadius = UDim.new(1, 0)
            
            local pName = Instance.new("TextLabel", contentFrame)
            pName.Size = UDim2.new(1, 0, 0, 30)
            pName.Position = UDim2.new(0, 0, 0, 100)
            pName.Text = "유저: " .. lp.Name
            pName.TextColor3 = Color3.fromRGB(255, 255, 255)
            pName.BackgroundTransparency = 1
            
            local pRank = Instance.new("TextLabel", contentFrame)
            pRank.Size = UDim2.new(1, 0, 0, 30)
            pRank.Position = UDim2.new(0, 0, 0, 130)
            pRank.Text = "RANK: ECA PREMIUM"
            pRank.TextColor3 = Color3.fromRGB(0, 255, 127)
            pRank.BackgroundTransparency = 1
        end
    end

    -- 사이드바 버튼 생성
    local function CreateTabBtn(name, pos, text)
        local btn = Instance.new("TextButton", sideBar)
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, pos)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function() ShowTab(name) end)
    end

    CreateTabBtn("Vision", 10, "시야 목록")
    CreateTabBtn("Profile", 50, "내 프로필")
    ShowTab("Vision")

    -- 최소화 기능 (열기 버튼)
    local openBtn = Instance.new("TextButton", menuGui)
    openBtn.Size = UDim2.new(0, 60, 0, 60)
    openBtn.Position = UDim2.new(0, 20, 0.5, -30)
    openBtn.Text = "열기"
    openBtn.Visible = false
    openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    openBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", openBtn).Color = Color3.fromRGB(0, 255, 127)
    MakeDraggable(openBtn)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
    end)
end

-------------------------------------------------------
-- [기존 기능 통합: 인증, 연출, 로딩]
-------------------------------------------------------

local function ShowBanScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.IgnoreGuiInset = true
    local bg = Instance.new("Frame", bannedGui); bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(15,0,0)
    local banText = Instance.new("TextLabel", bg); banText.Size = UDim2.new(1,0,0,50); banText.Position = UDim2.new(0,0,0.5,0); banText.Text = "ACCESS DENIED"; banText.TextColor3 = Color3.fromRGB(255,0,0); banText.TextSize = 60; banText.Font = Enum.Font.SourceSansBold; banText.BackgroundTransparency = 1
end

local function PlayMergeAnimation()
    local transGui = Instance.new("ScreenGui", playerGui); transGui.IgnoreGuiInset = true; transGui.DisplayOrder = 15000
    local pieces = {}
    local targets = {UDim2.new(0,0,0,0), UDim2.new(0.5,0,0,0), UDim2.new(0,0,0.5,0), UDim2.new(0.5,0,0.5,0)}
    for i = 1, 4 do
        local p = Instance.new("Frame", transGui); p.Size = UDim2.new(0.5, 0, 0.5, 0); p.BackgroundColor3 = Color3.fromRGB(0, 0, 0); p.BorderSizePixel = 0
        p.Position = UDim2.new(i % 2 == 0 and 1.5 or -0.5, 0, i > 2 and 1.5 or -0.5, 0); pieces[i] = p
        TweenService:Create(p, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targets[i]}):Play()
    end
    task.wait(0.8); LoadActualMenu()
    for i = 1, 4 do TweenService:Create(pieces[i], TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play() end
    task.wait(0.5); transGui:Destroy()
end

local function LoadMainHub()
    local mainGui = Instance.new("ScreenGui", playerGui); mainGui.Name = uiName
    local frame = Instance.new("Frame", mainGui); frame.Size = UDim2.new(0, 400, 0, 450); frame.Position = UDim2.new(0.5, -200, 0.5, -225); frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", frame)
    local topLogo = Instance.new("ImageLabel", frame); topLogo.Size = UDim2.new(0, 50, 0, 50); topLogo.Position = UDim2.new(0.5, -25, 0, 10); topLogo.Image = MAIN_LOGO; topLogo.BackgroundTransparency = 1
    local img = Instance.new("ImageLabel", frame); img.Size = UDim2.new(0, 300, 0, 200); img.Position = UDim2.new(0.5, -150, 0.15, 0); img.Image = "rbxassetid://74935234571734"; img.BackgroundTransparency = 1
    local input = Instance.new("TextBox", frame); input.Size = UDim2.new(0.7, 0, 0, 40); input.Position = UDim2.new(0.15, 0, 0.65, 0); input.PlaceholderText = "ECA-9123 입력..."; input.BackgroundColor3 = Color3.fromRGB(240, 240, 240); input.Text = ""
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.7, 0, 0, 40); btn.Position = UDim2.new(0.15, 0, 0.78, 0); btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127); btn.Text = "인증하기"; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold
    btn.MouseButton1Click:Connect(function()
        if input.Text:match("^%s*(.-)%s*$") == correctKey then mainGui:Destroy(); PlayMergeAnimation() else input.Text = "" end
    end)
end

local function startLoading()
    for _, name in pairs(Blacklist) do if string.lower(lp.Name) == string.lower(name) then ShowBanScreen(); return end end
    local screenGui = Instance.new("ScreenGui", playerGui); screenGui.IgnoreGuiInset = true; screenGui.DisplayOrder = 30000
    local bg = Instance.new("Frame", screenGui); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    local mainFrame = Instance.new("Frame", bg); mainFrame.Size = UDim2.new(0, 450, 0, 300); mainFrame.Position = UDim2.new(0.5, -225, 0.5, -150); mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", mainFrame)
    
    local logo1 = Instance.new("ImageLabel", mainFrame); logo1.Size = UDim2.new(0, 120, 0, 120); logo1.Position = UDim2.new(0.25, -60, 0.1, 0); logo1.Image = LOADING_LOGO; logo1.BackgroundTransparency = 1
    local logo2 = Instance.new("ImageLabel", mainFrame); logo2.Size = UDim2.new(0, 120, 0, 120); logo2.Position = UDim2.new(0.75, -60, 0.1, 0); logo2.Image = MAIN_LOGO; logo2.BackgroundTransparency = 1
    
    local status = Instance.new("TextLabel", mainFrame); status.Size = UDim2.new(1, 0, 0, 20); status.Position = UDim2.new(0, 0, 0.75, 0); status.Text = "Initializing..."; status.TextColor3 = Color3.fromRGB(0, 255, 127); status.BackgroundTransparency = 1
    local barBg = Instance.new("Frame", mainFrame); barBg.Size = UDim2.new(0.8, 0, 0, 4); barBg.Position = UDim2.new(0.1, 0, 0.9, 0); barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); local bar = Instance.new("Frame", barBg); bar.Size = UDim2.new(0, 0, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

    task.spawn(function()
        for i = 1, 4 do
            bar:TweenSize(UDim2.new(i/4, 0, 1, 0), "Out", "Quad", 0.8)
            task.wait(1)
        end
        screenGui:Destroy(); LoadMainHub()
    end)
end

startLoading()

