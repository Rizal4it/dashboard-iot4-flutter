import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://mgr-core.geryx.space:8443/data",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: "jwt_token");
          if (token != null) {
            options.headers["Authorization"] =
                "Bearer $token"; // ✅ Tambahkan token ke header
          }
          return handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: "jwt_token");
            navigatorKey.currentState?.pushReplacementNamed("/welcome");
          }
          return handler.next(e);
        },
      ),
    );
  }
}

// Navigator global untuk logout dari interceptor
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
