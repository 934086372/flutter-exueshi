import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/LabelList.dart';
import 'package:flutter_exueshi/components/SlideSheet.dart';
import 'package:flutter_exueshi/product/Cart.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:flutter_exueshi/product/ProdSearch.dart';
import 'package:flutter_exueshi/product/SwitchProjectAndArea.dart';

class ProductIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<ProductIndex>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int pageLoadStatus = 1; // 页面加载状态

  TabController _tabController;
  ScrollController _scrollController = new ScrollController();

  int _page = 1;

  var _prodList;

  bool showGetMore = false;

  final GlobalKey _childKey = GlobalKey();

  int prodType = 0;

  Map _initial = {'project': '专升本', 'area': '重庆'};

  List orderList = ['综合排序', '最热优先', '最新优先', '价格升序', '价格降序'];
  String orderItem;

  List subjectList = ['语文', '数学', '英语', '计算机'];
  Set selectedSubject;

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: 6, vsync: this)
      ..addListener(() {
        SlideSheet.dismiss();
        int _tabIndex = _tabController.index;
        if (_tabController.indexIsChanging) {
          setState(() {
            prodType = _tabIndex;
            pageLoadStatus = 1;
            refreshProdList();
          });
        }
      });

    // 监听页面滚动到底部
    _scrollController.addListener(() {
      if (!mounted) return;
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

    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..forward();

    _animation = Tween(begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0)).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _getProductList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              SlideSheet.dismiss();
              Navigator.of(context).push(PageRouter(ProdSearch()));
            }),
        title: renderTitle(),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                SlideSheet.dismiss();
                Navigator.of(context).push(PageRouter(Cart()));
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            key: _childKey,
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
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(Icons.menu),
                  ),
                  onTap: showModalSheet,
                )
              ],
            ),
          ),
          Expanded(
              child: Stack(
                children: <Widget>[
                  _renderPage(),
                ],
              )),
          renderBottom()
        ],
      ),
    );
  }

  void changeSubjectArea() async {
    SlideSheet.dismiss();
    var ret = await Navigator.of(context)
        .push(PageRouter(SwitchProjectAndArea(data: _initial)));
    if (ret != null)
      setState(() {
        _initial = ret;
      });
  }

  Widget _renderPage() {
    switch (pageLoadStatus) {
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
            onRefresh: refreshProdList);
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

  Widget renderTitle() {
    return GestureDetector(
      onTap: changeSubjectArea,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Builder(builder: (context) {
            String title = _initial['project'].toString() +
                '-' +
                _initial['area'].toString();
            return title.length > 10
                ? Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                : Text(
              title,
              style: TextStyle(fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
            );
          }),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20.0,
          )
        ],
      ),
    );
  }

  void showModalSheet() {
    RenderBox _box = _childKey.currentContext.findRenderObject();

    // 计算顶部透明区域大小
    double _topHeight =
        kToolbarHeight + MediaQuery
            .of(context)
            .padding
            .top + _box.size.height;
    double _defaultHeight = MediaQuery
        .of(context)
        .size
        .height * 0.5;

    SlideSheet.show(
        context,
        _topHeight,
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.white,
            height: _defaultHeight,
            child: Scaffold(
              body: renderMenuContent(),
              backgroundColor: Color.fromRGBO(251, 251, 251, 1),
            ),
          ),
        ));
  }

  Widget renderMenuContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15.0),
                    child: Text(
                      '产品排序',
                      style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 10.0),
                    child: LabelList(
                      data: orderList,
                      initialValue: orderItem,
                      onChanged: (v) {
                        orderItem = v;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15.0),
                    child: Text(
                      '学科选择',
                      style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 10.0),
                    child: LabelList(
                      data: subjectList,
                      isMultipleSelect: true,
                      initialValue: selectedSubject,
                      onChanged: (v) {
                        selectedSubject = v;
                      },
                    ),
                  )
                ],
              ),
            )),
        Row(
          children: <Widget>[
            Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      orderItem = null;
                      selectedSubject = null;
                      showModalSheet();
                    });
                  },
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: Text(
                        '重置',
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                      ),
                    ),
                  ),
                )),
            Expanded(
                child: GestureDetector(
                  onTap: () {
                    SlideSheet.dismiss();
                    setState(() {
                      pageLoadStatus = 1;
                      refreshProdList();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    color: Colors.lightBlueAccent,
                    child: Center(
                      child: Text(
                        '确定',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }

  Widget renderBottom() {
    if (showGetMore == false) return Container();
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SlideTransition(
          position: _animation,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        margin: EdgeInsets.only(top: 10.0),
        color: Colors.transparent,
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
      ),
    );
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
                child: Image.network(
                  item['logo'],
                  fit: BoxFit.fill,
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
                                fontSize: 16,
                                fontFamily: 'PingFang-SC-Bold'),
                          ),
                          Text(
                            '原价:￥' + item['price'].toString(),
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10.0,
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

  Map buildSearch() {
    // 筛选条件
    Map searchData = {'area': _initial['area'], 'catName': _initial['project']};
    if (selectedSubject != null)
      searchData.addAll({'course': selectedSubject.toList()});

    String prodTypeText;
    switch (prodType) {
      case 0:
        break;
      case 1:
        prodTypeText = '试卷';
        break;
      case 2:
        prodTypeText = '视频';
        break;
      case 3:
        prodTypeText = '套餐';
        break;
      case 4:
        prodTypeText = '计划';
        break;
      case 5:
        prodTypeText = '资料';
        break;
      default:
    }
    if (prodTypeText != null) searchData.addAll({'prodType': prodTypeText});
    return searchData;
  }

  Map buildOrder() {
    Map order;
    switch (orderItem) {
      case '综合排序':
        break;
      case '最热优先':
        order = {'saleMoneySum': 'desc'};
        break;
      case '最新优先':
        order = {'saleOnTime': 'desc'};
        break;
      case '价格降序':
        order = {'price': 'desc'};
        break;
      case '价格升序':
        order = {'price': 'asc'};
        break;
      default:
        break;
    }

    return order;
  }

  Map buildQueryData(page) {
    Map queryData = {
      'page': page,
      'num': 10,
      'type': 'ProdCenterREC',
      'search': buildSearch()
    };
    Map order = buildOrder();
    if (order != null) {
      queryData.addAll({'order': order});
    }
    return queryData;
  }

  Future _getProductList() async {
    Completer _completer = new Completer();

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProducts',
        data: buildQueryData(_page));

    if (response.statusCode == 200) {
      var ret = response.data;

      if (ret['code'].toString() == '200') {
        if (_prodList == null) {
          _prodList = ret['data'];
        } else {
          _prodList.addAll(ret['data']);
        }
        pageLoadStatus = 2;
      } else {
        if (_page == 1) {
          pageLoadStatus = 3;
        }
      }
    } else {
      pageLoadStatus = 4;
    }

    setState(() {
      showGetMore = false;
    });

    await Future.delayed(Duration(seconds: 1), () {
      _completer.complete(null);
    });

    return _completer.future;
  }

  // 下拉刷新重新加载数据
  Future refreshProdList() async {
    Completer _completer = new Completer();
    Ajax ajax = new Ajax();
    Response response =
    await ajax.post('/api/Product/getProducts', data: buildQueryData(1));
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        _prodList = ret['data'];
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
    }
    setState(() {});
    _completer.complete(null);
    return _completer.future;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
