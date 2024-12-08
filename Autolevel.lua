local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library//main/Library", true))()
local RemoteServices = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


local AmountToUse = {
	["Common"] = 200,
	["Uncommon"] = 100,
	["Rare"] = 70,
	["Epic"] = 40,
	["Legendary"] = 7,
	["Mythic"] = 3,
}

local MainWindow = library:AddWindow("autolevel", {
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(250, 346),
	can_resize = true,
})

local function InvokeServer(rem,...)
	return rem:InvokeServer(...)
end

local function FireServer(rem,...)
	rem:FireServer(...)
end

local function Ascend()
	InvokeServer(RemoteServices.LevelService.RF.AscendAbility,LocalPlayer.Data.Ability.Value)
end

local function PurchaseShard()
	while getgenv().AutoLevel do
		InvokeServer(RemoteServices.ShopService.RF.RollBanner,1,"UShards",10)	
		task.wait()
	end
end

local function CheckShardRarities()
	local Shards = InvokeServer(RemoteServices.CraftingService.RF.GetAllAbilityShards)
	for i,v in Shards do
		for _,b in v do
			print(_,b)
		end
	end
end

local function ShardEXP()
	local Shards = InvokeServer(RemoteServices.CraftingService.RF.GetAllAbilityShards)
	while getgenv().AutoLevel do
		for i,Data in Shards do
			task.wait()
			Shards = InvokeServer(RemoteServices.CraftingService.RF.GetAllAbilityShards)
			if not getgenv().AutoLevel then break end
			if Data.Shards and Data.Shards > 0 then
				print("SHARDING",i,"WITH RARITY:",Data.Rarity,"AMOUNT OF SHARDS:",Data.Shards)
				local Rarity = Data.Rarity
				local ShardsToUse = math.min(AmountToUse[Rarity],Data.Shards)
				InvokeServer(RemoteServices.LevelService.RF.ConsumeShardsForXP,{[i] = ShardsToUse})
				continue
			end
		end
	end
end

local MainTab = MainWindow:AddTab("main")

local AutoLevelSW = MainTab:AddSwitch("Auto-Level", function(bool)
	getgenv().AutoLevel = bool
	task.spawn(ShardEXP)
	task.spawn(PurchaseShard)
end)

local AutoAscend = MainTab:AddSwitch("Auto-Ascend", function(bool)
	getgenv().AutoAscend = bool
	task.spawn(function()
		while getgenv().AutoAscend do
			Ascend()
		end
	end)
end)

MainTab:Show()
AutoLevelSW:Set(false)
AutoAscend:Set(false)
