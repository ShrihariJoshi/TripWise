import 'package:flutter/material.dart';
import '../../model/trip_model.dart';

class TripDetailView extends StatelessWidget {
  final Trip trip;

  const TripDetailView({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip.destination)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.dateRange),
            const SizedBox(height: 16),
            Text("Budget: ₹${trip.budget}"),
            Text("Spent: ₹${trip.spent}"),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: trip.progress),
          ],
        ),
      ),
    );
  }
}
