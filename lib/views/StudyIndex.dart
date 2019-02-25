import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/study/ProductContent.dart';
import 'package:flutter_exueshi/study/StudyManage.dart';
import 'package:flutter_exueshi/study/VideoPlayer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<StudyIndex>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  var _pageLoadingStatus = 1;

  var studyingList = [];
  var studiedList = [];

  var userID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getMyStudyList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 0.0,
        leading: Container(
          width: 100,
          child: MaterialButton(
            child: Row(
              children: <Widget>[
                Text(
                  '全部',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14.0,
                  color: Colors.white,
                )
              ],
            ),
            padding: EdgeInsets.only(left: 10.0),
            onPressed: () {
              print('点击了类型筛选');
              showMenu(
                  context: context,
                  items: <PopupMenuEntry>[
                    PopupMenuItem(child: Text('全部')),
                    PopupMenuItem(child: Text('产品')),
                    PopupMenuItem(child: Text('视频')),
                    PopupMenuItem(child: Text('资料')),
                    PopupMenuItem(child: Text('试卷'))
                  ],
                  position: RelativeRect.fromLTRB(
                      0,
                      kToolbarHeight + MediaQuery
                          .of(context)
                          .padding
                          .top,
                      0,
                      0),
                  elevation: 5.0);
            },
          ),
        ),
        centerTitle: true,
        title: Text('我的学习'),
        actions: <Widget>[
          InkWell(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Center(
                child: Text(
                  '管理',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onTap: () {
              print('点击了管理');
              Navigator.of(context).push(CustomRoute(
                  StudyManage(studyingList: studyingList, userID: userID)));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: TabBar(
              tabs: <Tab>[
                Tab(
                  text: '我的学习',
                ),
                Tab(text: '学习完成'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              controller: _tabController,
            ),
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          Expanded(
            child: _renderPage(),
          ),
        ],
      ),
    );
  }

  Widget _renderPage() {
    switch (_pageLoadingStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _tabController,
          children: <Widget>[
            _studyingList(),
            _studiedList(),
          ],
        );
        break;
      case 3:
        return Center(
          child: Text('暂无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络错误'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
        break;
    }
  }

  Widget _studyingList() {
    // 判断是否有课程
    if (studyingList.toString() == [].toString()) {
      return Center(
        child: Text('空'),
      );
    } else {
      return RefreshIndicator(
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 10.0),
              itemCount: studyingList.length,
              itemBuilder: (context, index) {
                return _renderCourseItem(studyingList[index], context);
              }),
          onRefresh: _refreshStudyingList);
    }
  }

  Widget _studiedList() {
    // 判断是否有课程
    if (studiedList.toString() == [].toString()) {
      return Center(
        child: Text('暂无已学完课程'),
      );
    } else {
      return RefreshIndicator(
        child: ListView.builder(
            padding: EdgeInsets.only(top: 10.0),
            itemCount: studiedList.length,
            itemBuilder: (context, index) {
              return _renderCourseItem(studiedList[index], context);
            }),
        onRefresh: _refreshStudiedList,
      );
    }
  }

  // 渲染列表中的单个课程产品项
  Widget _renderCourseItem(item, context) {
    return Container(
      height: 100.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            print('点击课程');
            Navigator.of(context).push(CustomRoute(ProductContent(
              product: item,
            )));
          },
          child: Row(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16.0 / 10.0,
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      ClipRRect(
                        child: Center(
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: item['logo'],
                              fit: BoxFit.cover,
                            )),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      Container(
                        child: Text(
                          item['prodStatus'],
                          style: TextStyle(color: Colors.white, fontSize: 11.0),
                        ),
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                        padding: EdgeInsets.only(
                            left: 4.5, top: 2.0, right: 4.5, bottom: 2.0),
                      ),
                    ],
                  ),
                  height: 100.0,
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                            item['prodName'],
                            style: TextStyle(color: Colors.black),
                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          )),
                      _lastStudyItem(item['lastStudyItem']),
                      _validShow(item),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _validShow(item) {
    var _text;
    switch (item['validType']) {
      case '永久':
        _text = '永久有效';
        break;
      case '时间段':
        _text = item['validEndTime'] + ' 前有效';
        break;
      case '天数':
      // 使用支付时间 + 有效天数
        DateTime _payTime = DateTime.parse(item['payTime']);
        print(_payTime);
        DateTime _validEndTime =
        _payTime.add(Duration(days: item['validDays']));
        print(_validEndTime);
        _text = _payTime.year.toString() +
            '-' +
            _payTime.month.toString() +
            '-' +
            _payTime.day.toString() +
            ' 前有效';
        break;
    }

    Color _color = Color.fromRGBO(102, 102, 102, 1);
    if (item['prodStatus'] == '预售中' || item['validType'] == '永久') {
      _color = Color.fromRGBO(255, 102, 0, 1);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Text(_text, style: TextStyle(fontSize: 12.0, color: _color)),
    );
  }

  // 上次学习锚点
  Widget _lastStudyItem(lastItem) {
    if (lastItem.toString() == [].toString()) {
      // 无上次学习记录
      return Container();
    } else {
      IconData _icon;
      switch (lastItem['prodContentType']) {
        case '视频':
          _icon = MyIcons.video;
          break;
        case '资料':
          _icon = MyIcons.document;
          break;
        case '试卷':
          _icon = MyIcons.paper;
          break;
      }

      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              _icon,
              color: Color.fromRGBO(0, 145, 219, 0.6),
              size: 20.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  lastItem['prodContentName'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.0, color: Color.fromRGBO(153, 153, 153, 1)),
                ),
              ),
            ),
          ]);
    }
  }

  // 获取我的课程列表
  Future _getMyStudyList() async {
    Completer _completer = new Completer();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var user = json.decode(_prefs.getString('userData'));

    userID = user['userID'];

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/product/getStuProducts', data: {
      "userID": user['userID'],
      "page": 1,
      "studyStatus": '正在学习',
      "type": '全部',
      "num": 500
    });

    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        studyingList = ret['data'];
      } else {
        studyingList = [];
      }
    }

    Response response2 = await ajax.post('/api/product/getStuProducts', data: {
      "userID": user['userID'],
      "page": 1,
      "studyStatus": '学习完成',
      "type": '全部',
      "num": 500
    });

    if (response2.statusCode == 200) {
      var ret = response2.data;
      if (ret['code'].toString() == '200') {
        studiedList = ret['data'];
      } else {
        studiedList = [];
      }
    }

    setState(() {
      _pageLoadingStatus = 2;
    });

    _completer.complete(user);
    return _completer.future;
  }

  Future _refreshStudyingList() async {
    Completer _completer = new Completer();
    _getMyStudyList();
    await Future.delayed(Duration(seconds: 2), () {
      _completer.complete(null);
    });
    return _completer.future;
  }

  Future _refreshStudiedList() async {
    Completer _completer = new Completer();
    _getMyStudyList();
    await Future.delayed(Duration(seconds: 2), () {
      _completer.complete(null);
    });
    return _completer.future;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
