
ITEM.name = "FKLR Armor"
ITEM.description = "Bullet-Resistant Armor Plating."
ITEM.category = "Clothing"
ITEM.model = "models/eternalis/items/equipment/fklr_armor.mdl"
ITEM.outfitCategory = "body"

ITEM.bodyGroups = {
	["armor"] = 1
}
ITEM.bodyGroupsUnequipped = {
	["armor"] = 0
}

ITEM.weight = 4

ITEM.width = 2
ITEM.height = 2

function ITEM:CanEquipOutfit(client)
    local character = client:GetCharacter()
    if character and character.vars.class == "replika_fklr" then
        return true
    end

    client:NotifyLocalized("cannotEquipOutfit")
	return false
end
