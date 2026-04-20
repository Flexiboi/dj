if GetResourceState(Config.CoreName.ox_inv) ~= 'started' then return end

function RemoveItem(src, item, amount, info, slot)
    return exports.ox_inventory:RemoveItem(src, item, amount, info, slot or nil)
end

function AddItem(src, item, amount, info, slot)
    return exports.ox_inventory:AddItem(src, item, amount, info, slot or nil)
end

function HasInvGotItem(inv, search, item, metadata, amount)
    if type(amount) == "boolean" then return end
    if amount == 0 then return false end
    if exports.ox_inventory:Search(inv, search, item) >= amount then
        return true
    else
        return false
    end
end

function GetInvItems(inv)
    return exports.ox_inventory:GetInventoryItems(inv)
end

function GetItemBySlot(src, slot)
    local Player = exports.qbx_core:GetPlayer(src)
    return Player.Functions.GetItemBySlot(slot)
end

function GetItem(inv, item, metadata, returnsCount)
    return exports.ox_inventory:GetItem(inv, item, metadata, returnsCount)
end

function GetMetadatFromSlot(src, item, slot)
    local items = exports.ox_inventory:Search(src, 'slots', item)
    if items and #items > 0 then
        return items[slot].metadata
    end
    return nil
end

function RegisterStash(id, slots, maxWeight)
    return exports.ox_inventory:RegisterStash(id, id, slots, maxWeight)
end

function ClearStash(id)
    return exports.ox_inventory:ClearInventory(id, 'false')
end

function forceOpenStash(src, id)
    return exports.ox_inventory:forceOpenInventory(src, 'stash', id)
end

exports('UseMp3', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id
        TriggerClientEvent('flex_dj:client:UseMp3', src, inventory.items[slot].metadata.mp3id)
    end
end)
