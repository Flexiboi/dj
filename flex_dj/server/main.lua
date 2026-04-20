local SpeakersJson = LoadResourceFile(GetCurrentResourceName(), "./storage/speakers.json")
local RadiosJson = LoadResourceFile(GetCurrentResourceName(), "./storage/radios.json")
local TablesJson = LoadResourceFile(GetCurrentResourceName(), "./storage/tables.json")
local UsbJson = LoadResourceFile(GetCurrentResourceName(), "./storage/usb.json")
local Mp3Json = LoadResourceFile(GetCurrentResourceName(), "./storage/mp3.json")

local Storage = {
    CurrentPlayingIds = {},
    CurrentSongSettings = {},
    Speakers = {},
    UsedSpeakers = {},
    Tables = {},
    Radios = {},
    Usb = {},
    Mp3 = {},
}

local function IsSpeakerInUse(id)
    for k, v in pairs(Storage.UsedSpeakers) do
        if v == id then
            return k, true
        end
    end
    return 0, false
end

local function GetSpeakerArrayId(id)
    for k, v in pairs(Storage.Speakers) do
        if v.id == id then
            return k
        end
    end
    return false
end

local function GetRadioArrayId(id)
    for k, v in pairs(Storage.Radios) do
        if v.id == id then
            return k
        end
    end
    return false
end

local function GetTurnTableArrayId(id)
    for k, v in pairs(Storage.Tables) do
        if v.id == id then
            return k
        end
    end
    return false
end

local function GetClosestTableToPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    for k, v in pairs(Storage.Tables) do
        if #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 20.0 then
            return vector3(v.coords.x, v.coords.y, v.coords.z)
        end
    end
    return false
end

local function GetClosestRadioToPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    for k, v in pairs(Storage.Radios) do
        if #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 20.0 then
            return vector3(v.coords.x, v.coords.y, v.coords.z)
        end
    end
    return false
end

local function GetClosestIDToPlayer(src)
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    for k, v in pairs(Storage.Tables) do
        if #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 20.0 then
            return v.id
        end
    end
    for k, v in pairs(Storage.Radios) do
        if #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z)) < 20.0 then
            return v.id
        end
    end
    return false
end

local function IsPlayerNearCoords(src, coords)
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - coords.xyz) < 20.0 then
        return true
    end
    return false
end

lib.callback.register('flex_dj:server:isAdmin', function(source)
    return HasPermissions(source)
end)

lib.callback.register('flex_dj:server:RegisterStash', function(source, id, slot)
    if not id then
        local item = GetItemBySlot(source, slot)
        id = item.metadata.mp3id
    end
    Wait(10)
    local stashid = 'usbport_'..tostring(id)
    if not stashid then return false end
    RegisterStash(stashid, 1, 1)
    Wait(100)
    forceOpenStash(source, stashid)
    return stashid, id
end)

lib.callback.register('flex_dj:server:GetUSBId', function(source, id)
    local stashid = 'usbport_'..tostring(id)
    if not stashid then return false end
    local item = GetInvItems(stashid)
    if not item then return false end
    return item[1] and item[1].metadata and item[1].metadata.usbid or false
end)

lib.callback.register('flex_dj:server:GetUsbSongs', function(source, id)
    return Storage.Usb[id] or {}
end)

lib.callback.register('flex_dj:server:GetTables', function(source)
    local tables = {}
    for k, v in pairs(Storage.Tables) do
        table.insert(tables, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 25,
        })
    end
    return tables
end)

lib.callback.register('flex_dj:server:GetSpeakers', function(source)
    local speakers = {}
    for k, v in pairs(Storage.Speakers) do
        table.insert(speakers, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 25,
        })
    end
    return speakers
end)

lib.callback.register('flex_dj:server:GetRadios', function(source)
    local radios = {}
    for k, v in pairs(Storage.Radios) do
        table.insert(radios, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 25,
        })
    end
    return radios
end)

