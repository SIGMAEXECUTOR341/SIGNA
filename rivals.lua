local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pGui = player:WaitForChild("PlayerGui")

if pGui:FindFirstChild("DatoGodMode") then pGui.DatoGodMode:Destroy() end

-- --- SETTINGS ---
local aimbotEnabled = false
local aimPart = "Head"
local smoothPercent = 15
local fovRadius = 110
local aimKey = Enum.UserInputType.MouseButton2
local colorTarget = "Box"
local isBinding = false

local espSettings = {
    Box = false, Skeleton = false, FOV = true,
    BoxColor = Color3.fromRGB(0, 255, 120),
    SkeletonColor = Color3.fromRGB(255, 255, 255)
}

-- --- UI SETUP ---
local screenGui = Instance.new("ScreenGui", pGui); screenGui.Name = "DatoGodMode"
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 380, 0, 360); mainFrame.Position = UDim2.new(0.5, -190, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", mainFrame)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(60, 60, 70)

-- --- TOGGLE (RIGHT SHIFT) ---
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- SIDEBAR & TABS (Same as before)
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 100, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Instance.new("UICorner", sidebar)
local datoLabel = Instance.new("TextLabel", sidebar)
datoLabel.Size = UDim2.new(1, 0, 0, 50); datoLabel.Text = "dato"; datoLabel.TextColor3 = Color3.new(1,1,1); datoLabel.TextSize = 30; datoLabel.Font = Enum.Font.PatrickHand; datoLabel.BackgroundTransparency = 1

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, -120, 1, -20); container.Position = UDim2.new(0, 110, 0, 10); container.BackgroundTransparency = 1
local vFrame = Instance.new("Frame", container); vFrame.Size = UDim2.new(1,0,1,0); vFrame.BackgroundTransparency = 1; vFrame.Visible = true
local aFrame = Instance.new("Frame", container); aFrame.Size = UDim2.new(1,0,1,0); aFrame.BackgroundTransparency = 1; aFrame.Visible = false
Instance.new("UIListLayout", vFrame).Padding = UDim.new(0, 8)
Instance.new("UIListLayout", aFrame).Padding = UDim.new(0, 8)

local function makeTab(txt, y, target)
    local b = Instance.new("TextButton", sidebar); b.Size = UDim2.new(0.8, 0, 0, 35); b.Position = UDim2.new(0.1, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() vFrame.Visible = false; aFrame.Visible = false; target.Visible = true end)
end
makeTab("Visuals", 65, vFrame); makeTab("Aimbot", 110, aFrame)

-- --- TOGGLES & SLIDER ---
local function createToggle(txt, parent, cb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(40, 40, 45); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() cb(b) end)
end

createToggle("Box ESP: OFF", vFrame, function(b) espSettings.Box = not espSettings.Box; b.Text = "Box ESP: " .. (espSettings.Box and "ON" or "OFF") end)
createToggle("Skeleton: OFF", vFrame, function(b) espSettings.Skeleton = not espSettings.Skeleton; b.Text = "Skeleton: " .. (espSettings.Skeleton and "ON" or "OFF") end)
createToggle("Aimbot: OFF", aFrame, function(b) aimbotEnabled = not aimbotEnabled; b.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF") end)

-- --- RENDER ENGINE (RIVALS COMPATIBLE) ---
local drawings = {}
local function createL() local l = Drawing.new("Line"); l.Thickness = 1; l.Visible = false; return l end
local function getDraw(p)
    if not drawings[p] then 
        drawings[p] = {Box = Drawing.new("Square"), Skel = {H2T=createL(), T2LA=createL(), T2RA=createL(), T2LL=createL(), T2RL=createL()}}
        drawings[p].Box.Thickness = 1
    end
    return drawings[p]
end

local function getChar(p)
    return p.Character or (workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild(p.Name))
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        local draw = getDraw(p)
        local char = getChar(p)
        
        if p ~= player and char and char:FindFirstChild("Head") then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char.Head
            local rootP, on = camera:WorldToViewportPoint(root.Position)

            if on then
                local headP = camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                local legP = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(headP.Y - legP.Y)
                local w = h * 0.55
                
                draw.Box.Visible = espSettings.Box
                draw.Box.Size = Vector2.new(w, h)
                draw.Box.Position = Vector2.new(rootP.X - w/2, rootP.Y - h/2)
                draw.Box.Color = espSettings.BoxColor
                
                for _, l in pairs(draw.Skel) do l.Visible = espSettings.Skeleton; l.Color = espSettings.SkeletonColor end
                if espSettings.Skeleton then
                    local headS = camera:WorldToViewportPoint(char.Head.Position)
                    draw.Skel.H2T.From = Vector2.new(headS.X, headS.Y); draw.Skel.H2T.To = Vector2.new(rootP.X, rootP.Y)
                    -- Skeleton simplified for speed/compatibility in Rivals
                    draw.Skel.T2LA.Visible = false; draw.Skel.T2RA.Visible = false; draw.Skel.T2LL.Visible = false; draw.Skel.T2RL.Visible = false
                end
            else
                draw.Box.Visible = false; for _, l in pairs(draw.Skel) do l.Visible = false end
            end
        else
            draw.Box.Visible = false; for _, l in pairs(draw.Skel) do l.Visible = false end
        end
    end
end)

-- DRAG MENU
local d, s, sp; mainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d=true s=i.Position sp=mainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position-s mainFrame.Position=UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d=false end end)
