import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../screens/place_detail_screen.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Image.network(place.imageUrl, width: 70, fit: BoxFit.cover),
        title: Text(place.name),
        subtitle: Text(place.description),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          );
        },
      ),
    );
  }
}