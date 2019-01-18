/**
 * 打分组件
 *
 * */

import 'package:flutter/material.dart';

class Rating extends StatelessWidget {

  final int total;
  final int rating;

  Rating({
    @required this.total,
    @required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: List.generate(total, (int i) {
        if (i < rating) {
          return Icon(
            Icons.star,
            size: 10.5,
            color: Color.fromRGBO(255, 204, 0, 1),
          );
        } else {
          return Icon(
            Icons.star_border,
            size: 10.5,
            color: Color.fromRGBO(255, 204, 0, 1),
          );
        }
      }),
    );
  }

}