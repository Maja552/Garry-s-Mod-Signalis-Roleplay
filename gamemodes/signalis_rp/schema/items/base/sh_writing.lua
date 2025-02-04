
ITEM.name = "Writing Base"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.description = "Something that can be written on."
ITEM.width = 1
ITEM.height = 1
ITEM.business = true
ITEM.bAllowMultiCharacterInteraction = true
ITEM.category = "Documents"

ITEM.weight = 0.1

ITEM.maxPages = 3
ITEM.startFromPage0 = false

ITEM.canChangeTitle = false

function ITEM:GetName()
    if self:GetData("title", nil) then return self:GetData("title", nil) end

	return (CLIENT and L(self.name) or self.name)
end

function ITEM:SetTitle(item, text)
    item.name = text
    item:SetData("title", text)
end

ITEM.functions.SetTitle = {
	OnRun = function(item)
		netstream.Start(item.player, "ixEditTitlePaper", item:GetID())
		return false
	end,
	OnCanRun = function(item)
        if !item.canChangeTitle then return false end

		local owner = item:GetData("owner", 0)
		local isEmpty = true
	
		if item.pages and #item:GetData("pages", {}) == 0 then
			item:SetData("pages", item.pages)
		end

		for k,v in pairs(item:GetData("pages", {})) do
			if (v and isstring(v) and string.len(v) > 0) or (v and istable(v)) then
				isEmpty = false
				break
			end
		end

		-- Allow title change when the paper is empty
		if isEmpty then return true end

		-- Allow title change when the paper is not empty and the player is the owner or the player is staff
		if item.player and (item.player:IsStaff() or owner == item.player:GetCharacter():GetID()) then
			return true
		end

		return false
	end
}

function ITEM:GetDescription()
	local isEmpty = true
	
	for k,v in pairs(self:GetData("pages", {})) do
		if (v and v != "") then
			isEmpty = false
			break
		end
	end

	return ((self:GetData("owner", 0) == 0) or isEmpty)
		and string.format(self.description, "it hasn't been written on")
		or string.format(self.description, "it has been written on")
end

function ITEM:SetPages(pages, character)
	self:SetData("pages", pages, false, false, true)
	self:SetData("owner", character and character:GetID() or 0)
end

function ITEM:OnInstanced(invID, x, y, item)
	if item.pages then
		item:SetData("pages", item.pages)
	end
end

ITEM.functions.View = {
	OnRun = function(item)
		if item.pages and #item:GetData("pages", {}) == 0 then
			item:SetData("pages", item.pages)
		end
		netstream.Start(item.player, "ixViewPaper", item.maxPages, item.startFromPage0, item.backgroundPhoto, item:GetID(), item:GetData("pages", {}), 0)
		return false
	end,
	OnCanRun = function(item)
		local owner = item:GetData("owner", 0)

		local isEmpty = true
	
		if item.pages and #item:GetData("pages", {}) == 0 then
			item:SetData("pages", item.pages)
		end

		for k,v in pairs(item:GetData("pages", {})) do
			if (v and isstring(v) and string.len(v) > 0) or (v and istable(v)) then
				isEmpty = false
				break
			end
		end

		return !isEmpty or (item:GetData("owner", 0) != 0)
	end
}

ITEM.functions.Edit = {
	OnRun = function(item)
		if item.pages and #item:GetData("pages", {}) == 0 then
			item:SetData("pages", item.pages)
		end
		netstream.Start(item.player, "ixViewPaper", item.maxPages, item.startFromPage0, item.backgroundPhoto, item:GetID(), item:GetData("pages", {}), 1)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		
		if client:IsStaff() then
			return true
		end
		
		-- fix
		if item.pages and #item:GetData("pages", {}) == 0 then
			item:SetData("pages", item.pages)
		end

		local isEmpty = true
		for k,v in pairs(item:GetData("pages", {})) do
			if (v and v != "") then
				isEmpty = false
				break
			end
		end

		local owner = item:GetData("owner", 0)

		return isEmpty || (owner == client:GetCharacter():GetID())
	end
}

ITEM.functions.take.OnCanRun = function(item)
	local owner = item:GetData("owner", 0)
	return IsValid(item.entity) and (owner == 0 or owner == item.player:GetCharacter():GetID())
end
