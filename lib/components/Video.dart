/*
* 视频播放器插件
*
* */

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
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

  bool enableTitleInSmall = false;

  // 视频真实分辨率
  double realAspectRatio;

  Timer timer;

  bool showBarrage = false;

  Timer tmpTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isFullscreen = enableFull;

    // 初始化视频播放器
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        realAspectRatio = _controller.value.size.aspectRatio;
        _controller.pause();
        setState(() {});
      }, onError: (error) {
        print('初始化失败');
      }).catchError((_) {
        print(_controller.value);
      });

    _controller.addListener(() {
      print(_controller.value);
      if (_controller.value.position.inMilliseconds >=
          _controller.value.duration.inMilliseconds) {
        _controller.pause();
      }
    });

    videoController.showBarrage = showBarrage;
    videoController.title = title;

    print(videoController.title);

    // 测试发送弹幕
    tmpTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      videoController.sendBarrage(Text(
        '我是一条弹幕' + DateTime.now().toString(),
        style: TextStyle(color: Colors.white),
      ));
    });
  }

  @override
  void dispose() {
    videoController.dispose();
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
          setState(() {});
        }, onError: (error) {
          print('初始化失败');
        }).catchError((_) {
          print(_);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.initialized) {
      return Scaffold(
        body: Hero(
          tag: 'videoPlayer',
          child: Stack(
            children: <Widget>[
              renderBasicUI(), // 基础视频播放
              Positioned.fill(
                  child: VideoAdvancedUI(
                    videoController: videoController,
                    videoPlayerController: _controller,
                  ))
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: AspectRatio(
          child: Container(
            width: double.infinity,
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
          aspectRatio: aspectRatio,
        ),
      );
    }
  }

  // 渲染最底层播放器UI
  Widget renderBasicUI() {
    return Container(
      color: Colors.black,
      child: Center(
        child: isFullscreen
            ? Container()
            : AspectRatio(
          child: VideoPlayer(_controller),
          aspectRatio: realAspectRatio,
        ),
      ),
    );
  }
}

/*
* 弹幕视图
* */
class BarrageListView extends StatefulWidget {
  final VideoController videoController;
  final double height;

  const BarrageListView({Key key, this.videoController, this.height})
      : super(key: key);

  @override
  _BarrageListViewState createState() => _BarrageListViewState();
}

class _BarrageListViewState extends State<BarrageListView> {
  VideoController get videoController => widget.videoController;

  List<Text> barrageData = new List();

  double get height => widget.height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    videoController.addListener(() {
      if (!mounted) return;
      if (videoController.showBarrage) {
        setState(() {
          barrageData.addAll(videoController.barrageList);
        });
      } else {
        setState(() {
          barrageData.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: Stack(
            overflow: Overflow.clip,
            children: List.generate(barrageData.length, (index) {
              return Barrage(
                boxHeight: height,
                text: barrageData[index],
                onComplete: (v) {
                  //barrageData.remove(v);
                },
              );
            }),
          ),
        ));
  }
}

/*
*
* 渲染单个弹幕
*
* */
class Barrage extends StatefulWidget {
  final Text text;
  final ValueChanged onComplete;
  final double boxHeight;

  const Barrage({Key key, this.text, this.onComplete, this.boxHeight})
      : super(key: key);

  @override
  _BarrageState createState() => _BarrageState();
}

class _BarrageState extends State<Barrage> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Animation animation;

  Text get text => widget.text;

  ValueChanged get onComplete => widget.onComplete;

  double get boxHeight => widget.boxHeight;

  double singleHeight = 20.0;

  double top = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 根据高度计算最大行数，尽量避免重行
    int max = boxHeight ~/ singleHeight;
    top = Random().nextInt(max) * singleHeight;

    animationController =
    AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..forward()
      ..addListener(() {
        if (!mounted) return;
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

// 带时间标签的视频播放进度条组件
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const VideoProgressBar({Key key, this.videoPlayerController})
      : super(key: key);

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  VideoPlayerController get controller => widget.videoPlayerController;

  String timeLabel;
  String durationLabel;

  double progress = 0.0;
  TextStyle style = TextStyle(color: Colors.white, fontSize: 12.0);

  Pattern pattern = '.';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 视频总时长
    int duration = controller.value.duration.inMicroseconds;

    // 初始化视频时长 label
    setState(() {
      String durationText =
      controller.value.duration.toString().split(pattern)[0];
      List durationArray = durationText.split(RegExp(':'));
      if (controller.value.duration.inHours > 1) {
        durationLabel = durationText;
        timeLabel = '00:00:00';
      } else {
        durationLabel = durationArray[1] + ':' + durationArray[2];
        timeLabel = '00:00';
      }
    });

    controller.addListener(() {
      if (!mounted) return;

      double width = 100;
      int position = controller.value.position.inMicroseconds;
      double currentProgress = position / duration * width;

      setState(() {
        String timeText =
        controller.value.position.toString().split(pattern)[0];
        if (controller.value.duration.inHours > 1) {
          timeLabel = timeText;
        } else {
          List timeArray = timeText.split(RegExp(':'));
          timeLabel = timeArray[1] + ':' + timeArray[2];
        }
        if (currentProgress > progress) progress = currentProgress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(timeLabel, style: style),
        Expanded(
            child: Slider(
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
                })),
        Text(durationLabel, style: style),
      ],
    );
  }
}

/*
* 自定义视频控制器
*
* */
class VideoController extends ChangeNotifier {
  String title = '';
  bool isFullscreen = false;
  bool isLive = false;
  bool enableTitleInSmall = false;
  bool showBarrage = false;
  double aspectRatio = 16.0 / 9.0;
  List<Text> barrageList = new List<Text>();

  void sendBarrage(text) {
    barrageList = [text];
    notifyListeners();
  }

  void removeBarrage(text) {
    barrageList.remove(text);
  }

  void clear() {
    barrageList.clear();
    notifyListeners();
  }
}

/*
* 视频播放器UI操作层
* */
class VideoAdvancedUI extends StatefulWidget {
  final VideoPlayerController videoPlayerController; // 视频播放的控制器
  final VideoController videoController; // 自定义控制器

  const VideoAdvancedUI(
      {Key key, this.videoPlayerController, this.videoController})
      : super(key: key);

  @override
  _VideoAdvancedUIState createState() => _VideoAdvancedUIState();
}

class _VideoAdvancedUIState extends State<VideoAdvancedUI>
    with TickerProviderStateMixin {
  VideoPlayerController get videoPlayerController =>
      widget.videoPlayerController;

  VideoController get videoController => widget.videoController;

  // 是否全屏
  bool isFullscreen;

  // 小窗口是否显示标题栏
  bool enableTitleInSmall;

  // 标题
  String title;

  // 播放器比例
  double aspectRatio;

  // 是否直播
  bool isLive;

  // 是否显示UI界面
  bool showLayerWidget = true;

  // 自定义动画
  AnimationController animationController;
  Animation _heightFactor;

  // 自动隐藏UI显示层的延时执行的计时器
  Timer timer;

  // 是否显示清晰度列表，默认是不显示，点击切换清晰度按钮后切换
  bool showDefinitionList = false;

  // 是否显示弹幕
  bool showBarrage;

  // 缓存系统UI布局
  List<SystemUiOverlay> systemUiOverlay = SystemUiOverlay.values;

  // 分割正则
  Pattern patten = ".";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isFullscreen = videoController.isFullscreen;
    enableTitleInSmall = videoController.enableTitleInSmall;
    title = videoController.title;
    isLive = videoController.isLive;
    showBarrage = videoController.showBarrage;
    aspectRatio = videoController.aspectRatio;

    // 初始化控制栏的动画
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _heightFactor = animationController.drive(CurveTween(curve: Curves.easeIn));

    // 5秒后自动隐藏控制栏
    timer = Timer(Duration(seconds: 5), () {
      hideControl();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLayerWidget) {
      animationController.forward();
    } else {
      animationController.reverse().then((_) {
        if (!mounted) return;
        if (animationController.isCompleted) setState(() {});
      });
    }
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            renderTitle(), // 视频标题
            renderControllerBar(),
            renderDefinitionList(),
            renderBarrage()
          ],
        ),
      ),
      onTap: () {
        /*
          * 监听播放器点击事件
          *
          * toggle 播放器上其它显示Widget,
          *
          * 显示状态下，5秒后自定隐藏其它Widget
          *
          * */
        if (showLayerWidget) {
          // 已经显示状态下，清除定时器，并隐藏界面
          timer?.cancel();
          hideControl();
        } else {
          // 未显示状态下，立即显示，并设置5s后自动隐藏
          setState(() {
            showLayerWidget = true;
            if (isFullscreen)
              SystemChrome.setEnabledSystemUIOverlays(systemUiOverlay);
          });
          timer = Timer(Duration(seconds: 5), () {
            hideControl();
          });
        }
      },
    );
  }

  // 播放器的标题栏
  Widget renderTitle() {
    // 是否全屏
    if (isFullscreen) {
      if (title == null) title = '';
    } else {
      // 设置了小窗口不显示标题栏
      if (enableTitleInSmall == false) return Container();

      // 标题为空时不显示标题栏
      if (title == null || title == '') return Container();
    }

    // 状态栏高度
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
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
        child: Container(
          padding: EdgeInsets.only(top: statusBarHeight),
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
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
        ),
      ),
    );
  }

  // 播放器的底部控制条
  Widget renderControllerBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
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
      ),
    );
  }

  // 开始暂停
  Widget renderPlayPauseBtn() {
    return GestureDetector(
      child: Icon(
        videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        size: 30,
        color: Colors.white,
      ),
      onTap: () {
        setState(() {
          videoPlayerController.value.isPlaying
              ? videoPlayerController.pause()
              : videoPlayerController.play();
        });
      },
    );
  }

  // 渲染进度条
  Widget renderProgressBar() {
    // 若为直播不显示进度条
    if (isLive) return Expanded(child: Container());
    return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: VideoProgressBar(
            videoPlayerController: videoPlayerController,
          ),
        ));
  }

  // 弹幕开关
  Widget renderBarrageBtn() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        child: Icon(
          showBarrage ? MyIcons.barrage_on : MyIcons.barrage_off,
          color: Colors.white,
          size: 24,
        ),
        onTap: () {
          setState(() {
            showBarrage = !showBarrage;
            videoController.showBarrage = showBarrage;
            if (showBarrage == false) videoController.clear();
          });
        },
      ),
    );
  }

  // 渲染弹幕列表
  Widget renderBarrage() {
    // 不显示弹幕
    if (showBarrage == false) return Container();

    // 显示弹幕
    double height = MediaQuery
        .of(context)
        .size
        .width / aspectRatio - 40.0;

    return BarrageListView(videoController: videoController, height: height);
  }

  // 切换清晰度
  Widget renderDefinitionBtn() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(
          '高清',
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
      onTap: () {
        setState(() {
          showDefinitionList = !showDefinitionList;
        });
      },
    );
  }

  // 渲染清晰度列表
  Widget renderDefinitionList() {
    if (showLayerWidget == false) return Container();
    if (showDefinitionList == false) return Container();
    return Positioned(
      bottom: 45,
      right: 30,
      child: Container(
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
      ),
    );
  }

  // 清晰度列表单项样式
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
          // 退出全屏
          Navigator.pop(context);
        } else {
          // 进入全屏
          enterFullscreen();
        }
      },
    );
  }

  // 进入全屏
  void enterFullscreen() async {
    videoController.isFullscreen = true;
    await Navigator.of(context).push(PageRouteBuilder(
      settings: RouteSettings(isInitialRoute: false),
      pageBuilder: (context, animation1, animation2) {
        return FadeTransition(
          opacity: animation1,
          child: VideoPlayerFullscreen(
            videoPlayerController: videoPlayerController,
            videoController: videoController,
            systemUiOverlay: systemUiOverlay,
          ),
        );
      },
    ));

    // 退出全屏后执行操作
    setState(() {
      showBarrage = videoController.showBarrage;
      videoController.isFullscreen = false;
    });

    SystemChrome.setEnabledSystemUIOverlays(systemUiOverlay);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  // 延时自动隐藏控制条
  void hideControl() {
    setState(() {
      showLayerWidget = false;
      showDefinitionList = false;
      if (isFullscreen) {
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
    });
  }
}

// 全屏窗口播放
class VideoPlayerFullscreen extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final VideoController videoController;
  final List<SystemUiOverlay> systemUiOverlay;

  const VideoPlayerFullscreen({Key key,
    this.videoPlayerController,
    this.videoController,
    this.systemUiOverlay})
      : super(key: key);

  @override
  _VideoPlayerFullscreenState createState() => _VideoPlayerFullscreenState();
}

class _VideoPlayerFullscreenState extends State<VideoPlayerFullscreen> {
  VideoPlayerController get videoPlayerController =>
      widget.videoPlayerController;

  VideoController get videoController => widget.videoController;

  List<SystemUiOverlay> get systemUiOverlay => widget.systemUiOverlay;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 设置横屏播放
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: Center(
                child: AspectRatio(
                  child: VideoPlayer(videoPlayerController),
                  aspectRatio: videoPlayerController.value.aspectRatio,
                ),
              ),
            ),
            Positioned.fill(
                child: VideoAdvancedUI(
                  videoPlayerController: videoPlayerController,
                  videoController: videoController,
                ))
          ],
        ),
      ),
    );
  }
}
