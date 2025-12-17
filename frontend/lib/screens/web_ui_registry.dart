// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebCameraWidget extends StatefulWidget {
  final Function(Uint8List) onCapture;

  const WebCameraWidget({Key? key, required this.onCapture}) : super(key: key);

  @override
  State<WebCameraWidget> createState() => _WebCameraWidgetState();
}

class _WebCameraWidgetState extends State<WebCameraWidget> {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _initCamera();
  }

  void _initCamera() {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..width = 300
      ..height = 200;

    html.window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
      _videoElement!.srcObject = stream;
    });

    // Register a view type for Flutter Web
    // ignore: undefined_prefixed_name
    // Note: This works in modern Flutter Web (Flutter 3.10+)
    // we use a unique viewType for HtmlElementView
    final String viewType = 'videoElement-${_videoElement.hashCode}';
    // ignore: undefined_prefixed_name
    // ignore: avoid_web_libraries_in_flutter
    // platformViewRegistry is available in Dart:ui for web
    // workaround for Flutter Web
    // ignore: undefined_prefixed_name
    import 'dart:ui' as ui_web;
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => _videoElement!);

    setState(() {});
  }

  void _captureImage() {
    if (_videoElement == null) return;

    _canvasElement ??= html.CanvasElement(
      width: _videoElement!.videoWidth,
      height: _videoElement!.videoHeight,
    );

    final ctx = _canvasElement!.context2D;
    ctx.drawImage(_videoElement!, 0, 0);

    final dataUrl = _canvasElement!.toDataUrl('image/png');
    final bytes = base64Decode(dataUrl.split(',')[1]);
    widget.onCapture(bytes);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _videoElement == null) return const SizedBox();

    final String viewType = 'videoElement-${_videoElement.hashCode}';
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: HtmlElementView(viewType: viewType),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _captureImage,
          child: const Text('Capture Photo'),
        ),
      ],
    );
  }
}
