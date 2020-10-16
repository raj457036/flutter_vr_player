import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'media_filters.dart';

import '../event_message.dart';
import '../vr_player_controller.dart';

String _playerBaseUrl = "https://raj457036.github.io/webview_vr_player/Dev/?";

const _eventHandler = "mediaEventMessage";

class VRPlayerController extends VRPlayerObserver {
  String _mediaUrl;

  /// vr toggle button on bottom right corner
  final bool vrButton;

  /// auto play video when player loads the media
  final bool autoPlay;

  /// play video in loop
  final bool loop;

  /// enable debugging
  final bool debug;

  /// create an interactive console over the player
  final bool console;

  /// mute the media by default
  final bool muted;

  /// ask for motion permssion on ios devices for sterioscopic view
  final bool askIosMotionPermission;

  Map<int, VoidCallback> _eventMap = {};

  InAppWebViewController _frameController;

  /// triggers when player preprocesses are completed
  final VoidCallback onReady;

  /// triggers when player is build
  /// tip: subscribe to events here.
  final VoidCallback onBuild;

  VRPlayerController({
    this.onReady,
    this.onBuild,
    String mediaUrl,
    this.vrButton = false,
    this.autoPlay = true,
    this.loop = false,
    this.debug = false,
    this.console = false,
    this.muted = true,
    this.askIosMotionPermission = false,
  })  : assert(
          vrButton != null &&
              autoPlay != null &&
              loop != null &&
              debug != null &&
              console != null &&
              muted != null &&
              askIosMotionPermission != null,
        ),
        _mediaUrl = mediaUrl;

  void _onReady() {
    if (onReady != null) {
      onReady();
    }
  }

  // media filters

  /// Warning: Filters only work if [VRPlayer] is `live`,
  /// i.e [VRPlayer.live] is set to `true`
  ///
  /// builds a balance color filter for media playback
  buildBalanceFilter(int strength, int red, int green, int blue) {
    final jscr =
        "mediaFilter.buildBalanceFilter($strength, $red, $green, $blue);";
    _frameController.evaluateJavascript(source: jscr);
  }

  /// Warning: Filters only work if VRPlayer is `live`,
  /// i.e [VRPlayer.live] is set to `true`
  ///
  /// use [MediaFilters] for filterCodes
  ///
  /// available codes
  /// - NoFilter
  /// - F1977
  /// - Aden
  /// - Brannan
  /// - Brooklyn
  /// - Clarendon
  /// - Earlybird
  /// - Gingham
  /// - Hudson
  /// - Inkwell
  /// - Kelvin
  /// - Lark
  /// - LoFi
  /// - Maven
  /// - Mayfair
  /// - Moon
  /// - Nashville
  /// - Perpetua
  /// - Reyes
  /// - Rise
  /// - Slumber
  /// - Stinson
  /// - Toaster
  /// - Valencia
  /// - Walden
  /// - Willow
  /// - XproII
  /// - Balance
  ///
  /// Note: change balance with `buildBalanceFilter`
  /// Balance filter trys to reduce unwanted color from the media
  /// like removing blue light.
  applyFilter(String filterCode) {
    final jscr = "mediaFilter.applyFilter('$filterCode');";
    _frameController.evaluateJavascript(source: jscr);
  }

  genFilter(double sepia, double saturation, double brightness, double contrast,
      double hueRot) {
    final jscr =
        "mediaFilter.filter($sepia, $saturation, $brightness, $contrast, $hueRot);";
    _frameController.evaluateJavascript(source: jscr);
  }

  // methods
  setLoop(bool value) {
    final jscr = "mediaController.video.loop = $value;";
    _frameController.evaluateJavascript(source: jscr);
  }

  play() {
    final jscr = "mediaController.play();";
    _frameController.evaluateJavascript(source: jscr);
  }

  pause() {
    final jscr = "mediaController.pause();";
    _frameController.evaluateJavascript(source: jscr);
  }

