import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:ui';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:videoplayer/base/SystemUtil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
class LocalVideoPlayerScreen extends StatefulWidget {
  @override
  _LocalVideoPlayerScreenState createState() => _LocalVideoPlayerScreenState();

  static Future openLocalVideoPlayerScreen(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocalVideoPlayerScreen(),
      ),
    );
  }
}

class _LocalVideoPlayerScreenState extends State<LocalVideoPlayerScreen> {
  late VideoPlayerController _controller;
  GlobalKey rootWidgetKey = GlobalKey();
  late Timer _loopTimer;
  ScreenshotController screenshotController = ScreenshotController();
  String result = '';

  @override
  void initState() {
    super.initState();
    _loopTimer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      try{
        _capturePng();
      } catch(e){
        print('error:${e}');
      }
    });
    _controller = VideoPlayerController.network(
        'https://media.w3.org/2010/05/sintel/trailer.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  void cancelLoopTimer() {
    if (_loopTimer != null) {
      _loopTimer.cancel();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        RepaintBoundary(
          key: rootWidgetKey,
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ) : Container(),
        ),
        PositionedDirectional(start: 10, bottom: 10, child: Text(result)),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

    _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      rootWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if(boundary is RenderRepaintBoundary){
        var image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png) as ByteData;
        Uint8List? pngBytes = byteData?.buffer.asUint8List();
        print('LocalVideoPlayerScreen,pngBytes,${pngBytes}');
        // final directory = (await getApplicationDocumentsDirectory()).path;
        // print('LocalVideoPlayerScreen,directory,${directory}');
        // File imgFile = File('$directory/screenshot.png');
        // await imgFile.writeAsBytes(pngBytes).then((value) {} , onError: (e) { });
        // print('LocalVideoPlayerScreen,write success,');

      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  _doCapture() async {
      int time  = System.currentTimeMillis();
      screenshotController.capture().then((Uint8List? image) {
        print('image ,${image} cost:${System.currentTimeMillis() - time}ms');

      }).catchError((onError) {
        print(onError);
      });
    }


    // int time = System.currentTimeMillis();
    // final directory = (await getApplicationDocumentsDirectory())
    //     .path; //from path_provide package
    // String fileName = 'test';
    // String path = '$directory';
    // print('path,${path}');
    // await screenshotController.captureAndSave(
    //     path, //set path where screenshot will be saved
    //     fileName:fileName
    // );
    // //args support android / Web , i don't have a mac
    // String local = '$directory/${fileName}';
    // print('path:${local}');
    // String text = await FlutterTesseractOcr.extractText(
    //     local, language: 'eng',
    //     args: {
    //       "psm": "4",
    //       "preserve_interword_spaces": "1",
    //     });
    // print('text ${text} cost:${System.currentTimeMillis() - time}ms');
  //}
}