import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_exueshi/common/Ajax.dart';

class ProductIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<ProductIndex>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  int _pageLoadingStatus = 1; // 页面加载状态

  TabController _tabController;
  ScrollController _scrollController = ScrollController();

  int _page = 1;

  var _prodList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    _getProductList();

    // 监听页面滚动到底部
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('bottom');
        setState(() {
          _page++;
        });
        // 加载更多
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('选课中心'),
        elevation: 1.0,
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {})
        ],
        bottom: TabBar(
          tabs: <Tab>[
            Tab(
              text: '全部',
            ),
            Tab(
              text: '题库',
            ),
            Tab(
              text: '微课',
            ),
            Tab(
              text: '全程课',
            ),
            Tab(
              text: '定制课',
            ),
            Tab(
              text: '讲义',
            ),
          ],
          controller: _tabController,
          isScrollable: true,
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
            color: Color.fromRGBO(241, 241, 241, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('综合排序'),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14.0,
                ),
                Container(
                  width: 15.0,
                ),
                Text('筛选'),
                Icon(
                  Icons.filter_list,
                  size: 14.0,
                ),
              ],
            ),
          ),
          Expanded(
              child: _renderPage()),
        ],
      ),
    );
  }


  Widget _renderPage() {
    switch (_pageLoadingStatus) {
      case 1:
        return Center(child: CupertinoActivityIndicator(),);
        break;
      case 2:
        return RefreshIndicator(
            child: GridView.count(
              controller: _scrollController,
              crossAxisCount: 2,
              padding: EdgeInsets.all(10.0),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 172.5 / 190,
              // 设置item 的宽高比
              children: List.generate(_prodList.length, (index) {
                return _renderCourseItem(_prodList[index], index);
              }),
            ),
            onRefresh: _getProductList);
        break;
      case 3:
        return Center(child: Text('暂无数据'),);
        break;
      case 4:
        return Center(child: Text('网络错误'),);
        break;
      default:
        return Center(child: Text('未知错误'),);
        break;
    }
  }

  Future _getProductList() async {
    Completer _completer = new Completer();

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProducts', data: {
      'page': _page,
      'num': 10,
      'type': 'ProdCenterREC',
      'search': {
        'area': '重庆'
      }
    });

    if (response.statusCode == 200) {
      var ret = response.data;
      print(ret);

      if (ret['code'].toString() == '200') {
        _prodList = ret['data'];
      }
    }

    setState(() {
      _pageLoadingStatus = 2;
    });

    await Future.delayed(Duration(seconds: 1), () {
      _completer.complete(null);
    });

    return _completer.future;
  }

// 课程item组件
  Widget _renderCourseItem(item, index) {
    print(item);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 5.0),
          ]
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Image.network(
                item['logo'],
                fit: BoxFit.fill,
              ),
            ),
            Text(item['prodName'],
                overflow: TextOverflow.ellipsis, maxLines: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '￥500',
                    style: TextStyle(
                        color: Color.fromRGBO(255, 102, 0, 1),
                        fontSize: 18,
                        fontFamily: 'PingFang-SC-Bold'),
                  ),
                  Text(
                    '原价:￥500',
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 11.0,
                        color: Color.fromRGBO(153, 153, 153, 1)),
                  ),
                ]),
            Row(children: <Widget>[
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    if (index < 3) {
                      return Icon(
                        Icons.star,
                        size: 10.5,
                        color: Color.fromRGBO(255, 204, 0, 1),
                      );
                    } else {
                      return Icon(
                        Icons.star_border,
                        size: 10.5,
                        color: Color.fromRGBO(255, 204, 0, 1),
                      );
                    }
                  }),
                ),
              ),
              Text('已有13215人学习',
                  style: TextStyle(
                      fontSize: 10.0, color: Color.fromRGBO(153, 153, 153, 1)))
            ]),
          ],
        ),
      ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

