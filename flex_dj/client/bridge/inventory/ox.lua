if not Config then Config = {} end
if not Config.CoreName then Config.CoreName = {} end
if not Config.CoreName.ox_inv then Config.CoreName.ox_inv = 'ox_inventory' end

local function waitForOxInventory()
    local attempts = 0
    while GetResourceState(Config.CoreName.ox_inv) ~= 'started' and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    return GetResourceState(Config.CoreName.ox_inv) == 'started'
end

if not waitForOxInventory() then
    print("^1[flex_dj] ERROR: ox_inventory not started, USB metadata will not be displayed^0")
    return
end

local ox = exports.ox_inventory
if not ox then
    print("^1[flex_dj] ERROR: Failed to get ox_inventory export^0")
    return
end

local success = pcall(function()
    ox:displayMetadata('usbid', 'USB')
    ox:displayMetadata('mp3id', 'MP3')
end)

RegisterNetEvent('flex_dj:client:ox_inventory:openStash', function(stashId)
    OpenStash(stashId)
end)

function CloseInventory()
    return exports.ox_inventory:closeInventory()
end

function OpenStash(stashId)
    if not stashId or type(stashId) ~= 'string' then
        print("^3[flex_dj] Warning: Invalid stash ID received^0")
        return
    end
    if not ox then
        ox = exports.ox_inventory
        if not ox then
            print("^1[flex_dj] ERROR: ox_inventory not available^0")
            return
        end
    end
    local success, result = pcall(function()
        return ox:openInventory('stash', { id = stashId })
    end)
    if not success then
        print("^1[flex_dj] ERROR: Failed to open stash: " .. tostring(result) .. "^0")
    end
end