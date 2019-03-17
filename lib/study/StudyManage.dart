import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyManage extends StatefulWidget {
  final studyingList;

  final userID;

  const StudyManage({Key key, this.studyingList, this.userID})
      : super(key: key);

  @override
  _StudyManageState createState() => _StudyManageState(studyingList, userID);
}

class _StudyManageState extends State<StudyManage> {

  final userID;

  final _studyingList;

  final _selected = new Set();

  bool _selectedAll = false;

  _StudyManageState(this._studyingList, this.userID);

  var studyingList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studyingList = _studyingList;
  }

  @override
  Widget build(BuildContext context) {
    int _selectedLength = _selected.length;
    String _text = '标记为已学完';
    if (_selectedLength > 0) {
      _text += '($_selectedLength)';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('批量管理'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: studyingList.length,
                itemBuilder: (context, index) {
                  return _renderCourseItem(studyingList[index], index, context);
                }),
          ),
          Row(
            children: <Widget>[
              IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    _selectedAll
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _selectedAll
                        ? Color.fromRGBO(0, 170, 255, 1)
                        : Color.fromRGBO(204, 204, 204, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_selectedAll) {
                        _selected.clear();
                        _selectedAll = false;
                      } else {
                        for (var item in studyingList) {
                          _selected.add(item['prodID']);
                        }
                        _selectedAll = true;
                      }
                    });
                  }),
              Text('全选'),
              Expanded(
                child: Container(),
              ),
              Ink(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: FlatButton(
                    onPressed: () {
                      _finishAll();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child:
                      Text(_text, style: TextStyle(color: Colors.white)),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  Future _finishAll() async {
    Completer _completer = new Completer();

    var prodIDs = _selected.join(',');
    if (prodIDs.length <= 0) {
      _completer.complete('');
      return _completer.future;
    }

    Ajax ajax = new Ajax();
    Response response = await ajax.post(
        '/api/product/getStuProductStatuses', data: {
      'userID': userID,
      'prodIDs': _selected.join(','),
      'studyStatus': '学习完成'
    });

    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        var _newStudyingList = [];
        for (var item in studyingList) {
          if (!_selected.contains(item['prodID'])) {
            _newStudyingList.add(item);
          }
        }

        setState(() {
          studyingList = _newStudyingList;
          _selected.clear();
          _selectedAll = false;
        });
      }
    }
  }

  // 渲染列表中的单个课程产品项
  Widget _renderCourseItem(item, index, context) {
    double topPadding = 0;
    if (index == 0) {
      topPadding = 10.0;
    }

    final alreadySelected = _selected.contains(item['prodID']);

    return Container(
      height: 100.0,
      padding: EdgeInsets.only(top: topPadding, right: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(
                alreadySelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: alreadySelected
                    ? Color.fromRGBO(0, 170, 255, 1)
                    : Color.fromRGBO(204, 204, 204, 1),
              ),
              onPressed: () {
                setState(() {
                  if (alreadySelected) {
                    _selected.remove(item['prodID']);
                    _selectedAll = false;
                  } else {
                    _selected.add(item['prodID']);

                    // 检查是否已选完
                    if (_selected.length == studyingList.length) {
                      _selectedAll = true;
                    } else {
                      _selectedAll = false;
                    }
                  }
                });
              }),
          Container(
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                Container(
                    child: Image.network(
                      item['logo'],
                      fit: BoxFit.fill,
                    ),
                    width: 150.0),
              ],
            ),
            height: 100.0,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Text(
                        item['prodName'],
                        style: TextStyle(color: Colors.black),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      )),
                  _lastStudyItem(item['lastStudyItem']),
                  _validShow(item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 有效期显示
  Widget _validShow(item) {
    var _text;
    switch (item['validType']) {
      case '永久':
        _text = '永久有效';
        break;
      case '时间段':
        _text = item['validEndTime'] + ' 前有效';
        break;
      case '天数':
      // 使用支付时间 + 有效天数
        DateTime _payTime = DateTime.parse(item['payTime']);
        print(_payTime);
        DateTime _validEndTime =
        _payTime.add(Duration(days: item['validDays']));
        print(_validEndTime);
        _text = _payTime.year.toString() +
            '-' +
            _payTime.month.toString() +
            '-' +
            _payTime.day.toString() +
            ' 前有效';
        break;
    }

    Color _color = Color.fromRGBO(102, 102, 102, 1);
    if (item['prodStatus'] == '预售中' || item['validType'] == '永久') {
      _color = Color.fromRGBO(255, 102, 0, 1);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Text(_text, style: TextStyle(fontSize: 12.0, color: _color)),
    );
  }

  // 上次学习锚点
  Widget _lastStudyItem(lastItem) {
    if (lastItem.toString() == [].toString()) {
      // 无上次学习记录
      return Container();
    } else {
      IconData _icon;
      switch (lastItem['prodContentType']) {
        case '视频':
          _icon = MyIcons.video;
          break;
        case '资料':
          _icon = MyIcons.document;
          break;
        case '试卷':
          _icon = MyIcons.paper;
          break;
      }

      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              _icon,
              color: Color.fromRGBO(0, 145, 219, 0.6),
              size: 20.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  lastItem['prodContentName'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.0, color: Color.fromRGBO(153, 153, 153, 1)),
                ),
              ),
            ),
          ]);
    }
  }
}
