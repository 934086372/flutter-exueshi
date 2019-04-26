import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/Video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivingRoom extends StatefulWidget {
  final product;

  const LivingRoom({Key key, this.product}) : super(key: key);

  @override
  _LivingRoomState createState() => _LivingRoomState();
}

class _LivingRoomState extends State<LivingRoom> {
  get product => widget.product;

  int pageLoadStatus = 1;
  String _channelID;
  var liveDetail;

  VideoController videoController = new VideoController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(product);
    _channelID = product['channelID'];
    getLiveDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          centerTitle: true,
          title: Text('直播间'),
        ),
        body: renderPage());
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        String liveUrl = liveDetail['m3u8Url'];
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Video(
                      url: liveUrl,
                      isLive: true,
                      videoController: videoController,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      case 3:
        return Center(
          child: Text('无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络错误'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  // 获取直播详情
  void getLiveDetail() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var user = json.decode(_prefs.getString('userData'));
    var userID = user['userID'];

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Live/getLive',
        data: {'channelID': _channelID, 'userID': userID});

    print(response);
    int _status = 1;
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        liveDetail = ret['data'];
        _status = 2;
      } else {
        print(ret['msg']);
        _status = 3;
      }
    } else {
      _status = 4;
      print('网络请求错误');
    }

    setState(() {
      pageLoadStatus = _status;
    });
  }
}
