import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/Video.dart';

class LivingRoom extends StatefulWidget {
  @override
  _LivingRoomState createState() => _LivingRoomState();
}

class _LivingRoomState extends State<LivingRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 170, 255, 1),
        elevation: 1.0,
        centerTitle: true,
        title: Text('直播间'),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Video(
                url:
                    'http://vedio.exueshi.com/26c9073d9d3f448896b80924ffc30a1c/9b065e10ca3241d4bd763090ce18d0a6-23ed88f2a1a26984ec60a497bcc1d316.m3u8',
                title: '视频标题',
                initialStatus: false,
              ),
            ),
          )
        ],
      ),
    );
  }
}
