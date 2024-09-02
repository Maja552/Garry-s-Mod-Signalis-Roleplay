//AeroMatix || https://www.youtube.com/channel/UCzA_5QTwZxQarMzwZFBJIAw || http://steamcommunity.com/profiles/76561198176907257

AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
include ("shared.lua")

util.AddNetworkString("ciga")
util.AddNetworkString("cigaArm")
util.AddNetworkString("cigaTalking")

function cigaUpdate(ply, cigaID)
	if not ply.cigaCount then ply.cigaCount = 0 end
	if not ply.cantStartciga then ply.cantStartciga=false end
	if ply.cigaCount == 0 and ply.cantStartciga then return end
	
	ply.cigaID = cigaID
	ply.cigaCount = ply.cigaCount + 1
	if ply.cigaCount == 1 then
		ply.cigaArm = true
		net.Start("cigaArm")
		net.WriteEntity(ply)
		net.WriteBool(true)
		net.Broadcast()
	end
	if ply.cigaCount >= 50 then
		ply.cantStartciga = true
		Releaseciga(ply)
	end
end

hook.Add("KeyRelease","DocigaHook",function(ply, key)
	if key == IN_ATTACK then
		Releaseciga(ply)
		ply.cantStartciga=false
	end
end)

function Releaseciga(ply)
	if not ply.cigaCount then ply.cigaCount = 0 end
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass():sub(1,11) == "kanade_cigar" then
		if ply.cigaCount >= 5 then
			net.Start("ciga")
			net.WriteEntity(ply)
			net.WriteInt(ply.cigaCount, 8)
			net.WriteInt(ply.cigaID + (ply:GetActiveWeapon().juiceID or 0), 8)
			net.Broadcast()
		end
	end
	if ply.cigaArm then
		ply.cigaArm = false
		net.Start("cigaArm")
		net.WriteEntity(ply)
		net.WriteBool(false)
		net.Broadcast()
	end
	ply.cigaCount=0 
end