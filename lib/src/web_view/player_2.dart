import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../event_message.dart';
import '../vr_player_controller.dart';

class WebVRPlayerController extends VRPlayerObserver {
  String _mediaUrl;

  Map<int, VoidCallback> _eventMap = {};

  WebViewController _frameController;
  final VoidCallback onReady;

  WebVRPlayerController({this.onReady, @required String mediaUrl})
      : _mediaUrl = mediaUrl;

  void _onReady() {
    if (onReady != null) {
      onReady();
    }
  }

  // methods
  setLoop(bool value) {
    final jscr = "mediaController.video.loop = $value;";
    _frameController.evaluateJavascript(jscr);
  }

  play() {
    final jscr = "mediaController.play();";
    _frameController.evaluateJavascript(jscr);
  }

  pause() {
    final jscr = "mediaController.pause();";
    _frameController.evaluateJavascript(jscr);
  }

  seek(num byTime) {
    final jscr = "mediaController.seek($byTime);";
    _frameController.evaluateJavascript(jscr);
  }

  Future<void> setCurrentTime(double setTime) async {
    final jscr = "mediaController.currentTime($setTime);";
    await _frameController.evaluateJavascript(jscr);
  }

  Future<void> setPlaybackRate(int rate) async {
    final jscr = "mediaController.playbackRate($rate);";
    await _frameController.evaluateJavascript(jscr);
  }

  Future<void> forceReplay(int rate) async {
    final jscr = "mediaController.forceReplay();";
    await _frameController.evaluateJavascript(jscr);
  }

  Future<void> changeMedia(String url, {bool autoPlay = false}) async {
    final jscr = "mediaController.load('$url', $autoPlay);";
    await _frameController.evaluateJavascript(jscr);
    _mediaUrl = url;
  }

  enterVRMode() {
    final jscr = "mediaController.enterVRMode();";
    _frameController.evaluateJavascript(jscr);
  }

  exitVRMode() {
    final jscr = "mediaController.exitVRMode();";
    _frameController.evaluateJavascript(jscr);
  }

  // getters

  String get mediaLink => _mediaUrl;

  Future<num> get currentTime async {
    final jscr = "mediaController.currentTime();";
    return num.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<num> get playbackRate async {
    final jscr = "mediaController.playbackRate();";
    return num.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<int> get readyState async {
    final jscr = "mediaController.state;";
    return int.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<bool> get isPaused async {
    final jscr = "mediaController.paused;";
    return (await _frameController.evaluateJavascript(jscr)) == 'true';
  }

  Future<num> get duration async {
    final jscr = "mediaController.duration;";
    return num.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<num> get volume async {
    final jscr = "mediaController.volume;";
    return num.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<bool> get isMuted async {
    final jscr = "mediaController.isMuted;";
    return (await _frameController.evaluateJavascript(jscr)) == 'true';
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
    _frameController.evaluateJavascript(jscr);
  }

  @override
  void subscribeToAllEvents() {
    const jscr = "mediaController.subscribeToAllEvents();";
    _frameController.evaluateJavascript(jscr);
  }

  @override
  void unSubscribeFromAllEvents() {
    const jscr = "mediaController.unSubscribeFromAllEvents();";
    _frameController.evaluateJavascript(jscr);
  }

  @override
  void unSubscribeFrom(List<int> mediaEvents) {
    final events = _getEvents(mediaEvents);
    final jscr = "mediaController.unsubscribe($events);";
    _frameController.evaluateJavascript(jscr);
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

class WebVRPlayer extends StatefulWidget {
  final WebVRPlayerController controller;
  final Function(int) onPlayerLoading;
  final Function() onPlayerInit;
  final bool debugMode;
  final bool showVRBtn;
  final bool autoPlay;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const WebVRPlayer({
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

  @override
  _WebVRPlayerState createState() => _WebVRPlayerState();
}

class _WebVRPlayerState extends State<WebVRPlayer> {
  WebViewController webView;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: _buildInitalUrl(),
      gestureRecognizers: widget.gestureRecognizers,
      onWebViewCreated: _onWebViewCreated,
      javascriptChannels: Set.from([
        JavascriptChannel(
          name: 'MsgChannel',
          onMessageReceived: (JavascriptMessage message) {
            final _parsedMsg = json.decode(message.message);
            final EventMessage _message = EventMessage.fromJson(_parsedMsg);
            widget.controller.triggerCallback(_message);
          },
        )
      ]),
      onPageStarted: _onLoadStart,
      onPageFinished: _onLoadStop,
      debuggingEnabled: widget.debugMode,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  void _onLoadStart(String _) {
    if (widget.onPlayerInit != null) {
      widget.onPlayerInit();
    }
  }

  String _buildInitalUrl() {
    String base = "https://raj457036.github.io/webview_vr_player/?";

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
    return base;
  }

  void _onWebViewCreated(WebViewController controller) {
    webView = controller;
    widget.controller._frameController = controller;
  }

  void _onLoadStop(String _) async {
    final jsrc =
        "MediaMessageChannel.postMessage = function(msg) { MsgChannel.postMessage(msg); }";
    await webView.evaluateJavascript(jsrc);
    widget.controller._onReady();
  }

  @override
  void dispose() {
    widget.controller?.unSubscribeFromAllEvents();
    super.dispose();
  }
}
