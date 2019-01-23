import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'views/HomeIndex.dart';
import 'views/ProductIndex.dart';
import 'views/StudyIndex.dart';
import 'views/UserIndex.dart';

void main() {
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
  final Color _themeColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '易学仕在线',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: _themeColor,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

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

  void init() {
    pages..add(HomeIndex())..add(ProductIndex())..add(StudyIndex())..add(
        UserIndex());
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder(
        future: _getPreference(),
        builder: (context, snapshot) {
          print('alreadyUse: $alreadyUse');
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
    alreadyUse = prefs.getString('AlreadyUse') ?? 'no';
    return prefs.getString('AlreadyUse') ?? 'no';
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
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Stack(children: <Widget>[
            Swiper(
                loop: false,
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  String imagePath =
                      'images/boot/start_0' + (index + 1).toString() + '.jpg';
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
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
            )
          ]),
        ));
  }

  // 主页
  Widget _mainView() {
    return Scaffold(
      body: PageView.builder(
        pageSnapping: true,
        onPageChanged: _pageChange,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          return pages.elementAt(index);
        },
        itemCount: 4,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.black26,
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.blue,
              ),
              title: Text('首页')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.apps,
                color: Colors.black26,
              ),
              activeIcon: Icon(
                Icons.apps,
                color: Colors.blue,
              ),
              title: Text('选课中心')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.edit,
                color: Colors.black26,
              ),
              activeIcon: Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              title: Text('我的学习')),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color: Colors.black26,
              ),
              activeIcon: Icon(
                Icons.person_outline,
                color: Colors.blue,
              ),
              title: Text('个人中心'))
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(_currentIndex);
          });
        },
      ),
    );
  }
}
