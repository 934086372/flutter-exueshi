import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/AddressPicker.dart';

class SwitchCity extends StatefulWidget {
  @override
  _SwitchCityState createState() => _SwitchCityState();
}

class _SwitchCityState extends State<SwitchCity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text('选择地区'),
        centerTitle: true,
      ),
      body: AddressPicker(),
    );
  }
}
