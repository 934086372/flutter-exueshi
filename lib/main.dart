import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_exueshi/home/HomeIndex.dart';
import 'package:flutter_exueshi/product/ProductIndex.dart';
import 'package:flutter_exueshi/study/StudyIndex.dart';
import 'package:flutter_exueshi/user/UserIndex.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

/*
* 针对andorid 设置状态栏全透明
*
* 在android的主入口文件处设置
*
* public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
    {
         // api大于21设置状态栏透明
        getWindow().setStatusBarColor(0);
    }
    GeneratedPluginRegistrant.registerWith(this);
  }
}
*
* */

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '易学仕在线',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentBootPageIndex = 0; // 引导页的当前序号

  List<Widget> pages = List<Widget>(); // 主页页面
  int _currentIndex = 0; // 当前 tab 页 索引
  var _pageController = PageController(initialPage: 0);

  String alreadyUse;

  EventBus eventBus = new EventBus();

  void init() {
    pages
      ..add(HomeIndex())
      ..add(ProductIndex())
      ..add(StudyIndex())
      ..add(UserIndex());

    eventBus.on().listen((event) {
      print(event);
      if (event == 'changeMainTab') {
        setState(() {
          _currentIndex = 1;
        });
      }
    });
  }

  void _pageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPreference(),
        builder: (context, snapshot) {
          // 判断是否已经使用
          if (alreadyUse == 'yes') {
            return _mainView();
          } else {
            return _bootView();
          }
        });
  }

  // 获取用户是否已经使用过的状态
  _getPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    alreadyUse = prefs.getString('AlreadyUse') ?? 'no'; // 首次使用记录数据
  }

  _setPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('AlreadyUse', 'yes');
  }

  // 跳转
  Widget _useBtn() {
    if (_currentBootPageIndex == 3) {
      return Center(
        child: GestureDetector(
          child: Container(
            padding:
                EdgeInsets.only(left: 20.0, top: 8.0, right: 20.0, bottom: 8.0),
            child: Text(
              '马上使用',
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 145, 233, 0.85),
            ),
          ),
          onTap: () {
            _navigationToMain();
          },
        ),
      );
    } else {
      return Text('');
    }
  }

  // 导航到主页
  _navigationToMain() {
    _setPreference();
    setState(() {
      alreadyUse = 'yes';
    });
  }

  // 首次使用的宣传页
  Widget _bootView() {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(children: <Widget>[
        Swiper(
            loop: false,
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              String imagePath = 'assets/images/boot/start_0' +
                  (index + 1).toString() +
                  '.jpg';
              return Image.asset(
                imagePath,
                fit: BoxFit.fill,
              );
            },
            onIndexChanged: (int index) {
              setState(() {
                _currentBootPageIndex = index;
              });
            }),
        Positioned(
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.only(
                  left: 10.0, top: 2.0, right: 10.0, bottom: 2.0),
              child: Text(
                '跳过',
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
            ),
            onTap: () {
              _navigationToMain();
            },
          ),
          top: 40.0,
          right: 30.0,
        ),
        Positioned(
          child: _useBtn(),
          bottom: 80.0,
          width: MediaQuery.of(context).size.width,
        )
      ]),
    ));
  }

  // 主页
  Widget _mainView() {
    return Scaffold(
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
                  title: Text('首页')),
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
                  title: Text('选课中心')),
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
                  title: Text('我的学习')),
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
                  title: Text('个人中心'))
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
    );
  }
}
