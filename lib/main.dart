import 'dart:async';
import 'package:flutter/material.dart';
import 'vr_player.dart';

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
          "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8",
      onReady: () {
        // controller.subscribeToAllEvents();
        controller.onEvent(MediaEvent.PROGRESS, () async {
          final progress = await controller.currentTime;
          print("Progressed: $progress");
        });
        Future.delayed(Duration(seconds: 10), () {
          controller.applyFilter(MediaFilters.Moon);
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
          title: const Text('WebView Example'),
        ),
        body: VRPlayer(
          controller: controller,
          autoPlay: true,
          debugMode: true,
        ),
      ),
    );
  }
}
