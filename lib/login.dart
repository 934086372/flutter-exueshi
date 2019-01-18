import 'package:flutter/material.dart';

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
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () => Navigator.of(context).pop(),
          );
        }),
        title: Text('登录'),
        centerTitle: true,
        actions: <Widget>[Text('注册')],
      ),
      body: Container(
          color: Color.fromRGBO(241, 241, 241, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                            margin: EdgeInsets.only(right: 10.0),
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  hintText: '请输入手机号', border: InputBorder.none),
                            ),
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
                            margin: EdgeInsets.only(right: 10.0),
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  hintText: '请输入验证码', border: InputBorder.none),
                            ),
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 40.0,
                          color: Color.fromRGBO(226, 226, 226, 1),
                        ),
                        FlatButton(onPressed: () {}, child: Text('获取验证码'))
                        /*,*/
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Checkbox(value: true, onChanged: null),
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
                  margin: EdgeInsets.only(left: 10.0, top: 80.0, right: 10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            margin: EdgeInsets.only(right: 10.0),
                            height: 1,
                            color: Color.fromRGBO(204, 204, 204, 1),
                          )),
                          Text(
                            '使用其它登录方式',
                            style: TextStyle(
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                          Expanded(
                              child: Container(
                            margin: EdgeInsets.only(left: 10.0),
                            height: 1,
                            color: Color.fromRGBO(204, 204, 204, 1),
                          )),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Center(
                            child:
                                Icon(IconData(0xe634, fontFamily: 'appIcons')),
                          )
                        ],
                      )
                    ],
                  )),
            ],
          )),
    );
  }
}
