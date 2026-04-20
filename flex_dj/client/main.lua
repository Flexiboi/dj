local Storage = {
    localSoundId = GenerateLocalSoundId(),
    Speakers = {},
    Computers = {},
    Radios = {},
    Tables = {},
    TargetZones = {},
    Mic = false,
}
local Editor = {
    object = nil,
}

-- Resource start
-- Load all active stuff like speakers, ...
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Wait(1000)
    if LocalPlayer.state.isLoggedIn then
        TriggerEvent('flex_dj:client:Load')
    end
end)

-- On player load
-- Same as resource start just in case not everything is loaded
RegisterNetEvent('flex_dj:client:Load', function()
    Wait(100)
    if #Storage.Speakers > 0 then return end
    TriggerServerEvent('flex_dj:server:Load')
end)

-- Player unload
-- Same as resource stop
RegisterNetEvent('flex_dj:client:UnLoad', function()
    if DoesEntityExist(Editor.object) then
        DeleteEntity(Editor.object)
    end
    for _, v in pairs(Storage.Speakers) do
        if v.object then
            if DoesEntityExist(v.object) then
                DeleteEntity(v.object)
            end
        end
        if v.point then
            v.point:remove()
        end
    end
    for _, v in pairs(Storage.Tables) do
        if v.object then
            if DoesEntityExist(v.object) then
                DeleteEntity(v.object)
            end
        end
        if v.point then
            v.point:remove()
        end
    end
    for _, v in pairs(Storage.TargetZones) do
        exports.ox_target:removeZone(v)
    end
    Storage = {
        Speakers = {},
        Computers = {},
        Radios = {},
        TargetZones = {},
    }
    Editor = {
        object = nil,
    }
end)

-- Function to open usb stash / slot
-- @param id - ID of the USB / Can be nil
-- @param slot - ID of the used item slot if mp3 item is used or export
local function OpenUsbStash(id, slot)
    lib.callback('flex_dj:server:RegisterStash', false, function(stash, stashid)
        if stash then
        end
    end, id or nil, slot or nil)
end
exports('OpenUsbStash', OpenUsbStash)

-- Function to get all songs from usb
-- @param id - The id of the usb
local function GetUsbSongs(id)
    local songs = lib.callback.await("flex_dj:server:GetUsbSongs", false, id)
    local p = promise:new()
    p:resolve(songs)
    return Citizen.Await(p)
end
exports('GetUsbSongs', GetUsbSongs)

-- Function to get usb id from stash
-- @param id - The stash id
local function GetUsbId(id)
    local UsbId = lib.callback.await("flex_dj:server:GetUSBId", false, id)
    local p = promise:new()
    p:resolve(UsbId)
    return Citizen.Await(p)
end
exports('GetUsbId', GetUsbId)

-- Event To Use MP3 (TEMP UI)
-- @param data - id of the usb
RegisterNetEvent('flex_dj:client:UseMp3', function(id)
    local usb = exports.flex_dj:GetUsbId(id)
    if not usb then return end
    local songs = exports.flex_dj:GetUsbSongs(usb)
    if not songs then return end
    local songList = {}
    for k, v in pairs(songs) do
        table.insert(songList, {
            title = v.title,
            description = v.artist,
            icon = "fas fa-music",
            onSelect = function()
                if soundExists(Storage.localSoundId) then
                    Destroy(Storage.localSoundId)
                end
                Play(Storage.localSoundId, v.url, nil, false, 0.1, false)
                attachPlayer(Storage.localSoundId, GetPlayerServerId(cache.playerId))
            end,
        })
    end
    lib.registerContext({
        id = locale("menu.mp3.title"),
        title = locale("menu.mp3.title"),
        options = {
            {
                title = locale("menu.mp3.resume"),
                icon = "fas fa-play",
                onSelect = function()
                    Resume(Storage.localSoundId)
                end,
            },
            {
                title = locale("menu.mp3.pause"),
                icon = "fas fa-pause",
                onSelect = function()
                    Pause(Storage.localSoundId)
                end,
            },
            {
                title = locale("menu.mp3.stop"),
                icon = "fas fa-stop",
                onSelect = function()
                    Destroy(Storage.localSoundId)
                end,
            },
            {
                title = locale("menu.mp3.volume"),
                icon = "fas fa-volume-up",
                onSelect = function()
                    local input = lib.inputDialog(locale("menu.mp3.volume"), {
                        { type = 'slider', default = 10, min = 0, max = 100, label = locale("menu.mp3.volume"), step = 1, required = true },
                    })
                    if not input or not input[1] then return end
                    local succes = setVolumeMax(Storage.localSoundId, tonumber(input[1])/100, false)
                end,
            },
            {
                title = locale("menu.mp3.change_song"),
                icon = "fas fa-exchange-alt",
                onSelect = function()
                    lib.registerContext({
                        id = locale("menu.mp3.change_song"),
                        title = locale("menu.mp3.change_song"),
                        options = songList,
                    })
                    lib.showContext(locale("menu.mp3.change_song"))
                end,
            },
        },
    })
    lib.showContext(locale("menu.mp3.title"))
end)

