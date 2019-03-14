import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/sign/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('账户设置'),
        centerTitle: true,
      ),
      body: renderPage(),
      backgroundColor: Color.fromRGBO(241, 241, 241, 1),
    );
  }

  Widget renderPage() {
    return Column(
      children: <Widget>[
        Expanded(
            child: SingleChildScrollView(
              child: renderList(),
            )),
        Ink(
          child: FlatButton(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                child: Text(
                  '退出当前账户',
                  style: TextStyle(color: Colors.white, fontSize: 17.0),
                ),
              ),
            ),
            onPressed: logout,
          ),
          decoration: BoxDecoration(color: Colors.red),
        )
      ],
    );
  }

  Column renderList() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    width: 50.0,
                    height: 50.0,
                    color: Colors.lightBlueAccent,
                  ),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    color: Colors.redAccent,
                  )
                ],
              ),
              Divider(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('修改密码'),
                  ),
                  Icon(Icons.chevron_right)
                ],
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('允许3G/4G网络播放视频'),
                  ),
                  Switch.adaptive(value: false, onChanged: (v) {})
                ],
              ),
              Divider(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('允许视频连续播放'),
                  ),
                  Switch.adaptive(value: false, onChanged: (v) {})
                ],
              ),
              Divider(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('清除缓存'),
                  ),
                  Icon(Icons.chevron_right)
                ],
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('当前版本'),
                  ),
                  Text('1.0.0')
                ],
              ),
              Divider(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('检查新版本'),
                  ),
                  Text(
                    '当前已是最新版本',
                    style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void logout() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.remove('userData');

    Navigator.of(context).push(CustomRoute(Login()));
  }
}
