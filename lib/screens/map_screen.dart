// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_tourism_app/providers/place_providers.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(recommendedPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ du lịch')),
      body: placesAsync.when(
        data: (places) {
          final markers = places.map((place) {
            return Marker(
              markerId: MarkerId(place.id.toString()),
              position: LatLng(place.latitude, place.longitude),
              infoWindow: InfoWindow(title: place.name),
            );
          }).toSet();

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(10.7769, 106.7009), // TP.HCM
              zoom: 12,
            ),
            markers: markers,
            myLocationEnabled: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải bản đồ: $err')),
      ),
    );
  }
}