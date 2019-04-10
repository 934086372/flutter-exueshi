import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/components/ProdItem.dart';
import 'package:flutter_exueshi/components/SlideSheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdSearch extends StatefulWidget {
  @override
  _ProdSearchState createState() => _ProdSearchState();
}

class _ProdSearchState extends State<ProdSearch> {
  FocusNode focusNode;

  TextEditingController textEditingController = TextEditingController();

  int pageLoadStatus = 1;
  var prodList;

  var searchContent;

  List<String> searchHistory = new List<String>();

  GlobalKey _topBar = new GlobalKey();

  List orderList = ['综合排序', '最热优先', '最新优先', '价格升序', '价格降序'];
  String orderItem = '综合排序';

  int listLoadStatus = 2;
  ScrollController _scrollController = new ScrollController();
  int page = 1;
  bool showMore = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();

    // 监听输入框
    textEditingController.addListener(() {
      print(textEditingController.text);
      searchContent = textEditingController.text.toString().trim();
      if (searchContent == '') pageLoadStatus = 1;
      setState(() {});
    });

    // 监听滚动条时间
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // 滑倒底了
        setState(() {
          page++;
          showMore = true;
          print(_scrollController.position.pixels);
          print(_scrollController.position.maxScrollExtent);
          getSearchData();
        });
      }
    });
  }

  void init() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (_pref.getStringList('searchHistory') != null) {
      searchHistory = _pref.getStringList('searchHistory');
      print(searchHistory);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: renderSearchBar(),
      ),
      body: renderBody(),
    );
  }

  Widget renderSearchBar() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            margin: EdgeInsets.only(right: 25.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(241, 241, 241, 1),
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.search,
                    color: Color.fromRGBO(153, 153, 153, 1),
                  ),
                ),
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    scrollPadding: EdgeInsets.symmetric(vertical: 0.0),
                    style: TextStyle(fontSize: 14.0),
                    controller: textEditingController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0)),
                    onSubmitted: search,
                  ),
                ),
                searchContent == '' || searchContent == null
                    ? Container()
                    : GestureDetector(
                  onTap: () {
                    textEditingController.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    color: Color.fromRGBO(153, 153, 153, 1),
                    size: 20.0,
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Text(
            '取消',
            style: TextStyle(fontSize: 16.0),
          ),
        )
      ],
    );
  }

  Widget renderBody() {
    switch (pageLoadStatus) {
      case 1:
        return searchHistory.length > 0
            ? renderSearchHistory()
            : Center(
          child: Text('还没有搜索历史'),
        );
        break;
      case 2:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 3:
        return renderSearchData();
        break;
      case 4:
        return Center(
          child: Text('很遗憾，未找到您想要的产品'),
        );
        break;
      case 5:
        return Center(
          child: Text('网络请求失败'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  // 搜索历史界面
  Widget renderSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Text('最近搜索'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: List.generate(
                searchHistory.length < 20 ? searchHistory.length : 20, (index) {
              String _text = searchHistory[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    searchContent = _text;
                    textEditingController =
                    TextEditingController.fromValue(TextEditingValue(
                      text: _text,
                    ))
                      ..addListener(() {
                        if (textEditingController.text == '') {
                          setState(() {
                            pageLoadStatus = 1;
                          });
                        }
                      });
                    pageLoadStatus = 2;
                    page = 1;
                    getSearchData();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(226, 226, 226, 1),
                      border: Border.all(
                        color: Color.fromRGBO(226, 226, 226, 1),
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  padding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: Text(_text,
                      style: TextStyle(
                          color: Color.fromRGBO(51, 51, 51, 1),
                          fontSize: 14.0)),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  // 渲染搜索数据
  Widget renderSearchData() {
    print(prodList);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          key: _topBar,
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Text(orderItem),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.0,
                    )
                  ],
                ),
                onTap: () {
                  RenderBox _topBarWidget =
                  _topBar.currentContext.findRenderObject();
                  double paddingTop = kToolbarHeight +
                      _topBarWidget.size.height +
                      MediaQuery
                          .of(context)
                          .padding
                          .top;
                  SlideSheet.show(
                      context,
                      paddingTop,
                      Container(
                        color: Color.fromRGBO(251, 251, 251, 1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(orderList.length, (index) {
                            return renderOrderItem(orderList[index]);
                          }),
                        ),
                      ));
                },
              ),
              Expanded(child: Container()),
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.apps,
                      size: 16.0,
                    ),
                    Text('筛选'),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        Expanded(child: renderList()),
        renderBottom()
      ],
    );
  }

  Widget renderList() {
    switch (listLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        return ListView.builder(
            controller: _scrollController,
            itemCount: prodList.length,
            itemBuilder: (context, index) {
              return ProdItem(item: prodList[index]);
            });
        break;
      case 3:
        return Center(
          child: Text('抱歉，未筛选到您要的结果！'),
        );
        break;
      default:
        return Center(
          child: Text('未知错误'),
        );
    }
  }

  Widget renderBottom() {
    if (showMore == false) return Container();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      margin: EdgeInsets.only(top: 10.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CupertinoActivityIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              '加载中',
              style: TextStyle(fontSize: 14.0),
            ),
          )
        ],
      ),
    );
  }

  // 搜索
  void search(text) async {
    // 点击搜索，存储搜索历史
    searchContent = text.toString().trim();
    if (searchContent != '') {
      setState(() {
        pageLoadStatus = 2;
      });
      SharedPreferences _pref = await SharedPreferences.getInstance();
      var _searchHistory = _pref.getStringList('searchHistory');
      if (_searchHistory != null) searchHistory = _searchHistory;
      if (searchHistory.contains(searchContent) == false)
        searchHistory.add(searchContent);
      _pref.setStringList('searchHistory', searchHistory);
      getSearchData();
    }
  }

  Widget renderOrderItem(text) {
    bool isSelected = orderItem == text;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      color:
                      isSelected ? Colors.blue : Color.fromRGBO(51, 51, 51, 1)),
                )),
            isSelected
                ? Icon(
              Icons.check,
              size: 20.0,
              color: Colors.blue,
            )
                : Container()
          ],
        ),
      ),
      onTap: () {
        page = 1;
        listLoadStatus = 1;
        orderItem = text;
        SlideSheet.dismiss();
        setState(() {});
        getSearchData();
      },
    );
  }

  Map buildQueryData() {
    Map order;
    switch (orderItem) {
      case '综合排序':
        break;
      case '最热优先':
        order = {'saleMoneySum': 'desc'};
        break;
      case '最新优先':
        order = {'saleOnTime': 'desc'};
        break;
      case '价格降序':
        order = {'price': 'desc'};
        break;
      case '价格升序':
        order = {'price': 'asc'};
        break;
      default:
        break;
    }

    Map map = {
      'type': 'ProdCenterREC',
      'page': page,
      'num': 10,
      'search': {'condition': searchContent},
      'order': order
    };
    return map;
  }

  void getSearchData() async {
    Ajax ajax = new Ajax();
    Response response =
        await ajax.post('/api/Product/getProducts', data: buildQueryData());
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        if (prodList == null) {
          prodList = ret['data'];
        } else {
          prodList.addAll(ret['data']);
        }
        pageLoadStatus = 3;
        listLoadStatus = 2;
      } else {
        if (page == 1) {
          pageLoadStatus = 4;
          listLoadStatus = 3;
        }
      }
    } else {
      pageLoadStatus = 5;
    }

    setState(() {
      showMore = false;
    });
  }
}
