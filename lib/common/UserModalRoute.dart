import 'package:flutter/material.dart';

class UserModalRoute<T> extends ModalRoute<T> {
  final WidgetBuilder builder;
  final ThemeData theme;

  UserModalRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  @override
  // TODO: implement barrierColor
  Color get barrierColor => null;

  @override
  // TODO: implement barrierDismissible
  bool get barrierDismissible => true;

  @override
  // TODO: implement barrierLabel
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // TODO: implement buildPage
    return Builder(builder: this.builder);
  }

  @override
  // TODO: implement maintainState
  bool get maintainState => true;

  @override
  // TODO: implement opaque
  bool get opaque => false;

  @override
  // TODO: implement transitionDuration
  Duration get transitionDuration => Duration(milliseconds: 300);
}
