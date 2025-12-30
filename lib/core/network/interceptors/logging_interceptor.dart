import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor untuk logging request dan response
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ REQUEST');
      print('├─────────────────────────────────────────────────────────');
      print('│ ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        print('│ Headers:');
        options.headers.forEach((key, value) {
          print('│   $key: $value');
        });
      }
      if (options.data != null) {
        print('│ Body:');
        print('│   ${options.data}');
      }
      print('└─────────────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ RESPONSE');
      print('├─────────────────────────────────────────────────────────');
      print('│ ${response.requestOptions.method} ${response.requestOptions.uri}');
      print('│ Status Code: ${response.statusCode}');
      if (response.data != null) {
        print('│ Body:');
        print('│   ${response.data}');
      }
      print('└─────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────');
      print('│ ERROR');
      print('├─────────────────────────────────────────────────────────');
      print('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Error: ${err.message}');
      if (err.response?.data != null) {
        print('│ Response:');
        print('│   ${err.response?.data}');
      }
      print('└─────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }
}

