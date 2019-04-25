import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/index/InitialSetting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  int _currentBootPageIndex = 0; // 引导页的当前序号

  List projectList = new List();
  List areaList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
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
                navigateToMain();
              },
            ),
            top: 40.0,
            right: 30.0,
          ),
          Positioned(
            child: renderSkipBtn(),
            bottom: 80.0,
            width: MediaQuery.of(context).size.width,
          )
        ]),
      ),
    );
  }

  Widget renderSkipBtn() {
    if (_currentBootPageIndex != 3) return Container();
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
          navigateToMain();
        },
      ),
    );
  }

  void navigateToMain() async {
    // 记录用户已经第一次进入了应用
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setBool('isFirstUsse', false);
    // 导航到主页
    Navigator.of(context).push(PageRouter(InitialSetting(
      projectList: projectList,
      areaList: areaList,
    )));
  }

  void getProfileData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String productFilterData = _pref.getString('productFilterData');
    List profile = json.decode(productFilterData);
    profile.forEach((item) {
      if (item['value'] == 'catName') {
        projectList = item['data'];
      } else if (item['value'] == 'area') {
        areaList = item['data'];
      }
    });
    setState(() {});
  }
}
