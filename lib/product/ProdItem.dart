import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/components/SliverAppBarDelegate.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/product/Cart.dart';

class ProdItem extends StatefulWidget {
  final product;

  ProdItem({@required this.product}) : super();

  @override
  State<ProdItem> createState() {
    return Page(product: product);
  }
}

class Page extends State<ProdItem> with TickerProviderStateMixin {
  final product;
  String prodType;

  var _chapter;

  var _commentList;
  var _commentStar;

  Page({@required this.product}) : super();

  TabController _controller;
  TabController _controllerChild;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = TabController(length: 3, vsync: this);
    _controllerChild = TabController(length: 3, vsync: this);

    switch (product['prodType']) {
      case '视频':
        prodType = 'video';
        break;
      case '试卷':
        prodType = 'paper';
        break;
      case '资料':
        prodType = 'document';
        break;
      case '计划':
        prodType = 'plan';
        break;
      case '套餐':
        prodType = 'package';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _getProdDetail(product);

    _getChapter();

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 190, 255, 1),
          elevation: 0.0,
          title: Text('产品详情'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(CustomRoute(Cart()));
                })
          ],
        ),
        body: FutureBuilder(
            future: _getProdDetail(product),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _body();
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Widget _body() {
    return Column(
      children: <Widget>[Expanded(child: _header()), _bottomBar()],
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(226, 226, 226, 1), width: 0.5))),
      child: Row(children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.share,
                      size: 16.0,
                    ),
                    Text('分享')
                  ],
                ),
              ),
              Container(
                width: 0.5,
                height: 40.0,
                color: Color.fromRGBO(226, 226, 226, 1),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      MyIcons.like_border,
                      size: 16.0,
                    ),
                    Text('收藏')
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color.fromRGBO(242, 182, 0, 1),
                Color.fromRGBO(242, 161, 0, 1)
              ],
            )),
            /*padding: EdgeInsets.all(0.0),*/

            child: FlatButton(
              onPressed: () {},
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text(
                  '加入购物车',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: Ink(
          child: FlatButton(
            onPressed: () {},
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Text(
                '立即购买',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[
              Color.fromRGBO(242, 126, 0, 1),
              Color.fromRGBO(242, 102, 0, 1)
            ],
          )),
        )),
      ]),
    );
  }

  Widget _header() {
    return DefaultTabController(
        length: 3,
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Image.network(product['logo']),
                ),
                SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                        minHeight: 50.0,
                        maxHeight: 50.0,
                        child: Container(
                          child: TabBar(
                              controller: _controller,
                              unselectedLabelColor:
                              Color.fromRGBO(51, 51, 51, 1),
                              labelColor: Color.fromRGBO(0, 145, 219, 1),
                              indicatorWeight: 1.0,
                              tabs: <Tab>[
                                Tab(
                                  text: '详情',
                                ),
                                Tab(
                                  text: '目录',
                                ),
                                Tab(
                                  text: '评价',
                                ),
                              ]),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              border: Border(
                                  bottom: BorderSide(
                                      color: Color.fromRGBO(226, 226, 226, 1),
                                      width: 0.5))),
                        ))),
              ];
            },
            body: TabBarView(controller: _controller, children: <Widget>[
              _tabPage1(product),
              _tabPage2(),
              _tabPage3()
            ])));
  }

  // 详情页
  Widget _tabPage1(product) {
    return ListView(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
          child: Text(
            product['prodName'].toString(),
            style:
                TextStyle(fontSize: 17.0, color: Color.fromRGBO(51, 51, 51, 1)),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          child: Row(
            children: <Widget>[
              Text(product['realPrice'].toString(),
                  style: TextStyle(
                      color: Color.fromRGBO(255, 102, 0, 1), fontSize: 18.0)),
              Container(
                margin: EdgeInsets.only(left: 5.0),
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    border: Border.all(color: Color.fromRGBO(255, 102, 0, 1))),
                child: Text(product['prodType'].toString(),
                    style: TextStyle(
                        fontSize: 11.0, color: Color.fromRGBO(255, 102, 0, 1))),
              ),
              Expanded(child: Container()),
              Text(
                product['avgRating'].toString() + '分',
                style: TextStyle(color: Color.fromRGBO(255, 102, 0, 1)),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          child: Row(
            children: <Widget>[
              Text('原价: ' + product['price'].toString(),
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Color.fromRGBO(102, 102, 102, 1))),
              Expanded(child: Container()),
              Text(
                '2018.9.2前有效',
                style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1)),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(product['learnPeopleCount'].toString() + '人在学习',
                  style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                  )),
              Expanded(child: Container()),
              Text(
                product['area'].toString(),
                style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1), fontSize: 11.0),
              ),
              Text(
                '  适用',
                style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1), fontSize: 12.0),
              )
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      width: 10.0, color: Color.fromRGBO(241, 241, 241, 1)))),
        ),
