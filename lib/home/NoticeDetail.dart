import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';

class Notice extends StatelessWidget {
  final noticeItem;

  const Notice({Key key, this.noticeItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(noticeItem);

    String title = noticeItem['bulletionTitle'];
    String bulletionLink = noticeItem['bulletionLink'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                print('分享');
                Share.share(bulletionLink);
              })
        ],
      ),
      body: Builder(builder: (context) {
        return WebView(
          initialUrl: bulletionLink,
        );
      }),
    );
  }
}
