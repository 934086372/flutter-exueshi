import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return Stack(
          children: <Widget>[
            renderWaterMark(),
            Positioned.fill(
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: SingleChildScrollView(
                          child: renderQuestion(),
                        )),
                    renderBottomBar()
                  ],
                )),
          ],
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

  Widget renderWaterMark() {
    return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(12, (index) {
              return Transform.rotate(
                angle: -5 / 12,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('易学仕在线',
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color.fromRGBO(153, 153, 153, 0.2))),
                      Text('15310486021',
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color.fromRGBO(153, 153, 153, 0.2)))
                    ],
                  ),
                ),
              );
            }),
          ),
        ));
  }

  Widget renderBottomBar() {
    return Container(
      height: 50.0,
      child: Row(
        children: <Widget>[Text('已掌握'), Icon(Icons.edit)],
      ),
    );
  }

  Widget renderQuestion() {
    // 题目数据
    Map item = exData[0];

    print(item);

    // 题型
    int questionType = item['question_types'];
    print(questionType);

    switch (questionType) {
      case 1:
        break;
    }

    // 标题
    String title = '<div>' + item['question'].toString().trim() + '</div>';

    // 题目选项
    List options = item['answer'];

    // 标准答案
    String answer = item['question_standard_answer'];


    print(item['question_standard_answer'].length);

    // 题目解析
    String analysis = item['question_analyze'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        renderQuestionTitle(title),
        renderOptions(options, answer),
        renderDivider(),
        renderAnalysis(analysis)
      ],
    );
  }

  Widget renderDivider() {
    return Container(
      height: 10.0,
      color: Color.fromRGBO(241, 241, 241, 0.7),
    );
  }

  Widget renderQuestionTitle(title) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Color.fromRGBO(255, 255, 255, 0),
        child: HtmlView(data: title));
  }

  Widget renderOptions(options, answer) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: List.generate(options.length, (index) {
          String optionItem =
              '<div>' + options[index].toString().trim() + '</div>';
          //bool isCorrect = int.parse(answer) == index;
          bool isCorrect = false;
          return Row(
            children: <Widget>[
              isCorrect
                  ? Icon(
                Icons.check_circle,
                color: Colors.blue,
              )
                  : Icon(
                Icons.radio_button_unchecked,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
              Expanded(
                child: HtmlView(
                  data: optionItem,
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget renderAnalysis(analysis) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '题目解析：',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w700),
          ),
          HtmlView(
            data: analysis,
          )
        ],
      ),
    );
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