RegisterNetEvent('flex_dj:server:Load', function()
    local src = source
    for k, v in pairs(Storage.Speakers) do
        TriggerClientEvent('flex_dj:client:RegisterSpeaker', src, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 25,
        })
    end
    for k, v in pairs(Storage.Radios) do
        TriggerClientEvent('flex_dj:client:RegisterRadio', src, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 100,
        })
    end
    for k, v in pairs(Storage.Tables) do
        TriggerClientEvent('flex_dj:client:RegisterTable', src, {
            id = v.id or os.time(),
            model = v.model or nil,
            coords = v.coords and vector3(v.coords.x, v.coords.y, v.coords.z),
            rot = v.rot and vector3(v.rot.x, v.rot.y, v.rot.z) or nil,
            distance = v.distance or 100,
        })
    end
    local SongsToPlay = {}
    for key, id in pairs(Storage.CurrentPlayingIds) do
        local FoundSpeaker = false
        local song = Storage.CurrentSongSettings[id] or Storage.CurrentSongSettings[key]
        for k, v in pairs(Storage.Speakers) do
            if #(song.coords.xyz - vector3(v.coords.x, v.coords.y, v.coords.z)) <= (song.type and song.type:lower() == 'radio' and Storage.Radios[song.id] and Storage.Radios[song.id].distance or Storage.Tables[song.id] and Storage.Tables[song.id].distance or 100) then
                table.insert(SongsToPlay, {id = id..k, url = song.url, coords = vector3(v.coords.x, v.coords.y, v.coords.z), loop = song.loop, volume = song.volume or 0.3, panner = song.panner})
                FoundSpeaker = true
            end
        end
        if not FoundSpeaker then
            table.insert(SongsToPlay, {id = id, url = song.url, coords = song.coords, loop = song.loop, volume = song.volume or 0.3, panner = song.panner})
        end
    end
    -- CreateThread(function()
    --     local timeStamp = 0
    --     for k, song in pairs(SongsToPlay) do
    --         if song.id then
    --             PlaySound(src, song.id, song.url, song.coords, song.loop, song.volume or 0.3, song.panner)
    --             timeStamp = GetTimeStamp(song.id)
    --             if timeStamp then
    --                 SetTimeStamp(src, song.id, timeStamp)
    --             end
    --             SetMaxDistance(src, song.id, song.distance)
    --             if not song.loop then
    --                 SetDestroyOnFinish(src, song.id, true)
    --             end
    --         end
    --     end
    -- end)
    TriggerClientEvent('flex_dj:client:PlayGlobalSound', src, SongsToPlay)
end)

RegisterNetEvent('flex_dj:server:RegisterSpeaker', function(data)
    if not data then return end
    if type(Storage.Speakers) ~= 'table' then
        Storage.Speakers = {}
    end
    if not data.id then
        data.id = os.time()
    end
    table.insert(Storage.Speakers, data)
    TriggerClientEvent('flex_dj:client:RegisterSpeaker', -1, data)
    SaveResourceFile(GetCurrentResourceName(), "storage/speakers.json", json.encode(Storage.Speakers or {}), -1)
end)

RegisterNetEvent('flex_dj:server:DeleteSpeaker', function(id)
    if not id then return end
    if not Storage.Speakers[id] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Speakers[id].coords.x, Storage.Speakers[id].coords.y, Storage.Speakers[id].coords.z)
    if not HasPermissions(src) and #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    TriggerClientEvent('flex_dj:client:DeleteSpeaker', -1, id, SpeakerCoords.xyz)
    table.remove(Storage.Speakers, id)
    SaveResourceFile(GetCurrentResourceName(), "storage/speakers.json", json.encode(Storage.Speakers or {}), -1)
end)

RegisterNetEvent('flex_dj:server:SetSpeakerDistance', function(id, distance)
    if not id or not distance then return end
    local SpeakerId = GetSpeakerArrayId(id)
    if not SpeakerId then return end
    if not Storage.Speakers[SpeakerId] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Speakers[SpeakerId].coords.x, Storage.Speakers[SpeakerId].coords.y, Storage.Speakers[SpeakerId].coords.z)
    if not HasPermissions(src) and #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    Storage.Speakers[SpeakerId].distance = distance or 5
    SaveResourceFile(GetCurrentResourceName(), "storage/speakers.json", json.encode(Storage.Speakers or {}), -1)
