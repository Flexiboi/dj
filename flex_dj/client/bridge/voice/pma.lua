if GetResourceState('pma-voice') ~= 'started' then return end
function overrideProximityRange(state, range)
    if state then
        exports["pma-voice"]:overrideProximityRange(range or 50.0, true)
    else
        exports["pma-voice"]:clearProximityOverride()
    end
end