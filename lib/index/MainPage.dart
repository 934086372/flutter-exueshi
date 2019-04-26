import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/EventBus.dart';
import 'package:flutter_exueshi/components/ModalDialog.dart';
import 'package:flutter_exueshi/home/HomeIndex.dart';
import 'package:flutter_exueshi/index/UpdateApp.dart';
import 'package:flutter_exueshi/product/ProductIndex.dart';
import 'package:flutter_exueshi/study/StudyIndex.dart';
import 'package:flutter_exueshi/user/UserIndex.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  List<Widget> pages = List<Widget>(); // 主页页面
  int _currentIndex = 0; // 当前 tab 页 索引
  var _pageController = PageController(initialPage: 0);

  // 初始选择的地区以及考试项目数据
  Map initialSetting;

  Map updateInfo;
  List popupWinList;

  void _pageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages..add(HomeIndex())..add(ProductIndex())..add(StudyIndex())..add(UserIndex());

    // 监听首页点击查看更多
    eventBus.on('changeMainTab', (arg) {
      _pageController.jumpToPage(1);
    });

    initialCheck();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _tabText = TextStyle(fontSize: 12.0);

    DateTime _lastTapBackBtnTime;

    // 添加返回拦截
    return WillPopScope(
      onWillPop: () async {
        if (_lastTapBackBtnTime == null ||
            DateTime.now().difference(_lastTapBackBtnTime) >
                Duration(seconds: 1)) {
          _lastTapBackBtnTime = DateTime.now();
          return false;
        } else {
          // 此处添加进入后台方法
        }
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                pageSnapping: true,
                onPageChanged: _pageChange,
                controller: _pageController,
                itemBuilder: (BuildContext context, int index) {
                  return pages.elementAt(index);
                },
                itemCount: 4,
              ),
            ),
            CupertinoTabBar(
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.8),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      color: Colors.black26,
                      size: 24,
                    ),
                    activeIcon: Icon(
                      Icons.home,
                      color: Colors.blue,
                      size: 24,
                    ),
                    title: Text(
                      '首页',
                      style: _tabText,
                    )),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.apps,
                      color: Colors.black26,
                      size: 24,
                    ),
                    activeIcon: Icon(
                      Icons.apps,
                      color: Colors.blue,
                      size: 24,
                    ),
                    title: Text('选课中心', style: _tabText)),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.black26,
                      size: 24,
                    ),
                    activeIcon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 24,
                    ),
                    title: Text('我的学习', style: _tabText)),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.black26,
                      size: 24,
                    ),
                    activeIcon: Icon(
                      Icons.person_outline,
                      size: 24,
                      color: Colors.blue,
                    ),
                    title: Text('个人中心', style: _tabText))
              ],
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(_currentIndex);
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget renderPopupWindow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 15.0),
            child: Image.network(popupWinList[0]['msgPicture'])),
        GestureDetector(
          onTap: () {
            ModalDialog.dismiss();
          },
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.7),
                shape: BoxShape.circle),
            child: Icon(
              Icons.close,
              color: Color.fromRGBO(0, 0, 0, 0.3),
            ),
          ),
        ),
      ],
    );
  }

  /*
  * APP 初始检测
  * */
  void initialCheck() async {
    /*
    * 主界面所需数据
    *
    * 1. 新版本检测，第一优先级
    *
    * 2. 弹窗消息检测，第二优先级
    *
    * 3. 优惠券到期检测，第三优先级
    *
    * */

    String systemType = Platform.operatingSystem;
    String currentVersion = '0.0.0';

    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _initialSetting = _pref.getString('initialSetting');
    Map initialSetting = json.decode(_initialSetting);
    String area = initialSetting['area'];

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/app/check/newVersion',
        data: {'systemType': systemType, 'currentVersion': currentVersion});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        setState(() {
          updateInfo = ret['data'];
        });
        showWindow();
        return;
      }
    }

    Response response2 = await ajax
        .post('/api/app/messagepopup/findMessagePopup', data: {'area': area});
    if (response.statusCode == 200) {
      var ret = response2.data;
      if (ret['code'].toString() == '200') {
        popupWinList = ret['data'];
      }
    }

    String _user = _pref.getString('userData');
    if (_user != null) {
      Map userData = json.decode(_user);
      Response response3 = await ajax.post('/api/coupon/getUserExpiredCoupons',
          data: {'userID': userData['userID']});
      if (response3.statusCode == 200) {
        print(response3);
      }
    }

    setState(() {});
  }

  void showWindow() {
    ModalDialog.show(context, (context) {
      double maxWidth = MediaQuery
          .of(context)
          .size
          .width * 0.8;
      double maxHeight = MediaQuery
          .of(context)
          .size
          .height * 0.8;

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: UpdateApp(
          updateInfo: updateInfo,
        ),
      );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
