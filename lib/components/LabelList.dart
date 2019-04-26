import 'package:flutter/material.dart';

class LabelList extends StatefulWidget {
  final List data;
  final bool isMultipleSelect;
  final initialValue;
  final ValueChanged onChanged;

  final TextStyle style;
  final Color borderColor;
  final Color activeColor;

  const LabelList(
      {Key key,
      @required this.data,
      this.isMultipleSelect = false,
      this.initialValue,
      this.style =
          const TextStyle(fontSize: 12.0, color: Color.fromRGBO(51, 51, 51, 1)),
      this.borderColor = const Color.fromRGBO(215, 218, 219, 1),
      this.activeColor = const Color.fromRGBO(0, 170, 255, 1),
      this.onChanged})
      : assert(data != null),
        super(key: key);

  @override
  _LabelListState createState() => _LabelListState();
}

class _LabelListState extends State<LabelList> {
  List get data => widget.data;

  ValueChanged get onChanged => widget.onChanged;

  bool get isMultipleSelect => widget.isMultipleSelect;

  var selectedItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedItem = widget.initialValue;
    if (isMultipleSelect && selectedItem == null) {
      selectedItem = new Set();
    }
    print(selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    print(selectedItem);
    return isMultipleSelect ? renderMultipleSelect() : renderSingleSelect();
  }

  Widget renderSingleSelect() {
    return Wrap(
      runSpacing: 10.0,
      spacing: 10.0,
      children: List.generate(data.length, (index) {
        bool isActive = selectedItem == data[index];
        return GestureDetector(
          onTap: () {
            if (isMultipleSelect) {
              // 可多选
            } else {
              // 单选
              selectedItem = data[index];
              if (onChanged != null) onChanged(selectedItem);
            }
            print(selectedItem);
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
                color: isActive ? widget.activeColor : Colors.white,
                border: Border.all(
                  color: isActive ? widget.activeColor : widget.borderColor,
                ),
                borderRadius: BorderRadius.circular(30.0)),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
            child: Text(
              data[index],
              style: isActive
                  ? TextStyle(color: Colors.white, fontSize: 12.0)
                  : widget.style,
            ),
          ),
        );
      }),
    );
  }

  Widget renderMultipleSelect() {
    return Wrap(
      runSpacing: 10.0,
      spacing: 10.0,
      children: List.generate(data.length, (index) {
        bool isActive = selectedItem.contains(data[index]);
        return Label(
          onChanged: (v) {
            if (v) {
              selectedItem.add(data[index]);
            } else {
              selectedItem.remove(data[index]);
            }
            if (onChanged != null) onChanged(selectedItem);
          },
          text: data[index],
          isActive: isActive,
        );
      }),
    );
  }
}

class Label extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color borderColor;
  final Color activeColor;
  final ValueChanged onChanged;
  final bool isActive;

  const Label(
      {Key key,
      this.text = 'label',
      this.style =
          const TextStyle(fontSize: 12.0, color: Color.fromRGBO(51, 51, 51, 1)),
      this.borderColor = const Color.fromRGBO(215, 218, 219, 1),
      this.activeColor = const Color.fromRGBO(0, 170, 255, 1),
      @required this.onChanged,
      this.isActive = false})
      : super(key: key);

  @override
  _LabelState createState() => _LabelState();
}

class _LabelState extends State<Label> {
  ValueChanged get onChange => widget.onChanged;

  bool _isActive = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isActive = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _isActive = !_isActive;
        onChange(_isActive);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
            color: _isActive ? widget.activeColor : Colors.white,
            border: Border.all(
              color: _isActive ? widget.activeColor : widget.borderColor,
            ),
            borderRadius: BorderRadius.circular(30.0)),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        child: Text(
          widget.text,
          style: _isActive
              ? TextStyle(color: Colors.white, fontSize: 12.0)
              : widget.style,
        ),
      ),
    );
  }
}