end)

RegisterNetEvent('flex_dj:server:RegisterTable', function(data)
    if not data then return end
    if type(Storage.Tables) ~= 'table' then
        Storage.Tables = {}
    end
    if not data.id then
        data.id = os.time()
    end
    table.insert(Storage.Tables, data)
    TriggerClientEvent('flex_dj:client:RegisterTable', -1, data)
end)

RegisterNetEvent('flex_dj:server:RegisterRadio', function(data)
    if not data then return end
    if type(Storage.Radios) ~= 'table' then
        Storage.Radios = {}
    end
    if not data.id then
        data.id = os.time()
    end
    table.insert(Storage.Radios, data)
    TriggerClientEvent('flex_dj:client:RegisterRadio', -1, data)
end)

RegisterNetEvent('flex_dj:server:DeleteRadio', function(id)
    if not id then return end
    if not Storage.Radios[id] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Radios[id].coords.x, Storage.Radios[id].coords.y, Storage.Radios[id].coords.z)
    if not HasPermissions(src) and #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    TriggerClientEvent('flex_dj:client:DeleteRadio', -1, id, SpeakerCoords.xyz)
    table.remove(Storage.Radios, id)
    SaveResourceFile(GetCurrentResourceName(), "storage/radios.json", json.encode(Storage.Radios or {}), -1)
end)

RegisterNetEvent('flex_dj:server:SetRadioDistance', function(id, distance)
    if not id or not distance then return end
    if not Storage.Radios[id] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Radios[id].coords.x, Storage.Radios[id].coords.y, Storage.Radios[id].coords.z)
    if #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    Storage.Radios[id].distance = distance or 100
    SetMaxDistance(-1, Storage.CurrentPlayingIds[id], distance or 100)
    SaveResourceFile(GetCurrentResourceName(), "storage/radios.json", json.encode(Storage.Radios or {}), -1)
end)

RegisterNetEvent('flex_dj:server:SetTableDistance', function(id, distance)
    if not id or not distance then return end
    if not Storage.Tables[id] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Tables[id].coords.x, Storage.Tables[id].coords.y, Storage.Tables[id].coords.z)
    if #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    Storage.Tables[id].distance = distance or 100
    SetMaxDistance(-1, Storage.CurrentPlayingIds[id], distance or 100)
    SaveResourceFile(GetCurrentResourceName(), "storage/tables.json", json.encode(Storage.Tables or {}), -1)
end)

RegisterNetEvent('flex_dj:server:DeleteTable', function(id)
    if not id then return end
    if not Storage.Tables[id] then return end
    local src = source
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return end
    local pedCoords = GetEntityCoords(ped)
    local SpeakerCoords = vector3(Storage.Tables[id].coords.x, Storage.Tables[id].coords.y, Storage.Tables[id].coords.z)
    if not HasPermissions(src) and #(SpeakerCoords.xyz - pedCoords.xyz) > 20.0 then return DropPlayer(src, locale('error.exploit_kick')) end
    TriggerClientEvent('flex_dj:client:DeleteTable', -1, id, SpeakerCoords.xyz)
    table.remove(Storage.Tables, id)
    SaveResourceFile(GetCurrentResourceName(), "storage/tables.json", json.encode(Storage.Tables or {}), -1)
end)

