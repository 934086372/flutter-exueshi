import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/study/PaperIndex.dart';

import 'package:video_player/video_player.dart';

class ProductContent extends StatefulWidget {
  final product;

  const ProductContent({Key key, this.product}) : super(key: key);

  @override
  _ProductContentState createState() => _ProductContentState(this.product);
}

class _ProductContentState extends State<ProductContent> {
  final product;

  _ProductContentState(this.product);

  VideoPlayerController _controller;

  bool _showVideoControllerBar = true;

  var _duration;

  var _progressText = '';

  Pattern _patten = ".";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = VideoPlayerController.network(
        'http://vedio.exueshi.com/26c9073d9d3f448896b80924ffc30a1c/9b065e10ca3241d4bd763090ce18d0a6-23ed88f2a1a26984ec60a497bcc1d316.m3u8')
      ..initialize().then((_) {
        setState(() {});
      });

    // 监听
    _controller.addListener(() {
      setState(() {
        _progressText = _controller.value.position.toString().split(_patten)[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.value);

    var videoDuration = _controller.value.duration;

    _duration = _controller.value.duration.toString().split(_patten)[0];
    print(_duration);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 170, 255, 1),
          elevation: 0.0,
          title: Text('目录'),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            _controller.value.initialized ? videoPlayer() : Container(),
            Expanded(
                child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(MyIcons.paper),
                        title: Text('试卷'),
                        onTap: () {
                          Navigator.of(context).push(CustomRoute(PaperIndex()));
                        },
                      );
                    })),
          ],
        ));
  }

  Widget videoPlayer() {
    return GestureDetector(
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          !_showVideoControllerBar
              ? Container()
              : Positioned(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              color: Color.fromRGBO(0, 0, 0, 0.2),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
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
                    _progressText + '/' + _duration,
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      '高清',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(
                    Icons.fullscreen,
                    size: 35,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            bottom: 0,
            left: 0,
            right: 0,
            height: 45,
          ),
        ],
      ),
      onTap: () {
        // 点击
        setState(() {
          _showVideoControllerBar = !_showVideoControllerBar;
          if (_showVideoControllerBar) {
            Timer(Duration(seconds: 5), () {
              setState(() {
                _showVideoControllerBar = false;
              });
            });
          }
        });
      },
      onVerticalDragEnd: (_details) {
        print(_details);
      },
      onHorizontalDragEnd: (_details) {
        print(_details);
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
