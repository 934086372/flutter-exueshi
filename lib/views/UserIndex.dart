import 'package:flutter/material.dart';

class UserIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<UserIndex> {
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
      body: RefreshIndicator(
          child: Center(
            child: Text('个人中心'),
          ),
          onRefresh: () {}),
    );
  }
}
