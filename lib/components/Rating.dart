/**
 * 打分组件
 *
 * */

import 'package:flutter/material.dart';

class Rating extends StatefulWidget {
  final int total;
  final int rating;
  final ValueChanged onChanged;
  final double size;
  final Color color;

  const Rating({
    @required this.total,
    @required this.rating,
    @required this.onChanged,
    this.size = 24.0,
    this.color = const Color.fromRGBO(255, 204, 0, 1),
  });

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  int get total => widget.total;

  int get rating => widget.rating;

  ValueChanged get onChanged => widget.onChanged;

  double get size => widget.size;

  Color get color => widget.color;

  int _rating;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (int i) {
        if (i < _rating) {
          return GestureDetector(
            child: Icon(
              Icons.star,
              size: size,
              color: color,
            ),
            onTap: () {
              onChanged(i + 1);
              setState(() {
                _rating = i + 1;
              });
            },
          );
        } else {
          return GestureDetector(
            child: Icon(
              Icons.star_border,
              size: size,
              color: color,
            ),
            onTap: () {
              onChanged(i + 1);
              setState(() {
                _rating = i + 1;
              });
            },
          );
        }
      }),
    );
  }
}
