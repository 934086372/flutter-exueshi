import 'dart:async';

import 'package:flutter/material.dart';

class StudyIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<StudyIndex> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('我的学习'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              print('点击了管理');
            },
            child: Text('管理'),
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: TabBar(
              tabs: <Tab>[
                Tab(
                  text: '我的学习',
                ),
                Tab(text: '学习完成'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              controller: _tabController,
            ),
            color: Color.fromRGBO(241, 241, 241, 1),
          ),
          Expanded(
            child: TabBarView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _tabController,
              children: <Widget>[
                RefreshIndicator(
                    child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(top: 10.0),
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return _renderCourseItem(index);
                        }),
                    onRefresh: _refreshList),
                RefreshIndicator(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _renderCourseItem(index);
                      }),
                  onRefresh: _refreshList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _renderCourseItem(item) {
  return Container(
    height: 100.0,
    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
    child: FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: () {
          print('点击课程');
        },
        child: Row(
          children: <Widget>[
            Container(
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  Image.network(
                    'http://exueshi.oss-cn-hangzhou.aliyuncs.com/productLogo/2018-12-7-1544154824445.jpg',
                    fit: BoxFit.fitHeight,
                  ),
                  Container(
                    child: Text(
                      '预售中',
                      style: TextStyle(color: Colors.white, fontSize: 11.0),
                    ),
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    padding: EdgeInsets.only(
                        left: 4.5, top: 2.0, right: 4.5, bottom: 2.0),
                  ),
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
                          '新大纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲考点补充精讲班—文科文科',
                          style: TextStyle(color: Colors.black),
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.videocam,
                            color: Color.fromRGBO(0, 145, 219, 0.6),
                          ),
                          Text(
                            '视频名称',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                        ]),
                    Text('2019-12-25之前有效',
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Color.fromRGBO(153, 153, 153, 1))),
                  ],
                ),
              ),
            ),
          ],
        )),
  );
}

Future _refreshList() async {
  Completer _completer = new Completer();
  await Future.delayed(Duration(seconds: 2), () {
    _completer.complete(null);
  });
  return _completer.future;
}
