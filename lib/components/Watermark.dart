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

  const Watermark({Key key, this.title = '易学仕网校', this.subTitle, this.widget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RenderBox box = context.findRenderObject();
    print(box.size);

    double aspectRatio =
        (box.size.width / 3) / (box.size.height / 4); // 计算每一块的宽高比

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
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Color.fromRGBO(153, 153, 153, 0.2))),
                  subTitle != null
                      ? Text(subTitle,
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
