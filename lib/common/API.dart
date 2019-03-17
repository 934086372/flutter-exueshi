import 'dart:async';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

/*
* 统一管理API接口
*
* */

class API {
  String baseUrl = 'http://ns.seevin.com';

  String apiName;
  var data;
  var api = {'login': ''};

  API(apiName, {data});

  Future post() async {
    Dio dio = new Dio(Options(baseUrl: baseUrl));
    dio.post(api['login']);
  }

  Future getUserInfo() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
  }
}
