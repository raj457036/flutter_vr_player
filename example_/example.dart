import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vr_player/vr_player.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
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
        body: ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.393, 0.769, 0.189, 0, 0, //
            0.349, 0.686, 0.168, 0, 0, //
            0.272, 0.534, 0.131, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          child: VRPlayer(
            controller: controller,
            autoPlay: false,
            gestureRecognizers: Set()
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                ..onTapDown = (tap) {
                  print(
                      "This one prints ====================================================\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
                })),
          ),
        ),
      ),
    );
  }
}
