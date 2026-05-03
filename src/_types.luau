--!strict
--!optimize 2

export type BetterMarketplace = {
	server: typeof(require("./_server")),
	client: typeof(require("./_client"))
}

return 0
