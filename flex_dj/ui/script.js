var currentApp = null;
var appSettings = {
    currentUsb: null,
    musicapp: {
        songlist: document.querySelector("#musicapp #musiclist #songlist"),
    },
    dj: {
        player1: {
            song: null,
            volume: 0,
            playing: false
        },
        player2: {
            song: null,
            volume: 0,
            playing: false
        }
    }
};
const container = document.querySelector("#container");
const appbtns = document.querySelectorAll("[data-btn]");
const closebtns = document.querySelectorAll(".closeapp");

function darkenColor(r, g, b, percent = 0.3) {
    return {
        r: Math.max(0, Math.min(255, Math.floor(r * (1 - percent)))),
        g: Math.max(0, Math.min(255, Math.floor(g * (1 - percent)))),
        b: Math.max(0, Math.min(255, Math.floor(b * (1 - percent))))
    };
}

closebtns.forEach((btn) => {
    btn.addEventListener("click", function (e) {
        e.preventDefault();
        if (currentApp) {
            const appContainer = document.querySelector("#appscreen");
            if (appContainer) {
                appContainer.style.display = "none";
                const taskbar = document.querySelector("#taskbar");
                appbtns.forEach((btn) => {
                    if (taskbar && taskbar.contains(btn)) {
                        btn.classList.remove("active");
                    }
                });
            }
        }
    });
});

function RegisterAddBtn() {
    const addbtn = document.querySelector(".addsong");
    addbtn.addEventListener("click", function (e) {
        e.preventDefault();
        const input = document.querySelector("#input");
        if (input) {
            input.style.display = input.style.display === "flex" ? "none" : "flex";
        }
    });
}

appbtns.forEach((btn) => {
    btn.addEventListener("click", function (e) {
        e.preventDefault();
        const btnName = btn.getAttribute('data-btn');
        const appContainer = document.querySelector("#appscreen");
        const app = document.querySelector(`#${btnName}`);
        const startbar = document.querySelector("#startbar");
        if (btnName != 'start') {

            if (appContainer.style.display === "none") {
                appContainer.style.display = appContainer.style.display === "none" ? "grid" : "none";
            } else if (currentApp === btnName && appContainer.style.display === "grid" && startbar.style.display === "none") {
                appContainer.style.display = "none";
            }
            if (appContainer.style.display === null || appContainer.style.display === "" || currentApp === null || currentApp === null || currentApp === "" || currentApp !== btnName) { appContainer.style.display = "grid"; }
            
            if (currentApp) {
                const previousApp = document.querySelector(`#${currentApp}`);
                if (previousApp) {
                    previousApp.style.display = "none";
                }
            }
            currentApp = btnName;
            app.style.display = "grid";

            const computedStyle = getComputedStyle(btn);
            let color = computedStyle.backgroundColor;
            if (color === 'rgba(0, 0, 0, 0)' || color === 'rgb(0, 0, 0)') {
                const background = computedStyle.background;
                const rgbMatch = background.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
                
                if (rgbMatch) {
                    const [_, r, g, b] = rgbMatch;
                    color = `rgb(${r}, ${g}, ${b})`;
                }
            }
            const rgbValues = color.match(/\d+/g);
            if (rgbValues && rgbValues.length >= 3) {
                const [r, g, b] = rgbValues;
                const rgba = `rgba(${r}, ${g}, ${b}, 0.31)`;

                startbar.style.display = "none";
                const darker = darkenColor(r, g, b, 0.3);
                const borderColor = `rgba(${darker.r}, ${darker.g}, ${darker.b}, 0.28)`;
                appContainer.style.background = rgba;
                appContainer.style.border = `5px solid ${borderColor}`;

                const appbar = document.querySelector("#appbar");
                const taskbar = document.querySelector("#taskbar");
                appbtns.forEach((btn) => {
                    if (taskbar && taskbar.contains(btn)) {
                        btn.classList.remove("active");
                    }
                });
                if (appbar && appbar.contains(btn)) {
                    const taskbarBtn = taskbar.querySelector(`[data-btn="${btnName}"]`);
                    if (taskbarBtn) {
                        taskbarBtn.classList.add("active");
                    }
                } else if (taskbar && taskbar.contains(btn)) {
                    if (appContainer.style.display === "grid") {
                        btn.classList.add("active");
                    }
                }
            }
        } else {
            startbar.style.display = startbar.style.display === "none" ? "flex" : "none";
        }
    });
});

