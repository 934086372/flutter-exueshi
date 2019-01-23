import 'package:flutter/material.dart';

class ProductContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Page();
  }
}

class Page extends State<ProductContent> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('目录'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('hello'),
      ),
    );
  }
}
