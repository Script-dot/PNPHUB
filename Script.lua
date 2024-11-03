local mapIDs = {16732694052, 1586649844}

if not table.find(mapIDs, game.PlaceId) then
    game.Players.LocalPlayer:Kick("คุณโดนเตะออกจากเกม")
    return
end

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "PNP_HUB V6.PRO",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest"
})

-- แท็บหลัก
local MainTab = Window:MakeTab({
    Name = "หลัก",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = MainTab:AddSection({
    Name = "เมนูฟาร์ม"
})

local function ShowNotification(message)
    OrionLib:MakeNotification({
        Name = "การแจ้งเตือน",
        Content = message,
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

local AutoFarmEnabled = false
local CastEnabled = false
local Rod
local Progress = false
local Finished = false
local runCount = 0

MainTab:AddButton({
    Name = "เริ่มฟาร์มอัตโนมัติ",
    Callback = function()
        runCount = runCount + 1
        if runCount > 2 then
            game.Players.LocalPlayer:Kick("กดรันเกิน 2 รอบแล้ว ขออภัย!")
            return
        end
        
        AutoFarmEnabled = true
        ShowNotification("เริ่มฟาร์มอัตโนมัติแล้ว")

        local Players = game:GetService('Players')
        local LocalPlayer = Players.LocalPlayer
        local GuiService = game:GetService('GuiService')
        local VirtualInputManager = game:GetService('VirtualInputManager')
        local ReplicatedStorage = game:GetService('ReplicatedStorage')

        LocalPlayer.Character.ChildAdded:Connect(function(Child)
            if Child:IsA('Tool') and Child.Name:lower():find('rod') then
                Rod = Child
            end
        end)

        LocalPlayer.Character.ChildRemoved:Connect(function(Child)
            if Child == Rod then
                Finished = false
                Progress = false
                GuiService.SelectedObject = nil
                Rod = nil
            end
        end)

        LocalPlayer.PlayerGui.DescendantAdded:Connect(function(Descendant)
            if Descendant.Name == 'button' and Descendant.Parent.Name == 'safezone' then
                task.wait(0.1)
                GuiService.SelectedObject = Descendant
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            elseif Descendant.Name == 'playerbar' and Descendant.Parent.Name == 'bar' then
                Finished = true
                Descendant:GetPropertyChangedSignal('Position'):Wait()
                ReplicatedStorage.events.reelfinished:FireServer(100, true)
            end
        end)

        LocalPlayer.PlayerGui.DescendantRemoving:Connect(function(Descendant)
            if Descendant.Name == 'reel' then
                Finished = false
                Progress = false
            end
        end)

        coroutine.wrap(function()
            while true do
                if CastEnabled then
                    local args = { [1] = 100, [2] = 1 }
                    local character = LocalPlayer.Character
                    if character then
                        for _, obj in pairs(character:GetChildren()) do
                            if obj:FindFirstChild("events") and obj.events:FindFirstChild("cast") then
                                obj.events.cast:FireServer(unpack(args))
                                break
                            end
                        end
                    else
                        warn("ไม่พบตัวละคร!")
                    end
                end
                task.wait(1)
            end
        end)()
    end    
})

MainTab:AddToggle({
    Name = "หย่อนเหยื่อ",
    Default = false,
    Callback = function(v)
        CastEnabled = v
        if CastEnabled then
            ShowNotification("เปิดใช้งานการหย่อนเหยื่อ")
            coroutine.wrap(function()
                while CastEnabled do
                    local LocalPlayer = game:GetService("Players").LocalPlayer
                    local backpack = LocalPlayer.Backpack
                    local targetItem = nil
                    
                    for _, item in ipairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and item.Name:find("Rod") then
                            targetItem = item
                            break
                        end
                    end
                    
                    if targetItem then
                        local args = { [1] = targetItem }
                        LocalPlayer.PlayerGui.hud.safezone.backpack.events.equip:FireServer(unpack(args))
                        targetItem.events.cast:FireServer(100, 1)
                    else
                        warn("ไม่พบอุปกรณ์ที่ตรงตามเงื่อนไข")
                    end
                    task.wait(1)
                end
            end)()
            coroutine.wrap(function()
                while CastEnabled do
                    if not AutoFarmEnabled then
                        ShowNotification("โปรดกดปุ่มเริ่มฟาร์มอัตโนมัติหลังจากหย่อนเหยื่อ") 
                        task.wait(5)
                    else
                        break
                    end
                end
            end)()
        else
            ShowNotification("ปิดใช้งานการหย่อนเหยื่อ")
        end
    end    
})

MainTab:AddToggle({
    Name = "ขายปลาทั้งหมด",
    Default = false,
    Callback = function(v)
        if v then
            coroutine.wrap(function()
                while v do
                    workspace.world.npcs:FindFirstChild("Marc Merchant").merchant.sellall:InvokeServer()
                    task.wait(1) 
                end
            end)()
        else
            ShowNotification("ขายปลาทั้งหมดถูกปิดใช้งาน")
        end
    end    
})

MainTab:AddButton({
    Name = "ขายปลาหนึ่งตัว",
    Callback = function()
        workspace.world.npcs:FindFirstChild("Marc Merchant").merchant.sell:InvokeServer()
    end    
})

-- แท็บวาร์ป
local WarpTab = Window:MakeTab({
    Name = "วาร์ปไปเกาะ",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = WarpTab:AddSection({
    Name = "เมนูวาร์ปไปเกาะ"
})

local DropdownOptions = {"Moosewood", "ที่เอ็นชาตเบ็ด", "Roslit", "Snowcap", "Sunstone", "ถ้ำใต้น้ำวน"}
local SelectedOption

WarpTab:AddDropdown({
    Name = "เลือกตัวเลือก",
    Flag = "DropdownOption",
    Options = DropdownOptions,
    Default = DropdownOptions[1],
    Callback = function(Selected)
        SelectedOption = Selected
        print("คุณเลือก: " .. Selected)
    end    
})

WarpTab:AddButton({
    Name = "ยืนยันตัวเลือก",
    Callback = function()
        if not SelectedOption then
            print("กรุณาเลือกตัวเลือกก่อน!")
            return
        end

        local player = game.Players.LocalPlayer
        local humanoidRootPart = (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        local targetCFrame

        if SelectedOption == "Moosewood" then
            targetCFrame = CFrame.new(500.488434, 147.40181, 219.991364)
        elseif SelectedOption == "ที่เอ็นชาตเบ็ด" then
            targetCFrame = CFrame.new(1294.57568, -807.365051, -307.565216)
        elseif SelectedOption == "Roslit" then
            targetCFrame = CFrame.new(-1510.43311, 129.750626, 615.421875)
        elseif SelectedOption == "Snowcap" then
            targetCFrame = CFrame.new(2671.10767, 148.350555, 2388.95117)
        elseif SelectedOption == "Sunstone" then
            targetCFrame = CFrame.new(-902.682922, 136.266068, -1128.6886)
        elseif SelectedOption == "ถ้ำใต้น้ำวน" then
            targetCFrame = CFrame.new(-78.5218506, -482.720367, 1040.32788)
        end

        if targetCFrame then
            local tween = game:GetService("TweenService"):Create(humanoidRootPart, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
        end
    end    
})

local Section = WarpTab:AddSection({
    Name = "ไปฟาร์มเกาะอื่น"
})

local warpLocations = {
    {Name = "Rod", CFrame = CFrame.new(392.438293, 140.031982, 339.21286)},
    {Name = "ที่เอ็นชาตเบ็ด", CFrame = CFrame.new(1294.57568, -807.365051, -307.565216)},
    {Name = "Roslit", CFrame = CFrame.new(-1510.43311, 129.750626, 615.421875)},
    {Name = "Snowcap", CFrame = CFrame.new(2671.10767, 148.350555, 2388.95117)},
    {Name = "Sunstone", CFrame = CFrame.new(-902.682922, 136.266068, -1128.6886)},
    {Name = "ถ้ำใต้น้ำวน", CFrame = CFrame.new(-78.5218506, -482.720367, 1040.32788)}
}

for _, location in ipairs(warpLocations) do
    WarpTab:AddButton({
        Name = location.Name,
        Callback = function()
            local Tween = game:GetService("TweenService")
            Tween:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
            {CFrame = location.CFrame}):Play()
        end    
    })
end

-- แท็บการตั้งค่า
local SettingsTab = Window:MakeTab({
    Name = "การตั้งค่า",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Section = SettingsTab:AddSection({
    Name = "เมนูตั้งค่า"
})

SettingsTab:AddButton({
    Name = "โหมดกลางวัน",
    Default = false,
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 12
        lighting.Changed:Connect(function()
            lighting.ClockTime = 12
        end)
        ShowNotification("เปิดโหมดกลางวันแล้ว!")
    end
})

SettingsTab:AddButton({
    Name = "โหมดกลางคืน",
    Default = false,
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 0
        lighting.Changed:Connect(function()
            lighting.ClockTime = 0
        end)
        ShowNotification("เปิดโหมดกลางวคืนแล้ว!")
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function rejoinServer()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, player)
end

SettingsTab:AddButton({
    Name = "รีจอย",
    Callback = function()
        rejoinServer()
    end
})

SettingsTab:AddButton({
    Name = "ออกจากเกม",
    Callback = function()
        player:Kick("คุณโดนเตะออกจากเกม")
    end
})

local isBlurEnabled = false

SettingsTab:AddButton({
    Name = "เปิด/ปิดเบลอหน้าจอ",
    Callback = function()
        local lighting = game:GetService("Lighting")
        if isBlurEnabled then
            if lighting:FindFirstChild("ScreenBlur") then
                lighting.ScreenBlur:Destroy()
            end
            isBlurEnabled = false
        else
            local blur = Instance.new("BlurEffect")
            blur.Name = "ScreenBlur"
            blur.Size = 24
            blur.Parent = lighting
            isBlurEnabled = true
        end
    end
})