// ADD SONG FORM
const form_btn = document.querySelector("#musicapp #input form #submit");
const form = document.querySelector("#musicapp #input form");
form_btn.addEventListener("click", function (e) {
    e.preventDefault();
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");
    const year = now.getFullYear();
    const date = now.getDate();

    const formData = new FormData(form);
    const data = {
        url: formData.get("url"),
        title: formData.get("title"),
        artist: formData.get("artist"),
        genre: formData.get("genre"),
        bpm: formData.get("bpm"),
        length: formData.get("length"),
        dateadded: `${year}/${date} - ${hours}:${minutes}`
    };
    var newsong = '<div class="song" data-url'+data.url+'>'
    +'<span class="title">'+data.title+'</span>'
    +'<span class="artist">'+data.artist+'</span>'
    +'<span class="genre">'+data.genre+'</span>'
    +'<span class="bpm">'+data.bpm+'</span>'
    +'<span class="length">'+data.length+'</span>'
    +'<span class="dateadded">'+data.dateadded+'</span>'
    +'</div>' + appSettings.musicapp.songlist.innerHTML;
    appSettings.musicapp.songlist.innerHTML = newsong;

    fetch(`https://${GetParentResourceName()}/AddSong`, {
        method: 'POST',
        body: JSON.stringify({ id: appSettings.currentUsb, song: data }),
    }).then(e => {
        RegisterAddBtn();
    });
});

// DJ APP
const dj_explorer1 = document.querySelector("#djapp #explorer1");
var dj_explorer1_btns = document.querySelectorAll("#djapp #explorer1 .song");
const dj_volume1 = document.querySelector("#djapp #controls #volumeslider1");
const dj_queue1 = document.querySelector("#djapp #controls #queue1");
const dj_playpause1 = document.querySelector("#djapp #controls #play-pause1");
const dj_audiowave1 = document.querySelector("#djapp #audiowave1");
var dj_explorer2 = document.querySelector("#djapp #explorer2");
const dj_queue2 = document.querySelector("#djapp #controls #queue2");
const dj_playpause2 = document.querySelector("#djapp #controls #play-pause2");
var dj_explorer2_btns = document.querySelectorAll("#djapp #explorer2 .song");
const dj_volume2 = document.querySelector("#djapp #controls #volumeslider2");
const dj_audiowave2 = document.querySelector("#djapp #audiowave2");

dj_queue1.addEventListener("click", function (e) {
    e.preventDefault();
    fetch(`https://${GetParentResourceName()}/PlaySong`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, url: appSettings.dj.player1.song, deck: 1 }),
    })
});

dj_queue2.addEventListener("click", function (e) {
    e.preventDefault();
    fetch(`https://${GetParentResourceName()}/PlaySong`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, url: appSettings.dj.player2.song, deck: 2 }),
    })
});

dj_playpause1.addEventListener("click", function (e) {
    e.preventDefault();
    fetch(`https://${GetParentResourceName()}/StopSong`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, url: appSettings.dj.player1.song, deck: 1 }),
    })
});

dj_playpause2.addEventListener("click", function (e) {
    e.preventDefault();
    fetch(`https://${GetParentResourceName()}/StopSong`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, url: appSettings.dj.player2.song, deck: 2 }),
    })
});

function LoadSongsInDjExporer() {
    fetch(`https://${GetParentResourceName()}/GetSongs`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb }),
    })
    .then(res => res.json())
    .then(songs => {
        dj_explorer1.innerHTML = "";
        dj_explorer2.innerHTML = "";
        if (Array.isArray(songs)) {
            if(songs.length >= 1) {
                songs.forEach((song) => {
                    dj_explorer1.innerHTML += 
                        '<div class="song" data-url="' + song.url + '" data-deck="1">' +
                            '<span class="title">' + (song.title || "UNKNOWN") + '</span>' +
                            '<span class="bpm">BPM: ' + (song.bpm || "UNKNOWN") + '</span>' +
                        '</div>';
    
                    dj_explorer2.innerHTML += 
                        '<div class="song" data-url="' + song.url + '" data-deck="2">' +
                            '<span class="title">' + (song.title || "UNKNOWN") + '</span>' +
                            '<span class="bpm">BPM: ' + (song.bpm || "UNKNOWN") + '</span>' +
                        '</div>';
                });
                dj_explorer1_btns = document.querySelectorAll("#djapp #explorer1 .song");
                dj_explorer2_btns = document.querySelectorAll("#djapp #explorer2 .song");
                dj_explorer1_btns.forEach((btn) => {
                    btn.addEventListener("click", function (e) {
                        e.preventDefault();
                        dj_volume1.value = 10;
                        appSettings.dj.player1.volume = 10;
                        const title = this.querySelector(".title").textContent;
                        dj_audiowave1.querySelector("#title").innerHTML = title;
                        appSettings.dj.player1.song = this.dataset.url;
                    });
                });

                dj_explorer2_btns.forEach((btn) => {
                    btn.addEventListener("click", function (e) {
                        e.preventDefault();
                        dj_volume2.value = 10;
                        appSettings.dj.player2.volume = 10;
                        const title = this.querySelector(".title").textContent;
                        dj_audiowave2.querySelector("#title").innerHTML = title;
                        appSettings.dj.player2.song = this.dataset.url;
                    });
                });
            } else {
                LoadDjSongsBtn();
            }
        } else {
            console.log("Songs list is not an array:", songs);
        }
    });
}

