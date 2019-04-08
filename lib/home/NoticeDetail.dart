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
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Builder(builder: (context) {
        return WebView(
          initialUrl: bulletionLink,
        );
      }),
    );
  }
}
