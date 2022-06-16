local identifiers = {}

local function saveAppearance(identifier, appearance)
	SetResourceKvp(('%s:appearance'):format(identifier), json.encode(appearance))
end
exports('save', saveAppearance)

local function loadAppearance(source, identifier)
	local appearance = GetResourceKvpString(('%s:appearance'):format(identifier))
	identifiers[source] = identifier

	return appearance and json.decode(appearance) or {}
end
exports('load', loadAppearance)

local function saveOutfit(identifier, appearance, slot, outfitNames)
	SetResourceKvp(('%s:outfit_%s'):format(identifier, slot), json.encode(appearance))
	SetResourceKvp(('%s:outfits'):format(identifier), json.encode(outfitNames))
end
exports('saveOutfit', saveOutfit)

local function loadOutfit(identifier, slot)
	local appearance = GetResourceKvpString(('%s:outfit_%s'):format(identifier, slot))

	return appearance and json.decode(appearance) or {}
end
exports('loadOutfit', loadOutfit)

local function loadOutfitNames(identifier)
	local data = GetResourceKvpString(('%s:outfits'):format(identifier))

	return data and json.decode(data) or {}
end
exports('outfitNames', loadOutfitNames)

if GetResourceState('JLRP-Framework'):find('start') then
	local Core = exports['JLRP-Framework']:GetFrameworkObjects()

	Core = {
		GetExtendedPlayers = Core.GetExtendedPlayers,
		RegisterServerCallback = Core.RegisterServerCallback,
		GetPlayerFromId = Core.GetPlayerFromId,
	}
	
	AddEventHandler('Framework:playerLoaded', function(playerId, xPlayer)
		identifiers[playerId] = xPlayer.identifier		
		TriggerClientEvent('fivem-appearance:outfitNames', playerId, loadOutfitNames(xPlayer.identifier))
	end)

	RegisterNetEvent('esx_skin:save', function(appearance)
		local xPlayer = Core.GetPlayerFromId(source)
		MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', { json.encode(appearance), xPlayer.identifier })
	end)

	Core.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
		local xPlayer = Core.GetPlayerFromId(source)
		local appearance = MySQL.scalar.await('SELECT skin FROM users WHERE identifier = ?', { xPlayer.identifier })
		local jobSkin = {
			skin_male   = xPlayer.job.skin_male,
			skin_female = xPlayer.job.skin_female
		}

		cb(appearance ~= nil and json.decode(appearance) or nil, jobSkin)
	end)

	do
		local xPlayers = Core.GetExtendedPlayers()

		for i = 1, #xPlayers do
			local xPlayer = xPlayers[i]
			identifiers[xPlayer.source] = xPlayer.identifier
			TriggerClientEvent('fivem-appearance:outfitNames', xPlayer.source, loadOutfitNames(xPlayer.identifier))
		end
	end
end

RegisterNetEvent('fivem-appearance:save', function(appearance)
	local identifier = identifiers[source]

	if identifier then
		saveAppearance(identifier, appearance)
	end
end)

RegisterNetEvent('fivem-appearance:saveOutfit', function(appearance, slot, outfitNames)
	local identifier = identifiers[source]

	if identifier then
		saveOutfit(identifier, appearance, slot, outfitNames)
	end
end)

RegisterNetEvent('fivem-appearance:loadOutfitNames', function()
	local identifier = identifiers[source]
	TriggerClientEvent('fivem-appearance:outfitNames', source, identifier and loadOutfitNames(identifier) or {})
end)

RegisterNetEvent('fivem-appearance:loadOutfit', function(slot)
	local identifier = identifiers[source]
	TriggerClientEvent('fivem-appearance:outfit', source, slot, identifier and loadOutfit(identifier, slot) or {})
end)

AddEventHandler('playerDropped', function()
	identifiers[source] = nil
end)