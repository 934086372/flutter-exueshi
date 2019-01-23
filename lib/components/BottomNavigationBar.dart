import 'package:flutter/material.dart';

class UIBottomNavigationBar extends StatefulWidget {
  UIBottomNavigationBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex = 0,
  })  : assert(items != null),
        assert(0 <= currentIndex && currentIndex < items.length),
        super(key: key);

  final List<UIBottomNavigationBarItem> items;

  final ValueChanged<int> onTap;

  final int currentIndex;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BottomNavigationBarWidget();
  }
}

class UIBottomNavigationBarItem {
  const UIBottomNavigationBarItem({
    @required this.icon,
    this.title,
    Widget activeIcon,
  })  : activeIcon = activeIcon ?? icon,
        assert(icon != null);

  final Widget icon;
  final Widget title;
  final Widget activeIcon;
}

class BottomNavigationBarWidget extends State<UIBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Color.fromRGBO(0, 170, 255, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: InkResponse(
            onTap: () {},
            child: Container(
              color: Colors.red,
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  Container(height: 3.0),
                  Text(
                    '首页',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          )),
          Expanded(
              child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.apps,
                  color: Colors.white,
                ),
                Container(height: 3.0),
                Text(
                  '产品中心',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ],
            ),
          )),
          Expanded(
              child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                Container(height: 3.0),
                Text(
                  '我的学习',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ],
            ),
          )),
          Expanded(
              child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                Container(height: 3.0),
                Text(
                  '个人中心',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
