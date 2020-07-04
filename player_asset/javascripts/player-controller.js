const MediaEvent = {
    ABORTED: 1,
    CAN_PLAY: 2,
    CAN_PLAY_THROUGH: 3,
    DURATION_CHANGE: 4,
    ENDED: 5,
    ERROR: 6,
    LOADED_DATA: 7,
    LOADED_META_DATA: 8,
    LOAD_START: 9,
    PAUSE: 10,
    PLAY: 11,
    PLAYING: 12,
    PROGRESS: 13,
    RATE_CHANGE: 14,
    SEEKED: 15,
    SEEKING: 16,
    STALLED: 17,
    SUSPEND: 18,
    TIME_UPDATE: 19,
    VOLUME_CHANGE: 20,
    WAITING: 21,
    EXTERNAL: 22,
}

Object.freeze(MediaEvent);

class MediaMessage {

    constructor(readyState, eventType, message) {
        this.readyState = readyState;
        this.eventType = eventType;
        this.message = message;
    }

    getMessage() {
        const _message = {
            "readyState": this.readyState,
            "event": this.eventType,
            "message": this.message,
        }

        return JSON.stringify(_message);
    }
}

class MediaMessageChannel {

    constructor(controller) {
        this.controller = controller;
    }

    subscribe(code, self = this) {
        const vid = this.controller.video;

        if (code == MediaEvent.ABORTED) {
            vid.onabort = function () {
                self.sendMessage(MediaEvent.ABORTED);
            };
        }

        if (code == MediaEvent.CAN_PLAY) {
            vid.oncanplay = function () {
                self.sendMessage(MediaEvent.CAN_PLAY);
            };
        }

        if (code == MediaEvent.CAN_PLAY_THROUGH) {
            vid.oncanplaythrough = function () {
                self.sendMessage(MediaEvent.CAN_PLAY_THROUGH);
            };
        }

        if (code == MediaEvent.DURATION_CHANGE) {
            vid.ondurationchange = function () {
                self.sendMessage(MediaEvent.DURATION_CHANGE);
            };
        }

        if (code == MediaEvent.ENDED) {
            vid.onended = function () {
                self.sendMessage(MediaEvent.ENDED);
            };
        }

        if (code == MediaEvent.ERROR) {
            vid.onerror = function () {
                self.sendMessage(MediaEvent.ERROR);
            };
        }

        if (code == MediaEvent.LOADED_DATA) {
            vid.onloadeddata = function () {
                self.sendMessage(MediaEvent.LOADED_DATA);
            };
        }

        if (code == MediaEvent.LOADED_META_DATA) {
            vid.onloadedmetadata = function () {
                self.sendMessage(MediaEvent.LOADED_META_DATA);
            };
        }

        if (code == MediaEvent.LOAD_START) {
            vid.onloadstart = function () {
                self.sendMessage(MediaEvent.LOAD_START);
            };
        }

        if (code == MediaEvent.PAUSE) {
            vid.onpause = function () {
                self.sendMessage(MediaEvent.PAUSE);
            };
        }

        if (code == MediaEvent.PLAY) {
            vid.onplay = function () {
                self.sendMessage(MediaEvent.PLAY);
            };
        }

        if (code == MediaEvent.PLAYING) {
            vid.onplaying = function () {
                self.sendMessage(MediaEvent.PLAYING);
            };
        }

        if (code == MediaEvent.PROGRESS) {
            vid.onprogress = function () {
                self.sendMessage(MediaEvent.PROGRESS);
            };
        }

        if (code == MediaEvent.RATE_CHANGE) {
            vid.onratechange = function () {
                self.sendMessage(MediaEvent.RATE_CHANGE);
            }
        }

        if (code == MediaEvent.SEEKED) {
            vid.onseeked = function () {
                self.sendMessage(MediaEvent.SEEKED);
            };
        }

        if (code == MediaEvent.SEEKING) {
            vid.onseeking = function () {
                self.sendMessage(MediaEvent.SEEKING);
            };
        }

        if (code == MediaEvent.STALLED) {
            vid.onstalled = function () {
                self.sendMessage(MediaEvent.STALLED);
            };
        }

        if (code == MediaEvent.SUSPEND) {
            vid.onsuspend = function () {
                self.sendMessage(MediaEvent.SUSPEND);
            };
        }

        if (code == MediaEvent.TIME_UPDATE) {
            vid.ontimeupdate = function () {
                self.sendMessage(MediaEvent.TIME_UPDATE);
            };
        }

        if (code == MediaEvent.VOLUME_CHANGE) {
            vid.onvolumechange = function () {
                self.sendMessage(MediaEvent.VOLUME_CHANGE);
            };
        }

        if (code == MediaEvent.WAITING) {
            vid.onwaiting = function () {
                self.sendMessage(MediaEvent.WAITING);
            };
        }
    }

