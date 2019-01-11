import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class HomeIndex extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State<HomeIndex> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  Text(
                    '重庆',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(Icons.arrow_drop_down,size: 16.0, color: Colors.white,),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color.fromRGBO(255, 255, 255, 0.85),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.search,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                  )),
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  )
                ],
              ),
              height: 50.0,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
            ),
            color: Colors.blue,
          ),
          Expanded(
            child: RefreshIndicator(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return Image.network(
                          "http://via.placeholder.com/350x150",
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      pagination: SwiperPagination(),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 35 / 72,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemExtent: 20,
                        itemBuilder: (BuildContext text, int index) {
                          return ListTile(
                            title: Text('hello'),
                          );
                        }),
                  ),
                ],
              ),
              onRefresh: () {},
            ),
          )
        ],
      ),
    );
  }
}
