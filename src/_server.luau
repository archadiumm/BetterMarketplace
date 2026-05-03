--!strict
--!optimize 2

local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("_BetterMarketplace")

local Prompt: RemoteEvent
local StockConnection: RemoteFunction

Prompt = Instance.new("RemoteEvent")
Prompt.Parent = script.Parent
Prompt.Name = "prompt"

StockConnection = Instance.new("RemoteFunction")
StockConnection.Parent = script.Parent
StockConnection.Name = "stockconnection"

local Items = require("./@items")
local Settings = require("./@settings")


local BM_Server = {}

local PromptQueue: {[Player]: {Items.Item}} = {}
local Sessions: {[Player]: {[string]: boolean}} = {}

local function GetItem(Identifier: string | number): Items.Item
	if typeof(Identifier) == "string" then
		return Items[Identifier] :: Items.Item
	end
	
	local Item: Items.Item

	for _, item in pairs(Items) do
		if item.Id == Identifier then
			Item = item
			break
		end
	end

	return Item
end

local function GetName(Id: number): string
	for name, item in pairs(Items) do
		if item.Id == Id then
			return name
		end
	end
	
	return ""
end

local function UpdateStocks(): ()
	local StockData
	pcall(function()
		StockData = DataStore:GetAsync("STOCKS")
	end)
	
	if not StockData then 
		return 
	end
	
	local Stocks = {}

	for name, item in pairs(Items) do
		if item.Stock then
			item.Stock = math.clamp((if StockData and StockData[name] then StockData[name] else item.Stock), 0, math.huge)
			Stocks[name] = item.Stock
		end
	end
	
	for _, player in pairs(Players:GetPlayers()) do
		pcall(function()
			StockConnection:InvokeClient(player, Stocks)
		end)
	end
end

local function Charge(Player: Player, Item: Items.Item, Options: {[string]: any}?): ()
	if Options then
		if Options.Gifting and (not PromptQueue[Player] or #PromptQueue[Player] <= 0) then
			Player:SetAttribute("Gifting", Options.Gifting)
			Options.DelayPrompts = false
		end
		
		if Options.DelayPrompts then
			if not PromptQueue[Player] then
				PromptQueue[Player] = {}
			end

			table.insert(PromptQueue[Player], Item)

			if #PromptQueue[Player] > 1 then
				return
			end
		end
	end
	
	if Item.Type == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(Player, Item.Id)
	else
		MarketplaceService:PromptGamePassPurchase(Player, Item.Id)
	end
end

local function ClosePurchase(User: any, ProductId: number, Purchased: boolean): ()
	local Player: Player
	
	if typeof(User) == "number" then
		Player = Players:GetPlayerByUserId(User)
	else
		Player = User
	end
	
	Player:SetAttribute("Gifing", nil)
	
	if PromptQueue[Player] then
		table.remove(PromptQueue[Player], 1)
		
		local Next: Items.Item? = PromptQueue[Player][1]
		
		if Next then
			BM_Server.prompt(Player, GetName(Next.Id))
		else
			PromptQueue[Player] = nil
		end
	end
end

MarketplaceService.PromptProductPurchaseFinished:Connect(ClosePurchase)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(ClosePurchase)

MarketplaceService.ProcessReceipt = function(ReceiptInfo: {[string]: any}): Enum.ProductPurchaseDecision
	local Id: number = ReceiptInfo.ProductId
	local Player: Player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)
	
	local Item: Items.Item = GetItem(Id)
	
	local Gifting: string = tostring(Player:GetAttribute("Gifting"))
	local Target: any = Players:FindFirstChild(Gifting)
	if not Target then
		Target = Player
	end
	
	Item.Callback(Target)
	
	if Item.Stock then
		local Name = GetName(Id)
		
		DataStore:UpdateAsync("STOCKS", function(old)
			local old: {[string]: number} = old or {}
			old[Name] = old[Name] or Item.Stock
			
			old[Name] -= 1
			print(`New Stock: {old[Name]} for {Name}.`)
			
			return old
		end)
		
		UpdateStocks()
	end

	if Item.Type == Enum.InfoType.GamePass then
		Sessions[Target][GetName(Id)] = true

		local TargetPasses: any = Target:FindFirstChild("Passes", true)
		local PassValue: any = TargetPasses:FindFirstChild(GetName(Id))
		PassValue.Value = true
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function BM_Server.prompt(Player: Player, Name: string, Options: {[string]: any}?): ()
	UpdateStocks()
	
	local Item: Items.Item? = GetItem(Name)
	
	if not Item then
		return warn(`[BetterMarketPlace]: Item '{Name}' does not exist!`)
	end
	
	if Options and Options.Gifting and Options.Gifting == Player.Name then
		Options.Gifting = nil
	end
	
	if ((not Options or not Options.Gifting) and Item.Type == Enum.InfoType.GamePass and MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Item.Id)) or 
		(Item.Stock and Item.Stock <= 0)
	then
		return
	end
	
	Charge(Player, Item, Options)
end

function BM_Server.init(): ()
	if script:GetAttribute("INIT") then
		return
	end
	
	script:SetAttribute("INIT", true)
	
	local PassTracker: string? = Settings.PassTracker
	
	if not PassTracker or typeof(PassTracker) ~= "string" then
		return
	end
	
	local Split: {string} = PassTracker:split("/")
	
	local function HandlePlayer(Player: Player)
		local Location: any = Player
		local DataTable: {} = {}
		Sessions[Player] = {}

		if Settings.UseDS then
			DataTable = DataStore:GetAsync(tostring(Player.UserId)) or {}
		end
		
		for Index, Name in pairs(Split) do
			if Index == 1 then
				continue
			end
			
			if not Location:FindFirstChild(Name) then
				local New = Instance.new("Folder")
				New.Name = Name
				New.Parent = Location
			end
			
			Location = Location:FindFirstChild(Name)
		end
		
		for Name: string, Item: Items.Item in pairs(Items) do
			if Item.Type ~= Enum.InfoType.GamePass then
				continue
			end
			
			DataTable[Name] = DataTable[Name] or false
			Sessions[Player][Name] = DataTable[Name]
			
			local New = Instance.new("BoolValue")
			New.Name = Name
			New.Parent = Location
			New.Value = DataTable[Name]
			
			if not Settings.UseDS then
				New.Value = MarketplaceService:UserOwnsGamePassAsync(
					Player.UserId,
					Item.Id
				)
			end
		end
		
		UpdateStocks()
	end
	
	Players.PlayerAdded:Connect(HandlePlayer)
	Players.PlayerRemoving:Connect(function(Player: Player)
		if not Settings.UseDS then
			return
		end
		
		DataStore:UpdateAsync(tostring(Player.UserId), function(old)
			local old = Sessions[Player] or {}
			return old
		end)
		
		Sessions[Player] = nil
	end)
	
	for _, Player in pairs(Players:GetPlayers()) do
		if Player:FindFirstChild("Passes", true) then
			continue
		end
		
		HandlePlayer(Player)
	end
	
	if Settings.StockUpdates > 0 then
		task.spawn(function()
			while task.wait(Settings.StockUpdates) do
				UpdateStocks()
			end
		end)
	end
end

Prompt.OnServerEvent:Connect(function(Player: Player, NameBuffer: buffer, Options: {[string]: any}?)
	local Name: string = buffer.readstring(NameBuffer, 0, buffer.len(NameBuffer))
	BM_Server.prompt(Player, Name, Options)
end)

return BM_Server
