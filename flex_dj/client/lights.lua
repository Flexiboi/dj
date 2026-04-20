local lights = false
local stagePath = {
    vec3(1738.9534912109, 3236.4111328125, 40.803955078125),
    vec3(1726.2164306641, 3280.3481445312, 40.229797363281),
    vec3(1746.8194580078, 3268.6345214844, 40.234256744385),
    vec3(1751.0179443359, 3257.1662597656, 40.429466247559),
    vec3(1780.8382568359, 3246.8845214844, 41.361228942871),
    vec3(1768.4521484375, 3293.1098632812, 40.277744293213)
}
local lamps = {
    { pos = vec3(1774.0939941406, 3291.6713867188, 58.864608764648), speed = 1.0, offset = 0.0 },
    { pos = vec3(1775.2744140625, 3285.3447265625, 63.155502319336), speed = 0.7, offset = 1.5 },
    { pos = vec3(1782.9207763672, 3257.0090332031, 63.283462524414), speed = 1.3, offset = 4.2 },
    { pos = vec3(1785.0447998047, 3250.9309082031, 58.965003967285), speed = 0.9, offset = 2.8 },
}

RegisterNetEvent('flex_dj:client:StageLights', function(bpm)
    lights = not lights
    if lights then
        CreateThread(function()
            while lights do
                Wait(10)
                local currentTime = GetGameTimer()
                local beatMs = 60000 / (bpm or 140)
                local brightness = math.pow(1.0 - (currentTime % beatMs / beatMs), 3.0) * 15.0
                for i, lamp in ipairs(lamps) do
                    local totalTime = (currentTime / 1000.0) * lamp.speed
                    local segmentCount = #stagePath
                    local currentIdx = math.floor(totalTime % segmentCount) + 1
                    local nextIdx = (currentIdx % segmentCount) + 1
                    local segmentProgress = totalTime % 1.0
                    local p1 = stagePath[currentIdx]
                    local p2 = stagePath[nextIdx]
                    local currentTarget = p1 + (p2 - p1) * segmentProgress
                    local dir = currentTarget - lamp.pos
                    local mag = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
                    local dirNorm = vector3(dir.x / mag, dir.y / mag, dir.z / mag)
                    DrawSpotLight(
                        lamp.pos.x, lamp.pos.y, lamp.pos.z, 
                        dirNorm.x, dirNorm.y, dirNorm.z, 
                        math.random(0, 255), math.random(0, 255), math.random(0, 255), 
                        100.0, brightness, 5.0, 5.0, 1.0
                    )
                end
            end
        end)
    end
end)

RegisterCommand('lights', function (src, args)
    if args[1] then
        TriggerServerEvent('flex_dj:srver:StageLights', tonumber(args[1]))
    end
end, true and not Config.Debug)