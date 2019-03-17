import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrder extends StatefulWidget {
  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> with SingleTickerProviderStateMixin {
  TabController tabController;

  var orderAll;
  var orderPaying;
  var orderFinish;
  var orderClose;

  int pageLoadStatus = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);

    getMyOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 241, 241, 1),
      appBar: AppBar(
        elevation: 1.0,
        title: Text('我的订单'),
        centerTitle: true,
        bottom: TabBar(
          tabs: <Tab>[
            Tab(
              text: '全部订单',
            ),
            Tab(
              text: '待支付',
            ),
            Tab(
              text: '交易完成',
            ),
            Tab(
              text: '交易关闭',
            ),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
          controller: tabController,
          children: List.generate(4, (index) {
            return renderTabView();
          })),
    );
  }

  // 获取所有订单
  void getMyOrderList() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String _user = _pref.getString('userData');

    int status;

    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = Ajax();
      Response response = await ajax.post('/api/order/getOrders',
          data: {'userID': userData['userID'], 'page': 1, 'num': 500});

      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          print(ret);
          orderAll = ret['data'];
          status = 2;
        } else {
          status = 3;
        }
      } else {
        status = 4;
      }
    }
    setState(() {
      pageLoadStatus = status;
    });
  }

  Widget renderTabView() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return ListView.builder(
            itemCount: orderAll.length,
            itemBuilder: (context, index) {
              return renderOrderItem(orderAll[index]);
            });
        break;
      case 3:
        return Center(
          child: Text('暂无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('数据请求错误'),
        );
        break;
    }
  }

  Widget renderOrderItem(orderItem) {
    print(orderItem);

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('订单号:' + orderItem['orderID']),
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            color: Color.fromRGBO(250, 250, 250, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(orderItem['list'].length, (index) {
                var item = orderItem['list'][index];
                return renderContent(item);
              }),
            ),
          ),
          Padding(padding: EdgeInsets.all(10.0), child: renderBottom(orderItem))
        ],
      ),
    );
  }

  Widget renderContent(item) {
    print(item);

    return Container(
      height: 100,
      margin: EdgeInsets.only(bottom: 10.0),
      child: MaterialButton(
        padding: EdgeInsets.all(0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  child: Image.network(
                    item['logo'],
                    height: 90,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      item['targetType'].toString() == '产品'
                          ? Text(
                              item['prodName'].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Row(
                              children: List.generate(2, (index) {
                                if (index == 0) {
                                  switch (item['prodContentType'].toString()) {
                                    case '视频':
                                      return Icon(MyIcons.video);
                                      break;
                                    case '试卷':
                                      return Icon(MyIcons.paper);
                                      break;
                                    case '资料':
                                      return Icon(MyIcons.document);
                                      break;
                                    default:
                                      return Container();
                                  }
                                } else {
                                  return Text(
                                    item['prodContentName'].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                              }),
                            ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        '￥' + item['payPrice'].toString(),
                        style: TextStyle(color: Color.fromRGBO(255, 102, 0, 1)),
                      )
                    ],
                  ),
                ),
              )
            ]),
        onPressed: () {
          print(item);
          Navigator.of(context).push(PageRouter(ProdDetail(
            prodID: item['prodID'],
          )));
        },
      ),
    );
  }

  Widget renderBottom(item) {
    switch (item['orderStatus'].toString()) {
      case '已支付':
        return Row(
          children: <Widget>[
            Text('实际支付：'),
            Text('￥' + item['realPay'].toString(),
                style: TextStyle(color: Color.fromRGBO(255, 102, 0, 1))),
            Expanded(
              child: Container(),
            ),
            Text(
              '交易成功',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1)),
            )
          ],
        );
        break;
      case '待支付':
        return Row(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Text(
                  '关闭交易',
                  style: TextStyle(
                      fontSize: 12.0, color: Color.fromRGBO(153, 153, 153, 1)),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                        color: Color.fromRGBO(226, 226, 226, 1), width: 0.5)),
              ),
              onTap: () {
                print('关闭交易');
              },
            ),
            Container(
              width: 10.0,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Text(
                  '去付款',
                  style: TextStyle(
                      fontSize: 12.0, color: Color.fromRGBO(255, 255, 255, 1)),
                ),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 102, 0, 1),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                        color: Color.fromRGBO(255, 102, 0, 1), width: 0.5)),
              ),
              onTap: () {
                print('关闭交易');
              },
            ),
          ],
        );
        break;
      case '已取消':
        return Align(
            alignment: Alignment.centerRight,
            child: Text(
              '交易关闭',
            ));
        break;
      default:
        return Container();
    }
  }
}
