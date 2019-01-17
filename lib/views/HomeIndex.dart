import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dio/dio.dart';

class HomeIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Ad {
  final int adId;
  final String adName;
  final String adPicUrl;
  final String adPicName;
  final String adLink;

  Ad({this.adId, this.adName, this.adPicUrl, this.adPicName, this.adLink});

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      adId: json['ID'],
      adName: json['adName'],
      adPicUrl: json['adPicUrl'],
      adPicName: json['adPicName'],
      adLink: json['adLink'],
    );
  }
}

class Page extends State<HomeIndex> with AutomaticKeepAliveClientMixin {
  var _banners = [];
  var _bulletions = [];
  var _livings = [];
  var _products = [];

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHomeData();
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
          IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                print('购物车');
              })
        ],
      ),
      body: RefreshIndicator(
        child: FutureBuilder(
            future: _getHomeData(),
            builder: (context, snapshot) {
              // 产品的个数
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
              print(otherCount);
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Text('loading...'),
                  );
                  break;
                case ConnectionState.active:
                case ConnectionState.none:
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount: productsCount + otherCount,
                      itemBuilder: (BuildContext text, int index) {
                        if (index == 0) {
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
                            ),
                            width: clientWidth,
                            height: clientWidth * 159 / 375,
                          );
                        } else if (index == 1) {
                          return _noticeBar();
                        } else if (index == 2) {
                          return _livingContainer();
                        } else if (index >= otherCount) {
                          return _courseContainer(index - otherCount);
                        }
                      });
                  break;
              }
            }),
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

    completer.complete(true);
    return completer.future;
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
          Container(margin: EdgeInsets.only(top: 15.0),
              child: _buildCourseItem(index)),
        ],
      );
    } else {
      return _buildCourseItem(index);
    }
  }

  Widget _buildCourseItem(index) {
    return Container(
      height: 100.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Image.network(
              _products[index]['logo'],
              fit: BoxFit.fill,
            ),
            width: 160.0,
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
              'images/news.png',
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
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                          child: Image.network(
                            _livings[0]['logo'],
                            fit: BoxFit.fill,
                          ),
                        ),
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
                          child: Image.network(
                            _livings[1]['logo'],
                            fit: BoxFit.fill,
                          ),
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
                        child: Image.network(
                          _livings[index]['logo'],
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
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0, bottom: 10),
                            child: Text(
                              '主讲老师:' +
                                  _livings[index]['mainLecturer'].toString(),
                              style: TextStyle(fontSize: 14.0,
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
