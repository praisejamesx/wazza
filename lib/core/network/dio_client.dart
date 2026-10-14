import 'package:dio/dio.dart';
import 'dart:developer' as dev;

class DioClient {
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;
  
  late final Dio _dio;

  DioClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Wazza/2.0 (Android)',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => dev.log('[HTTP] $obj'),
    ));
  }

  Dio get dio => _dio;

  Future<Response> get(String url, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) {
    return _dio.get(url, options: headers != null ? Options(headers: headers) : null, queryParameters: queryParameters);
  }

  Future<Response> post(String url, {dynamic data, Map<String, String>? headers}) {
    return _dio.post(url, data: data, options: headers != null ? Options(headers: headers) : null);
  }
}
