import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BannerDetail extends StatelessWidget {
  final bannerItem;

  const BannerDetail({Key key, this.bannerItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(bannerItem);

    String title = bannerItem['adName'];
    String link = bannerItem['adLink'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Builder(builder: (context) {
        return WebView(
          initialUrl: link,
        );
      }),
    );
  }
}
