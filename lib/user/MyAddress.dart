import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/custom_router.dart';

class MyAddress extends StatefulWidget {
  @override
  _MyAddressState createState() => _MyAddressState();
}

class _MyAddressState extends State<MyAddress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('收货地址管理'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(CustomRoute(AddAddress(
                  action: 'add',
                )));
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 30.0, top: 80.0, right: 30.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                '还未添加收货地址，快去添加！',
                style: TextStyle(
                    fontSize: 17.0, color: Color.fromRGBO(51, 51, 51, 1)),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            Center(
              child: Text(
                '该地址仅用于当学员购买含实物赠品的课程或者购买实物教材时，平台方邮寄书籍使用',
                style: TextStyle(
                    fontSize: 14.0, color: Color.fromRGBO(153, 153, 153, 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddress extends StatefulWidget {
  final action;

  const AddAddress({Key key, this.action}) : super(key: key);

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  get action => widget.action;

  bool isDefault = true;

  String title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    title = action == 'add' ? '添加收货地址' : '编辑收货地址';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 241, 241, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text(title),
        centerTitle: true,
        actions: <Widget>[IconButton(icon: Icon(Icons.save), onPressed: () {})],
      ),
      body: renderBody(),
    );
  }

  Widget renderBody() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                padding: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(229, 229, 229, 0.5)))),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      child: renderLabel('收货人'),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: '请填写姓名', border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                padding: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(229, 229, 229, 0.5)))),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      child: renderLabel('联系电话'),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: '请填写电话号码', border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                padding: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromRGBO(229, 229, 229, 0.5)))),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 80,
                      child: renderLabel('所在地区'),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: '请填写地址', border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  children: <Widget>[
                    renderLabel('详细地址'),
                    Expanded(
                      child: TextFormField(
                        maxLines: 5,
                        decoration: InputDecoration(
                            hintText: '请填写详细地址', border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 10.0),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: renderLabel('设为默认'),
              ),
              Switch(
                  value: isDefault,
                  onChanged: (v) {
                    setState(() {
                      isDefault = !isDefault;
                    });
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget renderLabel(text) {
    return Container(
      width: 80,
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
