import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';

class SwitchProjectAndArea extends StatefulWidget {
  final Map data;

  const SwitchProjectAndArea({Key key, this.data}) : super(key: key);

  @override
  _SwitchProjectAndAreaState createState() => _SwitchProjectAndAreaState();
}

class _SwitchProjectAndAreaState extends State<SwitchProjectAndArea> {
  Map get data => widget.data;

  String project;
  String area;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    project = data['project'];
    area = data['area'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(''),
        centerTitle: true,
      ),
      body: renderPage(),
      backgroundColor: Color.fromRGBO(245, 248, 250, 1),
    );
  }

  Widget renderPage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(
                          MyIcons.paper,
                          color: Color.fromRGBO(255, 68, 68, 1),
                        ),
                      ),
                      Text(
                        '您目前想要考的是？',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: <Widget>[
                    renderProjectItem('专升本/专转本/专接本/专插本'),
                    renderProjectItem('计算机等级考试'),
                    renderProjectItem('教师资格证')
                  ],
                ),
                Container(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(
                          Icons.location_on,
                          color: Color.fromRGBO(57, 219, 0, 1),
                        ),
                      ),
                      Text(
                        '您考试的地区是？',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: <Widget>[
                    renderAreaItem('全国'),
                    renderAreaItem('重庆'),
                    renderAreaItem('四川')
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop({'project': project, 'area': area});
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                child: Text(
                  '确定选择',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          offset: Offset(2.0, 5.0),
                          blurRadius: 10.0,
                          spreadRadius: 2.0)
                    ],
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[
                          Color.fromRGBO(0, 170, 255, 1),
                          Color.fromRGBO(68, 204, 255, 1)
                        ])),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget renderProjectItem(title) {
    bool isActive = project == title;
    return GestureDetector(
      child: renderLabelItem(title, isActive),
      onTap: () {
        setState(() {
          project = title;
        });
      },
    );
  }

  Widget renderAreaItem(title) {
    bool isActive = area == title;
    return GestureDetector(
      child: renderLabelItem(title, isActive),
      onTap: () {
        setState(() {
          area = title;
        });
      },
    );
  }

  Widget renderLabelItem(String title, bool isActive) {
    Color bgColor = isActive ? Colors.blue : Colors.white;
    Color borderColor =
        isActive ? Colors.blue : Color.fromRGBO(190, 192, 194, 1);
    Color titleColor =
        isActive ? Colors.white : Color.fromRGBO(102, 102, 102, 1);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      child: Text(
        title.toString(),
        style: TextStyle(color: titleColor),
      ),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          border: Border.all(color: borderColor, width: 0.5)),
    );
  }
}
