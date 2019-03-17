import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<Cart> {
  List<String> items = List.generate(50, (int index) {
    return 'items $index';
  });
  var _selectAll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(items);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
        centerTitle: true,
        elevation: 1.0,
        actions: <Widget>[
          FlatButton(
              onPressed: () {},
              child: Text(
                '管理',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Column(
        children: <Widget>[_body(), _footer()],
      ),
    );
  }

  Widget _body() {
    return Expanded(
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onHorizontalDragStart: (direction) {
                print(direction);
              },
              onHorizontalDragDown: (pos) {

              },
              onHorizontalDragUpdate: (offset) {
                print(offset.delta.dx);
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.red,
                  ),
                  ListTile(
                    title: Text('title $index'),
                  )
                ],
              ),
            );
          }),
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
          Checkbox(
              value: _selectAll,
              onChanged: (value) {
                setState(() {
                  _selectAll = value;
                });
              }),
          Text('全选'),
          Expanded(
            child: Container(),
          ),
          Text(
            '合计:',
            style: TextStyle(fontSize: 17.0),
          ),
          Text(
            '￥498',
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
                onTap: () {},
              ))
        ],
      ),
    );
  }
}
