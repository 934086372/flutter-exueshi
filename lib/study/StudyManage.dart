import 'package:flutter/material.dart';

class StudyManage extends StatefulWidget {
  @override
  _StudyManageState createState() => _StudyManageState();
}

class _StudyManageState extends State<StudyManage> {
  bool _selectedAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 0.0,
        title: Text('批量管理'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, int) {
                  return ListTile(
                    title: Text('hello'),
                  );
                }),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  value: _selectedAll,
                  onChanged: (val) {
                    setState(() {
                      _selectedAll = !_selectedAll;
                    });
                  }),
              Text('全选'),
              Expanded(
                child: Container(),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text('标记为已学完'),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