function LoadDjSongsBtn() {
    dj_explorer1.innerHTML = '<div class="song" data-deck="1">'
    +'<span class="loadSongs" style="text-align: center; margin-left: 200px;">🗘</span>'
    +'</div>'
    dj_explorer2.innerHTML = '<div class="song" data-deck="2">'
    +'<span class="loadSongs" style="text-align: center; margin-left: 200px;">🗘</span>'
    +'</div>'
    const loadbtns = document.querySelectorAll("#djapp .explorer .song .loadSongs");
    loadbtns.forEach((btn) => {
        btn.addEventListener("click", function (e) {
            e.preventDefault();
            LoadSongsInDjExporer();
        });
    });
}

dj_volume1.addEventListener('change', function () {
    fetch(`https://${GetParentResourceName()}/setVolume`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, volume: (this.value/100), deck: 1 }),
    })
});

dj_volume2.addEventListener('change', function () {
    fetch(`https://${GetParentResourceName()}/setVolume`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8"
        },
        body: JSON.stringify({ id: appSettings.currentUsb, volume: (this.value/100), deck: 2 }),
    })
});

// Link with LUA
window.addEventListener('message', function(event) {
    var data = event.data
    if (data.type === 'open') {
        container.style.display = 'flex';
        appSettings.currentUsb = data.usb;
        const musicapp_usb_explorer = document.querySelector("#musicapp #explorer");
        musicapp_usb_explorer.innerHTML = '<div class="usb" data-usb='+data.usb+'>'+data.usb.toUpperCase()+'</div>';
        appSettings.musicapp.songlist.innerHTML = '<div class="addsong"><span>+</span></div>';
        RegisterAddBtn();
        LoadDjSongsBtn();
        const usb = document.querySelector("#musicapp #explorer .usb");
        usb.addEventListener("click", function (e) {
            e.preventDefault();
            fetch(`https://${GetParentResourceName()}/GetSongs`, {
                method: 'POST',
                body: JSON.stringify({ id: this.dataset.usb }),
            }).then(res => res.json()).then(songs => {
                appSettings.musicapp.songlist.innerHTML = ''
                if(Array.isArray(songs)) {
                    songs.forEach((song) => {
                        appSettings.musicapp.songlist.innerHTML += '<div class="song" data-url="'+song.url+'">'
                        +'<span class="title">'+(song.title || 'UNKNOWN')+'</span>'
                        +'<span class="artist">'+(song.artist || 'UNKNOWN')+'</span>'
                        +'<span class="genre">'+(song.genre || 'UNKNOWN')+'</span>'
                        +'<span class="bpm">'+(song.bpm || 'UNKNOWN')+'</span>'
                        +'<span class="length">'+(song.length || 'UNKNOWN')+'</span>'
                        +'<span class="dateadded">'+(song.dateadded || 'UNKNOWN')+'</span>'
                        +'</div>'
                    });
                }
                appSettings.musicapp.songlist.innerHTML += '<div class="addsong"><span>+</span></div>';
                RegisterAddBtn();
            });
        });
    }
});

document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
        closeNUI();
    }
});

function closeNUI() {
    fetch(`https://${GetParentResourceName()}/close_menu`, {
        method: 'POST',
    }).then(() => {
        container.style.display = 'none';
        appSettings.currentUsb = null;
        if (!appSettings.dj.player1.playing) {
            appSettings.dj.player1.volume = 0;
        }
        if (!appSettings.dj.player2.playing) {
            appSettings.dj.player2.volume = 0;
        }
    });
}