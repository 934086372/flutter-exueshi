import 'package:flutter/material.dart';
import 'package:flutter_exueshi/common/PageRouter.dart';
import 'package:flutter_exueshi/product/ProdDetail.dart';

class ProdItem extends StatelessWidget {
  final Map item;

  const ProdItem({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: Colors.white,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: InkWell(
        child: Container(
          height: 100.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16.0 / 10.0,
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(2.5)),
                        child: Center(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/loading.gif',
                            image: item['logo'],
                            fit: BoxFit.fill,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 6.5, top: 4.0, right: 6.5, bottom: 4.0),
                        child: Text(
                          item['status'],
                          style: TextStyle(fontSize: 11.0, color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.6),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(2.5))),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        item['prodName'],
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      )),
                      item['dataFlag'] != '免费'
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                  Text(
                                    "￥" + item['realPrice'].toString(),
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 102, 0, 1),
                                        fontSize: 18,
                                        fontFamily: 'PingFang-SC-Bold'),
                                  ),
                                  Text(
                                    '原价:￥' + item['price'],
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 11.0,
                                        color:
                                            Color.fromRGBO(153, 153, 153, 1)),
                                  ),
                                ])
                          : Text('免费'),
                      Row(children: <Widget>[
                        Expanded(
                          child: Row(
                            children: List.generate(5, (int i) {
                              if (i < item['avgRating']) {
                                return Icon(
                                  Icons.star,
                                  size: 10.5,
                                  color: Color.fromRGBO(255, 204, 0, 1),
                                );
                              } else {
                                return Icon(
                                  Icons.star_border,
                                  size: 10.5,
                                  color: Color.fromRGBO(255, 204, 0, 1),
                                );
                              }
                            }),
                          ),
                        ),
                        Text('已有' + item['learnPeopleCount'].toString() + '人学习',
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Color.fromRGBO(153, 153, 153, 1)))
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(PageRouter(ProdDetail(prodID: item['prodID'])));
        },
      ),
    );
  }
}
