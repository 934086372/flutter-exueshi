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

class Page extends State<HomeIndex> {
  List<Ad> _adList = new List<Ad>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getHomeData();
  }

  @override
  Widget build(BuildContext context) {
    _getHomeData();

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
        child: FutureBuilder<List<Ad>>(
            future: _getAd(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var bannersData = snapshot.data;
                return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (BuildContext text, int index) {
                      if (index == 0) {
                        return Container(
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return Image.network(
                                bannersData[index].adPicUrl,
                                fit: BoxFit.fill,
                              );
                            },
                            itemCount: bannersData.length,
                            pagination: SwiperPagination(),
                          ),
                          width: clientWidth,
                          height: clientWidth * 35 / 72,
                          padding: EdgeInsets.only(bottom: 10.0),
                        );
                      } else {
                        return _buildCourseItem(index);
                      }
                    });
              } else {
                return Text('loading');
              }
            }),
        onRefresh: _getData,
      ),
    );
  }

  Future<Ad> _getData() async {
    final Completer<Ad> completer = new Completer<Ad>();

    Response response;
    Dio dio = new Dio();
    dio.options.baseUrl = 'http://ns.seevin.com';
    dio.options.responseType = ResponseType.JSON;

    response = await dio.post('/api/home/sysad/banners', data: {'areas': '全国'});

    if (response.data['code'] == 200) {
      for (var adItem in response.data['data']) {
        var adModel = Ad.fromJson(adItem);
        _adList.add(adModel);
      }
    }
    completer.complete(null);

    return completer.future;
  }

  Future<List<Ad>> _getAd() async {
    Response response;
    Dio dio = new Dio();
    dio.options.baseUrl = 'http://ns.seevin.com';
    dio.options.responseType = ResponseType.JSON;
    response = await dio.post('/api/home/sysad/banners', data: {'areas': '全国'});
    if (response.data['code'] == 200) {
      for (var adItem in response.data['data']) {
        _adList.add(Ad.fromJson(adItem));
      }
      return _adList;
    } else {
      throw Exception('no data');
    }
  }

  void _getHomeData() async {
    Dio dio = new Dio();
    dio.options.baseUrl = 'http://ns.seevin.com';
    dio.options.responseType = ResponseType.JSON;

    Response response = await dio
        .post('/api/Product/getProductBannerBulletion', data: {'areas': '全国'});
    print(response.statusCode);
    // 判断返回结果
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        var banners = ret['data']['banners'];
        //var bulletions = ret['data']['bulletions'];
        //var products = ret['data']['products'];

        List<Ad> bannerList = new List<Ad>();
        for (var bannerItem in banners) {
          bannerList.add(Ad.fromJson(bannerItem));
        }
        _adList = bannerList;

        print(_adList.length);
      }
    } else {
      print("网络错误!");
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
              'http://exueshi.oss-cn-hangzhou.aliyuncs.com/productLogo/2018-12-7-1544154824445.jpg',
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
                        '新大纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲纲新大纲新大纲考点补充精讲班—文科文科',
                        style: TextStyle(color: Colors.black),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 10.5,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          ),
                          Icon(
                            Icons.star,
                            size: 10.5,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          ),
                          Icon(
                            Icons.star,
                            size: 10.5,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          ),
                          Icon(
                            Icons.star,
                            size: 10.5,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          )
                        ],
                      ),
                    ),
                    Text('已有13215人学习',
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
}
