// lib/screens/place_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_tourism_app/providers/place_providers.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final place = ref.watch(selectedPlaceProvider);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết')),
        body: const Center(child: Text('Không có thông tin địa điểm')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(place.latitude, place.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(place.id.toString()),
                    position: LatLng(place.latitude, place.longitude),
                  ),
                },
                myLocationEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(' ${place.rating.toStringAsFixed(1)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(place.description),
                  const SizedBox(height: 16),
                  if (place.images.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: place.images.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(place.images[i], width: 180, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.translate),
                    label: const Text('Dịch sang tiếng Anh'),
                    onPressed: () {
                      // Gọi translate API hoặc chuyển sang translate_screen
                      Navigator.pushNamed(context, '/translate', arguments: place.description);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}