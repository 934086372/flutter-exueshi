import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/study/DocumentStudy.dart';
import 'package:flutter_exueshi/study/PaperIndex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:video_player/video_player.dart';

class ProductContent extends StatefulWidget {
  final product;

  const ProductContent({Key key, this.product}) : super(key: key);

  @override
  _ProductContentState createState() => _ProductContentState();
}

class _ProductContentState extends State<ProductContent>
    with SingleTickerProviderStateMixin {
  get product => widget.product;

  String userID;
  String prodID;
  String prodType;
  String type;
  String orderID;
  var lastStudyItem;

  var prodChapters;

  TabController _tabController;
  VideoPlayerController _controller;

  bool _showVideoControllerBar = true;

  var _duration;
  var _progressText = '';
  bool showVideoPlayer = true;

  Pattern _patten = ".";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    prodID = product['prodID'];
    prodType = product['prodType'];
    lastStudyItem = product['lastStudyItem'];
    orderID = product['orderID'];

    switch (prodType) {
      case '套餐':
        type = 'package';
        break;
      case '计划':
        type = 'plan';
        break;
      case '试卷':
        type = 'paper';
        break;
      case '资料':
        type = 'document';
        break;
      case '视频':
        type = 'video';
        break;
    }

    _init();

    getProdInfo();

    _tabController = TabController(length: 3, vsync: this);

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

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        print(_tabController.index);
        showVideoPlayer = _tabController.index == 0;
      });
    });
  }

  Future<void> _init() async {
    // 获取是否非WiFi情况下播放视频的配置
    SharedPreferences _pref = await SharedPreferences.getInstance();
    bool allowPlayNotWifi = _pref.getBool('allowPlayNotWifi');

    print(allowPlayNotWifi);
  }

  Future<void> getProdInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var user = json.decode(_prefs.getString('userData'));

    userID = user['userID'];

    print(product['prodID']);
    print(product['prodType']);

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProductLists', data: {
      'userID': userID,
      'prodID': prodID,
      'type': type,
      'orderID': orderID
    });

    print(response);
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        setState(() {
          prodChapters = ret['data'];
        });
      } else {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    _duration = _controller.value.duration.toString().split(_patten)[0];

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('目录'),
          centerTitle: true,
        ),
        body: prodChapters == null
            ? Center(child: CircularProgressIndicator())
            : Container(
          child: buildBody(context),
          color: Colors.white,
        ));
  }

  Widget buildBody(BuildContext context) {
    if (type == 'package') {
      print(prodChapters['videos']);
      print(prodChapters['papers']);
      print(prodChapters['documents']);

      var _videos = prodChapters['videos'];
      var _papers = prodChapters['papers'];
      var _documents = prodChapters['documents'];

      List<Tab> _tabs = new List();
      if (_videos != false) {
        _tabs.add(Tab(
          text: '视频',
        ));
      }
      if (_papers != false) {
        _tabs.add(Tab(
          text: '试卷',
        ));
      }
      if (_documents != false) {
        _tabs.add(Tab(
          text: '资料',
        ));
      }

      return Column(
        children: <Widget>[
          showVideoPlayer
              ? _controller.value.initialized
              ? videoPlayer(false)
              : AspectRatio(
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.black,
            ),
            aspectRatio: 16.0 / 9.0,
          )
              : Container(),
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Color.fromRGBO(51, 51, 51, 1),
            unselectedLabelColor: Color.fromRGBO(153, 153, 153, 1),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: <Widget>[
              buildListView(_videos),
              ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(MyIcons.paper),
                      title: Text('试卷'),
                      onTap: () {
                        Navigator.of(context).push(PageRouter(PaperIndex()));
                      },
                    );
                  }),
              ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(MyIcons.document),
                      title: Text('资料'),
                      onTap: () {
                        Navigator.of(context)
                            .push(PageRouter(DocumentStudy()));
                      },
                    );
                  })
            ]),
          ),
          showVideoPlayer ? bottomBar() : Container()
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: List.generate(prodChapters.length, (index) {
            // 判断是否有分组名称
            var category = prodChapters[index];
            var groupName = category['groupName'].toString();
            var childList = category['list'];
            print(childList);
            if (groupName == '未分类') {
              return Column(
                children: List.generate(childList.length, (index) {
                  return renderItem(childList[index]);
                }),
              );
            } else {
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(groupName),
                children: List.generate(childList.length, (index) {
                  return renderItem(childList[index]);
                }),
              );
            }
          }),
        ),
      );
    }
  }

  Widget renderItem(item) {
    Icon _icon;
    String _title;
    switch (item['type'].toString()) {
      case '视频':
        _icon = Icon(MyIcons.video);
        _title = item['videoName'];
        break;
      case '试卷':
        _icon = Icon(MyIcons.paper);
        _title = item['paperName'];
        break;
      case '资料':
        _icon = Icon(MyIcons.document);
        _title = item['docAlias'];
        break;
    }
    return ListTile(
      leading: _icon,
      title: Text(
        _title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        switch (item['type'].toString()) {
          case '视频':
            break;
          case '试卷':
            Navigator.of(context).push(PageRouter(PaperIndex()));
            break;
          case '资料':
            Navigator.of(context).push(PageRouter(DocumentStudy()));
            break;
        }
      },
    );
  }

  Widget bottomBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(226, 226, 226, 1), width: 0.5))),
      alignment: Alignment.center,
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SwitchBtn(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.edit), Text('评价')],
            ),
          ),
          Expanded(
            child: Center(child: Text('标记为已学习')),
          )
        ],
      ),
    );
  }

  ListView buildListView(chapters) {
    print(chapters.length);
    return ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          var category = chapters[index];
          var groupName = category['groupName'].toString();
          var childList = category['list'];
          print(childList);
          if (groupName == '未分类') {
            return Column(
              children: List.generate(childList.length, (index) {
                return renderItem(childList[index]);
              }),
            );
          } else {
            return ExpansionTile(
              initiallyExpanded: true,
              title: Text(groupName),
              children: List.generate(childList.length, (index) {
                return renderItem(childList[index]);
              }),
            );
          }
        });
  }

  Widget videoPlayer(isFullscreen) {
    print('isFullscreen:' + isFullscreen.toString());

    return GestureDetector(
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
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
                          ? Icons.pause
                          : Icons.play_arrow,
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
                  GestureDetector(
                    child: Icon(
                      isFullscreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      size: 35,
                      color: Colors.white,
                    ),
                    onTap: () {
                      isFullscreen = !isFullscreen;
                      if (isFullscreen) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight
                        ]);
                        _videoFullscreen();
                      } else {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown
                        ]);
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
            bottom: 0,
            left: 0,
            right: 0,
            height: 45,
          ),
          _controller.value.isPlaying
              ? Container()
              : Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              child: GestureDetector(
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 60,
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                ),
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      // 单击出现控制条
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
      // 双击暂停播放
      onDoubleTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
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

  _videoFullscreen() async {
    final result = await Navigator.of(context).push(PageRouter(Scaffold(
        body: Stack(
          children: <Widget>[
            videoPlayer(true),
          ],
        ))));
    print(result);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}

class SwitchBtn extends StatefulWidget {
  @override
  _SwitchBtnState createState() => _SwitchBtnState();
}

class _SwitchBtnState extends State<SwitchBtn> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Row(
        children: <Widget>[
          isSelected ? Icon(MyIcons.like) : Icon(MyIcons.like_border),
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: Text('收藏'),
          )
        ],
      ),
    );
  }
}