RegisterNetEvent('flex_dj:server:PlayGlobalSound', function(id, type, url, coords, loop, volume, panner, deck)
    local src = source
    if not coords then
        coords = GetClosestTableToPlayerCoords(src) or GetClosestRadioToPlayerCoords(src) or false
        id = GetClosestIDToPlayer(src)
    end
    if not id then return end
    local SoundId = CreateSoundId()
    local NewSoundId = SoundId
    if deck then
       NewSoundId = SoundId..deck
    else
        NewSoundId = SoundId
    end
    local FoundSpeaker = false
    local SourceId = GetRadioArrayId(id) or GetSpeakerArrayId(id) or GetTurnTableArrayId(id)
    if not SourceId then return end
    if not IsPlayerNearCoords(src, coords) then return end
    if deck then
       id = id..deck
    end
    if Storage.CurrentPlayingIds[id] then return end
    local SongsToPlay = {}
    for k, v in pairs(Storage.Speakers) do
        if #(coords.xyz - vector3(v.coords.x, v.coords.y, v.coords.z)) <= (type and type:lower() == 'radio' and Storage.Radios[SourceId] and Storage.Radios[SourceId].distance or Storage.Tables[SourceId] and Storage.Tables[SourceId].distance or 100) then
            local SpeakerId, state = Storage.CurrentPlayingIds[id] and IsSpeakerInUse(Storage.CurrentPlayingIds[id]..k)
            if not Storage.CurrentPlayingIds[id] or not state then
                table.insert(SongsToPlay, {id = NewSoundId..k, distance = v.distance, url = url, coords = vector3(v.coords.x, v.coords.y, v.coords.z), loop = loop, volume = volume or 0.3, panner = panner})
                table.insert(Storage.UsedSpeakers, NewSoundId..k)
                FoundSpeaker = true
            end
        end
    end
    if not FoundSpeaker then
        table.insert(SongsToPlay, {id = NewSoundId, url = url, coords = coords, loop = loop, volume = volume or 0.3, panner = panner})
    end
    -- CreateThread(function()
    --     local count = #SongsToPlay
    --     if count == 0 then return end
    --     for i = 1, count do
    --         local song = SongsToPlay[i]
    --         PlaySound(-1, song.id, song.url, song.coords, song.loop, song.volume or 0.3, song.panner)
    --         SetMaxDistance(-1, song.id, song.distance or 5)
    --         if not song.loop then
    --             SetDestroyOnFinish(-1, song.id, true)
    --         end
    --     end
    --     Wait(100)
    --     local syncTime = GetTimeStamp(SongsToPlay[1].id)
    --     for i = 1, count do
    --         syncTime = GetTimeStamp(SongsToPlay[1].id)
    --         local song = SongsToPlay[i]
    --         SetTimeStamp(-1, song.id, syncTime or 0)
    --         Wait(1000)
    --     end
    -- end)
    TriggerClientEvent('flex_dj:client:PlayGlobalSound', -1, SongsToPlay)
    Storage.CurrentSongSettings[id] = {id = id, type = type, url = url, coords = coords, loop = loop, volume = volume, panner = panner, distance = 100}
    Storage.CurrentPlayingIds[id] = not NewSoundId and SoundId or NewSoundId
end)

RegisterNetEvent('flex_dj:server:SetGlobalSoundVolume', function(id, type, vol, deck)
    local src = source
    if not id then
        id = GetClosestIDToPlayer(src)
    end
    if not id then return end
    local lookupId = deck and (id .. deck) or id
    local currentPlayingId = Storage.CurrentPlayingIds[lookupId]
    if currentPlayingId then
        local FoundSpeaker = false
        if Storage.CurrentSongSettings[lookupId] then
            Storage.CurrentSongSettings[lookupId].volume = vol
        end
        for _, fullSpeakerId in pairs(Storage.UsedSpeakers) do
            if string.find(fullSpeakerId, currentPlayingId, 1, true) then
                TriggerClientEvent('flex_dj:client:GlobalSoundVolume', -1, fullSpeakerId, vol)
                FoundSpeaker = true
            end
        end
        if not FoundSpeaker then
            TriggerClientEvent('flex_dj:client:GlobalSoundVolume', -1, currentPlayingId, vol)
        end
    end
end)

