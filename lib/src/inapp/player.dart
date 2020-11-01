import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  WebViewController _frameController;

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
    _frameController.evaluateJavascript(jscr);
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
  /// - Amaro
  /// - Ashby
  /// - Charmes
  /// - Crema
  /// - Dogpatch
  /// - Ginza
  /// - Hefe
  /// - Helena
  /// - Juno
  /// - Ludwig
  /// - Poprocket
  /// - Sierra
  /// - Skyline
  /// - Sutro
  /// - Vesper
  ///
  /// Note: change balance with `buildBalanceFilter`
  /// Balance filter trys to reduce unwanted color from the media
  /// like removing blue light.
  applyFilter(String filterCode) {
    final jscr = "mediaFilter.applyFilter('$filterCode');";
    _frameController.evaluateJavascript(jscr);
  }

  genFilter(double sepia, double saturation, double brightness, double contrast,
      double hueRot) {
    final jscr =
        "mediaFilter.filter($sepia, $saturation, $brightness, $contrast, $hueRot);";
    _frameController.evaluateJavascript(jscr);
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

  void setMediaURL(String url) => _mediaUrl = url;

  Future<dynamic> buildPlayer({
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
    final _ = await _frameController.evaluateJavascript(jscr);
    await Future.delayed(const Duration(milliseconds: 500), () => onBuild());
    return _;
  }

  Future<void> setEventListener() async {
    final jsrc = """setTimeout(
              function() { 
                 MediaMessageChannel.postMessage = (msg) => $_eventHandler.postMessage(msg);
              }, 500);""";
    await _frameController.evaluateJavascript(jsrc);
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

  Future<bool> get isFlat async {
    final jscr = "mediaController.isFlat;";
    return await _frameController.evaluateJavascript(jscr) as bool;
  }

  String get mediaLink => _mediaUrl;

  Future<num> get currentTime async {
    final jscr = "mediaController.currentTime();";
    return num.tryParse(await _frameController.evaluateJavascript(jscr));
  }

  Future<num> get playbackRate async {
    final jscr = "mediaController.playbackRate();";
    return await _frameController.evaluateJavascript(jscr) as num;
  }

  Future get readyState {
    final jscr = "mediaController.state;";
    return _frameController.evaluateJavascript(jscr);
  }

  Future get isPaused {
    final jscr = "mediaController.paused;";
    return _frameController.evaluateJavascript(jscr);
  }

  Future get duration {
    final jscr = "mediaController.duration;";
    return _frameController.evaluateJavascript(jscr);
  }

  Future get volume {
    final jscr = "mediaController.volume;";
    return _frameController.evaluateJavascript(jscr);
  }

  Future get isMuted {
    final jscr = "mediaController.isMuted;";
    return _frameController.evaluateJavascript(jscr);
  }

  // Event Management

  String _getEvents(List<int> mediaEvents) {
    final events = mediaEvents.map((e) => e.toString()).join(',');
    return events;
  }

  Future<dynamic> switchToFlatView(
      {bool fullScreen = false, bool fillMode = false}) async {
    final jscr =
        "mediaController.togglePlayer(true, ${fullScreen ? 1 : 0}, $fillMode);";
    final _ = await _frameController.evaluateJavascript(jscr);
    return _;
  }

  Future<dynamic> switchToMonoView() async {
    final jscr = "mediaController.togglePlayer(false, 0, false);";
    final _ = await _frameController.evaluateJavascript(jscr);
    return _;
  }

  @override
  Future<void> subscribeTo(List<int> mediaEvents) async {
    final events = _getEvents(mediaEvents);
    final jscr = "mediaController.subscribe($events);";
    await _frameController.evaluateJavascript(jscr);
  }

  @override
  Future<void> subscribeToAllEvents() async {
    const jscr = "mediaController.subscribeToAllEvents();";
    await _frameController.evaluateJavascript(jscr);
  }

  @override
  Future<void> unSubscribeFromAllEvents() async {
    const jscr = "mediaController.unSubscribeFromAllEvents();";
    await _frameController.evaluateJavascript(jscr);
  }

  @override
  Future<void> unSubscribeFrom(List<int> mediaEvents) async {
    final events = _getEvents(mediaEvents);
    final jscr = "mediaController.unsubscribe($events);";
    await _frameController.evaluateJavascript(jscr);
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
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const VRPlayer({
    Key key,
    @required this.controller,
    this.onPlayerLoading,
    this.onPlayerInit,
    this.gestureRecognizers,
    this.debugMode = false,
  })  : assert(controller != null),
        super(key: key);

  static void changePlayerHost(String playerURL) {
    _playerBaseUrl = playerURL;
  }

  @override
  _VRPlayerState createState() => _VRPlayerState();
}

class _VRPlayerState extends State<VRPlayer> {
  WebViewController webView;
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    setPlatformSpecs();
  }

  setPlatformSpecs() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 29)
        WebView.platform = SurfaceAndroidWebView();
    }

    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_ready
        ? Center(
            child: CircularProgressIndicator(),
          )
        : WebView(
            initialUrl: _buildInitalUrl(),
            // initialHeaders: {},

            gestureNavigationEnabled: false,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            // initialOptions: InAppWebViewGroupOptions(
            //   crossPlatform: InAppWebViewOptions(
            //     debuggingEnabled: widget.debugMode,
            //     mediaPlaybackRequiresUserGesture: false,
            //     transparentBackground: true,
            //   ),
            //   ios: IOSInAppWebViewOptions(
            //     allowsInlineMediaPlayback: true,
            //     enableViewportScale: true,
            //     allowsLinkPreview: false,
            //     allowsPictureInPictureMediaPlayback: false,
            //     disallowOverScroll: true,
            //   ),
            // ),
            gestureRecognizers: widget.gestureRecognizers,
            // onWebViewCreated: _onWebViewCreated,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (_) {
              setState(() {
                webView = _;
                widget.controller._frameController = _;
              });
              _.clearCache();
            },
            // onLoadStart: _onLoadStart,
            // onLoadStop: _onLoadStop,
            // onProgressChanged: _onProgressChange,
            // onConsoleMessage: _onConsoleMessage,
            onPageStarted: _onLoadStart,
            onPageFinished: _onLoadStop,
            debuggingEnabled: widget.debugMode,
            javascriptChannels: getJsChannels(),
          );
  }

  void _onLoadStart(String url) {
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

  Set<JavascriptChannel> getJsChannels() {
    return [
      JavascriptChannel(
        name: _eventHandler,
        onMessageReceived: (result) {
          try {
            final _parsedMsg = json.decode(result.message);
            final EventMessage message = EventMessage.fromJson(_parsedMsg);
            widget.controller.triggerCallback(message);
          } catch (e) {}
        },
      )
    ].toSet();
  }

  // void _onWebViewCreated(InAppWebViewController controller) {
  //   webView = controller;
  //   widget.controller._frameController = controller;
  //   webView.addJavaScriptHandler(
  //     handlerName: 'mediaEventMessage',
  //     callback: (result) {
  //       final _parsedMsg = json.decode(result.first);
  //       final EventMessage message = EventMessage.fromJson(_parsedMsg);
  //       widget.controller.triggerCallback(message);
  //     },
  //   );
  // }

  // void _onProgressChange(InAppWebViewController controller, int progress) {
  //   if (widget.onPlayerLoading != null) {
  //     widget.onPlayerLoading(progress);
  //   }
  // }

  void _onLoadStop(String url) async {
    await widget.controller.setEventListener();
    if (widget.controller._onReady != null) widget.controller._onReady();
  }

  // void _onConsoleMessage(controller, consoleMessage) {
  //   if (widget.debugMode) {
  //     print("VR PLAYER: " + consoleMessage.message);
  //   }
  // }
}
