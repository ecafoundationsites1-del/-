-- [[ ECA V4 PREMIUM - UNABRIDGED FULL MASTER VERSION ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- [1. 설정 및 에셋 데이터베이스] -------------------------------------
local uiName = "ECA_V4_Complete_Edition"
local Blacklist = { "EOQY8" } 
local visionEnabled = false
local selectedProfileImage = "" -- 인증 코드에 따라 결정될 변수

-- 이미지 리스트
local MAIN_LOGO = "rbxassetid://88458059835503"
local LOADING_LOGO = "rbxassetid://129650208804431"
local AUTH_IMAGE = "rbxassetid://74935234571734"
local BAN_IMAGE = "rbxassetid://92988766959361"

-- [핵심] 인증 코드 및 프로필 이미지 매핑 (요청하신 4개 코드)
local KeyDatabase = {
    ["ED-F"] = "rbxassetid://120138476378643",
    ["WP-12"] = "rbxassetid://131961282024031",
    ["D-T1"] = "rbxassetid://92650433759232",
    ["RTY-19"] = "rbxassetid://88458059835503"
}

-- 열화상 효과
local thermalEffect = Instance.new("ColorCorrectionEffect")
thermalEffect.Brightness = 0.1
thermalEffect.Contrast = 0.4
thermalEffect.Saturation = -1
thermalEffect.TintColor = Color3.fromRGB(150, 200, 255)
thermalEffect.Enabled = false
thermalEffect.Parent = Lighting

-- [2. 핵심 유틸리티 함수] -------------------------------------------
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [3. 기능 함수: ESP] ----------------------------------------------
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local h = p.Character:FindFirstChild("ECA_ESP")
            if not h then
                h = Instance.new("Highlight", p.Character)
                h.Name = "ECA_ESP"
            end
            h.Enabled = visionEnabled
            h.FillColor = Color3.fromRGB(0, 255, 0)
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

-------------------------------------------------------
-- [4. 화면 생성: 밴 화면]
-------------------------------------------------------
local function ShowBanScreen()
    local bannedGui = Instance.new("ScreenGui", playerGui)
    bannedGui.Name = "ECA_Banned"
    bannedGui.IgnoreGuiInset = true
    bannedGui.ResetOnSpawn = false
    bannedGui.DisplayOrder = 100000

    local bg = Instance.new("Frame", bannedGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 0, 0)

    local banImg = Instance.new("ImageLabel", bg)
    banImg.Size = UDim2.new(0, 300, 0, 300)
    banImg.Position = UDim2.new(0.5, -150, 0.4, -150)
    banImg.Image = BAN_IMAGE
    banImg.BackgroundTransparency = 1
    banImg.ImageColor3 = Color3.fromRGB(255, 0, 0)

    local banText = Instance.new("TextLabel", bg)
    banText.Size = UDim2.new(1, 0, 0, 60); banText.Position = UDim2.new(0, 0, 0.7, 0); banText.Text = "ACCESS DENIED"; banText.TextColor3 = Color3.fromRGB(255, 0, 0); banText.TextSize = 50; banText.Font = Enum.Font.SourceSansBold; banText.BackgroundTransparency = 1
end

-------------------------------------------------------
-- [5. 화면 생성: 실제 메뉴 (인증 성공 후)]
-------------------------------------------------------
local function LoadActualMenu()
    local menuGui = Instance.new("ScreenGui", playerGui)
    menuGui.Name = "ECA_MainMenu"
    menuGui.ResetOnSpawn = false
    menuGui.DisplayOrder = 20000

    local mainFrame = Instance.new("Frame", menuGui)
    mainFrame.Size = UDim2.new(0, 500, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    local corner = Instance.new("UICorner", mainFrame); corner.CornerRadius = UDim.new(0, 8)
    MakeDraggable(mainFrame)

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local topCorner = Instance.new("UICorner", topBar); topCorner.CornerRadius = UDim.new(0, 8)
    
    local topLogo = Instance.new("ImageLabel", topBar)
    topLogo.Size = UDim2.new(0, 30, 0, 30)
    topLogo.Position = UDim2.new(0, 10, 0, 5)
    topLogo.Image = MAIN_LOGO
    topLogo.BackgroundTransparency = 1
    
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50); closeBtn.BackgroundTransparency = 1; closeBtn.TextSize = 20

    local sideBar = Instance.new("Frame", mainFrame)
    sideBar.Position = UDim2.new(0, 0, 0, 40); sideBar.Size = UDim2.new(0, 130, 1, -40); sideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); sideBar.BorderSizePixel = 0
    
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Position = UDim2.new(0, 140, 0, 50); contentFrame.Size = UDim2.new(1, -150, 1, -60); contentFrame.BackgroundTransparency = 1

    local function ShowTab(tabName)
        contentFrame:ClearAllChildren()
        if tabName == "Vision" then
            local toggle = Instance.new("TextButton", contentFrame)
            toggle.Size = UDim2.new(1, 0, 0, 60); toggle.Text = visionEnabled and "열화상 & 벽뚫: ON" or "열화상 & 벽뚫: OFF"
            toggle.BackgroundColor3 = visionEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
            toggle.TextColor3 = Color3.fromRGB(255,255,255); toggle.TextSize = 18; Instance.new("UICorner", toggle)
            toggle.MouseButton1Click:Connect(function()
                visionEnabled = not visionEnabled
                thermalEffect.Enabled = visionEnabled
                toggle.Text = visionEnabled and "열화상 & 벽뚫: ON" or "열화상 & 벽뚫: OFF"
                toggle.BackgroundColor3 = visionEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
                if visionEnabled then task.spawn(function() while visionEnabled do UpdateESP() task.wait(1) end end) end
            end)
        elseif tabName == "Profile" then
            local pImg = Instance.new("ImageLabel", contentFrame)
            pImg.Size = UDim2.new(0, 80, 0, 80)
            pImg.Position = UDim2.new(0.5, -40, 0, 0)
            pImg.Image = selectedProfileImage -- [핵심] 입력 코드에 따른 이미지 출력
            pImg.BackgroundTransparency = 1
            Instance.new("UICorner", pImg).CornerRadius = UDim.new(1,0)

            local pName = Instance.new("TextLabel", contentFrame); pName.Size = UDim2.new(1, 0, 0, 30); pName.Position = UDim2.new(0, 0, 0, 90); pName.Text = "USER: " .. lp.Name; pName.TextColor3 = Color3.fromRGB(255,255,255); pName.BackgroundTransparency = 1; pName.TextSize = 16
            local pRank = Instance.new("TextLabel", contentFrame); pRank.Size = UDim2.new(1, 0, 0, 30); pRank.Position = UDim2.new(0, 0, 0, 120); pRank.Text = "RANK: PREMIUM"; pRank.TextColor3 = Color3.fromRGB(0, 255, 127); pRank.BackgroundTransparency = 1; pRank.TextSize = 16
        end
    end

    local vBtn = Instance.new("TextButton", sideBar); vBtn.Size = UDim2.new(0.9,0,0,35); vBtn.Position = UDim2.new(0.05,0,0,10); vBtn.Text = "시야 목록"; Instance.new("UICorner", vBtn)
    vBtn.MouseButton1Click:Connect(function() ShowTab("Vision") end)
    local pBtn = Instance.new("TextButton", sideBar); pBtn.Size = UDim2.new(0.9,0,0,35); pBtn.Position = UDim2.new(0.05,0,0,50); pBtn.Text = "내 프로필"; Instance.new("UICorner", pBtn)
    pBtn.MouseButton1Click:Connect(function() ShowTab("Profile") end)
    
    ShowTab("Vision")

    local openBtn = Instance.new("TextButton", menuGui)
    openBtn.Size = UDim2.new(0, 60, 0, 60); openBtn.Position = UDim2.new(0, 20, 0.5, -30); openBtn.Text = "열기"; openBtn.Visible = false; openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); openBtn.TextColor3 = Color3.fromRGB(0, 255, 127); Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0); MakeDraggable(openBtn)

    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; openBtn.Visible = true end)
    openBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true; openBtn.Visible = false end)
