import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/user/MyNotesEx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNotes extends StatefulWidget {
  @override
  _MyNotesState createState() => _MyNotesState();
}

class _MyNotesState extends State<MyNotes> {
  int pageLoadStatus = 1;
  List noteList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text('我的笔记'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
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
        return ListView.builder(
            padding: EdgeInsets.all(0.0),
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              return renderItem(noteList[index]);
            });
        break;
      case 3:
        return Center(
          child: Text('您还没有记笔记哟！'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络请求错误'),
        );
        break;
      case 5:
        return Center(
          child: Text('您还未登录哦！'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  Widget renderItem(item) {
    print(noteList);
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          renderItemHeader(item),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10.0, bottom: 10.0),
            child: Text(
              item['remark'],
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 50,
              ),
              Expanded(
                child: Text(
                  item['prodName'] + '>' + item['paperName'],
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 12.0, color: Color.fromRGBO(153, 153, 153, 1)),
                ),
              ),
              Icon(
                Icons.link,
                color: Color.fromRGBO(153, 153, 153, 1),
                size: 18.0,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10.0, bottom: 10.0),
            child: renderItemFooter(item),
          )
        ],
      ),
    );
  }

  // 渲染头部组件
  Widget renderItemHeader(item) {
    bool isPublic = item['isPublic'] == 1;

    IconData icon;
    Color iconColor;
    switch (item['status']) {
      case '待审核':
        icon = Icons.timelapse;
        iconColor = Color.fromRGBO(100, 101, 102, 1);
        break;
      case '审核通过':
        icon = Icons.check_circle;
        iconColor = Color.fromRGBO(59, 198, 118, 1);
        break;
      case '审核未通过':
        icon = Icons.cancel;
        iconColor = Color.fromRGBO(255, 68, 68, 1);
        break;
    }

    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.access_time,
            size: 20.0,
            color: Color.fromRGBO(51, 51, 51, 1),
          ),
        ),
        Text(item['createTime']),
        Expanded(
          child: Container(),
        ),
        isPublic
            ? Icon(
          icon,
          color: iconColor,
          size: 20.0,
        )
            : Container(),
        isPublic
            ? Text(
          item['status'],
          style: TextStyle(color: iconColor),
        )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(isPublic ? '公开' : '私密'),
        ),
      ],
    );
  }

  // 渲染底部组件
  Widget renderItemFooter(item) {
    double iconSize = 16.0;
    Color color = Color.fromRGBO(153, 153, 153, 1);

    return Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.delete,
              size: iconSize,
              color: color,
            ),
            Text(
              '删除',
              style: TextStyle(color: color),
            )
          ],
        ),
        Container(
          width: 10.0,
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.edit,
              size: iconSize,
              color: color,
            ),
            Text(
              '编辑',
              style: TextStyle(color: color),
            )
          ],
        ),
        Container(
          width: 10.0,
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.favorite_border,
              size: iconSize,
              color: color,
            ),
            Text(
              item['likeCount'].toString(),
              style: TextStyle(color: color),
            )
          ],
        ),
        Expanded(child: Container()),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageRouter(MyNotesEx(
                  item: item,
                )));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
            decoration: BoxDecoration(
                border: Border.all(color: color, width: 0.5),
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(
              item['notesCount'] > 1
                  ? '所有笔记+' + item['notesCount'].toString()
                  : '查看习题',
              style: TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1), fontSize: 13.0),
            ),
          ),
        ),
      ],
    );
  }

  // 获取笔记数据
  void getNotes() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _user = _pref.getString('userData');
    if (_user != null) {
      Map user = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response = await ajax.post(
          '/api/ExerciseNotes/findCoursePaperExerciseNotes',
          data: {'userID': user['userID']});
      if (response.statusCode == 200) {
        Map ret = response.data;
        if (ret['code'].toString() == '200') {
          noteList = ret['data'];
          pageLoadStatus = 2;
        } else {
          pageLoadStatus = 3;
        }
      } else {
        pageLoadStatus = 4;
      }
    } else {
      pageLoadStatus = 5;
    }
    setState(() {});
  }
}
