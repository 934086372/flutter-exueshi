import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/Video.dart';

class VideoTest extends StatefulWidget {
  @override
  _VideoTestState createState() => _VideoTestState();
}

class _VideoTestState extends State<VideoTest> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: Color.fromRGBO(0, 170, 255, 1),
          title: Text('视频播放器插件'),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Video(
                url:
                    'http://vedio.exueshi.com/26c9073d9d3f448896b80924ffc30a1c/9b065e10ca3241d4bd763090ce18d0a6-23ed88f2a1a26984ec60a497bcc1d316.m3u8',
                title: '视频标题',
              ),
            ),
          ],
        ));
  }
}
