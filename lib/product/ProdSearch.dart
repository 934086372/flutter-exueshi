import 'package:flutter/material.dart';

class ProdSearch extends StatefulWidget {
  @override
  _ProdSearchState createState() => _ProdSearchState();
}

class _ProdSearchState extends State<ProdSearch> {
  FocusNode focusNode;

  TextEditingController textEditingController = TextEditingController();

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
        elevation: 1.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: renderSearchBar(),
      ),
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
                      print(v);
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
}
