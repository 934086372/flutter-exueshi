import 'package:flutter/material.dart';

class MyPhone extends StatefulWidget {
  @override
  _MyPhoneState createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('绑定手机号'),
        centerTitle: true,
      ),
    );
  }
}
