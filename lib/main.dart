import 'package:flutter/material.dart';
import 'package:flutter_exueshi/index/SplashPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  /*
  * 进入应用需经过的顺序
  *
  * 1. 启动页，在android，ios目录下分别进行设置，避免应用白屏
  *
  * 2. 闪屏广告
  *
  * 3. 引导页，根据用户是否第一次打开应用
  *
  * 4. 初始设置页，根据用户是否第一次打开应用
  *
  * */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '易学仕在线',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
      ),
      home: SplashPage(),
    );
  }
}
