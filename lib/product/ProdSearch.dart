import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';

class ProdSearch extends StatefulWidget {
  @override
  _ProdSearchState createState() => _ProdSearchState();
}

class _ProdSearchState extends State<ProdSearch> {
  FocusNode focusNode;

  TextEditingController textEditingController = TextEditingController();

  int pageLoadStatus = 1;
  var prodList;

  String searchContent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.addListener(() {
      print(textEditingController.text);
    });
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
                    onSubmitted: (v) {
                      // 搜索
                      setState(() {
                        searchContent = v;
                      });
                      getSearchData();
                    },
                  ),
                ),
                GestureDetector(
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
        return Center(
          child: Text('还没有搜索历史'),
        );
        break;
      case 2:
        return renderSearchData();
        break;
      case 3:
        return Center(
          child: Text('很遗憾，未找到您想要的产品'),
        );
        break;
      case 4:
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

  Widget renderSearchData() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('综合排序'),
          ],
        ),
        Expanded(
            child: ListView.builder(
                itemCount: prodList.length,
                itemBuilder: (context, index) {
                  return Container();
                })),
      ],
    );
  }

  Map buildQueryData() {
    Map map = {
      'type': 'ProdCenterREC',
      'page': 1,
      'num': 10,
      'search': {'condition': searchContent}
    };
    return map;
  }

  void getSearchData() async {
    print(buildQueryData());
    return;
    Ajax ajax = new Ajax();
    Response response =
        await ajax.post('/api/Product/getProducts', data: buildQueryData());
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
