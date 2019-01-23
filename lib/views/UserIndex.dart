import 'package:flutter/material.dart';

class UserIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<UserIndex> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('个人中心'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.message), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('images/avator.jpg'),
                  minRadius: 37.5,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'PHP是世界上最好的语言',
                        style: TextStyle(color: Colors.black, fontSize: 17.0),
                      ),
//                      Text('好嗨哟，感觉人生已经达到了高潮'),
                      Container(margin: EdgeInsets.only(top: 10.0), child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 14.0,
                            color: Color.fromRGBO(153, 153, 153, 1),
                          ),
                          Text(
                            '重庆',
                            style: TextStyle(
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          ),
                          Container(margin: EdgeInsets.only(left: 10.0),),
                          Icon(
                            Icons.phone_android,
                            size: 14.0,
                            color: Color.fromRGBO(153, 153, 153, 1),
                          ),
                          Text(
                            '15310486021',
                            style: TextStyle(
                                color: Color.fromRGBO(153, 153, 153, 1)),
                          )
                        ],
                      ),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
            child: Container(
              child: Row(children: <Widget>[
                _rowItem(0),
                _rowItem(1),
                _rowItem(2),
              ]),
            ),
          ),
          Expanded(
            child: _renderList(),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

Widget _rowItem(index) {
  var icon;
  var label;
  var count;
  switch (index) {
    case 0:
      count = 666;
      icon = Icons.edit;
      label = '笔记';
      break;
    case 1:
      count = 198;
      icon = Icons.library_books;
      label = '错题集';
      break;
    case 2:
      count = 13142;
      icon = Icons.favorite_border;
      label = '收藏';
      break;
  }
  return Expanded(
    child: FlatButton(
        padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
        onPressed: () {},
        child: Column(
          children: <Widget>[
            Text(count.toString(), style: TextStyle(fontSize: 27.0),),
            Container(
              margin: EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Icon(
                  icon, size: 13.0, color: Color.fromRGBO(153, 153, 153, 1),),
                Container(margin: EdgeInsets.only(left: 5.0),),
                Text(label,
                  style: TextStyle(fontSize: 13.0,
                      color: Color.fromRGBO(153, 153, 153, 1)),),
              ],),
            ),
          ],
        )),
  );
}

Widget _renderList() {
  return ListView(
    children: <Widget>[
      ListTile(leading: Icon(
        Icons.account_balance_wallet, color: Color.fromRGBO(255, 68, 68, 1),),
        title: Row(children: <Widget>[
          Expanded(child: Text('我的余额', style: TextStyle(
              color: Color.fromRGBO(51, 51, 51, 1),
              fontWeight: FontWeight.bold),),),
          Text('600.00', style: TextStyle(
              color: Color.fromRGBO(255, 68, 68, 1), fontSize: 18.0),)
        ],),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.calendar_today),
        title: Text('我的订单'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.card_giftcard),
        title: Text('优惠券'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.location_on),
        title: Text('地址管理'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.phone_android),
        title: Text('绑定手机号'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.question_answer),
        title: Text('帮助与反馈'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
      ListTile(leading: Icon(Icons.info),
        title: Text('关于我们'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},),
    ],
  );
}
