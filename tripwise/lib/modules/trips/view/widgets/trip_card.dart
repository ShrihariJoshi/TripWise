import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../model/trip_model.dart';
import '../trip_detail_view.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TripDetailView(trip: trip)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Name
            Row(
              children: [
                Expanded(
                  child: robotoText(
                    trip.tripName,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Created By
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                robotoText(
                  "Created by ${trip.createdBy}",
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff666666),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Destination
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                robotoText(
                  trip.destination,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff333333),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dates
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                robotoText(
                  trip.dateRange,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff666666),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Budget
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lightTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lightTeal.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  robotoText(
                    "Budget",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTeal,
                  ),
                  robotoText(
                    "₹${trip.budget.toStringAsFixed(0)}",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkTeal,
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
