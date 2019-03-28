import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirm extends StatefulWidget {
  final List prods;

  const OrderConfirm({Key key, this.prods}) : super(key: key);

  @override
  _OrderConfirmState createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  int pageLoadStatus = 2;

  List get prods => widget.prods;

  var couponList;

  int payMethod = 1; // 默认支付宝支付

  Set selectedCoupons = new Set();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('确认订单'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: renderBody(),
      backgroundColor: Color.fromRGBO(241, 241, 241, 1),
    );
  }

  Widget renderBody() {
    switch (pageLoadStatus) {
      case 1:
        return Center(child: CupertinoActivityIndicator());
        break;
      case 2:
        return Column(
          children: <Widget>[
            renderList(),
            renderBottom(),
          ],
        );
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
        break;
    }
  }

  Expanded renderList() {
    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Column(
            children: List.generate(prods.length, (index) {
              return renderListItem(prods[index]);
            }),
          ),
          GestureDetector(
            onTap: () {
              showPayMethod();
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: payMethod == 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text('支付方式'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            MyIcons.alipay,
                            size: 18,
                            color: Color.fromRGBO(0, 160, 233, 1),
                          ),
                        ),
                        Text('支付宝'),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.black26,
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text('支付方式'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            MyIcons.wepay,
                            size: 18,
                            color: Color.fromRGBO(9, 187, 7, 1),
                          ),
                        ),
                        Text('微信'),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.black26,
                        )
                      ],
                    ),
            ),
          ),
          Divider(
            height: 0.5,
            color: Color.fromRGBO(241, 241, 241, 1),
          ),
          GestureDetector(
            onTap: () {
              showCouponList();
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('优惠券'),
                  ),
                  Text('三张可用'),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.black26,
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: 10.0,
            color: Color.fromRGBO(241, 241, 241, 1),
          ),
        ],
      ),
    ));
  }

  // 渲染产品列表
  Widget renderListItem(item) {
    String prodName = item['prodName'].toString();
    String price = item['price'].toString();
    String realPrice = item['realPrice'].toString();
    String discount =
        (double.parse(item['price']) - double.parse(item['realPrice']))
            .toString();

    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  child: Image.network(
                    item['logo'],
                    height: 80,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      prodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('￥' + price),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0.5,
          color: Color.fromRGBO(241, 241, 241, 1),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('课程优惠'),
              ),
              Text('￥' + discount)
            ],
          ),
        ),
        Divider(
          height: 0.5,
          color: Color.fromRGBO(241, 241, 241, 1),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Text('小计：'),
              Text(
                '￥' + realPrice,
                style: TextStyle(
                    fontSize: 18.0, color: Color.fromRGBO(255, 102, 0, 1)),
              )
            ],
          ),
        ),
        Container(
          height: 5,
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg_border.png'),
                  repeat: ImageRepeat.repeatX)),
        )
      ],
    );
  }

  Container renderBottom() {
    return Container(
      height: 50.0,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Center(child: Text('合计：')),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('￥200.00',
                    style: TextStyle(
                        fontSize: 17.0, color: Color.fromRGBO(255, 102, 0, 1))),
                Text(
                  '减免￥400.00',
                  style: TextStyle(
                      fontSize: 11.0, color: Color.fromRGBO(153, 153, 153, 1)),
                )
              ],
            ),
          ),
          Container(
            color: Color.fromRGBO(255, 102, 0, 1),
            child: FlatButton(
              child: Text(
                '提交订单',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                print('提交订单');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget renderCouponItem(item) {
    bool isSelected = selectedCoupons.contains(item['couponID']);

    print(isSelected);

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
                IconButton(
                  icon: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                        )
                      : Icon(Icons.radio_button_unchecked),
                  onPressed: () {
                    if (isSelected) {
                      selectedCoupons.remove(item['couponID']);
                    } else {
                      selectedCoupons.add(item['couponID']);
                    }
                    setState(() {
                      print(selectedCoupons.length);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 展示支付方式列表
  void showPayMethod() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        '请选择支付方式',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  Ink(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          payMethod = 1;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              MyIcons.alipay,
                              color: Color.fromRGBO(0, 160, 233, 1),
                            ),
                            Expanded(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('支付宝'),
                            )),
                            payMethod == 1
                                ? Icon(
                                    Icons.check,
                                    size: 18.0,
                                    color: Colors.blue,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                  Ink(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          payMethod = 2;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              MyIcons.wepay,
                              color: Color.fromRGBO(9, 187, 1, 1),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('微信'),
                              ),
                            ),
                            payMethod == 2
                                ? Icon(
                                    Icons.check,
                                    size: 18.0,
                                    color: Colors.blue,
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // bottomSheet 展示优惠券列表
  void showCouponList() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          // 包一层 GestureDetector , 防止点击内容就关闭 sheet
          return GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('优惠券')),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: Color.fromRGBO(226, 226, 226, 1),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children:
                          List.generate(couponList['coupons'].length, (index) {
                        print(couponList['coupons'].length);
                        return renderCouponItem(couponList['coupons'][index]);
                      }),
                    ),
                  )),
                  Divider(
                    height: 0.5,
                    color: Color.fromRGBO(226, 226, 226, 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: GestureDetector(onTap: () {}, child: Text('确定')),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // 获取可用优惠券列表
  void getCoupons() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String user = _pref.getString('userData');
    if (user == null) {
      return;
    }
    List prodIDs = new List();
    prods.forEach((item) {
      prodIDs.add(item['prodID']);
    });
    var userData = json.decode(user);
    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/order/createOrderByCoupon',
        data: {'userID': userData['userID'], 'prodIDs': prodIDs});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        couponList = ret['data'];
      }
    }
  }
}
