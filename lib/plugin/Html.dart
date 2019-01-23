import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_text.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

class Html extends StatelessWidget {
  final String data;

  Html({this.data});

  _parseChildren(dom.Element e, widgetList) {
    print(e.outerHtml);
    if (e.localName == "img" && e.attributes.containsKey('src')) {
      var src = e.attributes['src'];

      print(src);

      if (src.startsWith("http") || src.startsWith("https")) {
        widgetList.add(new CachedNetworkImage(
          imageUrl: src,
          fit: BoxFit.cover,
        ));
      } else if (src.startsWith('data:image')) {
        var exp = new RegExp(r'data:.*;base64,');
        var base64Str = src.replaceAll(exp, '');
        var bytes = base64.decode(base64Str);
        widgetList.add(new Image.memory(bytes, fit: BoxFit.cover));
      }
    } else if (e.localName == "video") {
    } else if (!e.outerHtml.contains("<img") ||
        !e.outerHtml.contains("<video") ||
        !e.hasContent()) {
      widgetList.add(new HtmlText(data: e.outerHtml));
    } else if (e.children.length > 0) print('find child');
    e.children.forEach((e) => _parseChildren(e, widgetList));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    List<Widget> widgetList = new List();

    dom.Document document = parse(this.data);

    dom.Element docBody = document.body;

    List<dom.Element> docBodyChildren = docBody.children;
    if (docBodyChildren.length > 0)
      docBodyChildren.forEach((e) => _parseChildren(e, widgetList));

    print(widgetList.length);

    return Column(children: widgetList);
  }
}
