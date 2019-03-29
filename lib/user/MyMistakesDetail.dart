import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/user/RenderExercise.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMistakesDetail extends StatefulWidget {
  final paperID;
  final prodID;

  const MyMistakesDetail({Key key, this.paperID, this.prodID})
      : super(key: key);

  @override
  _MyMistakesDetailState createState() => _MyMistakesDetailState();
}

class _MyMistakesDetailState extends State<MyMistakesDetail> {
  int pageLoadStatus;
  var exerciseData;

  get prodID => widget.prodID;

  get paperID => widget.paperID;

  int count = 1;
  int currentIndex = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExercise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        centerTitle: true,
        title: Container(
          child: Row(
            children: <Widget>[
              Text('错题集'),
            ],
          ),
        ),
        actions: <Widget>[
          InkResponse(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.apps),
                  Text(
                    currentIndex.toString() + '/' + count.toString(),
                    style: TextStyle(fontSize: 10.0),
                  )
                ],
              ),
            ),
          )
        ],
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
        return PageView.builder(
          itemCount: exerciseData.length,
          itemBuilder: (context, index) {
            return RenderExercise(
              exid: exerciseData[index]['exerciseID'],
              prodID: prodID,
              paperID: paperID,
            );
          },
          onPageChanged: (index) {
            setState(() {
              currentIndex = index + 1;
            });
          },
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

  // 获取错题数据
  void getExercise() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response =
          await ajax.post('/api/user/collection/mistake/list', data: {
        'userID': userData['userID'],
        'token': userData['token'],
        'prodID': prodID,
        'paperID': paperID,
        'mistakeStatus': '未掌握'
      });
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          exerciseData = ret['data'];
          print(exerciseData.length);
          count = exerciseData.length;
          pageLoadStatus = 2;
        } else {
          pageLoadStatus = 3;
        }
      } else {
        pageLoadStatus = 4;
      }
    }
    setState(() {});
  }
}
