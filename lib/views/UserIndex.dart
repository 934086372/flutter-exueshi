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
                      Row(
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
                      ),
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
  switch (index) {
    case 0:
      icon = Icons.edit;
      label = '我的笔记';
      break;
    case 1:
      icon = Icons.library_books;
      label = '错题集';
      break;
    case 2:
      icon = Icons.favorite_border;
      label = '我的收藏';
      break;
  }
  return Expanded(
    child: FlatButton(
        padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
        onPressed: () {},
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment(1.5, -1.5),
              children: <Widget>[
                Icon(icon,),
                Container(
                  alignment: Alignment.center,
                  child: Text('2',
                    style: TextStyle(fontSize: 10.0, color: Colors.white),),
                  width: 15.0,
                  height: 15.0,
                  decoration: BoxDecoration(
                      color: Colors.redAccent, shape: BoxShape.circle),
                )
              ],),
            Text(label),
          ],
        )),
  );
}

Widget _renderList() {
  return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Icon(Icons.account_balance_wallet),
          title: Text('我的订单'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            print(index);
          },
        );
      });
}
