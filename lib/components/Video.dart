/*
* 视频播放器插件
*
* 功能列表
*
* sh
*
* */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exueshi/common/custom_router.dart';

import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  final String url; // 视频地址

  final String title; // 视频标题

  final double aspectRatio; // 视频比例

  final String background; // 背景图

  final bool initialStatus;

  final isLive;

  const Video({
    Key key,
    @required this.url,
    this.aspectRatio,
    this.background,
    this.initialStatus = false,
    this.title = '',
    this.isLive = false,
  })
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

  bool get isLive => widget.isLive;

  var isFullscreen;

  bool isShowDanmu = false;

  String timeLabel;
  var _duration;

  Pattern _patten = ".";

  bool enableTitleInSmall = false;

  bool cleanMode = false;

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
  void didUpdateWidget(Video oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print(cleanMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: _controller.value.initialized
              ? player()
              : AspectRatio(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.black,
            ),
            aspectRatio: 16.0 / 9.0,
          ),
        ),
        resizeToAvoidBottomInset: true);
  }

  Widget player() {
    return Container(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            child: VideoPlayer(_controller),
            onTap: () {
              setState(() {
                cleanMode = !cleanMode;
                print(cleanMode);
                if (cleanMode) {
                  SystemChrome.setEnabledSystemUIOverlays([]);
                } else {
                  SystemChrome.setEnabledSystemUIOverlays(
                      [SystemUiOverlay.top]);
                }
              });
            },
          ),
          cleanMode
              ? Container()
              : Positioned(
            child: playerTitle(),
            left: 0,
            right: 0,
            top: 0,
          ),
          cleanMode
              ? Container()
              : Positioned(
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
    if (!isFullscreen && !enableTitleInSmall) {
      return Container();
    }

    if (title == '') {
      return Container();
    }

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
              onPressed: () {
                SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);

                Navigator.pop(context);
                // 退出全屏
              }),
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
          _playAndPauseBtn(), // 播放|暂停按钮
          playProgressBar(), // 进度条
          Text(
            timeLabel + '/' + _duration,
            style: TextStyle(color: Colors.white),
          ),
          barrageBtn(),
          exchangeDefinitionBtn(),
          fullscreenBtn()
        ],
      ),
    );
  }

  Switch barrageBtn() {
    return Switch(
        value: isShowDanmu,
        onChanged: (v) {
          print(v);
          setState(() {
            isShowDanmu = !isShowDanmu;
          });
        });
  }

  GestureDetector fullscreenBtn() {
    return GestureDetector(
      child: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        size: 35,
        color: Colors.white,
      ),
      onTap: () {
        if (isFullscreen) {
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

          Navigator.pop(context);
        } else {
          _controller.pause();

//                SystemChrome.setPreferredOrientations([
//                  DeviceOrientation.landscapeLeft,
//                  DeviceOrientation.landscapeRight
//                ]);

          Navigator.push(context,
              CustomRoute(VideoPlayerFullscreen(controller: _controller)));
        }
      },
    );
  }

  Container exchangeDefinitionBtn() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      child: Text(
        '高清',
        style: TextStyle(color: Colors.white, fontSize: 12.0),
      ),
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 170, 255, 0.8),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
    );
  }

  Expanded playProgressBar() {
    return Expanded(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
            )));
  }

  GestureDetector _playAndPauseBtn() {
    return GestureDetector(
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
    );
  }

  // 点击全屏，新开一个全屏页面，显示播放器
  Widget playFullscreen() {}
}

// 直接使用之前的controller

class VideoPlayerFullscreen extends StatefulWidget {
  final controller;

  const VideoPlayerFullscreen({Key key, this.controller}) : super(key: key);

  @override
  _VideoPlayerFullscreenState createState() => _VideoPlayerFullscreenState();
}

class _VideoPlayerFullscreenState extends State<VideoPlayerFullscreen> {
  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Video(
        url:
        'http://vedio.exueshi.com/26c9073d9d3f448896b80924ffc30a1c/9b065e10ca3241d4bd763090ce18d0a6-23ed88f2a1a26984ec60a497bcc1d316.m3u8',
        initialStatus: true,
        title: '视频标题',
      ),
    );
  }
}
