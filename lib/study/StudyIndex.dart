import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/components/SlideSheet.dart';
import 'package:flutter_exueshi/sign/Login.dart';
import 'package:flutter_exueshi/study/ProductContent.dart';
import 'package:flutter_exueshi/study/StudyManage.dart';
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

  var pageLoadStatus = 1;

  var studyingList = [];
  var studiedList = [];

  var userID;

  String type = '全部';
  List menu = ['全部', '产品', '资料', '试卷', '视频'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getMyStudyList();
  }

  @override
  void didUpdateWidget(StudyIndex oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print(type);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('我的学习'),
        elevation: 0.0,
        leading: renderLeftMenu(),
        actions: <Widget>[renderRightMenu()],
      ),
      body: renderPage(),
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
        return Column(
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
              child: TabBarView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _tabController,
                children: <Widget>[
                  _studyingList(),
                  _studiedList(),
                ],
              ),
            ),
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
      case 5:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  '登录后查看更多内容',
                  style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
                ),
              ),
              GestureDetector(
                onTap: gotoLogin,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  child: Text(
                    '立即登录',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
        break;
    }
  }

  Widget renderLeftMenu() {
    if (pageLoadStatus != 2) return Container();

    return Container(
      width: 100,
      child: MaterialButton(
        child: Row(
          children: <Widget>[
            Text(
              type,
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14.0,
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10.0),
        onPressed: () {
          double paddingTop =
              kToolbarHeight + MediaQuery
                  .of(context)
                  .padding
                  .top;
          SlideSheet.show(
              context,
              paddingTop,
              Container(
                color: Color.fromRGBO(251, 251, 251, 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(menu.length, (index) {
                    return renderMenuItem(menu[index]);
                  }),
                ),
              ));
        },
      ),
    );
  }

  Widget renderMenuItem(text) {
    bool isSelected = type == text;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      color:
                      isSelected ? Colors.blue : Color.fromRGBO(51, 51, 51, 1)),
                )),
            isSelected
                ? Icon(
              Icons.check,
              size: 20.0,
              color: Colors.blue,
            )
                : Container()
          ],
        ),
      ),
      onTap: () {
        pageLoadStatus = 1;
        type = text;
        SlideSheet.dismiss();
        setState(() {});
        _getMyStudyList();
      },
    );
  }

  Widget renderRightMenu() {
    if (pageLoadStatus != 2) return Container();
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Center(
          child: Text(
            '管理',
          ),
        ),
      ),
      onTap: () {
        print('点击了管理');
        Navigator.of(context).push(PageRouter(
            StudyManage(studyingList: studyingList, userID: userID)));
      },
    );
  }

  Widget _studyingList() {
    // 判断是否有课程
    if (studyingList.toString() == [].toString())
      return Center(
        child: Text('空'),
      );

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
            Navigator.of(context).push(PageRouter(ProductContent(
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
  void _getMyStudyList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user == null) {
      setState(() {
        pageLoadStatus = 5;
      });
      return;
    }

    var user = json.decode(_user);
    userID = user['userID'];

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/product/getStuProducts', data: {
      "userID": user['userID'],
      "page": 1,
      "studyStatus": '正在学习',
      "type": type,
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
      "type": type,
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
      pageLoadStatus = 2;
    });
  }

  void gotoLogin() async {
    await Navigator.of(context).push(PageRouter(Login()));
    setState(() {
      _getMyStudyList();
    });
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
