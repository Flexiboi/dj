<img width="690" height="418" alt="image" src="https://github.com/user-attachments/assets/382c52df-f6e3-46b8-a8e2-7ef32cadc854" />
NOT TESTED ON LIVE SERVER
</br>
</br>

**FEATURES**
</br>
All stuff is created ingame and saved in json
</br>
Create speakers ingame (As many as yo u want)
</br>
Create radio’s → Each radio has defined config channel
</br>
Create DJ tables → here you can uplaod songs to usb and play them with 2 channel virtual dj table
</br>
MP3 player → Insert USB and play sonngs on the go for yourself
</br>
Remove all placed stuff
</br>
You can implement any framework if you want.
</br>
Works default with QBOX and MX-Surround
</br>
</br>

**HOW IT WORKS**
</br>
When playing songs it checks nearby speakers to play songs onto.
</br>
Each speaker is first checked if the speaker is in use or not unless same dj table and you 2 tracks at once.
</br>
Range check for speakers is defined when you setup a radio or dj system.
</br>
Systems, radio’s or speakers can be a prop or cancel on create to make it just a point if you already have a prop you want to play sound out of.
</br>
When no speaker is found it plays from the source.
</br>
</br>

**KNOWN ISSUES**
</br>
- When playing live stream links to speakers it will get offset since there is no way to get the current time of the audio like with a youtube song.
- Sometime you can not change the volume in the virtual dj app with the first listen.
</br>
</br>
</br>

**Dependencies**
</br>
- ox_lib
- framework like qbox
- mx surround or use own
```
[‘usb’] = { label = ‘USB’, weight = 1, type = ‘item’, stack = false, useable = true, shouldClose = true, combinable = nil, },

||[‘mp3_player’] = { label = ‘MP3 Player’, weight = 2, consume = 0, server = { export = ‘flex_dj.UseMp3’, }, shouldClose = true, buttons = { { label = ‘USB SLOT’, action = function(slot) exports.flex_dj:OpenUsbStash(nil, slot) end }, }, stack = true, close = true, description = ‘’ },
```
