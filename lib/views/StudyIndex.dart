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
      body: RefreshIndicator(
          child: Column(
            children: <Widget>[
              TabBar(
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
              Expanded(
                child: TabBarView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _tabController,
                  children: <Widget>[
                    Container(
                        color: Color.fromRGBO(241, 241, 241, 1),
                        child: Center(
                          child: Text('正在学习'),
                        )),
                    Container(
                      color: Color.fromRGBO(241, 241, 241, 1),
                      child: Center(
                        child: Text('学习完成'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onRefresh: () {
            setState(() {});
          }),
    );
  }
}
