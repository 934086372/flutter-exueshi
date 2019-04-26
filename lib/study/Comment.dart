import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/LabelList.dart';
import 'package:flutter_exueshi/components/Rating.dart';

// 评分组件
class Comment extends StatefulWidget {
  final String targetTypeName;
  final String targetID;

  final bool showCloseIcon;

  const Comment(
      {Key key, this.targetTypeName, this.targetID, this.showCloseIcon = true})
      : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  String get targetTypeName => widget.targetTypeName;

  String get targetID => widget.targetID;

  bool get showCloseIcon => widget.showCloseIcon;

  int rating = 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              renderHeader(),
              renderRatingWidget(),
              renderCommentLabel(),
              renderBottom()
            ],
          ),
        ));
  }

  Widget renderHeader() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                targetTypeName + '评分',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )),
        showCloseIcon
            ? IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : Container(),
      ],
    );
  }

  Widget renderRatingWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Rating(
              total: 5,
              rating: 5,
              color: Colors.blue,
              onChanged: (v) {
                setState(() {
                  rating = v;
                });
              }),
          Text(rating.toString() + '分'),
        ]);
  }

  Widget renderCommentLabel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('选择印象（最多选择3个标签）'),
          ),
          LabelList(
            isMultipleSelect: true,
            data: ['视频清晰', '逻辑清晰'],
            //onChanged: (v) {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '说点什么吧!',
                hintStyle: TextStyle(fontSize: 14.0),
                filled: true,
                fillColor: Color.fromRGBO(241, 241, 241, 1),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderBottom() {
    return GestureDetector(
      onTap: () {
        print('发表评价');
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Color.fromRGBO(0, 145, 219, 1),
        child: Text(
          '发表评价',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
