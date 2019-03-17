import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<SignUp> {
  var _selected = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('注册'),
        centerTitle: true,
      ),
      body: Container(
          color: Color.fromRGBO(241, 241, 241, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10.0),
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
                    Container(
                      height: 0.5,
                      color: Color.fromRGBO(226, 226, 226, 1),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.remove_red_eye,
                            size: 16.0,
                            color: Color.fromRGBO(204, 204, 204, 1),
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
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  hintText: '请输入您的密码',
                                  hintStyle: TextStyle(fontSize: 14.0),
                                  border: InputBorder.none),
                            )),
                          ),
                        )
                        /*,*/
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        value: _selected,
                        onChanged: (value) {
                          setState(() {
                            _selected = value;
                          });
                        }),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text('我已阅读并同意《'),
                          GestureDetector(
                            child: Text(
                              '学员服务条款',
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 170, 255, 1)),
                            ),
                            onTap: () {
                              print('查看条款');
                            },
                          ),
                          Text('》'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  padding: EdgeInsets.only(top: 17.0, bottom: 17.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                      color: Color.fromRGBO(204, 204, 204, 1)),
                  child: GestureDetector(
                    onTap: () {
                      print('SignUP');
                    },
                    child: Text(
                      '立即注册',
                      style: TextStyle(color: Colors.white, fontSize: 17.0),
                    ),
                  )),
            ],
          )),
    );
  }
}
