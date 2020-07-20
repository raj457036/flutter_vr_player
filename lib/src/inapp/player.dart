import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'media_filters.dart';

import '../event_message.dart';
import '../vr_player_controller.dart';

String _playerBaseUrl = "https://raj457036.github.io/webview_vr_player/?";

class VRPlayerController extends VRPlayerObserver {
  String _mediaUrl;

  Map<int, VoidCallback> _eventMap = {};

  InAppWebViewController _frameController;
  final VoidCallback onReady;

  VRPlayerController({this.onReady, @required String mediaUrl})
      : _mediaUrl = mediaUrl;

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

  String get mediaLink => _mediaUrl;

  Future<num> get currentTime async {
    final jscr = "mediaController.currentTime();";
    return await _frameController.evaluateJavascript(source: jscr) as num;
  }

  Future<num> get playbackRate async {
    final jscr = "mediaController.playbackRate();";
    return await _frameController.evaluateJavascript(source: jscr) as num;
  }

  int get readyState {
    final jscr = "mediaController.state;";
    return _frameController.evaluateJavascript(source: jscr) as int;
  }

  bool get isPaused {
    final jscr = "mediaController.paused;";
    return _frameController.evaluateJavascript(source: jscr) as bool;
  }

  num get duration {
    final jscr = "mediaController.duration;";
    return _frameController.evaluateJavascript(source: jscr) as num;
  }

  num get volume {
    final jscr = "mediaController.volume;";
    return _frameController.evaluateJavascript(source: jscr) as num;
  }

  bool get isMuted {
    final jscr = "mediaController.isMuted;";
    return _frameController.evaluateJavascript(source: jscr) as bool;
  }

  // Event Management

  String _getEvents(List<int> mediaEvents) {
    final events = mediaEvents.map((e) => e.toString()).join(',');
    return events;
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
  final bool debugMode;
  final bool showVRBtn;
  final bool autoPlay;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const VRPlayer({
    Key key,
    @required this.controller,
    this.onPlayerLoading,
    this.onPlayerInit,
    this.debugMode = false,
    this.showVRBtn = false,
    this.autoPlay = true,
    this.gestureRecognizers,
  })  : assert(controller != null),
        assert(debugMode != null),
        assert(showVRBtn != null),
        assert(autoPlay != null),
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
          debuggingEnabled: widget.debugMode,
          mediaPlaybackRequiresUserGesture: false,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          enableViewportScale: true,
          allowsLinkPreview: false,
          allowsPictureInPictureMediaPlayback: false,
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
    if (!widget.showVRBtn) {
      base += "VRBtn=false&";
    }
    if (!widget.autoPlay) {
      base += "autoPlay=false&";
    }

    if (!widget.debugMode) {
      base += "debug=true&";
    }
    return base;
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    webView = controller;
    widget.controller._frameController = controller;
    webView.addJavaScriptHandler(
      handlerName: 'mediaEventMessage',
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
    final jsrc = """setTimeout(
              function() { 
                MediaMessageChannel.postMessage = (msg) => window.flutter_inappwebview.callHandler('mediaEventMessage', msg);; 
              }, 1000);""";
    await webView.evaluateJavascript(source: jsrc);
    widget.controller._onReady();
  }

  void _onConsoleMessage(controller, consoleMessage) {
    if (widget.debugMode) {
      print("VR PLAYER: " + consoleMessage.message);
    }
  }
}
