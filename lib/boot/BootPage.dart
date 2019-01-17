import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class BootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Swiper(
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Text('Index $index');
            }),
      ),
    );
  }
}
