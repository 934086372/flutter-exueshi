import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCollections extends StatefulWidget {
  @override
  _MyCollectionsState createState() => _MyCollectionsState();
}

class _MyCollectionsState extends State<MyCollections>
    with SingleTickerProviderStateMixin {
  int pageLoadStatus = 1;

  TabController tabController;

  var prodList;
  var videoList;
  var paperList;
  var documentList;
  var exerciseList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 5, vsync: this);

    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      getCollectData(tabController.index);
    });
    getCollectData(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('我的收藏'),
        centerTitle: true,
      ),
      body: renderPage(),
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return Column(
          children: <Widget>[
            TabBar(
                labelColor: Colors.black,
                controller: tabController,
                tabs: <Tab>[
                  Tab(
                    text: '产品',
                  ),
                  Tab(
                    text: '视频',
                  ),
                  Tab(
                    text: '试卷',
                  ),
                  Tab(
                    text: '资料',
                  ),
                  Tab(
                    text: '试题',
                  )
                ]),
            Expanded(
                child: TabBarView(
                    controller: tabController,
                    children: List.generate(5, (index) {
                      return renderTabView(index);
                    })))
          ],
        );

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

  Widget renderTabView(tabIndex) {
    var data;
    switch (tabIndex) {
      case 0:
        data = prodList;
        break;
      case 1:
        data = videoList;
        break;
      case 2:
        data = paperList;
        break;
      case 3:
        data = documentList;
        break;
      case 4:
        data = exerciseList;
        break;
    }
    if (data == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Text('${index}');
        });
  }

  void getCollectData(tabIndex) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      var data;
      String apiUrl = '/api/Product/collectProContents';
      switch (tabIndex) {
        case 0:
          if (prodList != null) return;
          apiUrl = '/api/Product/collectProducts';
          data = {
            'userID': userData['userID'],
            'page': 1,
            'num': 500,
          };

          break;
        case 1:
          if (videoList != null) return;
          data = {
            'userID': userData['userID'],
            'page': 1,
            'num': 500,
            'type': 'video'
          };
          break;
        case 2:
          if (paperList != null) return;
          data = {
            'userID': userData['userID'],
            'page': 1,
            'num': 500,
            'type': 'paper'
          };
          break;
        case 3:
          if (documentList != null) return;
          data = {
            'userID': userData['userID'],
            'page': 1,
            'num': 500,
            'type': 'document'
          };
          break;
        case 4:
          if (exerciseList != null) return;
          apiUrl = '/api/Product/collectExercises';
          data = {'userID': userData['userID']};
          break;
        default:
          return;
      }

      var result;
      Ajax ajax = new Ajax();
      Response response = await ajax.post(apiUrl, data: data);
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          result = ret['data'];
          print('远程请求：' + result.toString());
        } else {
          result = [];
        }
      } else {
        result = false;
      }
      switch (tabIndex) {
        case 0:
          prodList = result;
          break;
        case 1:
          videoList = result;
          break;
        case 2:
          paperList = result;
          break;
        case 3:
          documentList = result;
          break;
        case 4:
          exerciseList = result;
          break;
      }
    } else {}
    setState(() {});
  }
}
