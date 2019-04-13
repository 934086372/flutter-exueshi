import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/ProdItem.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:flutter_exueshi/study/PaperIndex.dart';
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

  bool isExpanded = true;

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
        elevation: 0.0,
        title: Text('我的收藏'),
        centerTitle: true,
      ),
      body: renderPage(),
      backgroundColor: Colors.white,
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
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
        return renderProdList();
        break;
      case 1:
        data = videoList;
        break;
      case 2:
        data = paperList;
        return renderProdPaper();
        break;
      case 3:
        data = documentList;
        break;
      case 4:
        data = exerciseList;
        return renderExList();
        break;
    }
    if (data == null) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Text(index.toString());
        });
  }

  Widget renderProdList() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: prodList.length,
        itemBuilder: (context, index) {
          return ProdItem(
            item: prodList[index],
          );
        });
  }

  Widget renderProdVideo() {
    return ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          return ProdVideoItem();
        });
  }

  Widget renderProdPaper() {
    return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: paperList.length,
        itemBuilder: (context, index) {
          return ProdPaperItem(
            item: paperList[index],
          );
        });
  }

  Widget renderExList() {
    print(exerciseList);

    return ListView.builder(
        itemCount: exerciseList.length,
        itemBuilder: (context, index) {
          var group = exerciseList[index];
          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(group['prodName']),
            children: List.generate(group['list'].length, (i) {
              var item = group['list'][i];
              return ListTile(
                title: Text(item['paperName']),
              );
            }),
          );
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
          pageLoadStatus = 2;
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

class ProdVideoItem extends StatelessWidget {
  final Map item;

  const ProdVideoItem({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Ink(
      color: Colors.white,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: InkWell(
        child: Container(
          height: 100.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(2.5)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/loading.gif',
                  image: item['logo'],
                  fit: BoxFit.fill,
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        item['videoName'],
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Text('来自《' + item['prodName'] + '》'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(PageRouter(ProdDetail(prodID: item['prodID'])));
        },
      ),
    );
  }
}

class ProdPaperItem extends StatelessWidget {
  final Map item;

  const ProdPaperItem({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(2.5)),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/loading.gif',
              image: item['logo'],
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    item['paperName'],
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                    maxLines: 2,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  )),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text('试卷')),
                      GestureDetector(
                        child: Text(
                          '开始做题',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          print('开始做题');
                          Navigator.of(context).push(PageRouter(PaperIndex(
                            paperID: item['paperID'],
                            prodID: item['prodID'],
                            orderID: '',
                          )));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
