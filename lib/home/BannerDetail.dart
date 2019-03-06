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
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () {
                print('分享');
                Share.share(link);
              })
        ],
      ),
      body: Builder(builder: (context) {
        return WebView(
          initialUrl: link,
        );
      }),
    );
  }
}
