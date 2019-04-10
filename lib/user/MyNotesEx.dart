import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/Exercise.dart';
import 'package:flutter_exueshi/components/Watermark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNotesEx extends StatefulWidget {
  final Map item;

  const MyNotesEx({Key key, this.item}) : super(key: key);

  @override
  _MyNotesExState createState() => _MyNotesExState();
}

class _MyNotesExState extends State<MyNotesEx> {
  Map get item => widget.item;

  int pageLoadStatus = 1;

  Map exData;
  List noteMine;
  List noteStar;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(item);
    getExData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        centerTitle: true,
        title: Text('查看习题'),
      ),
      body: renderPage(),
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return renderBody();
        break;
      case 3:
        return Center(
          child: Text('未找到数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络请求错误'),
        );
        break;
      case 5:
        return Center(
          child: Text('未登录'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  Widget renderBody() {
    return Watermark(
      subTitle: '15310486021',
      widget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Exercise(
              item: exData,
            ),
            renderNoteList('我的笔记'),
            renderNoteList('精选笔记'),
          ],
        ),
      ),
    );
  }

  // 渲染笔记列表
  Widget renderNoteList(type) {
    List data = type == '我的笔记' ? noteMine : noteStar;
    print(data);

    if (data == null || data.length <= 0) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10.0),
          padding: EdgeInsets.all(10.0),
          child: Text(
            type,
            style: TextStyle(
                fontSize: 16.0,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontWeight: FontWeight.w700),
          ),
        ),
        Column(
          children: List.generate(data.length, (index) {
            return type == '我的笔记'
                ? renderMyNoteItem(data[index])
                : renderStarNoteItem(data[index]);
          }),
        ),
      ],
    );
  }

  Widget renderMyNoteItem(item) {
    print(item);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.access_time,
                size: 22.0,
              ),
              Expanded(child: Text(item['createTime'])),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(item['likeCount'].toString()),
              ),
              Icon(
                Icons.favorite_border,
                size: 16.0,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, top: 10.0, right: 10.0),
            child: Text(
              item['remark'],
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
          )
        ],
      ),
    );
  }

  Widget renderStarNoteItem(item) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                child: Image.network(item['portrait']),
              ),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Text(item['userName']),
                  Text(item['createTime']),
                ],
              )),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(item['likeCount'].toString()),
              ),
              Icon(Icons.favorite_border)
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, top: 10.0, right: 10.0),
            child: Text(
              item['remark'],
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
          )
        ],
      ),
    );
  }

  void getExData() async {
    Ajax ajax = new Ajax();

    Response response1 =
        await ajax.post('/api/StudyPaper/getShareExericse', data: {
      'exerciseID': item['exerciseID'],
      'groupID': item['exerciseID'],
    });

    if (response1.statusCode == 200) {
      Map ret = response1.data;
      print(ret);
      if (ret['code'].toString() == '200') {
        exData = ret['data'];
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
        setState(() {});
        return;
      }
    } else {
      pageLoadStatus = 4;
      setState(() {});
      return;
    }

    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _user = _pref.getString('userData');
    if (_user != null) {
      Map user = json.decode(_user);
      Response response2 = await ajax.post(
          '/api/ExerciseNotes/findUserExerciseNotes',
          data: {'userID': user['userID'], 'exerciseID': item['exerciseID']});
      Response response3 = await ajax
          .post('/api/exerciseNotes/findFeaturedExerciseNotes', data: {
        'userID': user['userID'],
        'exerciseID': item['exerciseID'],
        'page': 1,
        'num': 50
      });
      if (response2.statusCode == 200) {
        Map ret2 = response2.data;
        if (ret2['code'].toString() == '200') {
          noteMine = ret2['data'];
        } else {}
      }
      if (response3.statusCode == 200) {
        Map ret3 = response3.data;
        if (ret3['code'].toString() == '200') {
          noteStar = ret3['data'];
        } else {}
      }
    }
    setState(() {});
  }
}
