import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/Ajax.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_exueshi/user/MyMistakesDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMistakes extends StatefulWidget {
  @override
  _MyMistakesState createState() => _MyMistakesState();
}

class _MyMistakesState extends State<MyMistakes> {
  var mistakes;
  int pageLoadStatus = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMistakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        title: Text('错题集'),
        centerTitle: true,
      ),
      body: renderPage(),
    );
  }

  Widget renderPage() {
    switch (pageLoadStatus) {
      case 1:
        return Center(
          child: CupertinoActivityIndicator(),
        );
        break;
      case 2:
        print(mistakes);
        return ListView.builder(
            itemCount: mistakes.length,
            itemBuilder: (context, index) {
              var group = mistakes[index];
              return ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(group['prodName'].toString()),
                  children: List.generate(group['papers'].length, (i) {
                    var item = group['papers'][i];
                    return ListTile(
                      leading: Icon(MyIcons.paper),
                      title: Text(item['paperName']),
                      subtitle: Text('错题： ' +
                          item['mistakeCount'].toString() +
                          '   已掌握：' +
                          item['masteredCount'].toString()),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(PageRouter(MyMistakesDetail(
                          prodID: group['prodID'],
                          paperID: item['paperID'],
                        )));
                      },
                    );
                  }));
            });
        break;
      case 3:
        return Center(
          child: Text('暂无数据'),
        );
        break;
      case 4:
        return Center(
          child: Text('网络请求失败'),
        );
        break;
      default:
        return Container();
    }
  }

  void getMistakes() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString('userData');
    if (_user != null) {
      var userData = json.decode(_user);

      Ajax ajax = new Ajax();
      Response response = await ajax.post(
          '/api/Collectionmistakes/getUserMistakes',
          data: {'userID': userData['userID'], 'token': userData['token']});
      if (response.statusCode == 200) {
        var ret = response.data;
        if (ret['code'].toString() == '200') {
          mistakes = ret['data'];
          pageLoadStatus = 2;
        } else {
          pageLoadStatus = 3;
        }
      } else {
        pageLoadStatus = 4;
      }
    }

    setState(() {});
  }
}
