/*
* 视频播放器插件
*
* 功能列表
*
* sh
*
* */

import 'dart:async';
import 'dart:math';
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

  final VideoController videoController;

  const Video({
    Key key,
    @required this.url,
    this.aspectRatio = 16.0 / 9.0,
    this.background,
    this.enableFull = false,
    this.title = '',
    this.isLive = false,
    this.showBackBtn = false,
    this.videoController,
  })
      : assert(url != null),
        super(key: key);

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> with TickerProviderStateMixin {
  VideoPlayerController _controller;

  VideoController get videoController => widget.videoController;

  String get url => widget.url;

  String get title => widget.title;

  double get aspectRatio => widget.aspectRatio;

  String get background => widget.background;

  bool get enableFull => widget.enableFull;

  bool get isLive => widget.isLive;

  var isFullscreen;

  // 是否开启弹幕功能
  bool enableBarrage = false;

  String timeLabel;
  var _duration;

  Pattern _patten = ".";

  bool enableTitleInSmall = false;

  bool cleanMode = false;

  bool showControllerBar = true;

  List<SystemUiOverlay> systemUiOverlay = SystemUiOverlay.values;

  double realAspectRatio = 16.0 / 9.0;

  Timer timer;

  // 自定义动画
  AnimationController animationController;
  Animation _heightFactor;

  GlobalKey definitionBtnKey = new GlobalKey();

  bool showDefinitionList = false;

  bool showBarrage = false;

  double clientWidth;

  List<Text> barrageData = [
    Text(
      '老铁666',
      style: TextStyle(color: Colors.white, fontSize: 18.0),
    )
  ];

  Timer tmpTimer;

  // 视频播放监听器
  void listener() {
    if (!mounted) return;

    print('监听播放器');

    // 自动隐藏控制条
    if (cleanMode == false) {
      timer = Timer(Duration(seconds: 5), () {
        setState(() {
          cleanMode = true;
          showDefinitionList = false;
        });
      });
    }
    setState(() {
      String timeText = _controller.value.position.toString().split(_patten)[0];
      if (_controller.value.duration.inHours > 1) {
        timeLabel = timeText;
      } else {
        List timeArray = timeText.split(RegExp(':'));
        timeLabel = timeArray[1] + ':' + timeArray[2];
      }
    });
  }

  // 初始化视频时长 label
  void initDuration() {
    setState(() {
      String durationText =
      _controller.value.duration.toString().split(_patten)[0];
      List durationArray = durationText.split(RegExp(':'));
      if (_controller.value.duration.inHours > 1) {
        _duration = durationText;
      } else {
        _duration = durationArray[1] + ':' + durationArray[2];
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _heightFactor = animationController.drive(CurveTween(curve: Curves.easeIn));

    isFullscreen = enableFull;

    // 初始化视频播放器
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        print('初始化完成');
        realAspectRatio = _controller.value.size.aspectRatio;
        _controller.pause();
        initDuration();
      }, onError: (error) {
        print('初始化失败');
      }).catchError((_) {
        print(_);
      });

    _controller.addListener(listener);

    videoController.addListener(() {
      setState(() {
        barrageData.addAll(videoController.barrageList);
      });
    });

    tmpTimer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      setState(() {
        barrageData.add(Text(
          '我是一条弹幕',
          style: TextStyle(color: Colors.white),
        ));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    tmpTimer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(Video oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (url != oldWidget.url) {
      // 切换视频时，先清除之前的视频
      _controller.dispose();
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          print('切换视频源后初始化完成');
          // 检查视频比例
          realAspectRatio = _controller.value.size.aspectRatio;
          _controller.play();
          initDuration();
        }, onError: (error) {
          print('初始化失败');
        }).catchError((_) {
          print(_);
        })
        ..addListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    clientWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: _controller.value.initialized
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
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                )
              ],
            ),
          ),
        ),
        aspectRatio: 16.0 / 9.0,
      ),
    );
  }

  // 播放器
  Widget player() {
    print(barrageData.length);

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
                  if (cleanMode == false) {
                    timer?.cancel();
                    timer = Timer(Duration(seconds: 5), () {
                      setState(() {
                        cleanMode = true;
                      });
                    });
                  } else {
                    showDefinitionList = false;
                  }
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
                onDoubleTap: () {
                  print('双击暂停');
                },
              ),
            ),
          ),
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
          Positioned(bottom: 45, right: 30, child: renderDefinitionList()),
          Positioned.fill(
              child: Stack(
                children: List.generate(barrageData.length, (index) {
                  return Barrage(
                    text: barrageData[index],
                    onComplete: (v) {
                      barrageData.remove(barrageData[index]);
                    },
                  );
                }),
              )),
        ],
      ),
    );
  }

  // 播放器的标题栏
  Widget playerTitle() {
    if (!isFullscreen && !enableTitleInSmall) return Container();

    if (title == '') return Container();

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
    if (cleanMode) {
      animationController.reverse().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } else {
      animationController.forward();
    }

    return AnimatedBuilder(
      animation: animationController.view,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        );
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Row(
            children: <Widget>[
              // 播放|暂停按钮
              renderPlayPauseBtn(),
              // 进度条
              renderProgressBar(),
              // 弹幕开关
              renderBarrageBtn(),
              // 清晰度切换开关
              renderDefinitionBtn(),
              // 全屏按钮
              renderFullscreenBtn()
            ],
          ),
        ),
      ),
    );
  }

  Widget renderProgressBar() {
    // 播放时间字体样式
    TextStyle style = TextStyle(color: Colors.white, fontSize: 12.0);
    return Expanded(
      child: isLive
          ? Container()
          : Row(
        children: <Widget>[
          Text(timeLabel, style: style),
          Expanded(
              child: VideoProgressBar(
                controller: _controller,
              )),
          Text(_duration, style: style),
        ],
      ),
    );
  }

  // 弹幕开关
  Widget renderBarrageBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            showBarrage = !showBarrage;
          });
        },
        child: Icon(
          showBarrage ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
      ),
    );
  }

  // 全屏 | 退出全屏 按钮
  Widget renderFullscreenBtn() {
    return GestureDetector(
      child: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        size: 30,
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
  Widget renderDefinitionBtn() {
    return GestureDetector(
      key: definitionBtnKey,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: const EdgeInsets.all(5.0),
        child: Text(
          '高清',
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
      onTap: () {
        print('切换清晰度');
        setState(() {
          showDefinitionList = !showDefinitionList;
        });
      },
    );
  }

  Widget renderDefinitionList() {
    if (cleanMode) return Container();

    if (showDefinitionList == false) return Container();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      width: 50,
      child: Column(
        children: <Widget>[
          renderDefinitionItem('高清'),
          Divider(
            height: 10.0,
          ),
          renderDefinitionItem('标清'),
          Divider(
            height: 10.0,
          ),
          renderDefinitionItem('流畅'),
        ],
      ),
    );
  }

  Widget renderDefinitionItem(item) {
    TextStyle style = TextStyle(fontSize: 12.0, color: Colors.white);
    return GestureDetector(
      onTap: () {
        setState(() {
          showDefinitionList = false;
        });
      },
      child: Text(
        item,
        style: style,
      ),
    );
  }

  // 开始暂停
  GestureDetector renderPlayPauseBtn() {
    return GestureDetector(
      child: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        size: 30,
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

class Barrage extends StatefulWidget {
  final Text text;

  final ValueChanged onComplete;

  const Barrage({Key key, this.text, this.onComplete}) : super(key: key);

  @override
  _BarrageState createState() => _BarrageState();
}

class _BarrageState extends State<Barrage> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Animation animation;

  Text get text => widget.text;

  ValueChanged get onComplete => widget.onComplete;

  double top = Random().nextDouble() * 200;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController =
    AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..forward()
      ..addListener(() {
        if (animationController.isCompleted) {
          onComplete(text);
        }
      });

    animation = Tween(begin: Offset(1.0, 0.0), end: Offset(-1.0, 0.0)).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    double clientWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Positioned(
      top: top,
      width: clientWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: AnimatedBuilder(
          animation: animationController.view,
          builder: (context, child) {
            return SlideTransition(
              position: animation,
              child: child,
            );
          },
          child: text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    // TODO: implement dispose
    super.dispose();
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
    return Slider(
        value: progress,
        min: 0,
        max: 100,
        activeColor: Color.fromRGBO(0, 170, 255, 1),
        inactiveColor: Colors.white,
        onChanged: (v) {
          setState(() {
            progress = v;
            int milliSeconds =
                controller.value.duration.inMilliseconds * v ~/ 100;
            controller.seekTo(Duration(milliseconds: milliSeconds));
          });
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
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
//            VideoProgressBar(
//              controller: _controller,
//            ), // 进度条
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              child: Row(
                children: <Widget>[
                  _playAndPauseBtn(), // 播放|暂停按钮
                  VideoProgressBar(
                    controller: _controller,
                  ),
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

class VideoController extends ChangeNotifier {
  List<Text> barrageList = new List<Text>();

  void sendBarrage(text) {
    print('发送弹幕');
    barrageList.add(text);
    notifyListeners();
  }
}
