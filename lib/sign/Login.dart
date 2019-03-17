import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';

import 'package:flutter_exueshi/sign/SignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<Login> {
  String _loginType = 'code';
  String _loginText = '密码登录';
  int _countdown = 60;
  String _countdownText = '获取验证码';
  Color _countdownTextColor = Color.fromRGBO(51, 51, 51, 1);
  bool _loginBtnStatus = false; // 默认登录按钮不可用
  var _telephone;
  var _password;
  var _deviceid = 'androidTest';

  void _updateCountdown(_this) {
    setState(() {
      _countdown--;
      _countdownText = _countdown.toString() + 's后重发';
      if (_countdown <= 0) {
        _this.cancel();
        _countdown = 60;
        _countdownText = '获取验证码';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
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
                  Navigator.push(context, PageRouter(SignUp()));
                },
                child: Text('注册'),
              ))
        ],
      ),
      body: Container(
          color: Color.fromRGBO(241, 241, 241, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _loginForm(),
              _loginBtn(),
              Container(
                child: Center(
                  child: GestureDetector(
                    child: Text(
                      _loginText,
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      setState(() {
                        if (_loginType == 'code') {
                          _loginType = 'password';
                          _loginText = '验证码登录';
                        } else {
                          _loginType = 'code';
                          _loginText = '密码登录';
                        }
                      });
                    },
                  ),
                ),
                margin: EdgeInsets.only(top: 15.0),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              left: 15.0, top: 80.0, right: 15.0),
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
                                        color:
                                        Color.fromRGBO(153, 153, 153, 1)),
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
                  ),
                ),
              )
            ],
          )),
    );
  }

  // 监听电话号码是否存在
  void _telephoneListener(telephone) {
    Color _color = Color.fromRGBO(153, 153, 153, 1);
    telephone = telephone.toString();
    Pattern _pattern = new RegExp('1[3|4|5|7|8|9][0-9]{9}');
    bool isTelephone = telephone.startsWith(_pattern);

    if (telephone.length == 11) {
      _color = Color.fromRGBO(0, 190, 255, 1);
    }
    setState(() {
      print(isTelephone);
      print(telephone);
      _countdownTextColor = _color;
      _telephone = telephone;
    });
  }

  Widget _loginForm() {
    if (this._loginType == 'code') {
      return Container(
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
                          onChanged: _telephoneListener,
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
                        key: Key('yzm'),
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
                    child: Text(
                      _countdownText,
                      style: TextStyle(color: _countdownTextColor),
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(226, 226, 226, 1)))),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  ),
                  onTap: () {
                    if (_countdown == 60) {
                      _updateCountdown('');
                      Timer.periodic(Duration(seconds: 1), (_this) {
                        _updateCountdown(_this);
                      });
                    }
                  },
                )
                /*,*/
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
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
                          onChanged: _telephoneListener,
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
                  child: Icon(
                    Icons.visibility_off,
                    size: 14.0,
                    color: Colors.black45,
                  ),
                  width: 25.0,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                ),
                Expanded(
                  child: Container(
                    height: 50.0,
                    margin: EdgeInsets.only(right: 10.0),
                    child: Center(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _loginBtnStatus = !(val == '');
                            _password = val;
                          });
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: '请输入密码',
                            hintStyle: TextStyle(fontSize: 14.0),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Text('忘记密码'),
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(226, 226, 226, 1)))),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  ),
                  onTap: () {
                    print('忘记密码');
                  },
                )
                /*,*/
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _loginBtn() {
    Color _btnColor = Color.fromRGBO(204, 204, 204, 1);
    if (_loginBtnStatus) {
      _btnColor = Color.fromRGBO(0, 145, 219, 1);
    }
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15.0, right: 15.0),
        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2.5)),
            color: _btnColor),
        child: GestureDetector(
          onTap: () {
            if (_loginBtnStatus) {
              print('login');
              _login();
            }
          },
          child: Text(
            '登录',
            style: TextStyle(color: Colors.white, fontSize: 17.0),
          ),
        ));
  }

  // 登录方法
  Future _login() async {
    Ajax _ajax = new Ajax();
    Response response = await _ajax.post('/api/user/login/by/telephone/psw',
        data: {
          'telephone': _telephone,
          'userPsw': _password,
          'userDeviceID': _deviceid
        });

    if (response.statusCode == 200) {
      var ret = response.data;

      if (ret['code'].toString() == '200') {
        var userData = ret['data'];

        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString('userData', json.encode(userData));

        Navigator.pop(context);
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(ret['msg'])));
      }
    }
  }
}
