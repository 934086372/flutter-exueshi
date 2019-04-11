/*
*
* 自定义页面底层水印
*
* */

import 'package:flutter/material.dart';

class Watermark extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget widget;
  final Size size;

  const Watermark({Key key,
    this.title = '易学仕网校',
    this.subTitle,
    @required this.widget,
    @required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double aspectRatio = (size.width / 3) / (size.height / 4); // 计算每一块的宽高比

    return Stack(
      children: <Widget>[
        renderWaterMark(aspectRatio),
        Positioned.fill(child: widget),
      ],
    );
  }

  Widget renderWaterMark(aspectRatio) {
    return Positioned.fill(
        child: Container(
      color: Colors.white,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: aspectRatio,
        children: List.generate(12, (index) {
          return Transform.rotate(
            angle: -5 / 12,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Color.fromRGBO(153, 153, 153, 0.2))),
                  subTitle != null
                      ? Text(subTitle,
                      overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color.fromRGBO(153, 153, 153, 0.2)))
                      : Container()
                ],
              ),
            ),
          );
        }),
      ),
    ));
  }
}
