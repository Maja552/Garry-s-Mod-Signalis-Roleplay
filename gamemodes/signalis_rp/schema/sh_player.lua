﻿
local meta = FindMetaTable("Player")

function meta:IsFemale()
	local character = self:GetCharacter()

	if character then
		local class = ix.class.GetClass(character.vars.class)

		if self:IsReplika() then
			return character.vars.class != "replika_adlr"
		end

		if class then
			for k,v in pairs(class.models) do
				if v.mdl == self:GetModel() then
					if v.gender then
						return v.gender == "female"
					end
					break
				end
			end
		end
	end

	return false
end

function meta:IsReplika()
	return self:Team() == FACTION_REPLIKA or string.find(self:GetCharacter().vars.class:lower(), "replika")
end

function meta:GetPitch()
	local character = self:GetCharacter()
	if character then
		local class = ix.class.GetClass(character.vars.class)

		if character.vars.faction == "replika" then
			return class.talkPitch or 100
		end

		if character.vars.faction == "gestalt" then
			return character.vars.pitch or 100
		end
	end

	return 100
end

function meta:GetTalkPitchAndSpeed()
	local character = self:GetCharacter()
	if character then
		local class = ix.class.GetClass(character.vars.class)

		if character.vars.faction == "replika" then
			return class.talkPitch, class.talkSpeed or 1
		end

		if character.vars.faction == "gestalt" then
			return character.vars.pitch or 100, character.vars.talkspeed or 1
		end
	end

	return 100, 1
end

function meta:IsBioresonant()
	local character = self:GetCharacter()
	if character then
		local bioresonance = character:GetData("bioresonance", nil)
		if bioresonance then
			return bioresonance >= 1
		end

		local classTable = ix.class.GetClass(character.vars.class)
		if classTable and classTable.isBioresonant then
			return true
		end
	end

	return false
end

function meta:IsReplika()
	return self:Team() == FACTION_REPLIKA or string.find(self:GetCharacter().vars.class:lower(), "replika")
end

function meta:IsStaff()
	return self:IsAdmin() || self:IsUserGroup("operator") || self:IsUserGroup("moderator") || self:IsUserGroup("gamemaster")
end
