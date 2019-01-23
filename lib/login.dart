import 'package:flutter/material.dart';
import 'package:flutter_exueshi/custom_router.dart';
import 'components/MyIcons.dart';

import 'SignUp.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<Login> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 0.0,
        title: Text('登录'),
        centerTitle: true,
        actions: <Widget>[
          Container(
              width: 60,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: MaterialButton(
                shape: CircleBorder(),
                onPressed: () {
                  Navigator.push(context, CustomRoute(SignUp()));
                },
                child: Text(
                  '注册',
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
      body: Container(
          color: Color.fromRGBO(241, 241, 241, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Text('+86'),
                          width: 25.0,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Expanded(
                          child: Container(
                            height: 50.0,
                            margin: EdgeInsets.only(right: 10.0),
                            child: Center(
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      hintText: '请输入手机号',
                                      hintStyle: TextStyle(fontSize: 14.0),
                                      border: InputBorder.none),
                                )),
                          ),
                        )
                        /*,*/
                      ],
                    ),
                    Container(
                      height: 0.5,
                      color: Color.fromRGBO(226, 226, 226, 1),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          child: Text(''),
                          width: 25.0,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Expanded(
                          child: Container(
                            height: 50.0,
                            margin: EdgeInsets.only(right: 10.0),
                            child: Center(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    hintText: '请输入验证码',
                                    hintStyle: TextStyle(fontSize: 14.0),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            child: Text('获取验证码'),
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        width: 0.5,
                                        color:
                                        Color.fromRGBO(226, 226, 226, 1)))),
                            padding: EdgeInsets.all(10.0),
                            margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                          ),
                          onTap: () {
                            print('获取验证码');
                          },
                        )
                        /*,*/
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                      color: Color.fromRGBO(204, 204, 204, 1)),
                  child: GestureDetector(
                    onTap: () {
                      print('login');
                    },
                    child: Text(
                      '登录',
                      style: TextStyle(color: Colors.white, fontSize: 17.0),
                    ),
                  )),
              Container(
                child: Center(
                  child: Text(
                    '密码登录',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                margin: EdgeInsets.only(top: 15.0),
              ),
              Container(
                  margin: EdgeInsets.only(left: 15.0, top: 80.0, right: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 15.0),
                                height: 0.5,
                                color: Color.fromRGBO(204, 204, 204, 1),
                              )),
                          Text(
                            '使用其它登录方式',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15.0),
                                height: 0.5,
                                color: Color.fromRGBO(204, 204, 204, 1),
                              )),
                        ],
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(''),
                      ),
                      Icon(MyIcons.qq_border,
                          size: 40.0, color: Colors.black45),
                      Container(
                        width: 8.0,
                      ),
                      Icon(
                        MyIcons.wechat_border,
                        size: 40.0,
                        color: Colors.black45,
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