  seek(num byTime) {
    final jscr = "mediaController.seek($byTime);";
    _frameController.evaluateJavascript(source: jscr);
  }

  void setMediaURL(String url) => _mediaUrl = url;

  Future<void> buildPlayer({
    String url,
    bool enableVrButton,
    bool enableAutoPlay,
    bool enableLoop,
    bool enableDebug,
    bool enableConsole,
    bool enableMuted,
    bool enableAskIosMotionPermission,
  }) async {
    assert((url ?? _mediaUrl) != null,
        "Cannot build player without an actual url.");

    final String _url = url ?? _mediaUrl;
    final bool _vrButton = enableVrButton ?? vrButton,
        _autoPlay = enableAutoPlay ?? autoPlay,
        _loop = enableLoop ?? loop,
        _debug = enableDebug ?? debug,
        _console = enableConsole ?? console,
        _muted = enableMuted ?? muted,
        _askIosMotionPermission =
            enableAskIosMotionPermission ?? askIosMotionPermission;

    final jscr =
        "buildPlayer(url='$_url', vr_btn = $_vrButton, auto_play = $_autoPlay," +
            " loop = $_loop, debug = $_debug, muted = $_muted, debug_console = $_console, ios_perm = $_askIosMotionPermission);";
    await _frameController.evaluateJavascript(source: jscr);
    onBuild();
  }

  Future<void> setEventListener() async {
    final jsrc = """setTimeout(
              function() { 
                MediaMessageChannel.postMessage = (msg) => window.flutter_inappwebview.callHandler('$_eventHandler', msg);
              }, 1000);""";
    await _frameController.evaluateJavascript(source: jsrc);
  }

  Future<void> setCurrentTime(double setTime) async {
    final jscr = "mediaController.currentTime($setTime);";
    await _frameController.evaluateJavascript(source: jscr);
  }

  Future<void> setPlaybackRate(int rate) async {
    final jscr = "mediaController.playbackRate($rate);";
    await _frameController.evaluateJavascript(source: jscr);
  }

  Future<void> forceReplay(int rate) async {
    final jscr = "mediaController.forceReplay();";
    await _frameController.evaluateJavascript(source: jscr);
  }

  Future<void> changeMedia(String url, {bool autoPlay = false}) async {
    final jscr = "mediaController.load('$url', $autoPlay);";
    await _frameController.evaluateJavascript(source: jscr);
    _mediaUrl = url;
  }

  enterVRMode() {
    final jscr = "mediaController.enterVRMode();";
    _frameController.evaluateJavascript(source: jscr);
  }

  exitVRMode() {
    final jscr = "mediaController.exitVRMode();";
    _frameController.evaluateJavascript(source: jscr);
  }

  // getters

  Future<bool> get isFlat async {
    final jscr = "mediaController.isFlat;";
    return await _frameController.evaluateJavascript(source: jscr) as bool;
  }

  String get mediaLink => _mediaUrl;

  Future<num> get currentTime async {
    final jscr = "mediaController.currentTime();";
    return await _frameController.evaluateJavascript(source: jscr) as num;
  }

  Future<num> get playbackRate async {
    final jscr = "mediaController.playbackRate();";
    return await _frameController.evaluateJavascript(source: jscr) as num;
  }

  Future<int> get readyState {
    final jscr = "mediaController.state;";
    return _frameController.evaluateJavascript(source: jscr);
  }

  Future<bool> get isPaused {
    final jscr = "mediaController.paused;";
    return _frameController.evaluateJavascript(source: jscr);
  }

  Future<num> get duration {
    final jscr = "mediaController.duration;";
    return _frameController.evaluateJavascript(source: jscr);
  }

  Future<num> get volume {
    final jscr = "mediaController.volume;";
    return _frameController.evaluateJavascript(source: jscr);
  }

  Future<bool> get isMuted {
    final jscr = "mediaController.isMuted;";
    return _frameController.evaluateJavascript(source: jscr);
  }

  // Event Management

