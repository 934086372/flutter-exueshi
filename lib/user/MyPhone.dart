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
        elevation: 1.0,
        title: Text('绑定手机号'),
        centerTitle: true,
      ),
    );
  }
}
