import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/components/Video.dart';
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

  int pageLoadStatus = 1;

  String userID;
  String prodID;
  String prodType;
  String type;
  String orderID;
  var lastStudyItem;

  var prodChapters;

  List videoList = new List();
  var activeVideoItem;
  var activeDocItem;
  var activePaperItem;
  int activeTabIndex = 0;
  var activeItem;
  String activeVideoUrl;

  TabController _tabController;

  VideoController videoController;

  bool showVideoPlayer = true;

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

    videoController = new VideoController();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        showVideoPlayer = _tabController.index == 0;
      });
    });
  }

  Future<void> _init() async {
    // 获取是否非WiFi情况下播放视频的配置
    SharedPreferences _pref = await SharedPreferences.getInstance();
    bool allowPlayNotWifi = _pref.getBool('allowPlayNotWifi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('目录'),
        centerTitle: true,
      ),
      body: renderPage(),
      backgroundColor: Colors.white,
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return buildBody(context);
        break;
      case 3:
        return Center(
          child: Text('数据加载失败'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络请求失败'),
        );
        break;
      case 5:
        return Center(
          child: Text('未登录'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  Widget buildBody(BuildContext context) {
    print(activeVideoUrl);

    Widget videoPlayer;
    // 视频播放地址还未赋值，处于加载状态
    if (activeVideoUrl == null) {
      videoPlayer = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoActivityIndicator(),
              Text(
                '加载中...',
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              )
            ],
          ));
    } else if (activeVideoUrl == '') {
      videoPlayer = Center(
          child: Text(
            '视频获取失败，请检查视频地址!',
            style: TextStyle(color: Colors.white),
          ));
    } else {
      print(activeVideoItem['videoName']);
      videoPlayer = new Video(
        url: activeVideoUrl,
        title: activeVideoItem['videoName'],
        videoController: videoController,
      );
    }

    if (type == 'package') {
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
              ? AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.black,
              child: videoPlayer,
            ),
          )
              : Container(),
          TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: Color.fromRGBO(51, 51, 51, 1),
              unselectedLabelColor: Color.fromRGBO(153, 153, 153, 1),
              indicatorWeight: 1.0),
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
                        Navigator.of(context).push(PageRouter(DocumentStudy()));
                      },
                    );
                  })
            ]),
          ),
          showVideoPlayer ? bottomBar() : Container()
        ],
      );
    } else {
      return Column(children: <Widget>[
        showVideoPlayer
            ? AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            color: Colors.black,
            child: videoPlayer,
          ),
        )
            : Container(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(prodChapters.length, (index) {
                // 判断是否有分组名称
                var category = prodChapters[index];
                var groupName = category['groupName'].toString();
                var childList = category['list'];
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
          ),
        ),
      ]);
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
            activeVideoItem = item;
            getVideoPlayUrl(item['videoID']);
            break;
          case '试卷':
            activePaperItem = item;
            Navigator.of(context).push(PageRouter(PaperIndex(
                prodID: prodID, paperID: item['paperID'], orderID: orderID)));
            break;
          case '资料':
            activeDocItem = item;
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
            child: Center(child: SwitchBtn()),
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
    return ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          var category = chapters[index];
          var groupName = category['groupName'].toString();
          var childList = category['list'];
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

  // 获取视频播放地址
  void getVideoPlayUrl(videoID) async {
    Ajax ajax = new Ajax(baseUrl: 'http://blank.exueshi.com');
    Response response =
    await ajax.post('/api/Vod/getplayurl', data: {'code': videoID});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret != null && ret['VideoBase'] != null) {
        activeVideoUrl = ret['PlayInfoList']['PlayInfo'][0]['PlayURL'];
      } else {
        activeVideoUrl = '';
      }
    } else {
      activeVideoUrl = '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // 获取产品目录数据
  Future<void> getProdInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      Map user = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response = await ajax.post('/api/Product/getProductLists',
          data: {
            'userID': user['userID'],
            'prodID': prodID,
            'type': type,
            'orderID': orderID
          });

      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          prodChapters = ret['data'];
          // 数据的初始化处理
          handleChapterData(prodChapters);
          // 抽离纯视频列表数据
          getVideoList();
          pageLoadStatus = 2;
        } else {
          pageLoadStatus = 3;
        }
      } else {
        pageLoadStatus = 4;
      }
    } else {
      pageLoadStatus = 5;
    }

    setState(() {});
  }

  // 预处理目录数据
  void handleChapterData(prodChapters) {
    if (lastStudyItem != null) {
      // 有上次学习记录
      if (type == 'package') {
        // 套餐产品，初始化为第一个目录项
        var videos = prodChapters['videos'];
        var documents = prodChapters['documents'];
        var papers = prodChapters['papers'];
        if (videos != null && videos != false) {
          activeVideoItem = videos[0]['list'][0];
        }
        if (documents != null && documents != false) {
          activeDocItem = documents[0]['list'][0];
        }
        if (papers != null && papers != false) {
          activePaperItem = papers[0]['list'][0];
        }
        switch (lastStudyItem['prodContentType']) {
          case '视频':
            videos.forEach((group) {
              group['list'].forEach((item) {
                if (item['videoID'] == lastStudyItem['prodContentID'])
                  activeVideoItem = item;
              });
            });
            showVideoPlayer = true;
            break;
          case '资料':
            documents.forEach((group) {
              group['list'].forEach((item) {
                if (item['docID'] == lastStudyItem['prodContentID'])
                  activeDocItem = item;
              });
            });
            showVideoPlayer = false;
            break;
          case '试卷':
            papers.forEach((group) {
              group['list'].forEach((item) {
                if (item['paperID'] == lastStudyItem['prodContentID'])
                  activePaperItem = item;
              });
            });
            showVideoPlayer = false;
            break;
        }
      } else {
        prodChapters.forEach((group) {
          group['list'].forEach((item) {
            if (item['type'] == lastStudyItem['prodContentType']) {
              if (item['videoID'] == lastStudyItem['prodContentID']) {
                activeVideoItem = item;
                showVideoPlayer = true;
              } else if (item['docID'] == lastStudyItem['prodContentID']) {
                activeDocItem = item;
                showVideoPlayer = false;
              } else if (item['paperID'] == lastStudyItem['prodContentID']) {
                activePaperItem = item;
                showVideoPlayer = false;
              }
            }
          });
        });
      }
    } else {
      if (type == 'package') {
        var videos = prodChapters['videos'];
        var documents = prodChapters['documents'];
        var papers = prodChapters['papers'];

        /*
        * 倒排方法进行初始赋值
        * 1. 默认显示存在的第一个Tab
        * 2. 默认显示存在第一个目录项
        *
        * */
        if (documents != null && documents != false) {
          activeDocItem = documents[0]['list'][0];
          activeTabIndex = 2;
          activeItem = documents[0]['list'][0];
          activeItem.addAll({'prodContentType': '资料'});
        }
        if (papers != null && papers != false) {
          activePaperItem = papers[0]['list'][0];
          activeTabIndex = 1;
          activeItem = papers[0]['list'][0];
          activeItem.addAll({'prodContentType': '试卷'});
        }
        if (videos != null && videos != false) {
          activeVideoItem = videos[0]['list'][0];
          activeTabIndex = 0;
          activeItem = videos[0]['list'][0];
          activeItem.addAll({'prodContentType': '视频'});
          showVideoPlayer = true;
        }
      } else {
        // 非套餐类产品
        activeItem = prodChapters[0]['list'][0];
        activeItem.addAll({'prodContentType': activeItem['type']});
        if (activeItem['type'] == '视频')
          activeVideoItem = activeItem;
        else if (activeItem['type'] == '试卷')
          activePaperItem = activeItem;
        else if (activeItem['type'] == '资料') activeDocItem = activeItem;
      }
    }

    // 判断当前激活视频目录项是否存在, 存在则进行初始化
    if (activeVideoItem != null) getVideoPlayUrl(activeVideoItem['videoID']);
  }

  // 获取目录列表中的视频数据
  void getVideoList() {
    if (type == 'package') {
      List _video = prodChapters['videos'];
      if (_video != null && _video.length > 0) {
        _video.forEach((group) {
          group['list'].forEach((item) {
            videoList.add(item);
          });
        });
      }
    } else {
      prodChapters.forEach((group) {
        group['list'].forEach((item) {
          if (item['type'] == '视频') {
            videoList.add(item);
          }
        });
      });
    }
  }
}

class SwitchBtn extends StatefulWidget {
  @override
  _SwitchBtnState createState() => _SwitchBtnState();
}

class _SwitchBtnState extends State<SwitchBtn> {
  bool isSelected = false;

  double iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isSelected
              ? Icon(
            MyIcons.like,
            size: iconSize,
            color: Color.fromRGBO(68, 68, 68, 1),
          )
              : Icon(
            MyIcons.like_border,
            size: iconSize,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Text('收藏'),
          )
        ],
      ),
    );
  }
}
