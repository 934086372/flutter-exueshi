import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/EventBus.dart';
import 'package:flutter_exueshi/home/HomeIndex.dart';
import 'package:flutter_exueshi/product/ProductIndex.dart';
import 'package:flutter_exueshi/study/StudyIndex.dart';
import 'package:flutter_exueshi/user/UserIndex.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = List<Widget>(); // 主页页面
  int _currentIndex = 0; // 当前 tab 页 索引
  var _pageController = PageController(initialPage: 0);

  // 初始选择的地区以及考试项目数据
  Map initialSetting;

  void _pageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages
      ..add(HomeIndex())
      ..add(ProductIndex())
      ..add(StudyIndex())
      ..add(UserIndex());

    // 监听首页点击查看更多
    eventBus.on('changeMainTab', (arg) {
      _pageController.jumpToPage(1);
    });
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
}