end

-------------------------------------------------------
-- [6. 화면 생성: 인증창]
-------------------------------------------------------
local function LoadMainHub()
    local authGui = Instance.new("ScreenGui", playerGui)
    authGui.Name = "ECA_AuthHub"
    authGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", authGui)
    frame.Size = UDim2.new(0, 400, 0, 450)
    frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", frame)
    
    local topL = Instance.new("ImageLabel", frame); topL.Size = UDim2.new(0, 50, 0, 50); topL.Position = UDim2.new(0.5, -25, 0, 10); topL.Image = MAIN_LOGO; topLogo.BackgroundTransparency = 1
    
    -- [인증창 이미지 복구]
    local midImg = Instance.new("ImageLabel", frame)
    midImg.Size = UDim2.new(0, 300, 0, 200)
    midImg.Position = UDim2.new(0.5, -150, 0.15, 0)
    midImg.Image = AUTH_IMAGE
    midImg.BackgroundTransparency = 1

    local input = Instance.new("TextBox", frame); input.Size = UDim2.new(0.7, 0, 0, 40); input.Position = UDim2.new(0.15, 0, 0.65, 0); input.PlaceholderText = "코드를 입력하세요..."; input.BackgroundColor3 = Color3.fromRGB(240, 240, 240); input.Text = ""
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.7, 0, 0, 40); btn.Position = UDim2.new(0.15, 0, 0.78, 0); btn.BackgroundColor3 = Color3.fromRGB(0, 255, 127); btn.Text = "인증하기"; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold

    btn.MouseButton1Click:Connect(function()
        local code = input.Text:match("^%s*(.-)%s*$")
        if KeyDatabase[code] then
            selectedProfileImage = KeyDatabase[code] -- 선택한 코드의 이미지 저장
            authGui:Destroy()
            LoadActualMenu()
        else
            input.Text = ""
            input.PlaceholderText = "잘못된 코드입니다!"
        end
    end)
