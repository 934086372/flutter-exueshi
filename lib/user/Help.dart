import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/custom_router.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:flutter_exueshi/user/UserFeedback.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  var helpList;
  int pageLoadStatus = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHelpList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('帮助中心'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.feedback),
              onPressed: () {
                Navigator.of(context).push(CustomRoute(UserFeedback()));
              })
        ],
      ),
      body: renderPage(),
    );
  }

  void getHelpList() async {
    Ajax ajax = new Ajax();
    Response response =
        await ajax.post('/api/question/getQuestions', data: {'type': 'app'});
    print(response);
    if (response.statusCode == 200) {
      var ret = response.data;
      if (ret['code'].toString() == '200') {
        helpList = ret['data'];
        pageLoadStatus = 2;
      } else {
        pageLoadStatus = 3;
      }
    } else {
      pageLoadStatus = 4;
    }

    setState(() {});
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      case 2:
        return ListView.builder(
            itemCount: helpList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  helpList[index]['quTitle'].toString(),
                  style: TextStyle(fontSize: 14.0),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context)
                      .push(CustomRoute(HelpDetail(helpItem: helpList[index])));
                },
              );
            });
        break;
      case 3:
        return Center(child: Text('暂无数据'));
      default:
        return Center(child: Text('未知错误'));
    }
  }
}

class HelpDetail extends StatelessWidget {
  final helpItem;

  const HelpDetail({Key key, this.helpItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(helpItem);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        title: Text('帮助详情'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.feedback), onPressed: () {})
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            child: Text(
              helpItem['quTitle'].toString(),
              style: TextStyle(
                  fontSize: 16.0, color: Color.fromRGBO(51, 51, 51, 1)),
            ),
          ),
          Divider(
            height: 0.5,
            color: Color.fromRGBO(226, 226, 226, 1),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: HtmlView(data: helpItem['quContent'])),
          )
        ],
      ),
    );
  }
}
