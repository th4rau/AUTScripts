
repeat
    task.wait()
until game:IsLoaded()

StingrayLoaded = false
if not getgenv().StingrayLoaded then
    getgenv().StingrayLoaded = true
    -- Load Configs--

    -- Webhook
    pcall(function()
        if getgenv().Webhook then
            writefile("JJI_Webhook.txt", getgenv().Webhook)
        end
        if readfile("JJI_Webhook.txt") then
            getgenv().Webhook = readfile("JJI_Webhook.txt")
        end
    end)

    -- Init --
    local StartTime = tick()
    local LocalPlayer = game:GetService("Players").LocalPlayer

    repeat
        task.wait()
    until LocalPlayer.Character
    local Root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

    -- Paths & Services --
    local TS = game:GetService("TweenService")
    local RS = game:GetService("ReplicatedStorage")
    local Debris = game:GetService("Debris")
    local Lighting = game:GetService("Lighting")

    local Objects = workspace:WaitForChild("Objects")
    local Mobs = Objects:WaitForChild("Mobs")
    local Spawns = Objects:WaitForChild("Spawns")
    local Drops = Objects:WaitForChild("Drops")
    local Effects = Objects:WaitForChild("Effects")
    local Destructibles = Objects:WaitForChild("Destructibles")
    local Mission = Objects:WaitForChild("MissionItems")

    local LootUI = LocalPlayer.PlayerGui:WaitForChild("Loot")
    local Flip = LootUI:WaitForChild("Frame"):WaitForChild("Flip")
    local Replay = LocalPlayer.PlayerGui:WaitForChild("ReadyScreen"):WaitForChild("Frame"):WaitForChild("Replay")

    local ServerRemotes = RS:WaitForChild("Remotes"):WaitForChild("Server")
    local ClientRemotes = RS:WaitForChild("Remotes"):WaitForChild("Client")

    -- Consts --
    local Highlight = {"5 Demon Finger", "Maximum Scroll", "Domain Shard", "Iridescent Lotus", "Polished Beckoning Cat",
                       "Sapphire Lotus", "Fortune Gourd", "Demon Finger", "Energy Nature Scroll", "Purified Curse Hand",
                       "Jade Lotus", "Cloak of Inferno", "Split Soul", "Soul Robe", "Playful Cloud",
                       "Ocean Blue Sailor's Vest", "Deep Black Sailor's Vest", "Demonic Tobi", "Demonic Robe",
                       "Rotten Chains"}
    local Curses = {"Low Level Curse", "Grade 4 Curse", "Grade 3 Curse", "Grade 2 Curse", "Grade 1 Curse",
                    "Special Grade Curse"}

    -- Black screen check & Fail safe--
    task.spawn(function()
        task.wait(600)
        while true do
            game:GetService("TeleportService"):Teleport(10450270085)
            task.wait(10)
        end
    end)

    if game.PlaceId == 10450270085 then
        task.spawn(function()
            while true do
                game:GetService("TeleportService"):Teleport(78904562518018)
                task.wait(10)
            end
        end)
    elseif game.PlaceId == 78904562518018 then
        local SelectedInvestigation = "Eerie Farm"
        pcall(function()
            if readfile("JJI_LastInvestigation.txt") then
                SelectedInvestigation = readfile("JJI_LastInvestigation.txt")
            end
        end)
        task.wait(3)
        while task.wait(1) do
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Raids")
                :WaitForChild("QuickStart"):InvokeServer("Investigation", SelectedInvestigation, "Nightmare")
        end
    end

    -- Destroy fx --
    Effects.ChildAdded:Connect(function(Child)
        if Child.Name ~= "DeathBall" then
            Debris:AddItem(Child, 0)
        end
    end)

    Lighting.ChildAdded:Connect(function(Child)
        Debris:AddItem(Child, 0)
    end)

    Destructibles.ChildAdded:Connect(function(Child)
        Debris:AddItem(Child, 0)
    end)

    -- Uh, ignore this spaghetti way of determining screen center --
    local MouseTarget = Instance.new("Frame", LocalPlayer.PlayerGui:FindFirstChildWhichIsA("ScreenGui"))
    MouseTarget.Size = UDim2.new(0, 0, 0, 0)
    MouseTarget.Position = UDim2.new(0.5, 0, 0.5, 0)
    MouseTarget.AnchorPoint = Vector2.new(0.5, 0.5)
    local X, Y = MouseTarget.AbsolutePosition.X, MouseTarget.AbsolutePosition.Y

    -- UI --
    local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Manta/Stingray/refs/heads/main/UI"))()
    local MainUI = UI.InitUI()

    local Toggle = "ON"
    pcall(function()
        if isfile("JJI_State.txt") then
            Toggle = readfile("JJI_State.txt")
        else
            writefile("JJI_State.txt", "ON")
        end
    end)

    print("QUEUE TOGGLE: " .. Toggle)

    if Toggle == "ON" then
        UI.SetState(true)
    else
        UI.SetState(false)
    end

    UI.SetMain(function(State)
        if State == 1 then
            Toggle = "ON"
        else
            Toggle = "OFF"
        end
        writefile("JJI_State.txt", Toggle)
        print(readfile("JJI_State.txt"))
    end)

    local QueueSuccess = "False"
    if Toggle == "ON" then
        local Queued, QueueFail = pcall(function()
            queue_on_teleport(
                'loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Manta/Stingray/refs/heads/main/JJI/InvestigationFarm.lua"))()')()
        end)
        if not Queued then
            print("Put this script inside your auto-execution folder:", QueueFail)
            QueueSuccess = QueueFail
        else
            print("Queue success")
            QueueSuccess = "True"
        end
    end

    -- Funcs -- 
    local function Distance(P1, P2)
        return (P1 - P2).Magnitude
    end
    
    local function Hit()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Combat"):WaitForChild("M2"):FireServer(2)
    end


    local function Closest(P, I, V)
        local Closest_I = nil
        local Closest_D = math.huge

        for _, v in ipairs(I) do
            if not V[v] then
                local D = Distance(P, v.Position)
                if D < Closest_D then
                    Closest_D = D
                    Closest_I = v
                end
            end
        end

        return Closest_I, Closest_D
    end

    local function GenPath(PStart, I)
        local Path = {}
        local Visited = {}
        local PCurrent = PStart

        while #Path < #I do
            local Closest_I, D = Closest(PCurrent, I, Visited)
            if Closest_I then
                table.insert(Path, Closest_I)
                Visited[Closest_I] = true
                PCurrent = Closest_I.Position
            else
                break
            end
        end
        for i, v in pairs(Path) do
            print(i, v)
        end
        return Path
    end

    local function Godmode(State)
        ServerRemotes:WaitForChild("Combat"):WaitForChild("ToggleMenu"):FireServer(State)
    end

    local function Skill(Name)
        ServerRemotes:WaitForChild("Combat"):WaitForChild("Skill"):FireServer(Name)
    end

    local function TweenTo(CF)
        repeat
            task.wait()
        until not (Root.Anchored or Root:FindFirstChild("ForceField"))
        local Distance = (CF.Position - Root.Position).Magnitude
        local Tween = game:GetService("TweenService"):Create(Root,
            TweenInfo.new(Distance / 400, Enum.EasingStyle.Linear), {
                CFrame = CF
            })
        Tween:Play()
        Tween.Completed:Wait()
        task.wait(0.2)
    end

    local function Target(Humanoid)
        local s, e = pcall(function()
            ClientRemotes:WaitForChild("GetClosestTarget").OnClientInvoke = function()
                return Humanoid
            end
        end)
        if not s then
            print("Aim Hook Failure: " .. e)
        end
    end

    local function IsDead(C)
        if C:FindFirstChild("DeathBall") or (not C) then
            pcall(function()
                C:Destroy()
            end)
            return true
        end
        return false
    end

    local function Kill(C)
        print("Kill Begin")
        local Humanoid = C:WaitForChild("Humanoid", 2)
        print(Humanoid)
        local TargetName = C.Name
        TweenTo(C.PrimaryPart.CFrame + Vector3.new(0, 10, 0))
        Godmode(true)
        Target(Humanoid)
        task.wait(0.5)
        Skill("Chain Grab")
        repeat
            Hit()
            task.wait()
            C.PrimaryPart.CFrame = Root.CFrame
            if Humanoid.Health ~= Humanoid.MaxHealth then
                Humanoid.Health = 0
            end
            task.wait()
        until IsDead(C)
        Godmode(false)
        task.wait(0.3)
    end
    
    local function FKill(C)
        print("Kill Begin")
        local Humanoid = C:WaitForChild("Humanoid", 2)
        print(Humanoid)
        local TargetName = C.Name
        TweenTo(C.PrimaryPart.CFrame + Vector3.new(0, 10, 0))
        Target(Humanoid)
        repeat
            Hit()
            task.wait()
            Root.CFrame = C.PrimaryPart.CFrame
            if Humanoid.Health ~= Humanoid.MaxHealth then
                Humanoid.Health = 0
            end
            task.wait()
        until IsDead(C)
        task.wait(0.3)
    end

    local ChestsCollected = 0
    local function OpenChest()
        game:GetService("ReplicatedStorage").Remotes.Client.CollectChest.OnClientInvoke = function(Chest)
            print("Chest Collected")
            if Chest then
                ChestsCollected = ChestsCollected + 1
            end
            return {}
        end
        for i, v in ipairs(Drops:GetChildren()) do
            if v:FindFirstChild("Collect") then
                fireproximityprompt(v.Collect)
                task.wait()
            end
        end
    end

    local function Click(Button)
        Button.AnchorPoint = Vector2.new(0.5, 0.5)
        Button.Size = UDim2.new(50, 0, 50, 0)
        Button.Position = UDim2.new(0.5, 0, 0.5, 0)
        Button.ZIndex = 20
        Button.ImageTransparency = 1
        for i, v in ipairs(Button:GetChildren()) do
            if v:IsA("TextLabel") then
                v:Destroy()
            end
        end
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(X, Y, 0, true, game, 0)
        task.wait()
        VIM:SendMouseButtonEvent(X, Y, 0, false, game, 0)
        task.wait()
    end

    local function CheckForBoss()
        for i, v in ipairs(Mobs:GetChildren()) do
            if not table.find(Curses, v.Name) then
                return v
            end
        end
        return false
    end

    local Items = "| "
    game:GetService("ReplicatedStorage").Remotes.Client.Notify.OnClientEvent:Connect(function(Message)
        local Item = string.match(Message, '">(.-)</font>')
        if not (string.find(Item, "Stat Point") or string.find(Item, "Level") or string.find(Item, "EXP")) then
            if table.find(Highlight, Item) then
                Item = "**" .. Item .. "**"
            end
            Items = Items .. Item .. " | "
        end
    end)

    -- Main loop
    task.spawn(function()
        while not Replay.Visible do
        -- while tick()-StartTime <= 10 do

            task.spawn(function()
                if Drops:FindFirstChild("Chest") then
                    repeat
                        OpenChest()
                        task.wait()
                    until not Drops:FindFirstChild("Chest")
                end
            end)

            ClientRemotes:WaitForChild("StorylineDialogueSkip"):FireServer()

            --pcall(function()

                if Mission:FindFirstChild("CursedObject") then
                    Godmode(false)
                    local T = {}
                    for i, v in ipairs(Mission:GetChildren()) do
                        if v.Name == "CursedObject" then
                            table.insert(T, v)
                        end
                    end
                    local Path = GenPath(Root.Position, T)
                    for i, v in pairs(Path) do
                        pcall(function()
                            TweenTo(v.CFrame + Vector3.new(0, 2, 0))
                            v.Collect.HoldDuration = 0
                            task.wait()
                            fireproximityprompt(v.Collect)
                        end)
                    end
                elseif Mission:FindFirstChild("Civilian") then
                    Godmode(false)
                    print("Rescue Mission")
                    for i, v in ipairs(Mission:GetChildren()) do
                        if v.Name == "Civilian" then
                            pcall(function()
                                if v:FindFirstChild("PickUp") then
                                    v.PickUp.HoldDuration = 0
                                    TweenTo(v.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
                                    fireproximityprompt(v.PickUp)
                                    task.wait()
                                    TweenTo(game:GetService("Workspace").Map.Parts.SpawnLocation.CFrame)
                                    task.wait()
                                end
                            end)
                        end
                    end
                elseif CheckForBoss() then
                    Godmode(false)
                    print("Boss!")
                    local Boss = CheckForBoss()
                    Kill(Boss)
                    print("Boss Killed")
                elseif Mobs:FindFirstChild("QuestMarker", true) then
                    --Godmode(false)
                    Godmode(false)
                    local T = {}
                    for i,v in ipairs(Mobs:GetDescendants()) do
                        if v.Name == "QuestMarker" then
                            table.insert(T,v.Adornee)
                        end
                    end
                    local Path = GenPath(Root.Position, T)
                    for i,v in pairs(Path) do
                        FKill(v.Parent)
                    end
                else
                    if not Root.Parent:FindFirstChild("ForceField") then
                        Godmode(true)
                    else
                        task.wait(0.5)
                    end
                end
            -- end)
            task.wait()
        end

        local Sent, Error = pcall(function()
            if getgenv().Webhook then
                print("Sending webhook")
                task.wait(2)
                local Executor = (identifyexecutor() or "None Found")
                task.wait()
                local embed = {
                    ["title"] = LocalPlayer.Name .. " has completed an investigation in " ..
                        tostring(math.floor((tick() - StartTime) * 10) / 10) .. " seconds",
                    ['description'] = "Collected Items: " .. Items,
                    ["color"] = tonumber(000000)
                }
                local a = request({
                    Url = getgenv().Webhook,
                    Headers = {
                        ['Content-Type'] = 'application/json'
                    },
                    Body = game:GetService("HttpService"):JSONEncode({
                        ['embeds'] = {embed},
                        ['content'] = "-# [Debug Data] " .. "Executor: " .. Executor .. " | Chests Collected: " ..
                            tostring(ChestsCollected) .. " | Send a copy of this data to Manta if there's any issues",
                        ['avatar_url'] = "https://cdn.discordapp.com/attachments/1089257712900120576/1105570269055160422/archivector200300015.png"
                    }),
                    Method = "POST"
                })
                print("Webhook sent!")
            end
        end)
        task.wait()
        for i = 1, 10, 1 do
            Click(Replay)
            task.wait(1)
        end

    end)
end

