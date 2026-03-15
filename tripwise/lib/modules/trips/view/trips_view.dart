import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../controller/trips_controller.dart';
import 'widgets/create_trip_sheet.dart';
import 'widgets/trips_tabs.dart';
import 'widgets/trip_card.dart';

class TripsView extends StatelessWidget {
  TripsView({super.key});

  // ✅ Important: controller created ONCE
  final TripsController controller = Get.put(TripsController());

  void _openCreateTrip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateTripSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ).copyWith(top: 64, bottom: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, lightTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: robotoText(
                "My Trips",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          /// ✅ Tabs (Active / Upcoming / Completed)
          TripsTabs(controller: controller),

          /// ✅ Create / Join buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openCreateTrip(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: robotoText(
                      "Create Trip",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: darkTeal, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.openJoinTripDialog,
                    icon: const Icon(
                      Icons.person_add,
                      color: darkTeal,
                      size: 18,
                    ),
                    label: robotoText(
                      "Join Trip",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ✅ Trips List
          Expanded(
            child: Obx(() {
              final trips = controller.filteredTrips;

              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.airplanemode_inactive,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      robotoText(
                        "No trips found",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: trips.length,
                itemBuilder: (_, index) {
                  return TripCard(trip: trips[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
