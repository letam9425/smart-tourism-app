// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tourism_app/providers/place_providers.dart';
import 'package:smart_tourism_app/widgets/place_card.dart';
import 'package:smart_tourism_app/screens/place_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(recommendedPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám phá Việt Nam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => Navigator.pushNamed(context, '/recognition'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(recommendedPlacesProvider.future),
        child: placesAsync.when(
          data: (places) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return PlaceCard(
                place: place,
                onTap: () {
                  ref.read(selectedPlaceProvider.notifier).state = place;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlaceDetailScreen()),
                  );
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Lỗi: $err\nKéo xuống thử lại'),
          ),
        ),
      ),
    );
  }
}