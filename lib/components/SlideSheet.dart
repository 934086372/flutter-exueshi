import 'package:flutter/material.dart';

class SlideSheet {
  static SlideSheetView slideSheetView;

  static show(BuildContext context, double paddingTop, Widget widget) {
    var overlayState = Overlay.of(context);

    AnimationController _animationController = AnimationController(
        vsync: overlayState, duration: Duration(milliseconds: 100))
      ..forward();
    Animation animation = Tween(begin: Offset(0.0, -0.1), end: Offset(0.0, 0.0))
        .animate(
            CurvedAnimation(parent: _animationController, curve: Curves.linear))
          ..addListener(() {
            print(_animationController.value);
          });

    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      return Positioned.fill(
          top: paddingTop,
          child: GestureDetector(
            onTap: () {
              SlideSheet.dismiss();
            },
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //SlideSheetChild(animation: animation, widget: widget)
                  widget
                ],
              ),
            ),
          ));
    });
    slideSheetView = new SlideSheetView();

    slideSheetView._overlayEntry = overlayEntry;
    slideSheetView.overlayState = overlayState;
    slideSheetView._show();
  }

  static dismiss() {
    slideSheetView._dismissed();
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
        return SlideTransition(
          position: animation,
          child: child,
        );
      },
      child: widget,
    );
  }
}

class SlideSheetView {
  OverlayEntry _overlayEntry;
  OverlayState overlayState;
  bool dismissed = false;

  _show() {
    overlayState.insert(_overlayEntry);
  }

  _dismissed() {
    if (dismissed) {
      return;
    }
    this.dismissed = true;
    _overlayEntry?.remove();
  }
}
