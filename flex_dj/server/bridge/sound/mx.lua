if GetResourceState('mx-surround') ~= 'started' then return end

function CreateSoundId()
    return exports['mx-surround']:createUniqueId()
end

function PlaySound(src, soundId, url, coords, loop, volume, panner)
    return exports['mx-surround']:Play(src, soundId, url, coords, loop, volume, panner)
end

function DestroySound(src, id)
    return exports['mx-surround']:Destroy(src, id)
end

function SetVolume(src, soundId, volume)
    return exports['mx-surround']:setVolumeMax(source, soundId, volume or 0.5, false)
end

function SetMaxDistance(source, soundId, maxDistance)
    return exports['mx-surround']:setMaxDistance(source, soundId, maxDistance or 100)
end

function SetDestroyOnFinish(source, soundId, destroyOnFinish)
    return exports['mx-surround']:setDestroyOnFinish(source, soundId, destroyOnFinish)
end

function GetTimeStamp(soundId)
    return exports['mx-surround']:getTimeStamp(soundId)
end

function SetTimeStamp(source, soundId, timeStamp)
    return exports['mx-surround']:setTimeStamp(source, soundId, timeStamp)
end