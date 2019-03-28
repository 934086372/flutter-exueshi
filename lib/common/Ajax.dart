import 'package:dio/dio.dart';

class Ajax extends Dio {
  Ajax({baseUrl: 'http://ns.seevin.com'})
      : super(Options(baseUrl: baseUrl, responseType: ResponseType.JSON));
}
