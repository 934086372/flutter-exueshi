import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';

class UserFeedback extends StatefulWidget {
  @override
  _UserFeedbackState createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 243, 245, 1),
      appBar: AppBar(
        elevation: 1.0,
        title: Text('问题反馈'),
        centerTitle: true,
        actions: <Widget>[IconButton(icon: Icon(Icons.save), onPressed: () {})],
      ),
      body: renderPage(),
    );
  }

  Widget renderPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15.0),
          child: Text('您在哪方面遇到了问题'),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(15.0),
          child: Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 0, // gap between lines
            children: <Widget>[
              Chip(
                label: Text('登录问题'),
              ),
              Chip(
                label: Text('充值购买问题'),
              ),
              Chip(
                label: Text('视频问题'),
              ),
              Chip(
                label: Text('做题问题'),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 15.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: '请描述您的问题或建议', border: InputBorder.none),
                ),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      print('pickerImage');

                      //ImagePicker.pickImage(source: ImageSource.camera);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: EdgeInsets.all(10.0),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          color: Color.fromRGBO(204, 204, 204, 1),
                        ),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(
                              color: Color.fromRGBO(201, 201, 201, 1),
                              width: 0.5)),
                    ),
                  ),
                  Text('请上传图片，最多9张（至少上传1张）')
                ],
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 15.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '联系方式',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: TextField(
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: '选填，输入手机或QQ号便于我们联系！',
                        border: InputBorder.none)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
