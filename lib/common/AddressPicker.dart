import 'package:flutter/material.dart';

class AddressPicker extends StatefulWidget {
  @override
  _AddressPickerState createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  var data = {
    "topCitys": [
      {"id": 100000, "city": "全国", "pinyin": "全国"},
      {"id": 500000, "city": "重庆", "pinyin": "chongqing"},
      {"id": 530000, "city": "云南", "pinyin": "yunnan"},
      {"id": 520000, "city": "贵州", "pinyin": "guizhou"},
      {"id": 510000, "city": "四川", "pinyin": "sichuan"}
    ],
    "citys": [
      {"id": "110000", "city": "北京", "pinyin": "beijing"},
      {"id": "120000", "city": "天津", "pinyin": "tianjin"},
      {"id": "130000", "city": "河北", "pinyin": "hebei"},
      {"id": "140000", "city": "山西", "pinyin": "shanxi"},
      {"id": "150000", "city": "内蒙古", "pinyin": "neimenggu"},
      {"id": "210000", "city": "辽宁", "pinyin": "liaoning"},
      {"id": "220000", "city": "吉林", "pinyin": "jilin"},
      {"id": "230000", "city": "黑龙江", "pinyin": "heilongjiang"},
      {"id": "310000", "city": "上海", "pinyin": "shanghai"},
      {"id": "320000", "city": "江苏", "pinyin": "jiangsu"},
      {"id": "330000", "city": "浙江", "pinyin": "zhejiang"},
      {"id": "340000", "city": "安徽", "pinyin": "anhui"},
      {"id": "350000", "city": "福建", "pinyin": "fujian"},
      {"id": "360000", "city": "江西", "pinyin": "jiangxi"},
      {"id": "370000", "city": "山东", "pinyin": "shandong"},
      {"id": "410000", "city": "河南", "pinyin": "henan"},
      {"id": "420000", "city": "湖北", "pinyin": "hubei"},
      {"id": "430000", "city": "湖南", "pinyin": "hunan"},
      {"id": "440000", "city": "广东", "pinyin": "guangdong"},
      {"id": "450000", "city": "广西", "pinyin": "guangxi"},
      {"id": "460000", "city": "海南", "pinyin": "hainan"},
      {"id": "500000", "city": "重庆", "pinyin": "chongqing"},
      {"id": "510000", "city": "四川", "pinyin": "sichuan"},
      {"id": "520000", "city": "贵州", "pinyin": "guizhou"},
      {"id": "530000", "city": "云南", "pinyin": "yunnan"},
      {"id": "540000", "city": "西藏", "pinyin": "xizang"},
      {"id": "610000", "city": "陕西", "pinyin": "shanxi"},
      {"id": "620000", "city": "甘肃", "pinyin": "gansu"},
      {"id": "630000", "city": "青海", "pinyin": "qinghai"},
      {"id": "640000", "city": "宁夏", "pinyin": "ningxia"},
      {"id": "650000", "city": "新疆", "pinyin": "xinjiang"},
      {"id": "710000", "city": "台湾", "pinyin": "taiwan"},
      {"id": "810000", "city": "香港", "pinyin": "xianggang"},
      {"id": "820000", "city": "澳门", "pinyin": "aomen"}
    ]
  };

  ScrollController scrollController;
  TextEditingController textEditingController;
  bool showClearIcon = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 格式化数据
    formatData();

    scrollController =
        ScrollController(keepScrollOffset: true, debugLabel: 'addressScroller');

    // 监听文本框
    textEditingController = new TextEditingController()
      ..addListener(() {
        showClearIcon = textEditingController.text != '';
        setState(() {});
      });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            margin: EdgeInsets.all(10.0),
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
                      print(v);
                    },
                  ),
                ),
                showClearIcon
                    ? GestureDetector(
                        onTap: () {
                          textEditingController.clear();
                        },
                        child: Icon(
                          Icons.clear,
                          color: Color.fromRGBO(153, 153, 153, 1),
                          size: 20.0,
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          Expanded(
            child: renderAddressList(),
          )
        ],
      ),
    );
  }

  Widget renderAddressList() {
    List addressList = formatData();

    return Row(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              controller: scrollController,
              itemCount: addressList.length,
              itemBuilder: (context, index) {
                var group = addressList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 40,
                      key: Key(index.toString()),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      color: Color.fromRGBO(241, 241, 241, 1),
                      child: Align(
                        child: Text(group['label'].toString()),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(group['list'].length, (i) {
                        var item = group['list'][i];
                        return InkWell(
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                            child: Container(
                              height: 45,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Align(
                                child: Text(item.toString()),
                                alignment: Alignment.centerLeft,
                              ),
                            ));
                      }),
                    )
                  ],
                );
              }),
        ),
        SingleChildScrollView(
          child: Column(
            children: List.generate(addressList.length, (index) {
              return GestureDetector(
                onTap: () {
                  // 计算偏移
                  double offset = index * 40.0;
                  for (int i = 0; i < index; i++) {
                    offset += addressList[i]['list'].length * 45.0;
                  }
                  scrollController.animateTo(offset,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(addressList[index]['label'].toString()),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  List formatData() {
    var result = [];

    var list0 = [];
    data['topCitys'].forEach((item) {
      list0.add(item['city']);
    });
    result.add({'label': '热门城市', 'list': list0});
    Set indexSet = new Set();
    data['citys'].forEach((item) {
      String firstChar = item['pinyin'].toString().substring(0, 1);
      indexSet.add(firstChar);
    });
    List _tmpList = indexSet.toList();
    _tmpList.sort((left, right) => left.compareTo(right));

    _tmpList.forEach((index) {
      var groupList = [];
      data['citys'].forEach((item) {
        String firstChar = item['pinyin'].toString().substring(0, 1);
        indexSet.add(firstChar);
        if (firstChar == index) {
          groupList.add(item['city']);
        }
      });
      result.add({'label': index.toString().toUpperCase(), 'list': groupList});
    });
    return result;
  }
}
