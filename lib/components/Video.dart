import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  final String url; // 视频地址

  final String title; // 视频标题

  final double aspectRatio; // 视频比例

  final String background; // 背景图

  final bool initialStatus;

  const Video(
      {Key key,
      @required this.url,
      this.aspectRatio,
      this.background,
      this.initialStatus,
      this.title})
      : assert(url != null),
        super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController _controller;

  String get url => widget.url;

  String get title => widget.title;

  double get aspectRatio => widget.aspectRatio;

  String get background => widget.background;

  bool get initialStatus => widget.initialStatus;

  var isFullscreen;

  String timeLabel;
  var _duration;

  Pattern _patten = ".";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isFullscreen = initialStatus;

    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _duration = _controller.value.duration.toString().split(_patten)[0];
        });
      });

    _controller.addListener(() {
      setState(() {
        timeLabel = _controller.value.position.toString().split(_patten)[0];
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _controller.value.initialized
          ? player()
          : AspectRatio(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
              ),
              aspectRatio: 16.0 / 9.0,
            ),
    );
  }

  Widget player() {
    return GestureDetector(
      child: Stack(
        children: <Widget>[
          VideoPlayer(_controller),
          Positioned(
            child: playerTitle(),
            left: 0,
            right: 0,
            top: 0,
          ),
          Positioned(
            child: playerControllerBar(),
            left: 0,
            right: 0,
            bottom: 0,
          ),
        ],
      ),
    );
  }

  // 播放器的标题栏
  Widget playerTitle() {
    // 状态栏高度
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {}),
          Expanded(
              child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          )),
        ],
      ),
      decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.6)),
    );
  }

  // 播放器的底部控制条
  Widget playerControllerBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      color: Color.fromRGBO(0, 0, 0, 0.2),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 35,
              color: Colors.white,
            ),
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
          Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                  ))),
          Text(
            timeLabel + '/' + _duration,
            style: TextStyle(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              '高清',
              style: TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            child: Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 35,
              color: Colors.white,
            ),
            onTap: () {
              if (isFullscreen) {
                SystemChrome.setEnabledSystemUIOverlays(
                    [SystemUiOverlay.top, SystemUiOverlay.bottom]);

                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);

                Navigator.pop(context);
              } else {
                _controller.pause();

                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    body: Video(
                      url: url,
                      title: title,
                      initialStatus: true,
                    ),
                    //body: widget,
                  );
                }));
              }
            },
          )
        ],
      ),
    );
  }

  Widget playFullscreen() {}
}
