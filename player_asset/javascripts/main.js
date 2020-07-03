$(document).ready(function () {
  $(".play").click(function () {
    $("#video_player_id").get(0).play()
  });
  $(".pause").click(function () {
    $("#video_player_id").get(0).pause()
  });
  $("#stream-button").click(function () {
    playlist.streams[0] = $("#stream-input").val();
    init(true)
  })
});