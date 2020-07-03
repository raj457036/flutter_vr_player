import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VR Player'),
      ),
      body: Builder(builder: (BuildContext context) {
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            0.393, 0.769, 0.189, 0, 0, //
            0.349, 0.686, 0.168, 0, 0, //
            0.272, 0.534, 0.131, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          child: WebView(
            initialUrl:
                'https://raj457036.github.io/webview_vr_player?video=https://video.felixsmart.com:9443/vod/_definst_/mp4:40A36BC38F2D/40A36BC38F2D1593103010597/playlist.m3u8?token=16eaa183-d548-475c-ad07-7b1c61e31dde',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: play,
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  play() {
    final code = '''
        mediaController.video.loop = true;
        mediaController.load("https://video.felixsmart.com:9443/vod/_definst_/mp4:40A36BC38F2D/40A36BC38F2D1593103010597/playlist.m3u8?token=16eaa183-d548-475c-ad07-7b1c61e31dde");
        ''';
    _controller.evaluateJavascript(code);
  }
}
