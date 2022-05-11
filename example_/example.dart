import 'dart:async';

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
  late final VRPlayerController controller;
  bool _loaded = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    controller = VRPlayerController(
      autoPlay: true,
      onReady: () {
        setState(() {
          _loaded = true;
        });
      },
      onBuild: () {
        controller.subscribeToAllEvents();
        controller.onEvent(MediaEvent.PROGRESS, () async {
          final progress = await controller.currentTime;
          setState(() {
            _text = "Time: $progress";
          });
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
          title: const Text('VR PLAYER'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: VRPlayer(
                controller: controller,
              ),
            ),
            Positioned(
              child: Text(
                _text,
                style: TextStyle(color: Colors.white),
              ),
              top: 10.0,
              left: 0,
              right: 0,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RaisedButton(
                onPressed: _loaded
                    ? () async {
                        controller.setMediaURL(
                            "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8");
                        await controller.buildPlayer();
                      }
                    : null,
                child: _loaded
                    ? Text("Load and Play")
                    : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
