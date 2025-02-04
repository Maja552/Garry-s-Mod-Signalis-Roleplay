CLASS.name = "ARAR Replika"
CLASS.shortName = "ARAR"
CLASS.faction = FACTION_REPLIKA
CLASS.isDefault = false
CLASS.availableByDefault = false

CLASS.isAdministration = false
CLASS.isProtektor = false

CLASS.isBioresonant = false

CLASS.models = {
	{
		mdl = "models/voxaid/signalis_arar/arar_pm.mdl",
		hullMins = Vector(-12, -12, 0),
		hullMaxs = Vector(12, 12, 75),
		gender = "female"
	}
}
CLASS.health = 120
CLASS.physical_damage_taken = 0.7 -- titanium reinforced shell
CLASS.bullet_damage_taken = 0.7 -- titanium reinforced shell
CLASS.mental_strength = 0.92 -- arars are a bit more unstable...
CLASS.hunger = 0.9
CLASS.thirst = 0.9
-- titanium shell makes them less mobile
CLASS.speed = 0.9
CLASS.ladder_speed = 1.15
CLASS.jump_power = 0.9 -- not as bad because they are tall
CLASS.max_stamina = 1.87

CLASS.add_max_weight = 7
CLASS.add_inventory_width = 1
CLASS.add_inventory_height = 0

CLASS.talkPitch = 98
CLASS.talkSpeed = 0.8
CLASS.death_sounds = {
	{
		snd = "eternalis/player/death/death_arar.wav",
		volume = 0.95,
		sndLevel = 100,
		pitch = 100
	}
}
CLASS.breathing_sound = {
	snd = "eternalis/player/breathing/breathing_female.wav",
	volume = 1,
	sndLevel = 60,
	pitch = 95
}

-- attributes
CLASS.remove_attributes = true

CLASS.weapon_knowledge = 0
CLASS.min_weapon_knowledge = 0
CLASS.max_weapon_knowledge = 3
CLASS.medical_knowledge = 0
CLASS.min_medical_knowledge = 0
CLASS.max_medical_knowledge = 3

CLASS.description = {
	[[Allzweck-Reparatur-Arbeiter Replika
- 'Ara' -
(All-Purpose Repair Worker Replika 'Macaw')
Type: Generation 2 Low-Cost General Purpose
Frame: Biomechanical with Titanium-Reinforced Polyethylene Shell
Height: 185 cm]],

	[[The tough 'worker bees' of the construction and repair industry.
One of the earlier Replika designs, the simple but efficient Aras are actually the most-produced Replika type to date.
These strong and heavy worker units are a perfect fit for work in construction and production of industrial goods.
In many places throughout our Nation, Aras have already replaced all Gestalt workers in fields like Klimaforming and explosive ordnance disposal.]]
}

CLASS_REPLIKA_ARAR = CLASS.index

function CLASS:OnSet(client)
end

function CLASS:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	inventory:Add("ration_k4", 1)
	inventory:Add("id_arar", 1, {
		skin = 3,
		name = character:GetName(),
		charId = character:GetID(),
		issued = Schema:GetSignalisDate()
	})
	inventory:Add("helmet_arar", 1, {
		equip = true
	})
end
