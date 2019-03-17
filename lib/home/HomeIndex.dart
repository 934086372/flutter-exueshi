import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/home/BannerDetail.dart';
import 'package:flutter_exueshi/home/NoticeDetail.dart';
import 'package:flutter_exueshi/home/SwitchCity.dart';
import 'package:flutter_exueshi/home/VideoTest.dart';
import 'package:flutter_exueshi/product/Cart.dart';
import 'package:flutter_exueshi/product/ProdSearch.dart';
import 'package:flutter_exueshi/sign/Login.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:flutter_exueshi/study/LivingRoom.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_bus/event_bus.dart';

class HomeIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<HomeIndex> with AutomaticKeepAliveClientMixin {
  String city = '全国';

  var _banners = [];
  var _bulletions = [];
  var _livings = [];
  var _products = [];

  var loginData;

  double clientWidth;

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
    clientWidth = MediaQuery
        .of(context)
        .size
        .width;

    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: renderHeader(),
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

    Ajax ajax = new Ajax();

    Response response = await ajax
        .post('/api/Product/getProductBannerBulletion', data: {'areas': city});

    Response response2 =
    await ajax.post('/api/live/getLives', data: {'page': 1});

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
    switch (_pageLoadingStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              renderBanner(),
              renderNotice(),
              renderLiveCourse(),
              Column(
                children: List.generate(_products.length, (index) {
                  return renderCourseItem(index);
                }),
              ),
              GestureDetector(
                onTap: () {
                  print('more');
                  EventBus eventBus = new EventBus();
                  eventBus.fire('changeMainTab');
                  eventBus.fire('changeMainTab');
                },
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: Text('查看更多'),
                ),
              )
            ],
          ),
        );
      case 3:
        return Center(
          child: Text('无数据'),
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
    }
  }

  Widget renderHeader() {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: resetCity,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.location_on,
              ),
              Text(
                city,
                style: TextStyle(fontSize: 14.0),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.0,
              ),
            ],
          ),
        ),
        Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(PageRouter(ProdSearch()));
              },
              child: Container(
                height: 35,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Material(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color.fromRGBO(241, 241, 241, 1),
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.search,
                      color: Colors.black12,
                    ),
                    padding: EdgeInsets.only(right: 10.0),
                  ),
                ),
              ),
            )),
        GestureDetector(
            child: Stack(
              children: <Widget>[
                Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: Icon(
                    Icons.shopping_cart,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 0,
                  child: Container(
                    child: Center(
                        child: Text(
                          '50',
                          style: TextStyle(fontSize: 8.0),
                        )),
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    width: 16.0,
                    height: 16.0,
                  ),
                )
              ],
            ),
            onTap: () {
              print(loginData);
              if (loginData == '') {
                Navigator.of(context).push(PageRouter(Login()));
              } else {
                Navigator.of(context).push(PageRouter(Cart()));
              }
            })
      ],
    );
  }

  // 渲染banner
  Widget renderBanner() {
    if (_banners.length > 0)
      return AspectRatio(
        aspectRatio: 75 / 32,
        child: Swiper(
          layout: SwiperLayout.DEFAULT,
          viewportFraction: 0.8,
          scale: 0.9,
          itemBuilder: (BuildContext context, int index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                _banners[index]['adPicUrl'],
                fit: BoxFit.fill,
              ),
            );
          },
          itemCount: _banners.length,
          pagination: SwiperPagination(),
          loop: true,
          autoplay: true,
          duration: 5,
          onTap: (index) {
            Navigator.of(context)
                .push(PageRouter(BannerDetail(bannerItem: _banners[index])));
          },
        ),
      );
    return Container();
  }

  // 公告栏
  Widget renderNotice() {
    return Container(
      height: 45.0,
      margin: EdgeInsets.all(10.0),
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
              onTap: (index) {
                print(index);
                print(_bulletions[index]);
                Navigator.of(context)
                    .push(PageRouter(Notice(noticeItem: _bulletions[index])));
              },
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
                        _bulletions[index]['onlineTime']
                            .toString()
                            .substring(0, 10),
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
  Widget renderLiveCourse() {
    return _livings.length > 0
        ? Column(
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
                      borderRadius:
                      BorderRadius.all(Radius.circular(2.5))),
                ),
                Text(
                  '直播课程',
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ],
            )),
        Container(
            margin: EdgeInsets.only(top: 15.0), child: _livingList()),
      ],
    )
        : Container();
  }

  // 直播课列表
  Widget _livingList() {
    if (_livings.length == 0) {
      return Container();
    } else if (_livings.length == 1) {
      return renderOnlyLive(_livings[0]);
    } else if (_livings.length == 2) {
      return Container(
        padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: Row(
          children: <Widget>[
            renderTwoLive(_livings[0]),
            renderTwoLive(_livings[1])
          ],
        ),
      );
    } else {
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
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(PageRouter(LivingRoom(product: _livings[index])));
                },
                child: Container(
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
                ),
              );
            }),
      );
    }
  }

  Expanded renderTwoLive(item) {
    return Expanded(
        child: Container(
          margin: EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
            BoxShadow(color: Color.fromRGBO(26, 81, 170, 0.1), blurRadius: 15.0)
          ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: item['logo'])),
              ),
              Text(
                item['liveName'],
                style: TextStyle(fontSize: 15.0, letterSpacing: 0.15),
              ),
              Text('主讲老师:' + item['mainLecturer'].toString()),
              Text('直播时间:' + item['beginHourTime'].toString())
            ],
          ),
        ));
  }

  Widget renderOnlyLive(item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouter(LivingRoom(product: item)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color.fromRGBO(26, 81, 170, 0.1), blurRadius: 15.0)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                item['liveName'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17.0),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: item['logo']),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('主讲老师:' + item['mainLecturer'].toString()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text('直播时间:' + item['beginHourTime'].toString()),
                      ),
                      Container(
                        child: Text(
                          item['liveType'].toString(),
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color.fromRGBO(102, 102, 102, 1)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(215, 218, 219, 0.4),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0))),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 课程列表
  Widget renderCourseItem(index) {
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
    var item = _products[index];

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
                      image: item['logo'],
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 6.5, top: 4.0, right: 6.5, bottom: 4.0),
                    child: Text(
                      item['status'],
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
                          item['prodName'],
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        )),
                    item['dataFlag'] != '免费'
                        ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "￥" + item['realPrice'].toString(),
                            style: TextStyle(
                                color: Color.fromRGBO(255, 102, 0, 1),
                                fontSize: 18,
                                fontFamily: 'PingFang-SC-Bold'),
                          ),
                          Text(
                            '原价:￥' + item['price'],
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11.0,
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                        ])
                        : Text('免费'),
                    Row(children: <Widget>[
                      Expanded(
                        child: Row(
                          children: List.generate(5, (int i) {
                            if (i < item['avgRating']) {
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
                      Text('已有' + item['learnPeopleCount'].toString() + '人学习',
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
            .push(PageRouter(ProdDetail(prodID: item['prodID'])));
      },
    );
  }

  void resetCity() async {
    final _city = await Navigator.of(context).push(PageRouter(SwitchCity()));
    setState(() {
      city = _city;
      _getHomeData();
    });
  }
}