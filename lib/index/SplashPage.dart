import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/index/GuidePage.dart';
import 'package:flutter_exueshi/index/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // 闪屏广告时长，单位：秒
  int countdown = 3;

  // 闪屏倒计时计时器
  Timer timer;

  // 是否第一次使用
  bool isFirstUse;

  // 初始选择的地区以及考试项目数据
  Map initialSetting;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 获取初始数据
    getInitialData();

    // 闪屏广告倒计时
    timer = Timer.periodic(Duration(seconds: 1), (_timer) {
      setState(() {
        countdown--;
      });
      if (countdown <= 0) {
        _timer.cancel();
        if (isFirstUse == null || isFirstUse == true) {
          // 初次使用，进入引导页
          Navigator.of(context).push(PageRouter(GuidePage()));
        } else {
          // 非初次，进入主页
          Navigator.of(context).push(PageRouter(MainPage()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
              onTap: () async {
                timer.cancel();
                await Navigator.of(context).push(PageRouter(Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: true,
                    elevation: 0.5,
                  ),
                  body: WebView(
                    initialUrl: 'https://flutter.io',
                    javaScriptMode: JavaScriptMode.unrestricted,
                  ),
                )));
                // 此处进入主界面不再使用滑动进入动画
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MainPage();
                }));
              },
              child: Image.asset('assets/images/splash_ad.jpg',
                  fit: BoxFit.fitWidth)),
          Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    color: Color.fromRGBO(0, 0, 0, 0.5)),
                child: Text(
                  countdown.toString() + 's',
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ],
      ),
    );
  }

  // 获取应用初始化数据
  void getInitialData() async {
    // 获取本地缓存数据
    SharedPreferences _pref = await SharedPreferences.getInstance();

    isFirstUse = _pref.getBool('isFirstUse');

    String _initialSetting = _pref.getString('initialSetting');
    if (_initialSetting != null) initialSetting = json.decode(_initialSetting);

    Ajax ajax = new Ajax();
    var userData = _pref.get('userData');
    if (userData == null) return;
    var user = json.decode(userData);
    Response response = await ajax.post('/api/user/getMainData',
        data: {'userID': user['userID'], 'token': user['data']});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        var data = ret['data'];
        _pref.setInt('cartCount', data['prodCount']);
      }
    }

    Response response2 = await ajax.post('/api/Product/getProdFilter');
    if (response2.statusCode == 200) {
      if (response2.data['code'].toString() == '200') {
        _pref.setString(
            'productFilterData', json.encode(response2.data['data']));
      }
    }

    Response response3 = await ajax.post('/api/User/getCities');
    if (response3.statusCode == 200) {
      if (response3.data['code'].toString() == '200') {
        _pref.setString('cityData', json.encode(response3.data['data']));
      }
    }

    setState(() {});
  }
}
