if GetResourceState(Config.CoreName.qbx) ~= 'started' then return end
while GetResourceState('qbx_core') ~= 'started' do
    Wait(100)
end
local core = exports.qbx_core

function HasPermissions(src)
    return core:HasPermission(src, 'admin')
end

function GetPlayer(src)
    return core:GetPlayer(src)
end

function GetPlayerByCitizenId(identifier)
    return core:GetPlayerByCitizenId(identifier)
end

function AddMoney(src, AddType, amount, reason)
    return core:AddMoney(src, AddType, amount, reason or '')
end

function SetJob(src, job, grade)
    local Player = exports.qbx_core:GetPlayer(src)
    return core:SetJob(src, job, grade)
end

function GetJobs()
    return core:GetJobs()
end

-- core:CreateUseableItem(Config.Item.mp3, function(src, item)
--     TriggerClientEvent('flex_dj:client:UseMp3', src, item.metadata.mp3id)
--     return true
-- end)