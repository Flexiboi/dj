if GetResourceState(Config.CoreName.qbx) ~= 'started' then return end

function GetPlayerData()
    return exports.qbx_core:GetPlayerData()
end

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('flex_dj:client:UnLoad')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('flex_dj:client:Load')
end)