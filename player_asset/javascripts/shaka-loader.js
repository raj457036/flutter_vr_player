var playlist = {
  streams: [],
  titles: [],
  pos: -1,
};

function init(passIf) {
  // console.log("init");
  if (playlist.streams.length > 0 || passIf === true) {
    if (playlist.streams[0].indexOf("m3u8") != -1) {
      console.log("hls");
      hlsLoad()
    } else {
      console.log("dash");
      initApp()
    }
  }
}

function initApp() {
  shaka.polyfill.installAll();
  if (shaka.Player.isBrowserSupported()) {
    var player = initPlayer();
    window.player = player;
    doPlay(player, pushNext());
  } else {
    console.error('Browser not supported!');
  }
}

function initPlayer() {
  var video = document.getElementById('video_player_id');
  var player = new shaka.Player(video);

  player.addEventListener('error', onErrorEvent);
  video.addEventListener('ended', function () {
    player.unload();
    doPlay(player, pushNext());
  });
  return player;
}

function doPlay(player, src) {
  player.load(src.manifest).then(function () {
    console.log("hello");
  }).catch(onError);
}

function pushNext() {
  playlist.pos++;
  if (playlist.pos > playlist.streams.length - 1) {
    playlist.pos = 0;
  }
  return {
    manifest: playlist.streams[playlist.pos],
    title: playlist.titles[playlist.pos]
  };
}

function onErrorEvent(event) {
  onError(event.detail);
}

function onError(error) {
  console.error('Error code', error.code, 'object', error);
}

function hlsLoad(stream) {
  if (Hls.isSupported()) {
    var video = document.getElementById('video_player_id');
    var hls = new Hls();
    hls.loadSource(playlist.streams[0]);
    hls.attachMedia(video);
    hls.on(Hls.Events.MANIFEST_PARSED, function () {
      video.play();
    });
  } else {
    initApp();
  }
}