end

-------------------------------------------------------
-- [7. 로딩 시퀀스: 세분화된 문구 복구]
-------------------------------------------------------
local function startLoading()
    -- 밴 체크
    for _, name in pairs(Blacklist) do
        if string.lower(lp.Name) == string.lower(name) then ShowBanScreen(); return end
    end

    local loadingGui = Instance.new("ScreenGui", playerGui)
    loadingGui.IgnoreGuiInset = true
    loadingGui.ResetOnSpawn = false
    loadingGui.DisplayOrder = 30000

    local bg = Instance.new("Frame", loadingGui); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    local mainFrame = Instance.new("Frame", bg); mainFrame.Size = UDim2.new(0, 450, 0, 300); mainFrame.Position = UDim2.new(0.5, -225, 0.5, -150); mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", mainFrame)
    
    local logo1 = Instance.new("ImageLabel", mainFrame); logo1.Size = UDim2.new(0, 120, 0, 120); logo1.Position = UDim2.new(0.25, -60, 0.1, 0); logo1.Image = LOADING_LOGO; logo1.BackgroundTransparency = 1
    local logo2 = Instance.new("ImageLabel", mainFrame); logo2.Size = UDim2.new(0, 120, 0, 120); logo2.Position = UDim2.new(0.75, -60, 0.1, 0); logo2.Image = MAIN_LOGO; logo2.BackgroundTransparency = 1
    
    local status = Instance.new("TextLabel", mainFrame); status.Size = UDim2.new(1, 0, 0, 30); status.Position = UDim2.new(0, 0, 0.65, 0); status.Text = "Initializing..."; status.TextColor3 = Color3.fromRGB(0, 255, 127); status.Font = Enum.Font.Code; status.TextSize = 18; status.BackgroundTransparency = 1
    local barBg = Instance.new("Frame", mainFrame); barBg.Size = UDim2.new(0.8, 0, 0, 4); barBg.Position = UDim2.new(0.1, 0, 0.85, 0); barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local bar = Instance.new("Frame", barBg); bar.Size = UDim2.new(0, 0, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(0, 255, 127)

    task.spawn(function()
        -- [요청하신 세분화된 문구 리스트]
        local steps = {
            {s = "1단계: 안티치트 우회중...", c = Color3.fromRGB(255, 50, 50)},
            {s = "2단계: 시스템 침투 50%", c = Color3.fromRGB(255, 180, 0)},
            {s = "3단계: 보안 프로토콜 무력화", c = Color3.fromRGB(0, 255, 127)},
            {s = "4단계: PREMIUM 데이터 로드 완료", c = Color3.fromRGB(255, 255, 255)}
        }
        for i, step in ipairs(steps) do
            status.Text = step.s
            status.TextColor3 = step.c
            bar:TweenSize(UDim2.new(i/4, 0, 1, 0), "Out", "Quad", 1)
            task.wait(1.2)
        end
        loadingGui:Destroy()
        LoadMainHub()
    end)
end

-- 실행
startLoading()

