
ITEM.name = "KLBR Armor"
ITEM.description = "Bullet-Resistant Armor Plating."
ITEM.category = "Clothing"
ITEM.model = "models/eternalis/items/equipment/klbr_armor.mdl"
ITEM.outfitCategory = "body"

ITEM.bodyGroups = {
	["armor"] = 0
}
ITEM.bodyGroupsUnequipped = {
	["armor"] = 1
}

ITEM.weight = 4

ITEM.width = 2
ITEM.height = 2

function ITEM:CanEquipOutfit(client)
    local character = client:GetCharacter()
    if character and character.vars.class == "replika_klbr" then
        return true
    end

    client:NotifyLocalized("cannotEquipOutfit")
	return false
end
