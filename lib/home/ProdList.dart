import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';

class ProdList extends StatefulWidget {
  final String searchParams;

  const ProdList({Key key, this.searchParams}) : super(key: key);

  @override
  _ProdListState createState() => _ProdListState();
}

class _ProdListState extends State<ProdList> {
  String get searchParams => widget.searchParams;

  int pageLoadStatus = 1;
  List prodList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProdList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('推荐产品'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: renderBody(),
      backgroundColor: Colors.white,
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
            padding: EdgeInsets.only(top: 10.0),
            itemCount: prodList.length,
            itemBuilder: (context, index) {
              return renderItem(prodList[index]);
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
    return InkWell(
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

  // 获取推荐的产品列表数据
  void getProdList() async {
    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProductsBySearchUrl',
        data: {'url': searchParams, 'page': 1, 'num': 50});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        prodList = ret['data'];
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
    }
    setState(() {});
  }
}
