import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/SlideListTile.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
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
        elevation: 1.0,
        title: Text('消息中心'),
        centerTitle: true,
      ),
      body: renderPage(),
      backgroundColor: Colors.white,
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
              return renderItem(item);
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

  Widget renderItem(item) {
    return SlideListTile(
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: Row(
            children: <Widget>[
              Text(
                '【' + item['optType'] + '】',
                style: TextStyle(color: Color.fromRGBO(0, 149, 219, 1)),
              ),
              Expanded(
                child: Text(
                  item['noticeTitle'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item['publishTime'].toString().substring(0, 10),
                style: TextStyle(
                    fontSize: 14.0, color: Color.fromRGBO(153, 153, 153, 1)),
              )
            ],
          ),
          subtitle: Text(item['noticeContent']),
          onTap: () {
            Navigator.of(context).push(PageRouter(MyMessageDetail(item: item)));
          },
        ),
      ),
      menu: <Widget>[],
    );
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

class MyMessageDetail extends StatefulWidget {
  final item;

  const MyMessageDetail({Key key, this.item}) : super(key: key);

  @override
  _MyMessageDetailState createState() => _MyMessageDetailState();
}

class _MyMessageDetailState extends State<MyMessageDetail> {
  get item => widget.item;

  var detailData;

  int pageLoadStatus = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text('消息详情'),
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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(226, 226, 226, 1)))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      detailData['noticeTitle'],
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                    ),
                    Text(detailData['publishTime'],
                        style: TextStyle(
                            color: Color.fromRGBO(153, 153, 153, 1),
                            fontSize: 12.0)),
                  ],
                ),
              ),
              HtmlView(data: detailData['noticeContent'])
            ],
          ),
        );
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

  // 获取消息详情
  void getDetail() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response = await ajax.post('/api/user/sysnotice/info', data: {
        'userID': userData['userID'],
        'token': userData['token'],
        'noticeID': item['noticeID'],
        'type': item['type']
      });
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          detailData = ret['data'];
          print(detailData);
          pageLoadStatus = 2;
        } else {
          detailData = [];
          pageLoadStatus = 3;
        }
      } else {
        detailData = false;
        pageLoadStatus = 4;
      }
    }
    setState(() {});
  }
}
