import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';

class PaperIndex extends StatefulWidget {
  @override
  _PaperIndexState createState() => _PaperIndexState();
}

class _PaperIndexState extends State<PaperIndex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image.asset('assets/images/bg_ex_blank.png'),
              Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      Expanded(child: Container()),
                      IconButton(
                          icon: Icon(
                            MyIcons.like_border,
                            color: Colors.white,
                          ),
                          onPressed: () {}),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {})
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
