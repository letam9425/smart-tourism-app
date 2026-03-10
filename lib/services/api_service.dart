// lib/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smart_tourism_app/core/constants.dart';
import 'package:smart_tourism_app/models/place_model.dart';

/// Service layer xử lý tất cả các cuộc gọi API đến backend (FastAPI)
/// Tránh gọi Dio/http trực tiếp từ các screen → dễ test & bảo trì
class ApiService {
  // Singleton instance của Dio (chỉ tạo 1 lần)
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl, // Ví dụ: 'http://192.168.1.x:8000' hoặc domain
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Thêm interceptor để log lỗi hoặc attach token nếu có auth sau này
  static void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Có thể log request ở đây khi debug
          // print('REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // print('RESPONSE[${response.statusCode}] => ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Xử lý lỗi chung (ví dụ: show toast ở nơi gọi)
          String errorMessage = 'Lỗi kết nối';
          if (e.response != null) {
            errorMessage = e.response?.data['detail'] ?? 'Lỗi từ server (${e.response?.statusCode})';
          } else if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Hết thời gian kết nối';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Không nhận được phản hồi';
          }
          // Có thể throw custom exception hoặc return error message
          return handler.reject(e);
        },
      ),
    );
  }

  /// Khởi tạo service (gọi 1 lần ở main hoặc khi cần)
  static void init() {
    _setupInterceptors();
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Gợi ý địa điểm du lịch / nhà hàng gần vị trí hiện tại
  // ──────────────────────────────────────────────────────────────
  Future<List<Place>> getRecommendedPlaces({
    required double latitude,
    required double longitude,
    String? category, // ví dụ: 'di_tich', 'bien', 'nha_hang'
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/landmarks/recommend',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          if (category != null) 'category': category,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Không thể lấy gợi ý địa điểm: ${e.message}');
    } catch (e) {
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
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
        // Ví dụ trả về: {'landmark_id': 5, 'name': 'Phu Quoc', 'confidence': 0.92, ...}
      } else {
        throw Exception('Nhận diện thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception('Ảnh quá lớn, vui lòng chọn ảnh nhỏ hơn');
      }
      throw Exception('Lỗi khi upload ảnh: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi nhận diện: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Lấy chi tiết một địa điểm theo ID
  // ──────────────────────────────────────────────────────────────
  Future<Place> getPlaceDetail(int placeId) async {
    try {
      final response = await _dio.get('/landmarks/$placeId');

      if (response.statusCode == 200) {
        return Place.fromJson(response.data);
      } else {
        throw Exception('Không tìm thấy địa điểm');
      }
    } on DioException catch (e) {
      throw Exception('Lỗi lấy chi tiết: ${e.message}');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 4. Dịch nội dung (gọi backend hoặc dùng Google Translate API)
  // ──────────────────────────────────────────────────────────────
  Future<String> translateText({
    required String text,
    required String targetLang, // 'en', 'vi', 'fr',...
  }) async {
    try {
      final response = await _dio.post(
        '/translate',
        data: {
          'text': text,
          'target_lang': targetLang,
        },
      );

      if (response.statusCode == 200) {
        return response.data['translated_text'] as String;
      } else {
        return text; // fallback nếu lỗi
      }
    } catch (e) {
      print('Lỗi dịch: $e');
      return text; // fallback
    }
  }

  // Bạn có thể thêm các phương thức khác ở đây:
  // - getNearbyRestaurants(...)
  // - searchByVoice(String query)
  // - submitReview(...)
}