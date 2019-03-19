import 'package:flutter/material.dart';

class SlideListTile extends StatefulWidget {
  final Widget child;
  final List<Widget> menu;

  const SlideListTile({Key key, this.child, this.menu = const <Widget>[]})
      : super(key: key);

  @override
  _SlideListTileState createState() => _SlideListTileState();
}

class _SlideListTileState extends State<SlideListTile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _moveController;
  Animation<Offset> _moveAnimation;

  double _dragExtent = 0.0;

  double _threshold = 60.0;

  double get _overallDragAxisExtent {
    final Size size = context.size;
    return size.width;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _moveController = new AnimationController(
        duration: Duration(milliseconds: 300), vsync: this)
      ..addStatusListener((AnimationStatus status) {
        print(status);
      });
    _updateMoveAnimation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _moveController.dispose();
    super.dispose();
  }

  void _handleDragUpdating(DragUpdateDetails details) {
    _dragExtent += details.primaryDelta;
    if (_dragExtent > 0) {
      _dragExtent = 0;
      return;
    }
    setState(() {
      _updateMoveAnimation();
    });
    if (!_moveController.isAnimating) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > _threshold) {
      _dragExtent = -_threshold;
      setState(() {
        _updateMoveAnimation();
      });
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    } else {
      _dragExtent = 0.0;
      _moveController.value = -1.0;
    }
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;
    if (_moveController.isAnimating) {
      return;
    }
    _moveAnimation = _moveController
        .drive(Tween<Offset>(begin: Offset.zero, end: Offset(end, 0)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print(_moveController.value);
    Widget content =
        SlideTransition(position: _moveAnimation, child: widget.child);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Container(
            color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.menu,
            ),
          ),
        ),
        GestureDetector(
          child: Stack(
            children: <Widget>[content],
          ),
          onHorizontalDragUpdate: _handleDragUpdating,
          onHorizontalDragEnd: _handleDragEnd,
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
