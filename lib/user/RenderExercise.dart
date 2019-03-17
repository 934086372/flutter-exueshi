import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenderExercise extends StatefulWidget {
  final exid;
  final paperID;
  final prodID;

  const RenderExercise({Key key, this.exid, this.paperID, this.prodID})
      : super(key: key);

  @override
  _RenderExerciseState createState() => _RenderExerciseState();
}

class _RenderExerciseState extends State<RenderExercise>
    with AutomaticKeepAliveClientMixin {
  int pageLoadStatus = 1;

  get exid => widget.exid;

  get paperID => widget.paperID;

  get prodID => widget.prodID;

  var exData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEx();
  }

  @override
  Widget build(BuildContext context) {
    print(exData);
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HtmlView(data: exData[0]['question'].toString())
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

  void getEx() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = new Ajax();

      Response response =
          await ajax.post('/api/StudyPaper/getPaperQuestion', data: {
        'userID': userData['userID'],
        'exerciseID': exid,
        'prodID': prodID,
        'paperID': paperID
      });
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          exData = ret['data'];
          print(exData);
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
