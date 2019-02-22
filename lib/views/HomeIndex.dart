import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/product/Cart.dart';
import 'package:flutter_exueshi/sign/login.dart';
import 'package:flutter_exueshi/product/ProdItem.dart';
import 'package:flutter_exueshi/study/LivingRoom.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<HomeIndex> with AutomaticKeepAliveClientMixin {
  var _banners = [];
  var _bulletions = [];
  var _livings = [];
  var _products = [];

  var loginData;

  var _pageLoadingStatus = 1; // 1：加载中 | 2：完成 | 3：失败

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  // 获取登录数据
  _getPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginData = prefs.getString('loginData') ?? ''; // 首次使用记录数据
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHomeData();
    _getPreference();
  }

  @override
  Widget build(BuildContext context) {
    final clientWidth = MediaQuery
        .of(context)
        .size
        .width;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        brightness: Brightness.light,
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        title: Container(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              Text(
                '重庆',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.0,
                color: Colors.white,
              ),
              Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 20.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.search,
                          color: Colors.black12,
                        ),
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        actions: <Widget>[
          Stack(
            alignment: Alignment(0.5, -0.5),
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                  ),
                  onPressed: () {
                    print(loginData);
                    if (loginData == '') {
                      Navigator.of(context).push(CustomRoute(Login()));
                    } else {
                      Navigator.of(context).push(CustomRoute(Cart()));
                    }
                  }),
              Container(
                child: Center(
                    child: Text(
                      '99+',
                      style: TextStyle(fontSize: 10.0),
                    )),
                decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                width: 18.0,
                height: 18.0,
              ),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        child: _renderPage(),
        onRefresh: _getHomeData,
      ),
    );
  }

  // 获取主页数据
  Future _getHomeData() async {
    final Completer completer = new Completer();

    Dio dio = new Dio();
    dio.options.baseUrl = 'http://ns.seevin.com';
    dio.options.responseType = ResponseType.JSON;

    Response response = await dio
        .post('/api/Product/getProductBannerBulletion', data: {'areas': '全国'});

    Response response2 =
    await dio.post('/api/live/getLives', data: {'page': 1});

    // 判断返回结果
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        _banners = ret['data']['banners'];
        _bulletions = ret['data']['bulletions'];
        _products = ret['data']['products'];
      }
    } else {
      print("网络错误!");
    }

    if (response2.statusCode == 200) {
      var ret2 = response2.data;
      if (ret2['code'].toString() == '200') {
        _livings = ret2['data'];
      }
    }

    _pageLoadingStatus = 2;
    setState(() {});

    completer.complete(true);
    return completer.future;
  }

  // 渲染根据数据加载状态来渲染页面
  Widget _renderPage() {

    final clientWidth = MediaQuery
        .of(context)
        .size
        .width;

    switch (_pageLoadingStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        int productsCount = _products.length;
        int otherCount = 0;
        if (_banners.length > 0) {
          otherCount += 1;
        }
        if (_bulletions.length > 0) {
          otherCount += 1;
        }
        if (_livings.length > 0) {
          otherCount += 1;
        }
        return ListView.builder(
            itemCount: productsCount + otherCount,
            itemBuilder: (BuildContext text, int index) {
              if (index == 0 && _banners.length > 0) {
                return Container(
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(
                        _banners[index]['adPicUrl'],
                        fit: BoxFit.fill,
                      );
                    },
                    itemCount: _banners.length,
                    pagination: SwiperPagination(),
                    loop: false,
                    onTap: (index) {
                      print(index);
                      Navigator.of(context).push(CustomRoute(LivingRoom()));
                    },
                  ),
                  width: clientWidth,
                  height: clientWidth * 159 / 375,
                );
              } else if (index == 1 && _bulletions.length > 0) {
                return _noticeBar();
              } else if (index == 2 && _livings.length > 0) {
                return _livingContainer();
              } else if (index >= otherCount) {
                return _courseContainer(index - otherCount);
              }
            });
        break;
      case 3:
        return Center(child: Text('无数据'),);
        break;
      case 4:
        return Center(child: Text('网络错误'),);
        break;
      default:
        return Center(child: Text('未知错误'),);
    }
  }

  // 课程列表
  Widget _courseContainer(index) {
    if (index == 0) {
      return Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text(''),
                    width: 5.0,
                    height: 20.0,
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 145, 219, 1),
                        borderRadius: BorderRadius.all(Radius.circular(2.5))),
                  ),
                  Text(
                    '精品好课',
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ],
              )),
          Container(
              margin: EdgeInsets.only(top: 15.0),
              child: _buildCourseItem(index)),
        ],
      );
    } else {
      return _buildCourseItem(index);
    }
  }

  Widget _buildCourseItem(index) {
    return InkResponse(
      child: Container(
        height: 100.0,
        padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/loading.gif',
                      image: _products[index]['logo'],
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 6.5, top: 4.0, right: 6.5, bottom: 4.0),
                    child: Text(
                      _products[index]['status'],
                      style: TextStyle(fontSize: 11.0, color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.9),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(2.5))),
                  ),
                ],
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
                          _products[index]['prodName'],
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "￥" + _products[index]['realPrice'].toString(),
                            style: TextStyle(
                                color: Color.fromRGBO(255, 102, 0, 1),
                                fontSize: 18,
                                fontFamily: 'PingFang-SC-Bold'),
                          ),
                          Text(
                            '原价:￥' + _products[index]['price'],
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11.0,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                        ]),
                    Row(children: <Widget>[
                      Expanded(
                        child: Row(
                          children: List.generate(5, (int i) {
                            if (i < _products[index]['avgRating']) {
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
                      Text(
                          '已有' +
                              _products[index]['learnPeopleCount'].toString() +
                              '人学习',
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Color.fromRGBO(153, 153, 153, 1)))
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .push(CustomRoute(ProdItem(product: _products[index])));
      },
    );
  }

  // 公告栏
  Widget _noticeBar() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 45.0,
      margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(204, 204, 204, 1), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 45.0,
            child: Image.asset(
              'assets/images/news.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            margin:
            EdgeInsets.only(left: 10.0, top: 6.5, right: 10.0, bottom: 6.5),
            color: Color.fromRGBO(204, 204, 204, 1),
            width: 0.5,
          ),
          Expanded(
            child: Swiper(
              key: Key('noticeBar'),
              containerHeight: 45.0,
              scrollDirection: Axis.vertical,
              itemCount: _bulletions.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _bulletions[index]['bulletionTitle'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15.0,
                            color: Color.fromRGBO(102, 102, 102, 1)),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(
                        _bulletions[index]['onlineTime'],
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromRGBO(153, 153, 153, 1)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 直播列表
  Widget _livingContainer() {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  child: Text(''),
                  width: 5.0,
                  height: 20.0,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 145, 219, 1),
                      borderRadius: BorderRadius.all(Radius.circular(2.5))),
                ),
                Text(
                  '直播课程',
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ],
            )),
        Container(margin: EdgeInsets.only(top: 15.0), child: _livingList()),
      ],
    );
  }

  Widget _livingList() {
    if (_livings.length == 0) {
      return Text('');
    } else if (_livings.length == 1) {
      return Text('1');
    } else if (_livings.length == 2) {
      return Container(
        padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(26, 81, 170, 0.1),
                            blurRadius: 15.0)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(
                                Radius.circular(2.5)),
                            child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/loading.gif',
                                image: _livings[0]['logo'])),
                      ),
                      Text(
                        _livings[0]['liveName'],
                        style: TextStyle(fontSize: 15.0, letterSpacing: 0.15),
                      ),
                      Text('主讲老师:' + _livings[0]['mainLecturer'].toString()),
                      Text('直播时间:' + _livings[0]['beginHourTime'].toString())
                    ],
                  ),
                )),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(26, 81, 170, 0.1),
                            blurRadius: 15.0)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/loading.gif',
                              image: _livings[1]['logo']),
                        ),
                      ),
                      Text(_livings[1]['liveName']),
                      Text('主讲老师:' + _livings[1]['mainLecturer'].toString()),
                      Text('直播时间:' + _livings[1]['beginHourTime'].toString())
                    ],
                  ),
                )),
          ],
        ),
      );
    } else {
      //return Text('length:'+_livings.length.toString());
      var clientWidth = MediaQuery
          .of(context)
          .size
          .width;
      var itemWidth = (clientWidth - 50) / 2;
      var itemHeight = itemWidth * 160 / 222;
      return Container(
        height: 250.0,
        margin: EdgeInsets.only(bottom: 10.0),
        color: Colors.white,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _livings.length,
            itemBuilder: (BuildContext context, int index) {
              double marginLeft = 0;
              if (index == 0) {
                marginLeft = 10.0;
              }
              return Container(
                width: itemWidth,
                height: itemHeight,
                margin: EdgeInsets.only(
                    left: marginLeft, top: 5.0, right: 10.0, bottom: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color.fromRGBO(26, 81, 170, 0.1),
                          blurRadius: 15.0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: _livings[index]['logo'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _livings[index]['liveName'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0, bottom: 10),
                            child: Text(
                              '主讲老师:' +
                                  _livings[index]['mainLecturer'].toString(),
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Color.fromRGBO(51, 51, 51, 1)),
                            ),
                          ),
                          Text(
                            '直播时间:' +
                                _livings[index]['beginHourTime'].toString(),
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
      );
    }
  }
}
