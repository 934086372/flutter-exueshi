import 'package:flutter/material.dart';

// 自定义左右滑动路由动画
class PageRouter extends PageRouteBuilder {
  final Widget widget;

  PageRouter(this.widget)
      : super(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                          begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                      .animate(CurvedAnimation(
                          parent: animation1, curve: Curves.fastOutSlowIn)));
            });
}