RegisterNetEvent('flex_dj:server:StopGlobalSound', function(id, type, deck)
    local src = source
    if not id then
        id = GetClosestIDToPlayer(src)
    end
    if not id then return end
    local currentPlayingId = Storage.CurrentPlayingIds[id]
    if deck then
        currentPlayingId = Storage.CurrentPlayingIds[id..deck]
        Storage.CurrentPlayingIds[id..deck] = nil
    else
        Storage.CurrentPlayingIds[id] = nil
    end
    if currentPlayingId then
        local SourceId = GetRadioArrayId(id) or GetSpeakerArrayId(id) or GetTurnTableArrayId(id)
        if not SourceId then return end
        local FoundSpeaker = false
        for speakerId, _ in pairs(Storage.Speakers) do
            for k, v in pairs(Storage.UsedSpeakers) do
                if v == currentPlayingId..speakerId then
                    local SpeakerId, state = IsSpeakerInUse(currentPlayingId..speakerId)
                    if state then
                        -- DestroySound(-1, currentPlayingId..speakerId)
                        TriggerClientEvent('flex_dj:client:DestroyGlobalSound', -1, currentPlayingId..speakerId)
                        FoundSpeaker = true
                    end
                end
            end
        end
        if not FoundSpeaker then
            -- DestroySound(-1, currentPlayingId)
            TriggerClientEvent('flex_dj:client:DestroyGlobalSound', -1, currentPlayingId)
        end
    end
end)

RegisterNetEvent('flex_dj:server:SetGlobalDistance', function(id, type, distance)
    if Storage.CurrentPlayingIds[id] then
        local SourceId = GetRadioArrayId(id) or GetSpeakerArrayId(id) or GetTurnTableArrayId(id)
        if not SourceId then return end
        local FoundSpeaker = false
        for k, v in pairs(Storage.UsedSpeakers) do
            if v == Storage.CurrentPlayingIds[id]..k then
                local SpeakerId, state = IsSpeakerInUse(Storage.CurrentPlayingIds[id]..k)
                if state then
                    -- SetMaxDistance(-1, Storage.CurrentPlayingIds[id]..k, distance)
                    TriggerClientEvent('flex_dj:client:GlobalSoundDistance', -1, Storage.CurrentPlayingIds[id]..k, distance)
                    FoundSpeaker = true
                end
            end
        end
        if not FoundSpeaker then
            -- SetMaxDistance(-1, Storage.CurrentPlayingIds[id], distance)
            TriggerClientEvent('flex_dj:client:GlobalSoundDistance', -1, Storage.CurrentPlayingIds[id], distance)
        end
        Storage.CurrentSongSettings[id].distance = distance
    end
end)

RegisterNetEvent('flex_dj:server:DisableAllFilters', function(id)
    local src = source
    if not id then
        id = GetClosestIDToPlayer(src)
    end
    if not id then return end
    local currentPlayingId = Storage.CurrentPlayingIds[id]
    if deck then
        currentPlayingId = Storage.CurrentPlayingIds[id..deck]
        Storage.CurrentPlayingIds[id..deck] = nil
    else
        Storage.CurrentPlayingIds[id] = nil
    end
    if currentPlayingId then
        local SourceId = GetRadioArrayId(id) or GetSpeakerArrayId(id) or GetTurnTableArrayId(id)
        if not SourceId then return end
        local FoundSpeaker = false
        for speakerId, _ in pairs(Storage.Speakers) do
            for k, v in pairs(Storage.UsedSpeakers) do
                if v == currentPlayingId..speakerId then
                    local SpeakerId, state = IsSpeakerInUse(currentPlayingId..speakerId)
                    if state then
                        TriggerClientEvent('flex_dj:client:DisableAllFilters', -1, currentPlayingId..speakerId)
                        FoundSpeaker = true
                    end
                end
            end
        end
        if not FoundSpeaker then
            TriggerClientEvent('flex_dj:client:DisableAllFilters', -1, currentPlayingId)
        end
    end
end)

