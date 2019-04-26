import 'package:flutter/material.dart';

class ModalDialog {
  static ModalDialogView modalDialogView;

  static show(BuildContext context, WidgetBuilder child) {
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Scaffold(
        body: Center(
          child: Builder(builder: child),
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
      );
    });

    modalDialogView = new ModalDialogView();
    modalDialogView.context = context;
    modalDialogView._overlayEntry = overlayEntry;
    modalDialogView.overlayState = Overlay.of(context);
    modalDialogView._show();
  }

  static dismiss() {
    modalDialogView._dismissed();
  }
}

class ModalDialogView {
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
