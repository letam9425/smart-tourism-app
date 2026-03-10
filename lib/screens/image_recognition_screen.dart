// lib/screens/image_recognition_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_tourism_app/services/api_service.dart';
import 'package:smart_tourism_app/screens/place_detail_screen.dart';
import 'package:smart_tourism_app/providers/place_providers.dart';

// Notifier cho kết quả nhận diện
class RecognitionResultNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void setResult(Map<String, dynamic>? result) {
    state = result;
  }

  void clear() {
    state = null;
  }
}

final recognitionResultProvider = NotifierProvider<RecognitionResultNotifier, Map<String, dynamic>?>(
  RecognitionResultNotifier.new,
);

// Notifier cho trạng thái đang xử lý
class IsProcessingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool loading) {
    state = loading;
  }
}

final isProcessingProvider = NotifierProvider<IsProcessingNotifier, bool>(
  IsProcessingNotifier.new,
);

class ImageRecognitionScreen extends ConsumerWidget {
  const ImageRecognitionScreen({super.key});

  Future<void> _pickAndDetect(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, maxWidth: 800);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    ref.read(isProcessingProvider.notifier).setLoading(true);

    try {
      final result = await ApiService().detectLandmark(file);
      ref.read(recognitionResultProvider.notifier).setResult(result);

      final landmarkId = result['landmark_id'] as int?;
      if (landmarkId != null && landmarkId > 0) {
        final place = await ApiService().getPlaceDetail(landmarkId);
        ref.read(selectedPlaceProvider.notifier).select(place);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlaceDetailScreen()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi nhận diện: $e')),
        );
      }
    } finally {
      ref.read(isProcessingProvider.notifier).setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(isProcessingProvider);
    final result = ref.watch(recognitionResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhận diện danh lam')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Đang nhận diện ảnh...'),
            ] else if (result != null) ...[
              Text('Kết quả: ${result['name'] ?? 'Không xác định'}'),
              Text('Độ tin cậy: ${(result['confidence'] * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh'),
              onPressed: () => _pickAndDetect(context, ref, ImageSource.camera),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn từ thư viện'),
              onPressed: () => _pickAndDetect(context, ref, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}