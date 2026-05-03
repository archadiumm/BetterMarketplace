--!strict
--!optimize 2

local RunService = game:GetService("RunService")

local Items = require("@self/@items")

local Server = {}
local Client = {}
local Types = require("@self/_types")

if RunService:IsClient() then
	script:FindFirstChild("_server"):Destroy()
	Server = nil
	Client = require("@self/_client")
else
	Client = nil
	Server = require("@self/_server")
end

return table.freeze({
	server = Server,
	client = Client
}) :: Types.BetterMarketplace
