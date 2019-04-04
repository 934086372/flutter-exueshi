/*
* 视频播放器插件
*
* 功能列表
*
* sh
*
* */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  final String url; // 视频地址
  final String title; // 视频标题
  final double aspectRatio; // 视频比例
  final String background; // 背景图
  final bool enableFull; // 初始化时是否全屏播放
  final bool isLive; // 是否直播
  final bool showBackBtn; //

  const Video({
    Key key,
    @required this.url,
    this.aspectRatio = 16.0 / 9.0,
    this.background,
    this.enableFull = false,
    this.title = '',
    this.isLive = false,
    this.showBackBtn = false,
  })
      : assert(url != null),
        super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> with SingleTickerProviderStateMixin {
  VideoPlayerController _controller;

  String get url => widget.url;

  String get title => widget.title;

  double get aspectRatio => widget.aspectRatio;

  String get background => widget.background;

  bool get enableFull => widget.enableFull;

  bool get isLive => widget.isLive;

  var isFullscreen;

  bool isShowDanmu = false;

  String timeLabel;
  var _duration;

  Pattern _patten = ".";

  bool enableTitleInSmall = false;

  bool cleanMode = false;

  bool showControllerBar = true;

  List<SystemUiOverlay> systemUiOverlay = SystemUiOverlay.values;

  double realAspectRatio = 16.0 / 9.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isFullscreen = enableFull;

    // 初始化视频播放器
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        print('初始化完成');
        print(_controller.value);

        // 检查视频比例
        Size videoSize = _controller.value.size;

        realAspectRatio = videoSize.aspectRatio;
        _controller.pause();
        setState(() {
          _duration = _controller.value.duration.toString().split(_patten)[0];
        });
      }, onError: (error) {
        print('初始化失败');
        print(error);
      }).catchError((_) {
        print(_);
      });

    _controller.addListener(() {
      print(_controller.value.hashCode);
      setState(() {
        timeLabel = _controller.value.position.toString().split(_patten)[0];
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(Video oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CupertinoActivityIndicator(),
                    Text(
                      '加载中...',
                      style:
                      TextStyle(color: Colors.white, fontSize: 10.0),
                    )
                  ],
                ),
              ),
            ),
            aspectRatio: 16.0 / 9.0,
          ),
        ),
        resizeToAvoidBottomInset: true);
  }

  // 播放器
  Widget player() {
    return Hero(
      tag: 'videoPlayer',
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Center(
              child: GestureDetector(
                child: isFullscreen
                    ? Container()
                    : AspectRatio(
                  child: VideoPlayer(_controller),
                  aspectRatio: realAspectRatio,
                ),
                onTap: () {
                  setState(() {
                    cleanMode = !cleanMode;
                    if (isFullscreen) {
                      if (cleanMode) {
                        SystemChrome.setEnabledSystemUIOverlays([]);
                      } else {
                        SystemChrome.setEnabledSystemUIOverlays(
                            systemUiOverlay);
                      }
                    }
                  });
                },
              ),
            ),
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.3),
        child: Column(
          children: <Widget>[
            VideoProgressBar(
              controller: _controller,
            ), // 进度条
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              child: Row(
                children: <Widget>[
                  _playAndPauseBtn(), // 播放|暂停按钮
                  isLive
                      ? Container()
                      : Text(
                    timeLabel + '/' + _duration,
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  //barrageBtn(),
                  exchangeDefinitionBtn(),
                  fullscreenBtn()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 弹幕开关
  Widget barrageBtn() {
    return Switch(
        value: isShowDanmu,
        onChanged: (v) {
          print(v);
          setState(() {
            isShowDanmu = !isShowDanmu;
          });
        });
  }

  // 全屏 | 退出全屏 按钮
  Widget fullscreenBtn() {
    return GestureDetector(
      child: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        size: 35,
        color: Colors.white,
      ),
      onTap: () {
        if (isFullscreen) {
          print('退出全屏');

          SystemChrome.setEnabledSystemUIOverlays(systemUiOverlay);
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
          Navigator.pop(context, {'controller': _controller});
        } else {
          print('全屏');
          //_controller.pause();
          enterFullscreen();
        }
      },
    );
  }

  // 进入全屏
  void enterFullscreen() async {
    setState(() {
      isFullscreen = true;
    });

    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) {
        return FadeTransition(
          opacity: animation1,
          child: VideoPlayerFullscreen(controller: _controller),
        );
      },
    ));

    setState(() {
      isFullscreen = false;
    });

    SystemChrome.setEnabledSystemUIOverlays(systemUiOverlay);
    SystemChrome.setPreferredOrientations([]);
  }

  // 切换清晰度
  Widget exchangeDefinitionBtn() {
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

  // 开始暂停
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
}

// 进度条
class VideoProgressBar extends StatefulWidget {
  final controller;

  const VideoProgressBar({Key key, this.controller}) : super(key: key);

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  VideoPlayerController get controller => widget.controller;

  double progress = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 视频总时长
    int duration = controller.value.duration.inMicroseconds;

    controller.addListener(() {
      //double width = MediaQuery.of(context).size.width;
      double width = 100;
      int position = controller.value.position.inMicroseconds;
      double currentProgress = position / duration * width;

      if (currentProgress > progress) {
        setState(() {
          progress = currentProgress;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(progress);

    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            height: 2.0,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Positioned(
              child: Container(
                width: progress,
                height: 2.0,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 170, 255, 1),
                ),
              ))
        ],
      ),
    );
  }
}

// 全屏窗口播放
class VideoPlayerFullscreen extends StatefulWidget {
  final controller;

  const VideoPlayerFullscreen({Key key, this.controller}) : super(key: key);

  @override
  _VideoPlayerFullscreenState createState() => _VideoPlayerFullscreenState();
}

class _VideoPlayerFullscreenState extends State<VideoPlayerFullscreen> {
  VideoPlayerController get _controller => widget.controller;

  List<SystemUiOverlay> systemUiOverlay;

  bool cleanMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: "videoPlayer",
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: VideoPlayer(_controller),
              onTap: () {
                setState(() {
                  cleanMode = !cleanMode;
                  if (cleanMode) {
                    SystemChrome.setEnabledSystemUIOverlays([]);
                  } else {
                    SystemChrome.setEnabledSystemUIOverlays(systemUiOverlay);
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
      ),
    );
  }

  Widget playerTitle() {
    //double statusBarHeight = MediaQuery.of(context).padding.top;
    double statusBarHeight = 25.0;
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
                Navigator.pop(context);
                // 退出全屏
              }),
        ],
      ),
      decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.6)),
    );
  }

  // 播放器的底部控制条
  Widget playerControllerBar() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.3),
        child: Column(
          children: <Widget>[
            VideoProgressBar(
              controller: _controller,
            ), // 进度条
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              child: Row(
                children: <Widget>[
                  _playAndPauseBtn(), // 播放|暂停按钮

                  Expanded(
                    child: Container(),
                  ),
                  //barrageBtn(),
                  fullscreenBtn()
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget fullscreenBtn() {
    return GestureDetector(
      child: Icon(
        Icons.fullscreen_exit,
        size: 35,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
