import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('关于我们'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Image.asset('assets/images/about.jpg'),
      ),
    );
  }
}
