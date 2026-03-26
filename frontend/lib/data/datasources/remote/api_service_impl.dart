import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';

class ApiServiceImpl implements ApiService {
  final Dio _dio;
  final StorageService _storage;

  ApiServiceImpl(this._storage) : _dio = Dio(BaseOptions(baseUrl: 'https://api.example.com')) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        logger.d('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.d('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        logger.e('Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final message = error.response?.data['message'] ?? error.message;
      return Exception(message);
    }
    return Exception('Unknown error');
  }
}