RegisterNetEvent('flex_dj:server:SetStereoType', function(id, stereo)
    local src = source
    if not id then
        id = GetClosestIDToPlayer(src)
    end
    if not id then return end
    local currentPlayingId = Storage.CurrentPlayingIds[id]
    if deck then
        currentPlayingId = Storage.CurrentPlayingIds[id..deck]
        Storage.CurrentPlayingIds[id..deck] = nil
    else
        Storage.CurrentPlayingIds[id] = nil
    end
    if currentPlayingId then
        local SourceId = GetRadioArrayId(id) or GetSpeakerArrayId(id) or GetTurnTableArrayId(id)
        if not SourceId then return end
        local FoundSpeaker = false
        for speakerId, _ in pairs(Storage.Speakers) do
            for k, v in pairs(Storage.UsedSpeakers) do
                if v == currentPlayingId..speakerId then
                    local SpeakerId, state = IsSpeakerInUse(currentPlayingId..speakerId)
                    if state then
                        TriggerClientEvent('flex_dj:client:SetStereoType', -1, currentPlayingId..speakerId, stereo)
                        FoundSpeaker = true
                    end
                end
            end
        end
        if not FoundSpeaker then
            TriggerClientEvent('flex_dj:client:SetStereoType', -1, currentPlayingId, stereo)
        end
    end
end)

RegisterNetEvent('flex_dj:server:AddSong', function(id, song)
    if not Storage.Usb[id] then
        Storage.Usb[id] = {}
    end
    table.insert(Storage.Usb[id], song)
end)

-- USB AND MP3 GENERATION
local function GenerateUsbId()
    local id = 'usb'..math.random(1,9999)
    while Storage.Usb[id] do
        id = 'usb'..(os.time() or math.random(1,9999999))
        Wait(0)
    end
    return id
end
exports("GenerateUsbId", GenerateUsbId)

local function GenerateMp3Id()
    local id = 'mp3'..math.random(1,9999)
    while Storage.Mp3[id] do
        id = 'mp3'..(os.time() or math.random(1,9999999))
        Wait(0)
    end
    return id
end
exports("GenerateMp3Id", GenerateMp3Id)

RegisterNetEvent('flex_dj:server:GenerateUsb', function()
    local usbId = exports['flex_dj']:GenerateUsbId()
    if not usbId then return end
    AddItem(source, Config.Item.usb, 1, {usbid = usbId}, nil)
end)

RegisterNetEvent('flex_dj:server:GenerateMp3', function()
    local mp3id = exports['flex_dj']:GenerateMp3Id()
    if not mp3id then return end
    AddItem(source, Config.Item.mp3, 1, {mp3id = mp3id}, nil)
end)

CreateThread(function()
    RegisterCommand(Config.Commands.giveusb or "giveusb", function(source, args)
        local targetId = tonumber(args[1]) or source
        if not targetId then return end
        local usbId = exports['flex_dj']:GenerateUsbId()
        if not usbId then return end
        AddItem(targetId, Config.Item.usb, 1, {usbid = usbId}, nil)
    end)

    RegisterCommand(Config.Commands.givemp3 or "givemp3", function(source, args)
        local targetId = tonumber(args[1]) or source
        if not targetId then return end
        local mp3id = exports['flex_dj']:GenerateMp3Id()
        if not mp3id then return end
        AddItem(targetId, Config.Item.mp3, 1, {mp3id = mp3id}, nil)
    end)
end)

AddEventHandler('onResourceStart', function(res)
    Storage.Speakers = json.decode(SpeakersJson or {})
    Storage.Radios = json.decode(RadiosJson or {})
    Storage.Tables = json.decode(TablesJson or {})
    Storage.Usb = json.decode(UsbJson or {})
    Storage.Mp3 = json.decode(Mp3Json or {})
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    SaveResourceFile(GetCurrentResourceName(), "storage/speakers.json", json.encode(Storage.Speakers or {}), -1)
    SaveResourceFile(GetCurrentResourceName(), "storage/radios.json", json.encode(Storage.Radios or {}), -1)
    SaveResourceFile(GetCurrentResourceName(), "storage/tables.json", json.encode(Storage.Tables or {}), -1)
    SaveResourceFile(GetCurrentResourceName(), "storage/usb.json", json.encode(Storage.Usb or {}), -1)
    SaveResourceFile(GetCurrentResourceName(), "storage/mp3.json", json.encode(Storage.Mp3 or {}), -1)
end)

RegisterNetEvent('flex_dj:srver:StageLights', function(bpm)
    TriggerClientEvent('flex_dj:client:StageLights', -1, bpm)
end)