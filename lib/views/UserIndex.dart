import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/user/About.dart';
import 'package:flutter_exueshi/user/Help.dart';
import 'package:flutter_exueshi/user/MyAddress.dart';
import 'package:flutter_exueshi/user/MyCoupon.dart';
import 'package:flutter_exueshi/user/MyOrder.dart';
import 'package:flutter_exueshi/user/MyPhone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

class UserIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<UserIndex> with AutomaticKeepAliveClientMixin {
  int pageLoadStatus = 0;
  var userData;

  var dataCount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  void _init() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userData = _prefs.getString('userData');
    if (_userData != null) {
      userData = json.decode(_userData);

      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      String deviceID;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        print(androidInfo.androidId);
        deviceID = androidInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceID = iosDeviceInfo.identifierForVendor;
      }

      Ajax ajax = new Ajax();
      Response response = await ajax.post('/api/User/getUserCenterStatus',
          data: {'userID': userData['userID'], 'deviceID': deviceID});

      if (response.statusCode == 200) {
        var ret = response.data;
        print(ret);
        if (ret['code'].toString() == '200') {
          dataCount = ret['data'];
        }
      }
    } else {
      // 未登录
    }
    setState(() {
      pageLoadStatus = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('个人中心'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.message), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: renderPage(),
      backgroundColor: Colors.white,
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 0:
        return Center(child: CircularProgressIndicator());
        break;
      case 1:
        print(userData);
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage:
                      NetworkImage(userData['portrait']) == null
                          ? AssetImage('assets/images/avator.jpg')
                          : NetworkImage(userData['portrait']),
                      minRadius: 37.5,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userData['nickName'],
                            style:
                            TextStyle(color: Colors.black, fontSize: 17.0),
                          ),
//                      Text('好嗨哟，感觉人生已经达到了高潮'),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  size: 14.0,
                                  color: Color.fromRGBO(153, 153, 153, 1),
                                ),
                                Text(
                                  userData['city'].toString(),
                                  style: TextStyle(
                                      color: Color.fromRGBO(153, 153, 153, 1)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                ),
                                Icon(
                                  Icons.phone_android,
                                  size: 14.0,
                                  color: Color.fromRGBO(153, 153, 153, 1),
                                ),
                                Text(
                                  userData['telephone'].toString(),
                                  style: TextStyle(
                                      color: Color.fromRGBO(153, 153, 153, 1)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                child: Container(
                  child: Row(children: <Widget>[
                    _rowItem(0),
                    _rowItem(1),
                    _rowItem(2),
                  ]),
                ),
              ),
              Platform.isIOS
                  ? ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Color.fromRGBO(255, 68, 68, 1),
                ),
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '我的余额',
                        style: TextStyle(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '600.00',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 68, 68, 1),
                          fontSize: 18.0),
                    )
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              )
                  : Container(),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('我的订单'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('order');
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text('优惠券'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('coupon');
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('地址管理'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('address');
                },
              ),
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('绑定手机号'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('phone');
                },
              ),
              ListTile(
                leading: Icon(Icons.question_answer),
                title: Text('帮助与反馈'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('help');
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('关于我们'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  routerManage('about');
                },
              ),
            ],
          ),
        );
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  Widget _rowItem(index) {
    var icon;
    var label;
    var count;
    switch (index) {
      case 0:
        count = dataCount['noteCount'];
        icon = Icons.edit;
        label = '笔记';
        break;
      case 1:
        count = dataCount['mistakesCount'];
        icon = Icons.library_books;
        label = '错题集';
        break;
      case 2:
        count = dataCount['collectionCount'];
        icon = Icons.favorite_border;
        label = '收藏';
        break;
    }
    return Expanded(
      child: FlatButton(
          padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
          onPressed: () {},
          child: Column(
            children: <Widget>[
              Text(
                count.toString(),
                style: TextStyle(fontSize: 27.0),
              ),
              Container(
                margin: EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 13.0,
                      color: Color.fromRGBO(153, 153, 153, 1),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                          fontSize: 13.0,
                          color: Color.fromRGBO(153, 153, 153, 1)),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  void routerManage(item) {
    switch (item) {
      case 'order':
        Navigator.of(context).push(CustomRoute(MyOrder()));
        break;
      case 'coupon':
        Navigator.of(context).push(CustomRoute(MyCoupon()));
        break;
      case 'address':
        Navigator.of(context).push(CustomRoute(MyAddress()));
        break;
      case 'phone':
        Navigator.of(context).push(CustomRoute(MyPhone()));
        break;
      case 'help':
        Navigator.of(context).push(CustomRoute(Help()));
        break;
      case 'about':
        Navigator.of(context).push(CustomRoute(About()));
        break;
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
