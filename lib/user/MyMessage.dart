import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMessage extends StatefulWidget {
  @override
  _MyMessageState createState() => _MyMessageState();
}

class _MyMessageState extends State<MyMessage> {
  int pageLoadStatus = 1;

  var messageList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessageList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('消息中心'),
        centerTitle: true,
      ),
      body: renderPage(),
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return ListView.builder(
            itemCount: messageList.length,
            itemBuilder: (context, index) {
              var item = messageList[index];
              return ListTile(
                title: Text(item['noticeTitle'].toString()),
              );
            });
        break;
      case 3:
        return Center(
          child: Text('暂无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络请求错误'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  void getMessageList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response = await ajax.post('/api/user/sysnotice/user/Notices',
          data: {
            'userID': userData['userID'],
            'token': userData['token'],
            'page': 1,
            'num': 500
          });
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          messageList = ret['data'];
          pageLoadStatus = 2;
        } else {
          messageList = [];
          pageLoadStatus = 3;
        }
      } else {
        messageList = false;
        pageLoadStatus = 4;
      }
    }
    setState(() {});
  }
}
