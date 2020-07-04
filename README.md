# Flutter VR/360 Player

A VR/360 Player For Flutter

## Getting Started

VR player is based on [WebView VR Player](https://github.com/raj457036/webview_vr_player)

#### 1. Add `vr_player` to `pubspec.yaml`

```yaml
...

dependencies:
  flutter:
    sdk: flutter

  vr_player:
    git:
      url: https://github.com/raj457036/flutter_vr_player.git

...
```

#### 2. Initialize **VR Player**

```dart
import 'package:vr_player/vr_player.dart';

Future main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Required
    await VRPlayer.initializeVRPlayer();

    runApp(MyApp());
}


class MyApp extends StatefullWidget {
    ...
}

```

#### 3. use **VR PLAYER**

```dart
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
        controller.subscribeToAll();
        controller.onEvent(MediaEvent.PROGRESS, () async {
          final progress = await controller.currentTime;
          print("Video Progress: $progress");
        });
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter VR Player'),
        ),
        body: VRPlayer(controller: controller),
      ),
    );
  }
}
```

#### 4. Control your video playback or listen to events using 'VRPlayerController'

### ThankYou
