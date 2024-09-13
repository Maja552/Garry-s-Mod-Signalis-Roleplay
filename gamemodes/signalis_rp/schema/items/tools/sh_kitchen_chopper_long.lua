
ITEM.name = "Long kitchen chopper"
ITEM.model = Model("models/eternalis/items/weapons/kitchen/chopper_bigger.mdl")
ITEM.description = "A long, sharp kitchen chopper. Perfect for cutting vegetables and meat."
ITEM.skin = 0

ITEM.width = 2
ITEM.height = 1

ITEM.canSlice = true

ITEM.functions.Suicide = {
    icon = "icon16/cross.png",
	OnRun = SuicideItemFunction(item),
	OnCanRun = CanSuicide(item)
}
