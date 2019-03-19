import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/product/Cart.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:flutter_exueshi/product/ProdSearch.dart';

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

  bool showGetMore = false;

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
        setState(() {
          showGetMore = true;
          _page++;
          _getProductList();
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
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(PageRouter(ProdSearch()));
              }),
          IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).push(PageRouter(Cart()));
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TabBar(
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
                IconButton(
                  icon: Icon(Icons.format_list_bulleted),
                  onPressed: () {},
                )
              ],
            ),
          ),
          Expanded(child: _renderPage()),
          showGetMore
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CupertinoActivityIndicator(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '加载中',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _renderPage() {
    switch (_pageLoadingStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return RefreshIndicator(
            child: GridView.count(
              controller: _scrollController,
              crossAxisCount: 2,
              padding: EdgeInsets.all(10.0),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 8 / 9.5,
              // 设置item 的宽高比
              children: List.generate(_prodList.length, (index) {
                return _renderCourseItem(_prodList[index], index);
              }),
            ),
            onRefresh: _getProductList);
        break;
      case 3:
        return Center(
          child: Text('暂无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络错误'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
        break;
    }
  }

  Widget renderAppBar() {
    return Row(
      children: <Widget>[],
    );
  }

  Future _getProductList() async {
    Completer _completer = new Completer();

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProducts', data: {
      'page': _page,
      'num': 10,
      'type': 'ProdCenterREC',
      'search': {'area': '重庆'}
    });

    if (response.statusCode == 200) {
      var ret = response.data;

      if (ret['code'].toString() == '200') {
        if (_prodList == null) {
          _prodList = ret['data'];
        } else {
          _prodList.addAll(ret['data']);
        }
      }
    }

    setState(() {
      _pageLoadingStatus = 2;
      showGetMore = false;
    });

    await Future.delayed(Duration(seconds: 1), () {
      _completer.complete(null);
    });

    return _completer.future;
  }

// 课程item组件
  Widget _renderCourseItem(item, index) {
    String _learnPeopleCount = item['learnPeopleCount'].toString() + '人已学习';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouter(ProdDetail(
          prodID: item['prodID'],
        )));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 5.0),
        ]),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    topRight: Radius.circular(5.0)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/loading.gif',
                  image: item['logo'],
                  fit: BoxFit.fill,
                  /* child: Image.network(
                    item['logo'],
                    fit: BoxFit.fill,
                  ),*/
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item['prodName'],
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                    item['prodFlag'] == '免费'
                        ? Text(
                            '免费',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 102, 0, 1),
                                fontSize: 18,
                                fontFamily: 'PingFang-SC-Bold'),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Text(
                                  '￥' + item['realPrice'].toString(),
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 102, 0, 1),
                                      fontSize: 18,
                                      fontFamily: 'PingFang-SC-Bold'),
                                ),
                                Text(
                                  '原价:￥' + item['price'].toString(),
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
                            if (index < item['avgRating']) {
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
                      Text(_learnPeopleCount,
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Color.fromRGBO(153, 153, 153, 1)))
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
