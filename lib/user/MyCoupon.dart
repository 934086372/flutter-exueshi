import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/user/CouponCenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCoupon extends StatefulWidget {
  @override
  _MyCouponState createState() => _MyCouponState();
}

class _MyCouponState extends State<MyCoupon> with TickerProviderStateMixin {
  TabController tabController;

  var accessCouponList;
  var usedCouponList;
  var invalidCouponList;

  List<String> tabName = ['可使用', '已使用', '已过期'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(() {
      getMyCoupon(tabController.index);
    });

    getMyCoupon(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(241, 241, 241, 1),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: TextField(
            decoration: InputDecoration(
                hintText: '请输入优惠券兑换码',
                hintStyle: TextStyle(fontSize: 14.0),
                fillColor: Color.fromRGBO(241, 241, 241, 1),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                border: InputBorder.none),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text('兑换', style: TextStyle(fontSize: 16.0)),
            onPressed: () {},
          )
        ],
        bottom: TabBar(controller: tabController, tabs: <Tab>[
          Tab(
            text: tabName[0],
          ),
          Tab(
            text: tabName[1],
          ),
          Tab(
            text: tabName[2],
          )
        ]),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: TabBarView(
                  controller: tabController,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: renderTabView(index),
                    );
                  }))),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(PageRouter(CouponCenter()));
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  '去领券中心',
                  style: TextStyle(
                      color: Color.fromRGBO(0, 145, 219, 1), fontSize: 16.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget renderTabView(tabIndex) {
    var data;

    switch (tabIndex) {
      case 0:
        data = accessCouponList;
        break;
      case 1:
        data = usedCouponList;
        break;
      case 2:
        data = invalidCouponList;
        break;
    }

    if (data == null)
      return Center(
        child: CupertinoActivityIndicator(),
      );

    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var item = data[index];

          String validText;
          if (item['validType'] == '永久') {
            validText = '有效期: 永久有效';
          } else {
            validText = '有效期：' + item['validEndTime'] + '前有效';
          }

          return Card(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            elevation: 1.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('￥',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 0, 0, 1),
                                    )),
                                Text(
                                  '500',
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 0, 0, 1),
                                      fontSize: 40.0),
                                ),
                              ],
                            ),
                            Text('满1000元可用')
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item['couponName'].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  fontSize: 14.0),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              child: Text(item['useType'].toString(),
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 145, 219, 1),
                                      fontSize: 10.0)),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  border: Border.all(
                                      color: Color.fromRGBO(0, 145, 219, 1),
                                      width: 0.5,
                                      style: BorderStyle.solid)),
                            ),
                            Text(
                              validText,
                              style: TextStyle(
                                  color: Color.fromRGBO(102, 102, 102, 1),
                                  fontSize: 12.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    height: 0.5,
                    color: Color.fromRGBO(241, 241, 241, 1),
                  ),
                  renderCouponBottom(tabIndex, item)
                ],
              ),
            ),
          );
        });
  }

  Widget renderCouponBottom(tabIndex, item) {
    String useRange;

    switch (item['useRange']) {
      case 1:
        useRange = '全部产品可用';
        break;
      case 2:
        useRange = '非折扣产品可用';
        break;
      case 3:
        useRange = '指定产品可用';
        break;
    }

    switch (tabIndex) {
      case 0:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                useRange,
                style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1), fontSize: 12.0),
              ),
            ),
            Text(
              '去使用>',
              style: TextStyle(color: Color.fromRGBO(255, 102, 0, 1)),
            ),
          ],
        );
        break;
      case 1:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                useRange,
                style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1), fontSize: 12.0),
              ),
            ),
            Text(
              '已使用',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ],
        );
        break;
      case 2:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                useRange,
                style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1), fontSize: 12.0),
              ),
            ),
            Text(
              '已失效',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ],
        );
        break;
      default:
        return Container();
    }
  }

  /*
  * 获取优惠券数据
  * */
  void getMyCoupon(tabIndex) async {
    var couponList = [];

    switch (tabIndex) {
      case 0:
        if (accessCouponList != null) return;
        break;
      case 1:
        if (usedCouponList != null) return;
        break;
      case 2:
        if (invalidCouponList != null) return;
        break;
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);
      String userID = userData['userID'];
      Ajax ajax = new Ajax();
      Response response = await ajax.post('/api/coupon/getUserCoupons', data: {
        'userID': userID,
        'page': 1,
        'num': 500,
        'status': tabName[tabIndex]
      });
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          couponList = ret['data'];
        } else {
          couponList = [];
        }
      } else {
        print('网络请求错误');
      }
    } else {}

    switch (tabIndex) {
      case 0:
        accessCouponList = couponList;
        break;
      case 1:
        usedCouponList = couponList;
        break;
      case 2:
        invalidCouponList = couponList;
        break;
    }

    setState(() {});
  }
}
