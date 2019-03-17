import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exueshi/components/MyIcons.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

class DocumentStudy extends StatefulWidget {
  @override
  DocumentStudyState createState() {
    return new DocumentStudyState();
  }
}

class DocumentStudyState extends State<DocumentStudy> {
  String pathPDF = '';

  final pdfReader = PDFViewerPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        print(pathPDF);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pdfReader.close();
    pdfReader.dispose();
  }

  Future<File> createFileOfPdfUrl() async {
    final url = "http://africau.edu/images/default/sample.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              pdfReader.close();
              Navigator.of(context).pop();
            }),
        title: Text('pdf'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: pathPDF == ''
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : pdfViewer(),
          ),
          bottomBar()
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
    );
  }

  Widget pdfViewer() {
    double top = kToolbarHeight + MediaQuery.of(context).padding.top;
    double bottom = 50;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - top - bottom;

    Rect rect = Rect.fromLTWH(0, top, width, height);
    pdfReader.launch(pathPDF, rect: rect);

    return Center(child: const CircularProgressIndicator());
  }

  Widget bottomBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(226, 226, 226, 1), width: 0.5))),
      alignment: Alignment.center,
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(MyIcons.like_border), Text('收藏')],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.edit), Text('评价')],
            ),
          ),
          Expanded(
            child: Center(child: Text('标记为已学习')),
          )
        ],
      ),
    );
  }
}
