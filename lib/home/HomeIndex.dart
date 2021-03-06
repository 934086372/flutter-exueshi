import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/ProdItem.dart';
import 'package:flutter_exueshi/home/BannerDetail.dart';
import 'package:flutter_exueshi/home/NoticeDetail.dart';
import 'package:flutter_exueshi/home/ProdList.dart';
import 'package:flutter_exueshi/home/SwitchCity.dart';
import 'package:flutter_exueshi/product/Cart.dart';
import 'package:flutter_exueshi/product/ProdSearch.dart';
import 'package:flutter_exueshi/sign/Login.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:flutter_exueshi/study/LivingRoom.dart';
import 'package:flutter_exueshi/user/CouponCenter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_exueshi/common/EventBus.dart';

class HomeIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<HomeIndex> with AutomaticKeepAliveClientMixin {
  /*
  * 页面加载状态
  *
  * 1：加载中
  * 2：成功加载数据
  * 3：无数据
  * 4：网络请求失败
  *
  * */
  // 默认页面加载状态
  int pageLoadStatus = 1;

  String currentCity = '全国';

  List bannerList = [];
  List newsList = [];
  List liveList = [];
  List prodList = [];

  Map examCountDown;
  bool showCountDown = true;

  var userData;

  int cartCount = 0;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHomeData();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: renderHeader(),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        child: renderPage(),
        onRefresh: getHomeData,
      ),
    );
  }

  // 渲染根据数据加载状态来渲染页面
  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              renderBanner(),
              renderNotice(),
              renderCountDown(),
              renderLiveCourse(),
              renderProdList(),
              renderBottom(),
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

  // 渲染页面顶部AppBar
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
                currentCity,
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
                cartCount > 0
                    ? Positioned(
                        top: 5,
                        right: 0,
                        child: Container(
                          child: Center(
                              child: Text(
                            cartCount.toString(),
                            style:
                                TextStyle(fontSize: 8.0, color: Colors.white),
                          )),
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          width: 16.0,
                          height: 16.0,
                        ),
                      )
                    : Container()
              ],
            ),
            onTap: () {
              if (userData == null) {
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
    if (bannerList == null || bannerList.length <= 0) return Container();
    return AspectRatio(
      aspectRatio: 75 / 32,
      child: Swiper(
        layout: SwiperLayout.DEFAULT,
        //viewportFraction: 0.8,
        //scale: 0.9,
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(0.0),
            child: Image.network(
              bannerList[index]['adPicUrl'],
              fit: BoxFit.fill,
            ),
          );
        },
        itemCount: bannerList.length,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
                color: Colors.white, activeColor: Colors.blue)),
        loop: true,
        autoplay: true,
        duration: 5,
        onTap: (index) {
          String link = bannerList[index]['adLink'].toString();
          Pattern _pattern = '&optType=openinapp';
          if (link.contains(_pattern)) {
            // APP 内页面路由跳转
            // 处理掉链接中 的 '#' ，防止 Uri 无法解析参数
            String _link = link.replaceAll(new RegExp('/#/'), '/');
            Uri _uri = Uri.parse(_link);

            var parameters = _uri.queryParameters;
            if (parameters['prodID'] != null) {
              Navigator.push(context,
                  PageRouter(ProdDetail(prodID: parameters['prodID'])));
              return;
            }
            if (parameters['optDestination'] == null) return;

            // 跳转至优惠券中心
            if (parameters['optDestination'] == 'couponMarket') {
              // 判断是否登录
              Widget _page = new CouponCenter();
              if (userData == null) {
                _page = new Login();
              }
              Navigator.of(context).push(PageRouter(_page));
              return;
            }

            // 跳转至推荐产品列表
            if (parameters['optDestination'] == 'prodList') {
              //
              String searchParams = link.toString().split('?')[1];
              Navigator.of(context)
                  .push(PageRouter(ProdList(searchParams: searchParams)));
            }
          } else {
            Navigator.of(context)
                .push(PageRouter(BannerDetail(bannerItem: bannerList[index])));
          }
        },
      ),
    );
  }

  // 公告栏
  Widget renderNotice() {
    if (newsList == null || newsList.length <= 0) return Container();
    return Container(
      height: 45.0,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(241, 241, 241, 1), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40.0,
            child: Image.asset(
              'assets/images/news.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            color: Color.fromRGBO(241, 241, 241, 1),
            width: 0.5,
          ),
          Expanded(
            child: Swiper(
              key: Key('noticeBar'),
              containerHeight: 40.0,
              scrollDirection: Axis.vertical,
              itemCount: newsList.length,
              onTap: (index) {
                Navigator.of(context)
                    .push(PageRouter(Notice(noticeItem: newsList[index])));
              },
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        newsList[index]['bulletionTitle'],
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
                        newsList[index]['onlineTime']
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

  // 倒计时
  Widget renderCountDown() {
    if (examCountDown == null || showCountDown == false) return Container();

    Widget content = Container();
    if (examCountDown['content'] != '') {
      content = Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: Text(examCountDown['content']),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                gradient: RadialGradient(colors: <Color>[
                  Color.fromRGBO(255, 221, 17, 1),
                  Color.fromRGBO(255, 178, 11, 1)
                ], radius: 1.5)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('距离考试还有'),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.0,
                      children: <Widget>[
                        renderCountDownItem(examCountDown['first'], 1),
                        renderCountDownItem(examCountDown['second'], 1),
                        renderCountDownItem(examCountDown['third'], 1),
                        renderCountDownItem('Days', 2),
                      ],
                    ),
                  ),
                  content,
                ],
              ),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              width: 40.0,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showCountDown = false;
                    });
                  },
                  child: Image.asset('assets/images/bg_countdown.png'))),
        ],
      ),
    );
  }

  Widget renderCountDownItem(text, type) {
    double fontSize = type == 1 ? 30.0 : 10.0;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: Color.fromRGBO(51, 51, 51, 1),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Center(
          child: Text(
            text.toString(),
            style: TextStyle(
                color: Color.fromRGBO(255, 221, 17, 1),
                fontSize: fontSize,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  // 直播列表
  Widget renderLiveCourse() {
    return liveList.length > 0
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
                  margin: EdgeInsets.only(top: 15.0),
                  child: renderLivingList()),
            ],
          )
        : Container();
  }

  // 直播课列表
  Widget renderLivingList() {
    if (liveList.length == 0) {
      return Container();
    } else if (liveList.length == 1) {
      return renderOneLive(liveList[0]);
    } else if (liveList.length == 2) {
      return Container(
        padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: Row(
          children: <Widget>[
            renderTwoLive(liveList[0]),
            renderTwoLive(liveList[1])
          ],
        ),
      );
    } else {
      var clientWidth = MediaQuery.of(context).size.width;
      var itemWidth = (clientWidth - 50) / 2;
      var itemHeight = itemWidth * 160 / 222;
      return Container(
        height: 250.0,
        margin: EdgeInsets.only(bottom: 10.0),
        color: Colors.white,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: liveList.length,
            itemBuilder: (BuildContext context, int index) {
              double marginLeft = 0;
              if (index == 0) {
                marginLeft = 10.0;
              }
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(PageRouter(LivingRoom(product: liveList[index])));
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
                            image: liveList[index]['logo'],
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
                              liveList[index]['liveName'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0, bottom: 10),
                              child: Text(
                                '主讲老师:' +
                                    liveList[index]['mainLecturer'].toString(),
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color.fromRGBO(51, 51, 51, 1)),
                              ),
                            ),
                            Text(
                              '直播时间:' +
                                  liveList[index]['beginHourTime'].toString(),
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

  Widget renderTwoLive(item) {
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

  Widget renderOneLive(item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouter(LivingRoom(product: item)));
      },
      child: Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
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
                  child: AspectRatio(
                    aspectRatio: 16.0 / 10.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                      child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: item['logo']),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('主讲老师:' + item['mainLecturer'].toString()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
  Widget renderProdList() {
    if (prodList.length == 0) return Container();
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
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
        Column(
          children: List.generate(prodList.length, (index) {
            return ProdItem(item: prodList[index]);
          }),
        )
      ],
    );
  }

  // 渲染底部查看更多
  Widget renderBottom() {
    if (prodList.length == 0) return Container();
    return GestureDetector(
      onTap: () {
        eventBus.emit('changeMainTab', '2');
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text('查看更多')),
      ),
    );
  }

  // 切换城市
  void resetCity() async {
    var _city = await Navigator.of(context).push(PageRouter(SwitchCity()));
    if (_city == null) return;
    setState(() {
      currentCity = _city;
      pageLoadStatus = 1;
    });
    getHomeData();
  }

  // 获取登录数据
  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userData = prefs.getString('userData'); // 用户登录数据
  }

  // 获取主页数据
  Future getHomeData() async {
    /*
    * 首页需要的相关数据
    *
    * 1. 城市 + 考试项目数据
    *
    * 2. banner数据
    *
    * 3. 公告数据
    *
    * 4. 考试倒计时数据
    *
    * 5. 直播课数据
    *
    * 6. 精品好课数据
    *
    * 7. 购物车数据
    *
    * */

    final Completer completer = new Completer();

    Ajax ajax = new Ajax();

    // 获取初始选择的考试项目与地区数据
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _initialSetting = _pref.getString('initialSetting');
    Map initialSetting = json.decode(_initialSetting);

    currentCity = initialSetting['area'];
    String catId = initialSetting['catItem']['ID'];

    Response response = await ajax.post(
        '/api/Product/getProductBannerBulletion',
        data: {'area': currentCity, 'catID': catId});

    Response response2 = await ajax.post('/api/live/getLives', data: {
      'page': 1,
      'search': {'area': currentCity}
    });

    // 判断返回结果
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        bannerList = ret['data']['banners'];
        newsList = ret['data']['bulletions'];
        prodList = ret['data']['products'];

        if (ret['data']['examineDay'] != '') {
          String tmp = '000' + ret['data']['examineDay'].toString();
          examCountDown = {
            'examineDay': ret['data']['examineDay'],
            'examineTime': ret['data']['examineTime'],
            'first': tmp[tmp.length - 3],
            'second': tmp[tmp.length - 2],
            'third': tmp[tmp.length - 1],
            'content': ret['data']['examineContent']
          };
        } else {
          examCountDown = null;
        }
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
      completer.complete(true);
      return completer.future;
    }

    if (response2.statusCode == 200) {
      var ret2 = response2.data;
      if (ret2['code'].toString() == '200') {
        liveList = ret2['data'];
      } else {
        liveList = [];
      }
    }

    // 购物车数据
    int _cartCount = _pref.getInt('cartCount');
    if (_cartCount != null) {
      cartCount = _cartCount;
    }
    setState(() {});
    completer.complete(true);
    return completer.future;
  }
}