    unsubscribe(code) {
        const vid = this.controller.video;

        if (code == MediaEvent.ABORTED) {
            vid.onabort = null;
        }

        if (code == MediaEvent.CAN_PLAY) {
            vid.oncanplay = null;
        }

        if (code == MediaEvent.CAN_PLAY_THROUGH) {
            vid.oncanplaythrough = null;
        }

        if (code == MediaEvent.DURATION_CHANGE) {
            vid.ondurationchange = null;
        }

        if (code == MediaEvent.ENDED) {
            vid.onended = null;
        }

        if (code == MediaEvent.ERROR) {
            vid.onerror = null;
        }

        if (code == MediaEvent.LOADED_DATA) {
            vid.onloadeddata = null;
        }

        if (code == MediaEvent.LOADED_META_DATA) {
            vid.onloadedmetadata = null;
        }

        if (code == MediaEvent.LOAD_START) {
            vid.onloadstart = null;
        }

        if (code == MediaEvent.PAUSE) {
            vid.onpause = null;
        }

        if (code == MediaEvent.PLAY) {
            vid.onplay = null;
        }

        if (code == MediaEvent.PLAYING) {
            vid.onplaying = null;
        }

        if (code == MediaEvent.PROGRESS) {
            vid.onprogress = null;
        }

        if (code == MediaEvent.RATE_CHANGE) {
            vid.onratechange = null;
        }

        if (code == MediaEvent.SEEKED) {
            vid.onseeked = null;
        }

        if (code == MediaEvent.SEEKING) {
            vid.onseeking = null;
        }

        if (code == MediaEvent.STALLED) {
            vid.onstalled = null;
        }

        if (code == MediaEvent.SUSPEND) {
            vid.onsuspend = null;
        }

        if (code == MediaEvent.TIME_UPDATE) {
            vid.ontimeupdate = null;
        }

        if (code == MediaEvent.VOLUME_CHANGE) {
            vid.onvolumechange = null;
        }

        if (code == MediaEvent.WAITING) {
            vid.onwaiting = null;
        }
    }

    sendMessage(event, message = "") {
        const mediaMessage = new MediaMessage(this.controller.video.readyState, event, message);

        try {
            this._postMessage(mediaMessage.getMessage());
            return true;
        } catch (error) {
            console.error("postMessage is not defined. try : MediaMessageChannel.postMessage = someMethod");
        }

        return false;
    }

    _postMessage(message) {
        MediaMessageChannel.postMessage(message);
    }
}

class MediaController {

    constructor(id) {
        this.video = document.getElementById(id);
        this.channel = new MediaMessageChannel(this);
    }

    play() {
        this.video.play();
    }

    seek(by_time) {
        this.currentTime(this.currentTime() + by_time);
    }

    currentTime(time) {
        if (time < this.duration && time > 0) {
            this.video.currentTime = time;
        } else return this.video.currentTime;
    }

    play() {
        this.video.play();
    }

    pause() {
        this.video.pause();
    }

    playbackRate(rate) {
        if (rate < 5 && rate > -1) {
            this.video.playbackRate = rate;
        } else return this.video.playbackRate;
    }


    forceReplay() {
        this.pause();
        this.currentTime(0);
        init(true);
    }

    load(url, autoPlay = false) {
        this.pause();
        this.currentTime(0);
        playlist.streams[0] = url;
        init(true);

        if (autoPlay) {
            this.play();
        } else {
            this.pause();
        }
    }

    enterVRMode() {
        const scene = $("a-scene")[0];
        scene.enterVR();
    }

    exitVRMode() {
        const scene = $("a-scene")[0];
        scene.exitVR();
    }

    subscribeToAllEvents() {
        const codes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];

        for (var code of codes) {
            this.channel.subscribe(code);
        }
    }

    unSubscribeFromAllEvents() {
        const codes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];

        for (var code of codes) {
            this.channel.unsubscribe(code);
        }
    }

    subscribe(...codes) {
        for (var code of codes) {
            this.channel.subscribe(code);
        }
    }

    unsubscribe(...codes) {
        for (var code of codes) {
            this.channel.unsubscribe(code);
        }
    }

    // getters
    get state() {
        return this.video.readyState;
    }

    get paused() {
        return this.video.paused;
    }

    get duration() {
        return this.video.duration;
    }

    get volume() {
        return this.video.volume * 100;
    }

    get isMuted() {
        return this.video.muted;
    }
}


function getUrlParameter(name) {
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    var results = regex.exec(location.search);
    return results === null ? null : decodeURIComponent(results[1].replace(/\+/g, ' '));
};

function processParams() {
    const url = getUrlParameter('video');
    const VRBtn = getUrlParameter('VRBtn');
    const autoPlay = getUrlParameter('autoPlay');
    const loop = getUrlParameter('loop');

    window.mediaController = new MediaController('video_player_id');

    if (url !== null) {
        playlist.streams[0] = url;
        init(true)

        if (autoPlay !== 'false') {
            mediaController.play();
        } else {
            mediaController.pause();
        }

        if (loop === 'true') {
            mediaController.video.loop = true;
        }

        if (VRBtn === 'false') {
            var h = document.getElementsByTagName('head').item(0);
            var s = document.createElement("style");
            s.type = "text/css";
            s.appendChild(document.createTextNode(".a-enter-vr-button {display: none;}"));
            h.appendChild(s);
        }
    }



}

document.addEventListener('DOMContentLoaded', processParams);