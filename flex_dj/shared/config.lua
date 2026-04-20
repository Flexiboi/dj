Config = {}

Config.Debug = true
Config.CoreName = {
    qb = 'qb-core',
    esx = 'es_extended',
    ox = 'ox_core',
    ox_inv = 'ox_inventory',
    qbx = 'qbx_core',
}

Config.Notify = {
    client = function(msg, type, time)
        lib.notify({
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
    server = function(src, msg, type, time)
        lib.notify(src, {
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
}

Config.Commands = {
    addspeaker = "addspeaker", -- Setup a new speaker
    addradio = "addradio", -- Setup a new radio
    addtable = "addtable",
    editspeaker = "speakers", -- Remove a placed speaker
    editradio = "radios", -- Remove a placed radio
    edittable = "tables",
    giveusb = "giveusb",
    givemp3 = "givemp3",
}

Config.Item = {
    usb = 'usb',
    mp3 = 'mp3_player'
}

Config.Computers = {
    {label = "sf_prop_sf_laptop_01a", value = "sf_prop_sf_laptop_01a"},
    {label = "sf_prop_sf_laptop_01b", value = "sf_prop_sf_laptop_01b"},
    {label = "prop_laptop_lester", value = "prop_laptop_lester"},
    {label = "xm_prop_x17_laptop_lester_01", value = "xm_prop_x17_laptop_lester_01"},
    {label = "ba_prop_club_laptop_dj", value = "ba_prop_club_laptop_dj"},
    {label = "xm_prop_x17_laptop_mrsr", value = "xm_prop_x17_laptop_mrsr"},
    {label = "h4_prop_h4_turntable_01a", value = "h4_prop_h4_turntable_01a"},
    {label = "h4_prop_battle_dj_deck_01a_a", value = "h4_prop_battle_dj_deck_01a_a"},
    {label = "sf_prop_sf_dj_desk_01a", value = "sf_prop_sf_dj_desk_01a"},
    {label = "sf_prop_sf_dj_desk_02a", value = "sf_prop_sf_dj_desk_02a"},
}

Config.Speakrs = {
    {label = "sf_prop_sf_speaker_l_01a", value = "sf_prop_sf_speaker_l_01a"},
    {label = "sf_prop_sf_speaker_l_01a", value = "sf_prop_sf_speaker_l_01a"},
    {label = "sf_prop_sf_speaker_l_01a", value = "sf_prop_sf_speaker_l_01a"},
}

Config.Radios = {
    {label = "sm_prop_smug_radio_01", value = "sm_prop_smug_radio_01"},
    {label = "prop_radio_01", value = "prop_radio_01"},
    {label = "v_res_j_radio", value = "v_res_j_radio"},
    {label = "m24_1_prop_m41_radio_01a", value = "m24_1_prop_m41_radio_01a"},
    {label = "sm_prop_smug_wall_radio_01", value = "sm_prop_smug_wall_radio_01"},
    {label = "prop_jukebox_02", value = "prop_jukebox_02"},
    {label = "prop_50s_jukebox", value = "prop_50s_jukebox"},
    {label = "ch_prop_arcade_jukebox_01a", value = "ch_prop_arcade_jukebox_01a"},
}

Config.RadioChannels = {
    {label = "Vossendaal", value = "https://a7.asurahosting.com:6750/radio.mp3"},
}

Config.MicRange = 50.0