if GetResourceState('mx-surround') ~= 'started' then return end

function GenerateLocalSoundId()
    return exports['mx-surround']:createUniqueId()
end

function soundExists(soundId)
    return exports['mx-surround']:soundExists(soundId)
end

function Destroy(soundId)
    return exports['mx-surround']:Destroy(soundId)
end

function Resume(soundId)
    return exports['mx-surround']:Resume(soundId)
end

function Play(soundId, url, coords, loop, volume, panner)
    return exports['mx-surround']:Play(soundId, url, coords, loop, volume, panner)
end

function attachPlayer(soundId, playerId)
    return exports['mx-surround']:attachPlayer(soundId, playerId)
end

function Pause(soundId)
    return exports['mx-surround']:Pause(soundId)
end

function setVolumeMax(soundId, volume, disableOverWrite)
    return exports['mx-surround']:setVolumeMax(soundId, volume, disableOverWrite)
end

function PlaySound(soundId, url, coords, loop, volume, panner)
    return exports['mx-surround']:Play(soundId, url, coords, loop, volume, panner)
end

function SetMaxDistance(soundId, maxDistance)
    return exports['mx-surround']:setMaxDistance(soundId, maxDistance or 100)
end

function SetDestroyOnFinish(soundId, destroyOnFinish)
    return exports['mx-surround']:setDestroyOnFinish(soundId, destroyOnFinish)
end

function SetTimeStamp(soundId, timeStamp)
    return exports['mx-surround']:setTimeStamp(soundId, timeStamp)
end

function DisableFilters(soundId, disableFilter)
    exports['mx-surround']:setDisableInteriorFilter(soundId, disableFilter)
    return exports['mx-surround']:setDisableVehicleFilter(soundId, disableFilter)
end

function setStereoMode(soundId, stereo)
    return exports['mx-surround']:setStereoMode(soundId, stereo)
end

function isPlaying(soundId)
    return exports['mx-surround']:isPlaying(soundId)
end