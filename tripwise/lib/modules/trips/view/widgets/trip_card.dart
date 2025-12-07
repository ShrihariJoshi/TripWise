import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/trip_model.dart';
import '../detail/trip_detail_view.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TripDetailView(trip: trip)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Destination
            Text(
              trip.destination,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            /// ✅ Trip ID (small but important)
            Text(
              "Trip ID: ${trip.id.substring(0, 8)}",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),

            const SizedBox(height: 4),

            /// Dates
            Text(trip.dateRange, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 12),

            /// Progress
            LinearProgressIndicator(
              value: trip.progress.clamp(0, 1),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }
}