//        HtmlView(
////          data: product['prodDetail'].toString(),
//          data: '<img src="http://ns.seevin.com/ueditor/php/upload/image/20180725/1532503996245109.jpg"/>',
//          onLaunchFail: (url) {
//            print('fail');
//          },
//        )
      ],
    );
  }

  // 章节目录页
  Widget _tabPage2() {
    // 判断产品类型
    if (prodType == 'package') {
      // 套餐产品
      List<Tab> _tabs = new List<Tab>();
      List<Widget> _tabViews = new List<Widget>();
      var tabLength = 0;
      if (_chapter['videos'] != false) {
        tabLength++;
        _tabs.add(Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(MyIcons.video),
              Text('视频'),
            ],
          ),
        ));
        _tabViews.add(ListView(
          children: _getChapterItem(_chapter['videos']),
        ));
      }
      if (_chapter['papers'] != false) {
        tabLength++;
        _tabs.add(Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(MyIcons.paper),
              Text('试卷'),
            ],
          ),
        ));
        _tabViews.add(ListView(
          children: _getChapterItem(_chapter['papers']),
        ));
      }
      if (_chapter['documents'] != false) {
        tabLength++;
        _tabs.add(Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(MyIcons.document),
              Text('资料'),
            ],
          ),
        ));
        _tabViews.add(ListView(
          children: _getChapterItem(_chapter['documents']),
        ));
      }
      return DefaultTabController(
          length: tabLength,
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverAppBarDelegate(
                          minHeight: 50.0,
                          maxHeight: 50.0,
                          child: Container(
                            child: TabBar(
                                controller: _controllerChild,
                                unselectedLabelColor:
                                Color.fromRGBO(102, 102, 102, 1),
                                labelColor: Color.fromRGBO(51, 51, 51, 1),
                                indicatorWeight: 1.0,
                                indicatorColor: Colors.white,
                                labelStyle:
                                TextStyle(fontWeight: FontWeight.bold),
                                unselectedLabelStyle:
                                TextStyle(fontWeight: FontWeight.normal),
                                tabs: _tabs),
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ))),
                ];
              },
              body: TabBarView(
                  controller: _controllerChild, children: _tabViews)));
    } else {
      // 其它类型产品
      return ListView(
        children: _getChapterItem(_chapter),
      );
    }
  }

  // 设置目录列表
  List<Widget> _getChapterItem(data) {
    List<Widget> _list = new List<Widget>();
    for (int i = 0; i < data.length; i++) {
      var groupName = data[i]['groupName'].toString();
      bool isGrouped = groupName != '未分类';

      if (isGrouped) {
        // 有正常分组
        _list.add(ExpansionTile(
            title: Text(groupName),
            initiallyExpanded: true,
            children: List.generate(data[i].length, (int index) {
              var item = data[i]['list'][index];
              var itemName = '';
              var itemIcon;
              switch (item['type']) {
                case '视频':
                  itemIcon = Icon(MyIcons.video);
                  itemName = item['videoName'];
                  break;
                case '试卷':
                  itemIcon = Icon(MyIcons.paper);
                  itemName = item['paperName'];
                  break;
                case '资料':
                  itemIcon = Icon(MyIcons.document);
                  itemName = item['docAlias'];
                  break;
              }
              return ListTile(
                leading: itemIcon,
                title: Text(itemName),
              );
            })));
      } else {
        // 无分组
        for (int j = 0; j < data[i]['list'].length; j++) {
          var item = data[i]['list'][j];
          var itemName = '';
          var itemIcon;
          switch (item['type']) {
            case '视频':
              itemIcon = Icon(MyIcons.video);
              itemName = item['videoName'];
              break;
            case '试卷':
              itemIcon = Icon(MyIcons.paper);
              itemName = item['paperName'];
              break;
            case '资料':
              itemIcon = Icon(MyIcons.document);
              itemName = item['docAlias'];
              break;
          }
          _list.add(ListTile(
            leading: itemIcon,
            title: Text(itemName),
          ));
        }
      }
    }
    return _list;
  }

  // 评价页
  Widget _tabPage3() {
    return FutureBuilder(
        future: _getComments(),
        builder: (context, snapshot) {
          print(snapshot);

          if (snapshot.connectionState == ConnectionState.done) {
            print(_commentList.length);

            if (_commentList.length > 0) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _commentHeader(),
                    Expanded(
                        child: ListView.builder(
                            itemCount: _commentList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _commentItem(index);
                            })),
                  ],
                ),
              );
            } else {
              return Center(child: Text('暂无数据'),);
            }

          } else {
            return Center(
              child: Text('加载中...'),
            );
          }
        });
  }

  Widget _commentHeader() {
    var five = _commentStar['five'];
    var four = _commentStar['four'];
    var three = _commentStar['three'];
    var second = _commentStar['second'];
    var one = _commentStar['one'];
    var count = five + four + three + second + one;

    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(241, 241, 241, 1), width: 10.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '产品总评价',
            style:
                TextStyle(color: Color.fromRGBO(51, 51, 51, 1), fontSize: 17.0),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Text(
                        (product['avgRating'] + 0.0).toString(),
                        style: TextStyle(fontSize: 50.0),
                      ),
                    ),
                    /*Text(
                    '分',
                    style: TextStyle(fontSize: 17.0),
                  )*/
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(5, (int index) {
                  return Row(
                    children: <Widget>[
                      Row(
                        children: List.generate(5, (int i) {
                          if (i < 5 - index) {
                            return Icon(
                              Icons.star,
                              size: 12.0,
                              color: Color.fromRGBO(204, 204, 204, 1),
                            );
                          } else {
                            return Icon(
                              Icons.star,
                              size: 12.0,
                              color: Colors.white,
                            );
                          }
                        }),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 100.0,
                        ),
                      ),
                    ],
                  );
                }),
              ))
            ]),
          ),
        ],
      ),
    );
  }

  Widget _commentItem(index) {
    var item = _commentList[index];

    // 最后一条评论不显示底边
    var borderWidth = 0.5;
    if (index == _commentList.length - 1) {
      borderWidth = 0;
    }

    // 头像
    var avatar = item['portrait'] != null
        ? NetworkImage(item['portrait'])
        : AssetImage('images/avator.jpg');
    // 昵称
    var name = item['nickName'] != null ? item['nickName'] : '匿名用户';
    // 评论内容
    var content = item['content'] != null ? item['content'] : '';
    // 评论回复内容
    var replyContent = item['replyContent'] != null ? item['replyContent'] : '';

    Pattern pattern = ',';
    var labels = item['labels'].toString().split(pattern);

    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(207, 207, 207, 1),
                  width: borderWidth))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: CircleAvatar(
              backgroundImage: avatar,
            ),
            margin: EdgeInsets.only(right: 10.0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(name)),
                    Row(
                      children: List.generate(5, (index) {
                        if (index < item['score']) {
                          return Icon(
                            Icons.star,
                            size: 10.0,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          );
                        } else {
                          return Icon(
                            Icons.star_border,
                            size: 10.0,
                            color: Color.fromRGBO(255, 204, 0, 1),
                          );
                        }
                      }),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _commentTarget(item)),
                      Text(
                        item['scoreTime'].toString().substring(0, 10),
                        style: TextStyle(
                            color: Color.fromRGBO(153, 153, 153, 1),
                            fontSize: 12.0),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Row(
                      children: List.generate(labels.length, (int index) {
                    return Container(
                      margin: EdgeInsets.only(right: 5.0),
                      padding: EdgeInsets.only(left: 2.0, right: 2.0),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                            color: Color.fromRGBO(255, 102, 0, 1),
                            fontSize: 10.0),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2.5)),
                          border: Border.all(
                              color: Color.fromRGBO(255, 102, 0, 1))),
                    );
                  })),
                ),
                _commentContent(content),
                _commentReply(replyContent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 评论对象组件
  Widget _commentTarget(item) {
    switch (item['targetType']) {
      case '资料':
        return Row(
          children: <Widget>[
            Icon(
              MyIcons.document,
              size: 18.0,
              color: Color.fromRGBO(0, 145, 219, 1),
            ),
            Container(width: 5.0),
            Expanded(
                child: Text(
              '资料：' + item['targetName'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ))
          ],
        );
        break;
      case '试卷':
        return Row(
          children: <Widget>[
            Icon(
              MyIcons.paper,
              size: 18.0,
              color: Color.fromRGBO(0, 145, 219, 1),
            ),
            Container(width: 5.0),
            Expanded(
                child: Text('资料：' + item['targetName'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1))))
          ],
        );
        break;
      case '视频':
        return Row(
          children: <Widget>[
            Icon(
              MyIcons.video,
              size: 18.0,
              color: Color.fromRGBO(0, 145, 219, 1),
            ),
            Container(width: 5.0),
            Expanded(
                child: Text('资料：' + item['targetName'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1))))
          ],
        );
        break;
      default:
        return Row(
          children: <Widget>[
            Icon(
              MyIcons.document,
              size: 18.0,
              color: Color.fromRGBO(0, 145, 219, 1),
            ),
            Container(width: 5.0),
            Expanded(
                child: Text(
              '资料：' + item['targetName'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ))
          ],
        );
    }
  }

  // 评论内容小组件
  Widget _commentContent(content) {
    if (content != '') {
      return Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
          child: Text(content));
    } else {
      return Container();
    }
  }

  // 评论回复内容小组件
  Widget _commentReply(reply) {
    if (reply != '') {
      return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 10.0),
        padding:
            EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0, bottom: 10.0),
        decoration: BoxDecoration(color: Color.fromRGBO(241, 241, 241, 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '团队回复：',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
            Text(
              reply,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future _getProdDetail(product) async {
    Completer completer = new Completer();

    Ajax ajax = new Ajax();
    Response response = await ajax
        .post('/api/Product/getProduct', data: {'prodID': product['prodID']});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        product = ret['data'];
        completer.complete(product);
      }
    }

    return completer.future;
  }

  Future _getChapter() async {
    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Product/getProductLists',
        data: {'prodID': product['prodID'], 'type': prodType});
    if (response.statusCode == 200) {
      var ret = response.data;
      print(ret);
      _chapter = ret['data'];
    }
  }

  Future _getComments() async {
    Completer completer = new Completer();

    String prodID = this.product['prodID'];
    Ajax ajax = new Ajax();
    Response response = await ajax.post('/api/Appraise/getProAppraises',
        data: {'prodID': prodID, 'page': 1});
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        _commentList = ret['data'];
        _commentStar = ret['star'];
      } else {
        _commentList = [];
        _commentStar = [];
      }
    }
    completer.complete(true);
    completer.future;
  }
}
