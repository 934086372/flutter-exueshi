import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_html_textview/flutter_html_textview.dart';

class ExamPaper extends StatefulWidget {
  @override
  _ExamPaperState createState() => _ExamPaperState();
}

class _ExamPaperState extends State<ExamPaper> {
  var _exIDs;
  var data_exCache;
  var data_exIDs;

  Map _answers = new Map();

  PageController _pageController = new PageController(initialPage: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getEx(); // 初始化获取数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 170, 255, 1),
          elevation: 1.0,
          title: Text('考试模式'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.card_membership), onPressed: () {})
          ],
        ),
        body: data_exCache == null
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : PageView.builder(
                controller: _pageController,
                itemCount: data_exCache.length,
                itemBuilder: (context, index) {
                  if (data_exCache[index]['type'] == 'section') {
                    String _sectionTitle = data_exCache[index]['title'];
                    return Center(
                      child: Text('$_sectionTitle'),
                    );
                  } else {
                    return _renderExItem(data_exCache[index]);
                  }
                },
                onPageChanged: (index) {
                  print(index);
                },
              ));
  }

  /*
  * 1. 是否材料题
  *     1.1 材料题
  *     1.2 听力题
  *
  * 2. 是否客观题
  *     2.1 单选题
  *     2.2 多选题
  *     2.3 判断题
  *
  * 3. 是否填空题
  *
  * 4. 是否简答题
  *
  * */
  Widget _renderExItem(item) {
    print(item['question_types']);

    bool isGroupEx =
        item['subject'] != '' || item['subject_addon'] != null; // 是否材料题
    bool isObjectiveEx = true; // 是否客观题
    bool isBlankEx = true; // 是否填空题
    bool isSubjectiveEx = true; // 是否主观题（问答题）

    bool isSingleChoiceEx = item['question_types'] == 1;
    bool isMultipleChoiceEx = item['question_types'] == 2;
    bool isJudgementEx = item['question_types'] == 6;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isSingleChoiceEx ? _renderSingleChoiceQuestion(item) : Container(),
          isJudgementEx ? _renderJudgementQuestion(item) : Container(),
        ],
      ),
    );
  }

  // 渲染单选题
  Widget _renderSingleChoiceQuestion(item) {
    bool alreadyHandle = _answers.containsKey(item['exid']);

    String _userAnswer = '';
    if (alreadyHandle) {
      _userAnswer = _answers[item['exid']]['answer'];
    }

    String title = "<p>" + item['question'] + "</p>";

    Color _active = Color.fromRGBO(0, 170, 255, 1);
    Color _defaultIcon = Color.fromRGBO(153, 153, 153, 1);
    Color _defaultText = Color.fromRGBO(102, 102, 102, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HtmlTextView(data: title),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(item['answer'].length, (index) {
            String _optionText = item['answer'][index].toString().trim();

            bool isSelected = _userAnswer == _optionText;

            return ListTile(
              leading: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: _active,
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: _defaultIcon,
                    ),
              title: Text(
                _optionText,
                style: TextStyle(color: isSelected ? _active : _defaultText),
              ),
              onTap: () {
                setState(() {
                  _answers[item['exid']] = {'answer': _optionText};
                });
              },
            );
          }),
        )
      ],
    );
  }

  // 渲染判断题
  Widget _renderJudgementQuestion(item) {
    bool alreadyHandle = _answers.containsKey(item['exid']);

    String _userAnswer = '';
    if (alreadyHandle) {
      _userAnswer = _answers[item['exid']]['answer'];
    }

    String title = "<p>" + item['question'] + "</p>";

    Color _active = Color.fromRGBO(0, 170, 255, 1);
    Color _defaultIcon = Color.fromRGBO(153, 153, 153, 1);
    Color _defaultText = Color.fromRGBO(102, 102, 102, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HtmlTextView(data: title), // 题目标题
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(2, (index) {
            String _optionText = index == 0 ? '正确' : '错误';
            bool isSelected = _userAnswer == _optionText;
            return ListTile(
              leading: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: _active,
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: _defaultIcon,
                    ),
              title: Text(
                _optionText,
                style: TextStyle(color: isSelected ? _active : _defaultText),
              ),
              onTap: () {
                setState(() {
                  _answers[item['exid']] = {'answer': _optionText};
                });
              },
            );
          }),
        )
      ],
    );
  }

  Future _getEx() async {
    Completer _completer = new Completer();

    Ajax ajax = new Ajax();

    String prodID = 'P20190286696598b6a35b';
    String paperID = '1211';
    var paperData;

    Response response = await ajax.post('/api/StudyPaper/getPaper',
        data: {'prodID': prodID, 'paperID': paperID});

    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        paperData = ret['data'];
        var _tmpExIDs = [];
        for (var section in paperData['question']) {
          for (var item in section['question']) {
            _tmpExIDs.add(item);
          }
        }
        _exIDs = _tmpExIDs;
      }
    }

    if (_exIDs != null) {
      Response response2 =
          await ajax.post('/api/StudyPaper/getPaperQuestions', data: {
        'userID': 'U201821436701',
        'exerciseIDs': _exIDs,
        'prodID': prodID,
        'paperID': paperID,
        'question': paperData['question'],
      });

      print({
        'userID': 'U201821436701',
        'exerciseIDs': _exIDs,
        'prodID': prodID,
        'paperID': paperID,
        'question': paperData['question'],
      });

      print(response2);

      if (response2.statusCode == 200) {
        var ret2 = response2.data;

        var _exCache = [];
        var _ids = [];

        var _exData = ret2['data'];

        int index = 0;
        var sectionTitle = '';
        for (var item in _exData) {
          if (item['title'] != sectionTitle) {
            sectionTitle = item['title'];
            var sectionItem = {
              'type': 'section',
              'title': item['title'],
              'replenish': item['replenish']
            };
            _exCache.add(sectionItem);
          }
          item['type'] = 'exercise';
          item['exIndex'] = index + 1;
          _exCache.add(item);
          _ids.add(item['exid']);
        }

        data_exCache = _exCache;
        data_exIDs = _ids;
      }
    }

    //setState(() {});

    _completer.complete();

    return _completer.future;
  }
}
