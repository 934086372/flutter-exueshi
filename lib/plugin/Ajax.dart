import 'package:dio/dio.dart';

class Ajax extends Dio {
  Ajax()
      : super(Options(
            baseUrl: 'http://ns.seevin.com', responseType: ResponseType.JSON));
}
