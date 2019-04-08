import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponCenter extends StatefulWidget {
  @override
  _CouponCenterState createState() => _CouponCenterState();
}

class _CouponCenterState extends State<CouponCenter> {
  int pageLoadStatus = 1;
  List couponList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCouponList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('优惠券中心'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: renderBody(),
    );
  }

  Widget renderBody() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return ListView.builder(
            itemCount: couponList.length,
            itemBuilder: (context, index) {
              return renderItem(couponList[index]);
            });
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

  Widget renderItem(item) {
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
            renderCouponBottom(item)
          ],
        ),
      ),
    );
  }

  Widget renderCouponBottom(item) {
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

    switch (item.status) {
      case '未领取':
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                useRange,
                style: TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1), fontSize: 12.0),
              ),
            ),
            GestureDetector(
              child: Text(
                '领取',
                style: TextStyle(color: Color.fromRGBO(255, 102, 0, 1)),
              ),
              onTap: () {
                print('领用');
              },
            ),
          ],
        );
        break;
      case '去使用':
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
              '去使用',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ],
        );
        break;
      case '已领完':
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
              '已领完',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ],
        );
        break;
      case '已结束':
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
              '已结束',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ],
        );
        break;
      default:
        return Container();
    }
  }

  void getCouponList() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _user = _pref.getString('userData');
    if (_user != null) {
      Map user = json.decode(_user);
      Ajax ajax = new Ajax();
      Response response = await ajax
          .post('/api/coupon/getCoupons', data: {'userID': user['userID']});
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          couponList = ret['data'];
          pageLoadStatus = 2;
        } else {
          couponList = [];
          pageLoadStatus = 3;
        }
      } else {
        pageLoadStatus = 4;
      }
      setState(() {});
    }
  }
}
