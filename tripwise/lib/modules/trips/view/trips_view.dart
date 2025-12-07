import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/widgets/gradient_header.dart';
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
      backgroundColor: const Color(0xffFAFBFB),

      // ✅ Floating + button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _openCreateTrip(context),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          /// ✅ Gradient header
          const GradientHeader(
            title: "My Trips",
          ),

          /// ✅ Create / Join buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openCreateTrip(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Create Trip"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: controller.openJoinTripDialog,
                    icon: const Icon(Icons.person_add, color: Colors.teal),
                    label: const Text(
                      "Join Trip",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ✅ Tabs (Active / Upcoming / Completed)
          TripsTabs(controller: controller),

          /// ✅ Trips List
          Expanded(
            child: Obx(
              () {
                final trips = controller.filteredTrips;

                if (trips.isEmpty) {
                  return const Center(
                    child: Text(
                      "No trips found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (_, index) {
                    return TripCard(trip: trips[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
