import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/study/Comment.dart';
import 'package:flutter_exueshi/study/ExamPaper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaperIndex extends StatefulWidget {
  final String prodID;
  final String paperID;
  final String orderID;

  const PaperIndex({Key key, this.paperID, this.prodID, this.orderID})
      : super(key: key);

  @override
  _PaperIndexState createState() => _PaperIndexState();
}

class _PaperIndexState extends State<PaperIndex> {
  String get prodID => widget.prodID;

  String get paperID => widget.paperID;

  String get orderID => widget.orderID;

  int pageLoadStatus = 1;
  Map paperData = new Map();

  int rating = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPaper();
    print('初始化');
  }

  @override
  Widget build(BuildContext context) {
    return renderPage();
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return renderPageContent();
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

  Widget renderPageContent() {
    print('rating:' + rating.toString());

    String paperName = paperData['title'];
    String paperDesc = paperData['description'];

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image.asset('assets/images/bg_ex_blank.png'),
              Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          Expanded(child: Container()),
                          IconButton(
                              icon: Icon(
                                MyIcons.like_border,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              onPressed: () {
                                showCommentSheet();
                              })
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            paperName,
                            style:
                            TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          paperDesc,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          Expanded(
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          gradient: LinearGradient(colors: <Color>[
                            Color.fromRGBO(0, 170, 255, 0.2),
                            Color.fromRGBO(68, 204, 255, 0.2)
                          ])),
                    ),
                    Positioned(
                        left: 5,
                        top: 5,
                        child: Container(
                          width: 140.0,
                          height: 140.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(70.0)),
                              gradient: LinearGradient(colors: <Color>[
                                Color.fromRGBO(0, 170, 255, 0.3),
                                Color.fromRGBO(68, 204, 255, 0.3)
                              ])),
                        )),
                    Positioned(
                        left: 10.0,
                        top: 10.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(PageRouter(ExamPaper()));
                          },
                          child: Container(
                            width: 130.0,
                            height: 130.0,
                            child: Center(
                              child: Text(
                                '开始做题',
                                style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(65.0)),
                                gradient: LinearGradient(colors: <Color>[
                                  Color.fromRGBO(0, 170, 255, 1),
                                  Color.fromRGBO(68, 204, 255, 1)
                                ])),
                          ),
                        )),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  // 显示评价窗口
  void showCommentSheet() {
    // 新开了一个界面，与父界面的数据
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Comment();
        });
  }

  void getPaper() async {
    Ajax ajax = new Ajax();

    Response response = await ajax.post('/api/StudyPaper/getPaper', data: {
      'prodID': prodID,
      'paperID': paperID,
    });
    if (response.statusCode == 200) {
      Map ret = response.data;
      print(ret);
      if (ret['code'].toString() == '200') {
        paperData = ret['data'];
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
    }

    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _user = _pref.getString('userData');
    if (_user != null) {
      Map user = json.decode(_user);
      Response response2 =
      await ajax.post('/api/user/study/paper/flow/info', data: {
        'userID': user['userID'],
        'paperID': paperID,
        'orderID': orderID,
      });
      print(response2);
      if (response2.statusCode == 200) {
        Map ret = response2.data;
        if (ret['code'].toString() == '200') {}
      }
    }

    setState(() {});
  }
}

