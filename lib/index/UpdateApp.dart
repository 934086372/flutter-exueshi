import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/ModalDialog.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatefulWidget {
  final Map updateInfo;

  const UpdateApp({Key key, @required this.updateInfo}) : super(key: key);

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  Map get updateInfo => widget.updateInfo;

  // 初始化状态
  int updateStatus = 1;

  String downloadProgress = '0%';
  String received = '0Mb';
  String total = '0Mb';

  @override
  Widget build(BuildContext context) {
    String title = '发现新版本 v-' + updateInfo['versionCode'].toString();
    String subTitle = updateInfo['onlineTime'].toString().substring(0, 10);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image.asset('assets/images/bg_update.png'),
              Positioned(
                  top: 15,
                  left: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subTitle,
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Color.fromRGBO(255, 255, 255, 0.75)),
                        ),
                      )
                    ],
                  ))
            ],
          ),
          renderWindowContent()
        ],
      ),
    );
  }

  Widget renderWindowContent() {
    switch (updateStatus) {
      case 1:
        return renderInitState();
        break;
      case 2:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('正在下载安装包：(' + received + '/' + total + ')'),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: LinearProgressIndicator(),
              )
            ],
          ),
        );
        break;
      case 3:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Center(child: Text('下载完成，正在安装...')),
        );
        break;
      default:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Center(child: Text('更新失败！')),
        );
    }
  }

  Widget renderInitState() {
    String content = updateInfo['updateTip'];

    double maxHeight = MediaQuery.of(context).size.height * 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: HtmlView(
                data: content.toString(),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[renderCancelBtn(), renderUpdateBtn()],
          ),
        ),
      ],
    );
  }

  Widget renderCancelBtn() {
    // 非强制更新
    if (updateInfo['isForceUpdate'] == 2) return Container();

    return GestureDetector(
      onTap: () {
        ModalDialog.dismiss();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(215, 218, 219, 1),
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        margin: EdgeInsets.only(right: 10.0),
        child: Text(
          '暂不更新',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget renderUpdateBtn() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(0, 145, 219, 1),
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Text(
          '立即更新',
          style: TextStyle(color: Colors.white),
        ),
      ),
      onTap: () {
        setState(() {
          updateStatus = 2;
        });
        downloadApk();
      },
    );
  }

  void downloadApk() async {
    Directory appDir = await getTemporaryDirectory();

    String downloadUrl =
        'https://exueshi.oss-cn-hangzhou.aliyuncs.com/download/exueshi-v-0.0.25.apk';

    String savePath = appDir.path + '/exueshi-v-0.0.25.apk';

    Dio dio = new Dio();
    dio.download(downloadUrl, savePath, onProgress: (_received, _total) {
      if (_total != -1) {
        //print((received / total * 100).toStringAsFixed(0) + "%");

        if (_received < _total) {
          downloadProgress =
              (_received / _total * 100).toStringAsFixed(0) + "%";
          received = (_received / 1024 / 1024).toStringAsFixed(3) + 'Mb';
          total = (_total / 1024 / 1024).toStringAsFixed(3) + 'Mb';
        } else {
          updateStatus = 3;
          launch('https://www.baidu.com');
        }
        setState(() {});
      }
    });
  }
}
