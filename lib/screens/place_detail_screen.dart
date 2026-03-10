import 'package:flutter/material.dart';
import '../models/place_model.dart';
import 'map_screen.dart';
import 'package:smart_tourism_app/screens/map_screen.dart';
class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Column(
        children: [

          Image.network(
            place.imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 20),

          Text(
            place.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(place.description),
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("Xem bản đồ"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(place: place),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}