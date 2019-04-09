import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
