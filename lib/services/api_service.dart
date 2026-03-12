// lib/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:smart_tourism_app/core/constants.dart';
import 'package:smart_tourism_app/models/place_model.dart';

/// Service layer xử lý tất cả các cuộc gọi API đến backend (FastAPI)
/// Tránh gọi Dio/http trực tiếp từ các screen → dễ test & bảo trì
class ApiService {
  // Singleton instance của Dio (chỉ tạo 1 lần)
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl, // Đã sửa ở constants.dart thành 'http://10.0.2.2:8000' cho emulator
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Thêm interceptor để log lỗi hoặc attach token sau này
  static void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request khi debug (tùy chọn)
          // debugPrint('REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response khi debug (tùy chọn)
          // debugPrint('RESPONSE[${response.statusCode}] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String? errorMessage;
          if (e.response != null) {
            errorMessage = e.response?.data['detail'] as String? ??
                'Lỗi từ server (${e.response?.statusCode})';
            debugPrint('Response error data: ${e.response?.data}');
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Hết thời gian kết nối';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Không nhận được phản hồi';
          } else {
            errorMessage = e.message ?? 'Lỗi kết nối không xác định';
          }

          debugPrint('API Error: $errorMessage');
          return handler.reject(e);
        },
      ),
    );
  }

  /// Khởi tạo service (gọi 1 lần ở main.dart)
  static void init() {
    _setupInterceptors();
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Gợi ý địa điểm du lịch / nhà hàng gần vị trí hiện tại
  // ──────────────────────────────────────────────────────────────
  Future<List<Place>> getRecommendedPlaces({
    required double latitude,
    required double longitude,
    String? category,
    int limit = 10,
  }) async {
    try {
      debugPrint('Calling getRecommendedPlaces with lat=$latitude, lng=$longitude, limit=$limit');

      final response = await _dio.get(
        '/landmarks/recommend',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          if (category != null) 'category': category,
          'limit': limit,
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data type: ${response.data.runtimeType}');
      debugPrint('Response data: $response.data');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => Place.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data == null) {
          debugPrint('Response data is null');
          return [];
        } else {
          debugPrint('Response data is not List: ${data.runtimeType}');
          throw Exception('Response không phải List: $data');
        }
      } else {
        throw Exception('Lỗi server: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getRecommendedPlaces: ${e.type} - ${e.message}');
      if (e.response != null) {
        debugPrint('Response error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Không thể lấy gợi ý địa điểm: ${e.message ?? "Unknown Dio error"}');
    } catch (e, stackTrace) {
      debugPrint('Unexpected error in getRecommendedPlaces: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Nhận diện danh lam thắng cảnh từ ảnh (upload ảnh)
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> detectLandmark(File imageFile) async {
    try {
      String fileName = imageFile.path.split(Platform.pathSeparator).last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/landmarks/detect',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint('Detect response status: ${response.statusCode}');
      debugPrint('Detect response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Nhận diện thất bại: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in detectLandmark: ${e.type} - ${e.message}');
      if (e.response?.statusCode == 413) {
        throw Exception('Ảnh quá lớn, vui lòng chọn ảnh nhỏ hơn');
      }
      throw Exception('Lỗi khi upload ảnh: ${e.message ?? "Unknown error"}');
    } catch (e) {
      debugPrint('Unexpected error in detectLandmark: $e');
      throw Exception('Lỗi không xác định khi nhận diện: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Lấy chi tiết một địa điểm theo ID
  // ──────────────────────────────────────────────────────────────
  Future<Place> getPlaceDetail(int placeId) async {
    try {
      final response = await _dio.get('/landmarks/$placeId');

      debugPrint('Detail response status: ${response.statusCode}');
      debugPrint('Detail response data: ${response.data}');

      if (response.statusCode == 200) {
        return Place.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Không tìm thấy địa điểm: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getPlaceDetail: ${e.type} - ${e.message}');
      throw Exception('Lỗi lấy chi tiết: ${e.message ?? "Unknown error"}');
    } catch (e) {
      debugPrint('Unexpected error in getPlaceDetail: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 4. Dịch nội dung (gọi backend hoặc dùng Google Translate API)
  // ──────────────────────────────────────────────────────────────
  Future<String> translateText({
    required String text,
    required String targetLang,
  }) async {
    try {
      final response = await _dio.post(
        '/translate',
        data: {
          'text': text,
          'target_lang': targetLang,
        },
      );

      debugPrint('Translate response status: ${response.statusCode}');
      debugPrint('Translate response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['translated_text'] as String? ?? text;
      } else {
        debugPrint('Translate failed: ${response.statusCode}');
        return text; // fallback
      }
    } on DioException catch (e) {
      debugPrint('DioException in translateText: ${e.type} - ${e.message}');
      return text;
    } catch (e) {
      debugPrint('Unexpected error in translateText: $e');
      return text;
    }
  }
}