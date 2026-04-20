if GetResourceState(Config.CoreName.qb) ~= 'started' then return end
local QBCore = exports[Config.CoreName.qb]:GetCoreObject()

function GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end