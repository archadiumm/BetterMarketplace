--!strict
--!optimize 2

export type Item = {
	Id: number,
	Type: Enum.InfoType,
	Callback: (Player: Player) -> (),
	
	Stock: number?
}

local Items: {[string]: Item} = {
	
}

return Items
