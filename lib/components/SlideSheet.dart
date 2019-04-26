import 'package:flutter/material.dart';

class SlideSheet {
  static SlideSheetView slideSheetView;

  static show(BuildContext context, double paddingTop, Widget widget) {

    /*
    * 检查是否已有打开窗口，有则先关闭当前已经打开的窗口
    * 需判断打开的窗口与之前的窗口是否同一个，有则关闭后不执行之后的操作
    *
    * */
    if (slideSheetView != null) {
      if (slideSheetView.context == context) {
        slideSheetView._dismissed();
        return;
      }
      slideSheetView._dismissed();
    }

    var overlayState = Overlay.of(context);
    AnimationController _animationController = AnimationController(
        vsync: overlayState, duration: Duration(milliseconds: 200))
      ..forward();
    Animation slideAnimation =
    _animationController.drive(CurveTween(curve: Curves.easeIn));

    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      return Positioned.fill(
          top: paddingTop,
          child: GestureDetector(
            onTap: () {
              SlideSheet.dismiss();
            },
            child: Scaffold(
              backgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SlideSheetChild(animation: slideAnimation, widget: widget)
                  //widget
                ],
              ),
            ),
          ));
    });
    slideSheetView = new SlideSheetView();

    slideSheetView.context = context;
    slideSheetView._overlayEntry = overlayEntry;
    slideSheetView.overlayState = overlayState;
    slideSheetView._show();
  }

  static dismiss() {
    slideSheetView?._dismissed();
  }
}

class SlideSheetChild extends StatelessWidget {
  final Animation animation;
  final Widget widget;

  const SlideSheetChild({Key key, this.animation, this.widget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: Align(
            heightFactor: animation.value,
            child: child,
          ),
        );
      },
      child: widget,
    );
  }
}

class SlideSheetView {
  BuildContext context;

  OverlayEntry _overlayEntry;
  OverlayState overlayState;
  bool dismissed = false;

  _show() {
    overlayState.insert(_overlayEntry);
  }

  _dismissed() {
    if (this.dismissed) {
      return;
    }
    this.dismissed = true;
    this.context = null;
    _overlayEntry?.remove();
  }
}
