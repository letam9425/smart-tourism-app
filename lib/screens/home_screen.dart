import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/place_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Tourism"),
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          return PlaceCard(place: places[index]);
        },
      ),
    );
  }
}