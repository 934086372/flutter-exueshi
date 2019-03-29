import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/Rating.dart';

// 试卷评分界面
class Comment extends StatefulWidget {
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  int rating = 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '试卷评分',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Row(
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
                  ]),
            ],
          ),
        ));
  }
}
