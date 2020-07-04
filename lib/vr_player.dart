import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const int __vrPlayerProviderPort = 8015;
final InAppLocalhostServer __vrPlayerProvider =
    InAppLocalhostServer(port: __vrPlayerProviderPort);

class EventMessage {
  final int readyState;
  final int event;
  final message;

  const EventMessage(this.readyState, this.event, this.message);

  EventMessage.fromJson(Map<String, dynamic> jsonMessage)
      : readyState = jsonMessage.containsKey('readyState')
            ? jsonMessage['readyState']
            : null,
        event = jsonMessage.containsKey('event') ? jsonMessage['event'] : null,
        message =
            jsonMessage.containsKey('message') ? jsonMessage['message'] : null;
}

class MediaEvent {
  static const int ABORTED = 1;
  static const int CAN_PLAY = 2;
  static const int CAN_PLAY_THROUGH = 3;
  static const int DURATION_CHANGE = 4;
  static const int ENDED = 5;
  static const int ERROR = 6;
  static const int LOADED_DATA = 7;
  static const int LOADED_META_DATA = 8;
  static const int LOAD_START = 9;
  static const int PAUSE = 10;
  static const int PLAY = 11;
  static const int PLAYING = 12;
  static const int PROGRESS = 13;
  static const int RATE_CHANGE = 14;
  static const int SEEKED = 15;
  static const int SEEKING = 16;
  static const int STALLED = 17;
  static const int SUSPEND = 18;
  static const int TIME_UPDATE = 19;
  static const int VOLUME_CHANGE = 20;
  static const int WAITING = 21;
  static const int EXTERNAL = 22;
}

abstract class VRPlayerObserver {
  void subscribeTo(List<int> event);
  void unsubscribeFrom(List<int> event);
  void subscribeToAll();
  void unSubscribeFromAll();
  void onEvent(int event, VoidCallback callback);
  void triggerCallback(EventMessage message);
}

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

  seek(int byTime) {
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

  Future<void> changeMedia(String url) async {
    final jscr = "mediaController.load($url);";
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

  Future<double> get currentTime async {
    final jscr = "mediaController.currentTime();";
    return await _frameController.evaluateJavascript(source: jscr) as double;
  }

  Future<int> get playbackRate async {
    final jscr = "mediaController.playbackRate();";
    return await _frameController.evaluateJavascript(source: jscr) as int;
  }

  int get readyState {
    final jscr = "mediaController.state;";
    return _frameController.evaluateJavascript(source: jscr) as int;
  }

  bool get isPaused {
    final jscr = "mediaController.paused;";
    return _frameController.evaluateJavascript(source: jscr) as bool;
  }

  double get duration {
    final jscr = "mediaController.duration;";
    return _frameController.evaluateJavascript(source: jscr) as double;
  }

  double get volume {
    final jscr = "mediaController.volume;";
    return _frameController.evaluateJavascript(source: jscr) as double;
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
  void subscribeToAll() {
    const jscr = "mediaController.subscribeToAllEvents();";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void unSubscribeFromAll() {
    const jscr = "mediaController.unSubscribeFromAllEvents();";
    _frameController.evaluateJavascript(source: jscr);
  }

  @override
  void unsubscribeFrom(List<int> mediaEvents) {
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

  static initializeVRPlayer() async {
    await __vrPlayerProvider.start();
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
    String base =
        "http://localhost:$__vrPlayerProviderPort/player_asset/index.html?";

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
    final jsrc =
        "MediaMessageChannel.postMessage = (msg) => window.flutter_inappwebview.callHandler('mediaEventMessage', msg);";
    await webView.evaluateJavascript(source: jsrc);
    widget.controller._onReady();
  }

  void _onConsoleMessage(controller, consoleMessage) {
    if (widget.debugMode) {
      print("VR PLAYER: " + consoleMessage.message);
    }
  }
}
