if GetResourceState(Config.CoreName.esx) ~= 'started' then return end
local ESX = exports[Config.CoreName.esx]:getSharedObject()

function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end