  String _getEvents(List<int> mediaEvents) {
    final events = mediaEvents.map((e) => e.toString()).join(',');
    return events;
  }

  void switchToFlatView({bool fullScreen = false}) {
    final jscr = "mediaController.viewInFlat($fullScreen);";
    _frameController.evaluateJavascript(source: jscr);
  }

  void switchToMonoView() {
    final jscr = "mediaController.viewInMono();";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void subscribeTo(List<int> mediaEvents) {
    final events = _getEvents(mediaEvents);
    final jscr = "mediaController.subscribe($events);";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void subscribeToAllEvents() {
    const jscr = "mediaController.subscribeToAllEvents();";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void unSubscribeFromAllEvents() {
    const jscr = "mediaController.unSubscribeFromAllEvents();";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void unSubscribeFrom(List<int> mediaEvents) {
    final events = _getEvents(mediaEvents);
    final jscr = "mediaController.unsubscribe($events);";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void onEvent(int mediaEvent, callback) {
    _eventMap[mediaEvent] = callback;
  }

  @override
  void triggerCallback(EventMessage message) {
    if (_eventMap.containsKey(message.event)) {
      _eventMap[message.event]();
    }
  }
}

class VRPlayer extends StatefulWidget {
  final VRPlayerController controller;
  final Function(int) onPlayerLoading;
  final Function() onPlayerInit;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const VRPlayer({
    Key key,
    @required this.controller,
    this.onPlayerLoading,
    this.onPlayerInit,
    this.gestureRecognizers,
  })  : assert(controller != null),
        super(key: key);

  static void changePlayerHost(String playerURL) {
    _playerBaseUrl = playerURL;
  }

  @override
  _VRPlayerState createState() => _VRPlayerState();
}

class _VRPlayerState extends State<VRPlayer> {
  InAppWebViewController webView;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrl: _buildInitalUrl(),
      initialHeaders: {},
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          debuggingEnabled: widget.controller.debug,
          mediaPlaybackRequiresUserGesture: false,
          transparentBackground: true,
          disableContextMenu: true,
          supportZoom: false,
          incognito: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          enableViewportScale: true,
          allowsLinkPreview: false,
          allowsPictureInPictureMediaPlayback: false,
          disallowOverScroll: true,
        ),
      ),
      gestureRecognizers: widget.gestureRecognizers,
      onWebViewCreated: _onWebViewCreated,
      onLoadStart: _onLoadStart,
      onLoadStop: _onLoadStop,
      onProgressChanged: _onProgressChange,
      onConsoleMessage: _onConsoleMessage,
    );
  }

  void _onLoadStart(InAppWebViewController controller, String url) {
    if (widget.onPlayerInit != null) {
      widget.onPlayerInit();
    }
  }

  String _buildInitalUrl() {
    String base = _playerBaseUrl;

    final mediaLink = widget.controller.mediaLink;

    if (mediaLink != null) {
      base += "video=$mediaLink&";
    }
    if (!widget.controller.vrButton) {
      base += "VRBtn=false&";
    }
    if (!widget.controller.autoPlay) {
      base += "autoPlay=false&";
    }

    if (widget.controller.debug) {
      base += "debug=true&";
    }
    return base;
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    webView = controller;
    widget.controller._frameController = controller;
    webView.addJavaScriptHandler(
      handlerName: _eventHandler,
      callback: (result) {
        final _parsedMsg = json.decode(result.first);
        final EventMessage message = EventMessage.fromJson(_parsedMsg);
        widget.controller.triggerCallback(message);
      },
    );
  }

  void _onProgressChange(InAppWebViewController controller, int progress) {
    if (widget.onPlayerLoading != null) {
      widget.onPlayerLoading(progress);
    }
  }

  void _onLoadStop(InAppWebViewController controller, String url) async {
    await widget.controller.setEventListener();
    widget.controller._onReady();
  }

  void _onConsoleMessage(controller, consoleMessage) {
    if (widget.controller.debug) {
      print("VR PLAYER: " + consoleMessage.message);
    }
  }
}
