import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Color bgColor;
  final EdgeInsets padding;
  final VoidCallback onTap;

  const Button({Key key, this.bgColor, this.text, this.padding, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Text(text),
        color: bgColor,
        padding: padding,
      ),
    );
  }
}
