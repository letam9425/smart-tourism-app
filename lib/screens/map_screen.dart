import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place_model.dart';

class MapScreen extends StatelessWidget {
  final Place place;

  const MapScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(place.latitude, place.longitude),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId(place.name),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(title: place.name),
          ),
        },
      ),
    );
  }
}