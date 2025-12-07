import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/trip_model.dart';

class TripsController extends GetxController {
  /// ----------------------------
  /// STATE
  /// ----------------------------

  final activeTab = TripStatus.active.obs;

  final trips = <Trip>[].obs;

  final isCreating = false.obs;

  final joinTripController = TextEditingController();

  final Uuid _uuid = const Uuid();

  /// ----------------------------
  /// TAB LOGIC
  /// ----------------------------

  void setTab(TripStatus status) {
    activeTab.value = status;
  }

  List<Trip> get filteredTrips =>
      trips.where((t) => t.status == activeTab.value).toList();

  /// ----------------------------
  /// CREATE TRIP
  /// ----------------------------

  void createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
  }) {
    if (isCreating.value) return;

    isCreating.value = true;

    final newTrip = Trip(
      id: _uuid.v4(), // ✅ unique trip id
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      spent: 0,
      members: 1,
    );

    trips.add(newTrip);

    isCreating.value = false;

    Get.snackbar(
      "Trip Created",
      "Trip to $destination created",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ----------------------------
  /// JOIN TRIP DIALOG
  /// ----------------------------

  void openJoinTripDialog() {
    joinTripController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Join Trip",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter Trip ID",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: joinTripController,
                decoration: InputDecoration(
                  hintText: "e.g. 550e8400-e29b-41d4",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (Get.isDialogOpen ?? false) {
                          Navigator.of(Get.overlayContext!).pop();
                        }
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        final tripId = joinTripController.text.trim();

                        if (tripId.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Trip ID cannot be empty",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        /// 🔁 BACKEND LATER
                        /// For now — just simulate successful join
                        if (Get.isDialogOpen ?? false) {
                          Navigator.of(Get.overlayContext!).pop();
                        }

                        Get.snackbar(
                          "Joined Trip",
                          "Trip ID: $tripId",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text("Join"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// ----------------------------
  /// CLEANUP
  /// ----------------------------

  @override
  void onClose() {
    joinTripController.dispose();
    super.onClose();
  }
}
