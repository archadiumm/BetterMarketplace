--!strict
--!optimize 2

local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Prompt = script.Parent:WaitForChild("prompt", 10) :: RemoteEvent
local StockConnection = script.Parent:WaitForChild("stockconnection", 10) :: RemoteFunction

local Items = require("./@items")

local Player = Players.LocalPlayer

local Connections: {[any]: any} = {}
type Connection = {
	disconnect: () -> ()
}

StockConnection.OnClientInvoke = function(Stocks: {[string]: number})
	for name, stock in pairs(Stocks) do
		if Connections[name] then
			Connections[name].Update(stock)
		end
	end
end

local BM_Client = {}

function BM_Client.prompt(Name: string, Options: {[string]: any}?): ()
	local NameBuffer = buffer.create(#Name)
	buffer.writestring(NameBuffer, 0, Name)
	
	Prompt:FireServer(NameBuffer, Options)
end

function BM_Client.connect(Object: TextLabel|TextButton, Text: string, StockName: string, Callback: (number) -> ()?): Connection
	Connections[StockName] = {
		Update = function(Stock)
			Object.Text = string.format(Text, tostring(Stock))
			
			if Callback then
				Callback(Stock)
			end
		end,
		
		disconnect = function()
			Connections[StockName] = nil
		end,
	}
	
	return Connections[StockName]
end

return BM_Client
