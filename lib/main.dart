import 'package:flutter/material.dart';

import 'views/HomeIndex.dart';
import 'views/ProductIndex.dart';
import 'views/StudyIndex.dart';
import 'views/UserIndex.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Widget> pages = List<Widget>();

  int _currentIndex = 0; // 当前 tab 页 索引

  void init() {
    print('init');
    pages..add(HomeIndex())..add(ProductIndex())..add(StudyIndex())..add(
        UserIndex());
    print('$pages');
  }

  var _pageController = PageController(initialPage: 0);

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
    return Scaffold(
      body: PageView.builder(
        onPageChanged: _pageChange,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          print('currentPage: $index');
          _currentIndex = index;
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
