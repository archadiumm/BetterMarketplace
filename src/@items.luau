--!strict
--!optimize 2

export type Item = {
	Id: number,
	Type: Enum.InfoType,
	Callback: (Player: Player) -> (),
	
	Stock: number?
}

local Items: {[string]: Item} = {
	-- Add your items here! Follow the documentation to see what to do!
}

return Items
