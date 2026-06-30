import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Appels HTTP vers l’API web (Express).
class SdisApiClient {
  SdisApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: '${AppConfig.apiBaseUrl}/api',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 30),
                headers: {'Accept': 'application/json'},
              ),
            );

  final Dio dio;

  void setAccessToken(String? token) {
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    return dio.post(path, data: data);
  }

  Future<Response<dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    return dio.patch(path, data: data);
  }

  static String apiErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Impossible de joindre l’API (${AppConfig.apiBaseUrl}). '
          'Vérifiez que `npm run dev` tourne sur le PC et que l’URL réseau est correcte.';
    }
    return e.message ?? 'Erreur réseau';
  }
}
