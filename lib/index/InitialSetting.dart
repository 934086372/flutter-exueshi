import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/LabelList.dart';
import 'package:flutter_exueshi/index/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialSetting extends StatefulWidget {
  final List projectList;
  final List areaList;

  const InitialSetting({Key key, this.projectList, this.areaList})
      : super(key: key);

  @override
  _InitialSettingState createState() => _InitialSettingState();
}

class _InitialSettingState extends State<InitialSetting> {
  List get projectList => widget.projectList;

  List get areaList => widget.areaList;

  @override
  Widget build(BuildContext context) {
    print(projectList);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: Text(
                  '您目前要考的是？',
                  style: TextStyle(
                      fontSize: 20, color: Color.fromRGBO(51, 51, 51, 1)),
                ),
              ),
              Column(
                children: List.generate(projectList.length, (index) {
                  return renderItem(projectList[index]);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 渲染单个项目
  Widget renderItem(item) {
    return GestureDetector(
      onTap: () {
        setInitialData(item);
        if (item['isAreaDifferent']) {
          Navigator.push(
              context,
              PageRouter(SetArea(
                areaList: areaList,
              )));
        } else {
          Navigator.push(context, PageRouter(MainPage()));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.5, vertical: 12.5),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  offset: Offset(0, 5),
                  blurRadius: 10.0,
                  spreadRadius: 0.0)
            ]),
        child: Row(
          children: <Widget>[
            Container(
              width: 60.0,
              margin: EdgeInsets.only(right: 20.0),
              child: FadeInImage.assetNetwork(
                image: item['logo'],
                placeholder: 'assets/images/loading.gif',
              ),
            ),
            Text(
              item['name'],
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  void setInitialData(item) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    Map data = {
      'catItem': item,
      'area': '',
    };
    _pref.setString('initialSetting', json.encode(data));
  }
}

class SetArea extends StatefulWidget {
  final List areaList;

  const SetArea({Key key, this.areaList}) : super(key: key);

  @override
  _SetAreaState createState() => _SetAreaState();
}

class _SetAreaState extends State<SetArea> {
  String area = '全国';

  List data = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 格式化地区数据
    widget.areaList.forEach((item) {
      data.add(item['name']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60.0, left: 15.0, right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            renderTitle(),
            renderAreaList(),
            renderBottom(),
          ],
        ),
      ),
    );
  }

  Widget renderTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.location_on,
            size: 24.0,
          ),
          Text(
            '你考试地区是？',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget renderAreaList() {
    return Expanded(
      child: LabelList(
        data: data,
        initialValue: '全国',
        onChanged: (v) {
          print(v);
          setState(() {
            area = v;
          });
        },
      ),
    );
  }

  Widget renderBottom() {
    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: GestureDetector(
            child: Container(
              width: 200,
              padding: EdgeInsets.symmetric(vertical: 14.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromRGBO(68, 204, 255, 1),
                        Color.fromRGBO(0, 170, 255, 1)
                      ]),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  )),
              child: Text(
                '确认选择',
                style: TextStyle(fontSize: 17.0, color: Colors.white),
              ),
            ),
            onTap: () {
              setInitialData(area);
              Navigator.of(context).push(PageRouter(MainPage()));
            },
          ),
        ),
        Positioned(
            right: 5.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '上一步',
                  style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 16.0),
                ),
              ),
            )),
      ],
    );
  }

  void setInitialData(item) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String tmp = _pref.getString('initialSetting');
    Map data = json.decode(tmp);
    data['area'] = item;
    _pref.setString('initialSetting', json.encode(data));
  }
}
