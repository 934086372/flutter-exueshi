import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/SlideListTile.dart';
import 'package:flutter_exueshi/product/OrderConfirm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<Cart> with TickerProviderStateMixin {
  var _selectAll = false;
  int pageLoadStatus = 1;
  List cartList;

  Set selectedItem = new Set(); // 已选商品集合
  double orderAmount = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
              onPressed: () {},
              child: Text(
                '管理',
              ))
        ],
      ),
      body: Column(
        children: <Widget>[_body(), _footer()],
      ),
    );
  }

  Widget _body() {
    switch (pageLoadStatus) {
      case 1:
        return Center(child: CupertinoActivityIndicator());
        break;
      case 2:
        return Expanded(
          child: ListView.builder(
              itemCount: cartList.length,
              itemBuilder: (BuildContext context, int index) {
                return SlideListTile(
                  child: renderItem(cartList[index]),
                  menu: <Widget>[
                    FlatButton(
                        onPressed: () {},
                        child: Center(
                            child: Text(
                              '删除',
                              style: TextStyle(color: Colors.white),
                            )))
                  ],
                );
              }),
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

  Widget renderItem(item) {
    bool isSelected = selectedItem.contains(item['prodID']);

    return Container(
      height: 100,
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Align(
            child: GestureDetector(
              child: isSelected
                  ? Icon(
                Icons.check_circle,
                color: Color.fromRGBO(0, 170, 255, 1),
              )
                  : Icon(
                Icons.radio_button_unchecked,
                color: Color.fromRGBO(204, 204, 204, 1),
              ),
              onTap: () {
                if (isSelected) {
                  selectedItem.remove(item['prodID']);
                  orderAmount -= double.parse(item['realPrice']);
                } else {
                  selectedItem.add(item['prodID']);
                  orderAmount += double.parse(item['realPrice']);
                }
                _selectAll = selectedItem.length == cartList.length;
                setState(() {});
              },
            ),
          ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/loading.gif',
                  image: item['logo'].toString(),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  item['prodName'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(child: Container()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '￥' + item['realPrice'].toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(255, 102, 0, 1),
                          fontSize: 18.0),
                    ),
                    Text(
                      ' 原价:￥' + item['price'].toString(),
                      style: TextStyle(
                          fontSize: 11,
                          color: Color.fromRGBO(153, 153, 153, 1)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(226, 226, 226, 1), width: 0.5))),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: selectAll,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _selectAll
                  ? Icon(
                Icons.check_circle,
                color: Color.fromRGBO(0, 170, 255, 1),
              )
                  : Icon(
                Icons.radio_button_unchecked,
                color: Color.fromRGBO(204, 204, 204, 1),
              ),
            ),
          ),
          Text('全选'),
          Expanded(
            child: Container(),
          ),
          Text(
            '合计:',
            style: TextStyle(fontSize: 17.0),
          ),
          Text(
            '￥${orderAmount}',
            style: TextStyle(
                fontSize: 17.0, color: Color.fromRGBO(255, 102, 0, 1)),
          ),
          Container(width: 10.0),
          Ink(
              color: Color.fromRGBO(255, 102, 1, 1),
              child: InkWell(
                child: Container(
                  child: Text(
                    '结算',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  padding: EdgeInsets.only(
                      left: 25.0, top: 17.0, right: 25.0, bottom: 17.0),
                ),
                onTap: () {
                  // 判断有没有选中
                  if (selectedItem.length <= 0) {
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: Text('请先选择要结算的上品')));
                  } else {
                    List prods = List();
                    cartList.forEach((item) {
                      if (selectedItem.contains(item['prodID'])) {
                        prods.add(item);
                      }
                    });
                    Navigator.of(context)
                        .push(PageRouter(OrderConfirm(prods: prods)));
                  }
                },
              ))
        ],
      ),
    );
  }

  void selectAll() {
    if (_selectAll) {
      // 已全选
      selectedItem.clear();
      orderAmount = 0.0;
    } else {
      // 非全选
      cartList.forEach((item) {
        selectedItem.add(item['prodID']);
        orderAmount += double.parse(item['realPrice']);
      });
    }
    setState(() {
      _selectAll = !_selectAll;
    });
  }

  void getCartList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user == null) {
      setState(() {
        pageLoadStatus = 5;
      });
      return;
    }

    var user = json.decode(_user);

    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/user/cart/prods', data: {
      'userID': user['userID'],
      'token': user['token'],
      'page': 1,
      'num': 50
    });
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        cartList = ret['data'];
        pageLoadStatus = 2;
      } else {
        cartList = [];
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
    }
    setState(() {});
  }
}