-- Play the audio from the source from server side
-- @param array - list of all the stuff to play
RegisterNetEvent('flex_dj:client:PlayGlobalSound', function(SongsToPlay)
    CreateThread(function()
        local count = #SongsToPlay
        if count == 0 then return end
        for i = 1, count do
            local song = SongsToPlay[i]
            local panner = {
                panningModel = 'HRTF',
                refDistance = song.distance,  -- Distance of the volume dropoff start
                rolloffFactor = 1.0, -- How fast the volume drops off (don't 0.1)
                distanceModel = 'exponential',
                coneInnerAngle = 360.0,
                coneOuterAngle = 0.0,
            }
            PlaySound(song.id, song.url, vec3(song.coords.x, song.coords.y, song.coords.z+1), song.loop or false, song.volume or 0.3, panner)
            SetMaxDistance(song.id, song.distance or 5)
            if not song.loop then
                SetDestroyOnFinish(song.id, true)
            end
        end
        Wait(100)
        local syncTime = GetTimeStamp(SongsToPlay[1].id)
        for i = 1, count do
            syncTime = GetTimeStamp(SongsToPlay[1].id)
            local song = SongsToPlay[i]
            SetTimeStamp(song.id, syncTime or 0)
        end
    end)
end)

-- Destroy the audio from the source from server side
-- @param soundId - id of the source
RegisterNetEvent('flex_dj:client:DestroyGlobalSound', function(soundId)
    Destroy(soundId)
end)

-- Set the audio volume from the source from server side
-- @param soundId - Id of the source
-- @param volume - Volume for the source
RegisterNetEvent('flex_dj:client:GlobalSoundVolume', function(soundId, volume)
    setVolumeMax(soundId, volume, false)
end)

-- Set the audio distance from the source from server side
-- @param soundId - Id of the source
-- @param distance - Distance for the source
RegisterNetEvent('flex_dj:client:GlobalSoundDistance', function(soundId, distance)
    SetMaxDistance(soundId, distance, false)
end)

-- Set the audio distance from the source from server side
-- @param soundId - Id of the source
-- @param disableFilter - false = disavle filters
RegisterNetEvent('flex_dj:client:DisableAllFilters', function(soundId, disableFilter)
    DisableFilters(soundId, disableFilter)
end)

-- Set the audio distance from the source from server side
-- @param soundId - Id of the source
-- @param disableFilter - false = disavle filters
RegisterNetEvent('flex_dj:client:SetStereoType', function(soundId, stereo)
    setStereoMode(soundId, stereo)
end)

-- Register new speaker
-- @param data - all speaker data like model, ...
RegisterNetEvent('flex_dj:client:RegisterSpeaker', function(data)
    if data.model then
        local point = lib.points.new(data.coords.xyz, 100.0)
        function point:onEnter()
            local obj = CreateObjectNoOffset(data.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
            SetEntityRotation(obj, data.rot.x, data.rot.y, data.rot.z, 2, true)
            FreezeEntityPosition(obj, true)
            Storage.Speakers[point] = {id = point, object = obj, coords = data.coords, point = point}
        end
        function point:onExit()
            if DoesEntityExist(Storage.Speakers[point].object) then
                DeleteEntity(Storage.Speakers[point].object)
            end
        end
    else
        table.insert(Storage.Speakers, {id = #Storage.Speakers, object = nil, coords = data.coords, point = nil})
    end
end)

-- Register new radio
-- @param data - all Radio data like model, ...
RegisterNetEvent('flex_dj:client:RegisterRadio', function(data)
    if data.model then
        local point = lib.points.new(data.coords.xyz, 100.0)
        function point:onEnter()
            local obj = CreateObjectNoOffset(data.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
            SetEntityRotation(obj, data.rot.x, data.rot.y, data.rot.z, 2, true)
            FreezeEntityPosition(obj, true)
            if not Storage.Radios[point] then
                Storage.Radios[point] = {id = point, object = obj, coords = data.coords, point = point, target = nil}
            else
                Storage.Radios[point].object = obj
            end
            local target = exports.ox_target:addLocalEntity(obj, {{
                name = locale("target.play_radio"),
                label = locale("target.play_radio"),
                icon = "radio",
                distance = 1.5,
                onSelect = function()
                    local input = lib.inputDialog(locale("menu.radio.selectchannel"), {
                        { type = 'select',  label = locale("menu.radio.channel"), options = Config.RadioChannels, required = true },
                    })
                    if not input or not input[1] then return end
                    if not isPlaying(data.id) then
                        TriggerServerEvent('flex_dj:server:PlayGlobalSound', data.id, 'radio', input[1], data.coords.xyz, true, 0.05, nil)
                    end
                    TriggerServerEvent('flex_dj:server:SetGlobalDistance', data.id, data.distance or 100)
                end
            },{
                name = locale("target.volume_radio"),
                label = locale("target.volume_radio"),
                icon = "radio",
                distance = 1.5,
                onSelect = function()
                    local input = lib.inputDialog(locale("menu.radio.radiovolume"), {
                        { type = 'slider', default = 10, min = 0, max = 100, label = locale("menu.radio.volume"), step = 1, required = true },
                    })
                    if not input or not input[1] then return end
                    TriggerServerEvent('flex_dj:server:SetGlobalSoundVolume', data.id, 'radio', tonumber(input[1])/100)
                end
            },{
                name = locale("target.stop_radio"),
                label = locale("target.stop_radio"),
                icon = "radio",
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent('flex_dj:server:StopGlobalSound', data.id, 'radio')
                end
            },})
            Storage.Radios[point].target = target
        end
        function point:onExit()
            if DoesEntityExist(Storage.Radios[point].object) then
                DeleteEntity(Storage.Radios[point].object)
            end
            exports.ox_target:removeLocalEntity(Storage.Radios[point].object)
        end
    else
        local point = lib.points.new(data.coords.xyz, 100.0)
        table.insert(Storage.Radios, {id = #Storage.Radios, object = nil, coords = data.coords, point = point})
        function point:onEnter()
            Storage.TargetZones[point] = exports.ox_target:addBoxZone({
                coords = data.coords.xyz,
                size = vec3(0.15, 0.15, 0.15),
                rotation = data.coords.w or 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = locale("target.play_radio"),
                        label = locale("target.play_radio"),
                        icon = "radio",
                        distance = 1.5,
                        onSelect = function()
                            local input = lib.inputDialog(locale("menu.radio.selectchannel"), {
                                { type = 'select',  label = locale("menu.radio.channel"), options = Config.RadioChannels, required = true },
                            })
                            if not input or not input[1] then return end
                            if not isPlaying(data.id) then
                                TriggerServerEvent('flex_dj:server:PlayGlobalSound', data.id, 'radio', input[1], data.coords.xyz, true, 0.05, nil)
                            end
                            TriggerServerEvent('flex_dj:server:SetGlobalDistance', data.id, data.distance or 100)
                        end
                    },{
                        name = locale("target.volume_radio"),
                        label = locale("target.volume_radio"),
                        icon = "radio",
                        distance = 1.5,
                        onSelect = function()
                            local input = lib.inputDialog(locale("menu.radio.radiovolume"), {
                                { type = 'slider', default = 10, min = 0, max = 100, label = locale("menu.radio.volume"), step = 1, required = true },
                            })
                            if not input or not input[1] then return end
                            TriggerServerEvent('flex_dj:server:SetGlobalSoundVolume', data.id, 'radio', tonumber(input[1])/100)
                        end
                    },{
                        name = locale("target.stop_radio"),
                        label = locale("target.stop_radio"),
                        icon = "radio",
                        distance = 1.5,
                        onSelect = function()
                            TriggerServerEvent('flex_dj:server:StopGlobalSound', data.id, 'radio')
                        end
                    },
                },
            })
        end
        function point:onExit()
            exports.ox_target:removeZone(Storage.TargetZones[point])
        end
    end
end)

-- Register new table
-- @param data - all Table data like model, ...
RegisterNetEvent('flex_dj:client:RegisterTable', function(data)
    if data.model then
        local point = lib.points.new(data.coords.xyz, 100.0)
        function point:onEnter()
            local obj = CreateObjectNoOffset(data.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
            SetEntityRotation(obj, data.rot.x, data.rot.y, data.rot.z, 2, true)
            FreezeEntityPosition(obj, true)
            if not Storage.Tables[point] then
                Storage.Tables[point] = {id = point, object = obj, coords = data.coords, point = point, target = nil}
            else
                Storage.Tables[point].object = obj
            end
            local target = exports.ox_target:addLocalEntity(obj, {{
                    name = locale("target.use_computer"),
                    label = locale("target.use_computer"),
                    icon = "radio",
                    distance = 1.5,
                    onSelect = function()
                        lib.callback("flex_dj:server:GetUSBId", false, function(id)
                            if id then
                                SendNUIMessage({
                                    type = "open",
                                    usb = id
                                })
                                SetNuiFocus(true, true)
                            else
                                lib.callback('flex_dj:server:RegisterStash', false, function(stash)
                                    if stash then
                                    end
                                end, data.id)
                            end
                        end, data.id)
                    end
                },
                {
                    name = locale("target.insert_usb"),
                    label = locale("target.insert_usb"),
                    icon = "usb",
                    distance = 1.5,
                    onSelect = function()
                        lib.callback('flex_dj:server:RegisterStash', false, function(stash)
                            if stash then
                            end
                        end, data.id)
                    end
                },
                {
                    name = locale("target.usemic"),
                    label = locale("target.usemic"),
                    icon = "microphone",
                    distance = 1.5,
                    onSelect = function()
                        Storage.Mic = not Storage.Mic
                        overrideProximityRange(Storage.Mic, Config.MicRange)
                        if Storage.Mic then
                            Config.Notify.client(locale("info.mic_on"), 'info', 3000)
                        else
                            Config.Notify.client(locale("info.mic_off"), 'info', 3000)
                        end
                        CreateThread(function()
                            while Storage.Mic do
                                Wait(3000)
                                if #(data.coords.xyz - GetEntityCoords(cache.ped)) > 10 then
                                    Storage.Mic = false
                                    overrideProximityRange(false, Config.MicRange)
                                    return Config.Notify.client(locale("info.mic_off"), 'info', 3000)
                                end
                            end
                        end)
                    end
                },
            })
            Storage.Tables[point].target = target
        end
        function point:onExit()
            if DoesEntityExist(Storage.Tables[point].object) then
                DeleteEntity(Storage.Tables[point].object)
            end
            exports.ox_target:removeLocalEntity(Storage.Tables[point].object)
        end
    else
        local point = lib.points.new(data.coords.xyz, 100.0)
        table.insert(Storage.Tables, {id = #Storage.Tables, object = nil, coords = data.coords, point = point})
        function point:onEnter()
            Storage.TargetZones[point] = exports.ox_target:addBoxZone({
                coords = data.coords.xyz,
                size = vec3(0.15, 0.15, 0.15),
                rotation = data.coords.w or 0.0,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = locale("target.use_computer"),
                        label = locale("target.use_computer"),
                        icon = "radio",
                        distance = 1.5,
                        onSelect = function()
                            lib.callback("flex_dj:server:GetUSBId", false, function(id)
                                if id then
                                    SendNUIMessage({
                                        type = "open",
                                        usb = id
                                    })
                                    SetNuiFocus(true, true)
                                else
                                    lib.callback('flex_dj:server:RegisterStash', false, function(stash)
                                        if stash then
                                        end
                                    end, data.id)
                                end
                            end, data.id)
                        end
                    },
                    {
                        name = locale("target.insert_usb"),
                        label = locale("target.insert_usb"),
                        icon = "usb",
                        distance = 1.5,
                        onSelect = function()
                            lib.callback('flex_dj:server:RegisterStash', false, function(stash)
                                if stash then
                                end
                            end, data.id)
                        end
                    },
                    {
                        name = locale("target.usemic"),
                        label = locale("target.usemic"),
                        icon = "microphone",
                        distance = 1.5,
                        onSelect = function()
                            Storage.Mic = not Storage.Mic
                            overrideProximityRange(Storage.Mic, Config.MicRange)
                            if Storage.Mic then
                                Config.Notify.client(locale("info.mic_on"), 'info', 3000)
                            else
                                Config.Notify.client(locale("info.mic_off"), 'info', 3000)
                            end
                            CreateThread(function()
                                while Storage.Mic do
                                    Wait(3000)
                                    if #(data.coords.xyz - GetEntityCoords(cache.ped)) > 10 then
                                        Storage.Mic = false
                                        overrideProximityRange(false, Config.MicRange)
                                        return Config.Notify.client(locale("info.mic_off"), 'info', 3000)
                                    end
                                end
                            end)
                        end
                    },
                },
            })
        end
        function point:onExit()
            exports.ox_target:removeZone(Storage.TargetZones[point])
        end
    end
end)

-- NUI --
-- Get Songs
-- @param data - Table
RegisterNUICallback('GetSongs', function(data, cb)
    if not data.id then return end
    cb(GetUsbSongs(data.id))
end)

-- Play Songs
-- @param data - Table
RegisterNUICallback('PlaySong', function(data, cb)
    if data.id and data.url then
        TriggerServerEvent('flex_dj:server:PlayGlobalSound', nil, 'table', data.url, nil, true, 0.1, nil, data.deck)
        cb(true)
    else
        cb(false)
    end
end)

-- Stop Songs
-- @param data - Table
RegisterNUICallback('StopSong', function(data, cb)
    if data.id and data.url then
        TriggerServerEvent('flex_dj:server:StopGlobalSound', nil, 'table', data.deck)
        cb(true)
    else
        cb(false)
    end
end)

-- Add Songs
-- @param data - Table
RegisterNUICallback('AddSong', function(data, cb)
    if data.id then
        TriggerServerEvent('flex_dj:server:AddSong', data.id, data.song)
        cb(true)
    else
        cb(false)
    end
end)

-- Set Songs Volume
-- @param data - Table
RegisterNUICallback('setVolume', function(data, cb)
    if not data.id then return cb(false) end
    TriggerServerEvent('flex_dj:server:SetGlobalSoundVolume', nil, 'table', tonumber(data.volume) or 0.1, data.deck)
    cb(true)
end)

-- Close Menu
-- @param data - Table
RegisterNUICallback('close_menu', function(data, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

-- Delete Speaker
-- @param id - Speaker id
-- @param coords - Vector3 where speaker is
RegisterNetEvent('flex_dj:client:DeleteSpeaker', function(id, coords)
    local PedCoords = GetEntityCoords(cache.ped)
    if not coords or not PedCoords or #(coords.xyz - PedCoords) > 20 then return end
    for k, v in pairs(Storage.Speakers) do
        if #(v.coords - coords) < 1 then
            if v.object then
                if DoesEntityExist(v.object) then
                    DeleteEntity(v.object)
                end
            end
            if v.point then
                v.point:remove()
            end
            Storage.Speakers[k] = nil
            return
        end
    end
end)

-- Delete Radio
-- @param id - Radio id
-- @param coords - Vector3 where radio is
RegisterNetEvent('flex_dj:client:DeleteRadio', function(id, coords)
    local PedCoords = GetEntityCoords(cache.ped)
    if not coords or not PedCoords or #(coords.xyz - PedCoords) > 20 then return end
    for k, v in pairs(Storage.Radios) do
        if #(v.coords - coords) < 1 then
            if v.object then
                if DoesEntityExist(v.object) then
                    exports.ox_target:removeLocalEntity(v.object)
                    DeleteEntity(v.object)
                end
            end
            if Storage.TargetZones[v.point] then
                exports.ox_target:removeZone(Storage.TargetZones[v.point])
            end
            if v.point then
                v.point:remove()
            end
            Storage.Radios[k] = nil
            return
        end
    end
end)

-- Delete Table
-- @param id - Table id
-- @param coords - Vector3 where table is
RegisterNetEvent('flex_dj:client:DeleteTable', function(id, coords)
    local PedCoords = GetEntityCoords(cache.ped)
    if not coords or not PedCoords or #(coords.xyz - PedCoords) > 20 then return end
    for k, v in pairs(Storage.Tables) do
        if #(v.coords - coords) < 1 then
            if v.object then
                if DoesEntityExist(v.object) then
                    exports.ox_target:removeLocalEntity(v.object)
                    DeleteEntity(v.object)
                end
            end
            if Storage.TargetZones[v.point] then
                exports.ox_target:removeZone(Storage.TargetZones[v.point])
            end
            if v.point then
                v.point:remove()
            end
            Storage.Tables[k] = nil
            return
        end
    end
end)

-- Add Table
-- Command to register a new table
-- Can be prop or cancel for no prop / use target zone
RegisterCommand(Config.Commands.addtable, function (src, args)
    if Editor.object and DoesEntityExist(Editor.object) then return end
    local input = lib.inputDialog(locale("menu.create.setup_speaker"), {
        { type = 'select',  label = locale("menu.create.select_model"), options = Config.Computers, required = true },
    })
    local model = input and input[1] or nil
    local data = nil
    if model then
        lib.requestModel(model, 1000)
        local coords = GetEntityCoords(cache.ped)
        local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
        Editor.object = obj
        SetEntityAlpha(obj, 200, false)
        SetEntityCollision(obj, false, false) 
        FreezeEntityPosition(obj, true)
        data = exports.flex_dj:useGizmo(obj)
    else
        data = exports.flex_dj:use3dselect()
    end

    if not data or not data.canceled then
        if DoesEntityExist(Editor.object) then
            DeleteEntity(Editor.object)
        end
        local input = lib.inputDialog(locale("menu.distance", 0), {
            { type = 'slider', default = 50, min = 0, max = 1000, label = locale("menu.distance", 0), step = 1, required = true },
        })
        if not input or not input[1] then return end
        TriggerServerEvent('flex_dj:server:RegisterTable', {
            model = model or nil,
            coords = data and data.position or data,
            rot = data and data.rotation or nil,
            distance = tonumber(input[1]) or 100,
        })
    end
    lib.hideTextUI()
end, true and not Config.Debug)

-- Add Speaker
-- Command to register a new speaker
-- Can be prop or cancel for no prop / use target zone
RegisterCommand(Config.Commands.addspeaker, function (src, args)
    if Editor.object and DoesEntityExist(Editor.object) then return end
    local input = lib.inputDialog(locale("menu.create.setup_speaker"), {
        { type = 'select',  label = locale("menu.create.select_model"), options = Config.Speakrs, required = true },
    })
    local model = input and input[1] or nil
    local data = nil
    if model then
        lib.requestModel(model, 1000)
        local coords = GetEntityCoords(cache.ped)
        local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
        Editor.object = obj
        SetEntityAlpha(obj, 200, false)
        SetEntityCollision(obj, false, false) 
        FreezeEntityPosition(obj, true)
        data = exports.flex_dj:useGizmo(obj)
    else
        data = exports.flex_dj:use3dselect()
    end

    if not data or not data.canceled then
        if DoesEntityExist(Editor.object) then
            DeleteEntity(Editor.object)
        end
        local input = lib.inputDialog(locale("menu.distance", 0), {
            { type = 'slider', default = 50, min = 0, max = 1000, label = locale("menu.distance", 0), step = 1, required = true },
        })
        if not input or not input[1] then return end
        TriggerServerEvent('flex_dj:server:RegisterSpeaker', {
            model = model or nil,
            coords = data and data.position or data,
            rot = data and data.rotation or nil,
            distance = tonumber(input[1]) or 100,
        })
    end
    lib.hideTextUI()
end, true and not Config.Debug)

-- Add Radio
-- Command to register a new radio
-- Can be prop or cancel for no prop / use target zone
RegisterCommand(Config.Commands.addradio, function (src, args)
    if Editor.object and DoesEntityExist(Editor.object) then return end
    local input = lib.inputDialog(locale("menu.create.setup_speaker"), {
        { type = 'select',  label = locale("menu.create.select_model"), options = Config.Radios, required = true },
    })
    local model = input and input[1] or nil
    local data = nil
    if model then
        lib.requestModel(model, 1000)
        local coords = GetEntityCoords(cache.ped)
        local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, false)
        Editor.object = obj
        SetEntityAlpha(obj, 200, false)
        SetEntityCollision(obj, false, false) 
        FreezeEntityPosition(obj, true)
        data = exports.flex_dj:useGizmo(obj)
    else
        data = exports.flex_dj:use3dselect()
    end

    if not data or not data.canceled then
        if Editor.object then
            if DoesEntityExist(Editor.object) then
                DeleteEntity(Editor.object)
            end
        end
        local input = lib.inputDialog(locale("menu.distance", 0), {
            { type = 'slider', default = 50, min = 0, max = 1000, label = locale("menu.distance", 0), step = 1, required = true },
        })
        if not input or not input[1] then return end
        TriggerServerEvent('flex_dj:server:RegisterRadio', {
            model = model or nil,
            coords = data and data.position or data,
            rot = data and data.rotation or nil,
            distance = tonumber(input[1]) or 100,
        })
    end
    lib.hideTextUI()
end, true and not Config.Debug)

-- Edit Speaker
-- Command to edit speaker
-- Change range, delete, ...
RegisterCommand(Config.Commands.editspeaker, function (src, args)
    lib.callback("flex_dj:server:GetSpeakers", false, function(speakers)
        if speakers and next(speakers) then
            local list = {}
            for k, v in pairs(speakers) do
                table.insert(list,{
                    title = 'Speaker: '..k,
                    description = locale("menu.delete.coords", v.coords),
                    icon = "cross",
                    onSelect = function()
                        lib.registerContext({
                            id = 'deletespeakermenu'..k,
                            title = locale("menu.delete.sub_title"),
                            options = {
                                {
                                    title = locale("menu.delete.teleport"),
                                    icon = "cross",
                                    onSelect = function()
                                        SetEntityCoordsNoOffset(cache.ped, v.coords.x, v.coords.y, v.coords.z, false, false, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.distance", v.distance),
                                    icon = "cross",
                                    onSelect = function()
                                        local input = lib.inputDialog(locale("menu.distance", v.distance), {
                                            { type = 'slider', default = 5, min = 0, max = 1000, label = locale("menu.distance", v.distance), step = 1, required = true },
                                        })
                                        if not input or not input[1] then return end
                                        TriggerServerEvent('flex_dj:server:SetSpeakerDistance', v.id, tonumber(input[1]))
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.disablefilters"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:DisableAllFilters', v.id, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.type.stereo"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:SetStereoType', v.id, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.type.3d"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:SetStereoType', v.id, false)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.delete.delete"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:DeleteSpeaker', k)
                                        lib.hideContext()
                                    end,
                                },
                            },
                        })
                        lib.showContext('deletespeakermenu'..k)
                    end,
                })
            end
            lib.registerContext({
                id = 'deletespeakermenu',
                title = locale("menu.delete.title"),
                options = list,
            })
            lib.showContext('deletespeakermenu')
        end
    end)
end, true and not Config.Debug)

-- Edit Radio
-- Command to edit radio
-- Change range, delete, ...
RegisterCommand(Config.Commands.editradio, function (src, args)
    lib.callback("flex_dj:server:GetRadios", false, function(speakers)
        if speakers and next(speakers) then
            local list = {}
            for k, v in pairs(speakers) do
                table.insert(list,{
                    title = 'Radio: '..k,
                    description = locale("menu.delete.coords", v.coords),
                    icon = "cross",
                    onSelect = function()
                        lib.registerContext({
                            id = 'deleteradiomenu'..k,
                            title = locale("menu.delete.sub_title"),
                            options = {
                                {
                                    title = locale("menu.delete.teleport"),
                                    icon = "cross",
                                    onSelect = function()
                                        SetEntityCoordsNoOffset(cache.ped, v.coords.x, v.coords.y, v.coords.z, false, false, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.distance", v.distance),
                                    icon = "cross",
                                    onSelect = function()
                                        local input = lib.inputDialog(locale("menu.distance", v.distance), {
                                            { type = 'slider', default = 50, min = 0, max = 1000, label = locale("menu.distance", v.distance), step = 1, required = true },
                                        })
                                        if not input or not input[1] then return end
                                        TriggerServerEvent('flex_dj:server:SetRadioDistance', v.id, tonumber(input[1]))
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.disablefilters"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:DisableAllFilters', v.id, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.delete.delete"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:DeleteRadio', k)
                                        lib.hideContext()
                                    end,
                                },
                            },
                        })
                        lib.showContext('deleteradiomenu'..k)
                    end,
                })
            end
            lib.registerContext({
                id = 'deleteradiomenu',
                title = locale("menu.delete.title"),
                options = list,
            })
            lib.showContext('deleteradiomenu')
        end
    end)
end, true and not Config.Debug)

-- Edit Table
-- Command to edit table
-- Change range, delete, ...
RegisterCommand(Config.Commands.edittable, function (src, args)
    lib.callback("flex_dj:server:GetTables", false, function(speakers)
        if speakers and next(speakers) then
            local list = {}
            for k, v in pairs(speakers) do
                table.insert(list,{
                    title = 'Tables: '..k,
                    description = locale("menu.delete.coords", v.coords),
                    icon = "cross",
                    onSelect = function()
                        lib.registerContext({
                            id = 'deletetablesmenu'..k,
                            title = locale("menu.delete.sub_title"),
                            options = {
                                {
                                    title = locale("menu.delete.teleport"),
                                    icon = "cross",
                                    onSelect = function()
                                        SetEntityCoordsNoOffset(cache.ped, v.coords.x, v.coords.y, v.coords.z, false, false, true)
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.distance", v.distance),
                                    icon = "cross",
                                    onSelect = function()
                                        local input = lib.inputDialog(locale("menu.distance", v.distance), {
                                            { type = 'slider', default = 50, min = 0, max = 1000, label = locale("menu.distance", v.distance), step = 1, required = true },
                                        })
                                        if not input or not input[1] then return end
                                        TriggerServerEvent('flex_dj:server:SetTableDistance', v.id, tonumber(input[1]))
                                        lib.hideContext()
                                    end,
                                },
                                {
                                    title = locale("menu.delete.delete"),
                                    icon = "cross",
                                    onSelect = function()
                                        TriggerServerEvent('flex_dj:server:DeleteTable', k)
                                        lib.hideContext()
                                    end,
                                },
                            },
                        })
                        lib.showContext('deletetablesmenu'..k)
                    end,
                })
            end
            lib.registerContext({
                id = 'deletetablesmenu',
                title = locale("menu.delete.title"),
                options = list,
            })
            lib.showContext('deletetablesmenu')
        end
    end)
end, true and not Config.Debug)

-- Resource stop
-- Delete / stop everything
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    if DoesEntityExist(Editor.object) then
        DeleteEntity(Editor.object)
    end
    for _, v in pairs(Storage.Speakers) do
        if DoesEntityExist(v.object) then
            DeleteEntity(v.object)
        end
        if v.point then
            v.point:remove()
        end
    end
    for _, v in pairs(Storage.Radios) do
        if DoesEntityExist(v.object) then
            exports.ox_target:removeLocalEntity(v.object)
            DeleteEntity(v.object)
        end
        if v.point then
            v.point:remove()
        end
    end
    for _, v in pairs(Storage.Tables) do
        if DoesEntityExist(v.object) then
            exports.ox_target:removeLocalEntity(v.object)
            DeleteEntity(v.object)
        end
        if v.point then
            v.point:remove()
        end
    end
    for _, v in pairs(Storage.TargetZones) do
        exports.ox_target:removeZone(v)
    end
end)