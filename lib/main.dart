import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vr_player/vr_player.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VRPlayer.initializeVRPlayer();
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VRPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VRPlayerController(
      mediaUrl:
          "https://video.felixsmart.com:9443/live/_definst_/40A36BC4C907/playlist.m3u8?token=06f98ebc-983e-48a2-bb03-7d6f16a25fd3",
      onReady: () {
        controller.subscribeToAllEvents();
        controller.onEvent(MediaEvent.PROGRESS, () async {
          final progress = await controller.currentTime;
          print("Progressed: $progress");
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppWebView Example'),
        ),
        body: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.matrix([
                0.393, 0.769, 0.189, 0, 0, //
                0.349, 0.686, 0.168, 0, 0, //
                0.272, 0.534, 0.131, 0, 0, //
                0, 0, 0, 1, 0, //
              ]),
              child: VRPlayer(
                controller: controller,
                // autoPlay: false,
                debugMode: true,
                gestureRecognizers: Set()
                  ..add(
                      Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                        ..onTapDown = (tap) {
                          print(
                              "This one prints ====================================================\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                        })),
              ),
            ),
            Positioned(
              child: RaisedButton(
                child: Text("play"),
                onPressed: play,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void play() async {
    await controller.changeMedia(
        "https://video.felixsmart.com:9443/vod/_definst_/mp4:40A36BC38F2D/40A36BC38F2D1593103010597/playlist.m3u8?token=16eaa183-d548-475c-ad07-7b1c61e31dde");
    controller.play();
  }
}
