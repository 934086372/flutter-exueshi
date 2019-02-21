import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/study/ExamPaper.dart';

class PaperIndex extends StatefulWidget {
  @override
  _PaperIndexState createState() => _PaperIndexState();
}

class _PaperIndexState extends State<PaperIndex> {
  @override
  Widget build(BuildContext context) {
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
                              onPressed: () {})
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '《新大纲考点补充精讲班》常见问题解答',
                            style:
                            TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          '闲鱼是阿里巴巴旗下闲置交易平台App客户端（iOS版和安卓版）。会员只要使用淘宝或支付宝账户登录，无需经过复杂的开店流程',
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
                            Navigator.of(context).push(
                                CustomRoute(ExamPaper()));
                          },
                          child: Container(
                            width: 130.0,
                            height: 130.0,
                            child: Center(
                              child: Text(
                                '开始做题',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(65.0)),
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


}
