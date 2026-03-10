// lib/providers/place_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tourism_app/models/place_model.dart';
import 'package:smart_tourism_app/services/api_service.dart';

// Provider cho danh sách gợi ý places
final recommendedPlacesProvider = FutureProvider<List<Place>>((ref) async {
  // Mock vị trí TP.HCM - sau này thay bằng geolocator thật
  const double mockLat = 10.7769;
  const double mockLng = 106.7009;

  return await ApiService().getRecommendedPlaces(
    latitude: mockLat,
    longitude: mockLng,
    limit: 10,
  );
});

// Notifier cho place đang chọn
class SelectedPlaceNotifier extends Notifier<Place?> {
  @override
  Place? build() => null;

  void select(Place? place) {
    state = place;
  }
}

final selectedPlaceProvider = NotifierProvider<SelectedPlaceNotifier, Place?>(
  SelectedPlaceNotifier.new,
);