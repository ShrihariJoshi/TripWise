import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/data/services/api_service.dart';
import 'package:tripwise/modules/profile/controller/profile_controller.dart';
import 'package:uuid/uuid.dart';
import '../model/trip_model.dart';

class TripsController extends GetxController {
  final api = Get.find<ApiService>();

  /// ----------------------------
  /// STATE
  /// ----------------------------

  final activeTab = TripStatus.active.obs;

  final trips = <Trip>[].obs;

  final isCreating = false.obs;

  final joinTripController = TextEditingController();

  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    // Schedule fetch after build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTrips();
    });
  }

  /// ----------------------------
  /// FETCH TRIPS FROM BACKEND
  /// ----------------------------

  Future<void> fetchTrips() async {
    try {
      final userName = Get.find<ProfileController>().fullName.value;
      final response = await api.get('/trip-details?username=$userName');

      if (response['trips'] != null) {
        final List<dynamic> tripsData = response['trips'];

        trips.clear();

        for (var tripJson in tripsData) {
          final trip = Trip(
            id: tripJson['trip_id']?.toString() ?? _uuid.v4(),
            tripName: tripJson['trip_name'] ?? '',
            createdBy: tripJson['created_by'] ?? 'Unknown',
            destination: tripJson['destination'] ?? '',
            startDate: tripJson['start_date'] != null
                ? DateTime.parse(tripJson['start_date'])
                : DateTime.now(),
            endDate: tripJson['end_date'] != null
                ? DateTime.parse(tripJson['end_date'])
                : DateTime.now(),
            budget: tripJson['trip_budget']?.toDouble() ?? 0.0,
            spent: tripJson['amount_spent']?.toDouble() ?? 0.0,
            members: tripJson['members']?.length ?? 0,
            memberNames: tripJson['members'] != null
                ? List<String>.from(tripJson['members'])
                : [],
          );

          trips.add(trip);
        }
      }
    } catch (e) {
      // If API fails, load sample trips as fallback
      _loadSampleTrips();
      Get.snackbar(
        "Info",
        "Loading sample trips",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xff4DB6AC),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// ----------------------------
  /// SAMPLE DATA (Fallback)
  /// ----------------------------

  void _loadSampleTrips() {
    final now = DateTime.now();

    trips.addAll([
      // Active Trip 1
      Trip(
        id: _uuid.v4(),
        tripName: "Goa Beach Getaway",
        createdBy: "You",
        destination: "Goa, India",
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        budget: 25000,
        spent: 12000,
        members: 4,
        memberNames: ["You", "Rahul Sharma", "Priya Patel", "Vikram Singh"],
      ),

      // Active Trip 2
      Trip(
        id: _uuid.v4(),
        tripName: "Manali Adventure",
        createdBy: "Rahul Sharma",
        destination: "Manali, Himachal Pradesh",
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 6)),
        budget: 35000,
        spent: 8500,
        members: 3,
        memberNames: ["Rahul Sharma", "Amit Kumar", "Neha Gupta"],
      ),

      // Upcoming Trip 1
      Trip(
        id: _uuid.v4(),
        tripName: "Kerala Backwaters",
        createdBy: "You",
        destination: "Alleppey, Kerala",
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 20)),
        budget: 40000,
        spent: 0,
        members: 2,
        memberNames: ["You", "Priya Patel"],
      ),

      // Upcoming Trip 2
      Trip(
        id: _uuid.v4(),
        tripName: "Rajasthan Heritage Tour",
        createdBy: "Priya Patel",
        destination: "Jaipur, Rajasthan",
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 37)),
        budget: 50000,
        spent: 0,
        members: 5,
        memberNames: [
          "Priya Patel",
          "You",
          "Rahul Sharma",
          "Amit Kumar",
          "Vikram Singh",
        ],
      ),

      // Upcoming Trip 3
      Trip(
        id: _uuid.v4(),
        tripName: "Ladakh Expedition",
        createdBy: "Vikram Singh",
        destination: "Leh, Ladakh",
        startDate: now.add(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 70)),
        budget: 75000,
        spent: 0,
        members: 6,
        memberNames: [
          "Vikram Singh",
          "You",
          "Rahul Sharma",
          "Neha Gupta",
          "Amit Kumar",
          "Anjali Verma",
        ],
      ),

      // Completed Trip 1
      Trip(
        id: _uuid.v4(),
        tripName: "Udaipur Weekend",
        createdBy: "You",
        destination: "Udaipur, Rajasthan",
        startDate: now.subtract(const Duration(days: 45)),
        endDate: now.subtract(const Duration(days: 42)),
        budget: 18000,
        spent: 17500,
        members: 2,
        memberNames: ["You", "Neha Gupta"],
      ),

      // Completed Trip 2
      Trip(
        id: _uuid.v4(),
        tripName: "Shimla Family Trip",
        createdBy: "Amit Kumar",
        destination: "Shimla, Himachal Pradesh",
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 85)),
        budget: 30000,
        spent: 28900,
        members: 4,
        memberNames: ["Amit Kumar", "Priya Patel", "Rahul Sharma", "You"],
      ),

      // Completed Trip 3
      Trip(
        id: _uuid.v4(),
        tripName: "Rishikesh Yoga Retreat",
        createdBy: "Neha Gupta",
        destination: "Rishikesh, Uttarakhand",
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 115)),
        budget: 22000,
        spent: 21000,
        members: 3,
        memberNames: ["Neha Gupta", "Priya Patel", "Anjali Verma"],
      ),

      // Completed Trip 4
      Trip(
        id: _uuid.v4(),
        tripName: "Mumbai City Break",
        createdBy: "You",
        destination: "Mumbai, Maharashtra",
        startDate: now.subtract(const Duration(days: 150)),
        endDate: now.subtract(const Duration(days: 147)),
        budget: 15000,
        spent: 15200,
        members: 1,
        memberNames: ["You"],
      ),
    ]);
  }

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

  Future<void> createTrip({
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
  }) async {
    if (isCreating.value) return;

    isCreating.value = true;

    try {
      final body = {
        'trip_name': tripName,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'destination': destination,
        'created_by': 'user1',
        'trip_budget': budget,
      };

      final response = await api.post('/trip', body: body);

      // Parse response and create Trip object
      final newTrip = Trip(
        id: response['id'] ?? _uuid.v4(),
        tripName: response['trip_name'] ?? tripName,
        createdBy: response['created_by'] ?? "You",
        destination: response['destination'] ?? destination,
        startDate: response['start_date'] != null
            ? DateTime.parse(response['start_date'])
            : startDate,
        endDate: response['end_date'] != null
            ? DateTime.parse(response['end_date'])
            : endDate,
        budget: response['trip_budget']?.toDouble() ?? budget,
        spent: response['spent']?.toDouble() ?? 0,
        members: response['members'] ?? 1,
        memberNames: response['member_names'] != null
            ? List<String>.from(response['member_names'])
            : ["You"],
      );

      trips.add(newTrip);

      Get.snackbar(
        "Trip Created",
        "Trip '$tripName' created successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xff4DB6AC),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create trip: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isCreating.value = false;
    }
  }

  /// ----------------------------
  /// JOIN TRIP
  /// ----------------------------

  Future<bool> joinTrip(String tripName) async {
    try {
      final userName = Get.find<ProfileController>().fullName.value;

      final body = {
        'username': userName,
        'tripname': tripName,
        'role': 'member',
      };

      final response = await api.post('/join_trip', body: body);

      if (response['message'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to join trip: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
  }

  /// ----------------------------
  /// JOIN TRIP DIALOG
  /// ----------------------------

  void openJoinTripDialog() {
    joinTripController.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: lightTeal.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: darkTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  robotoText(
                    "Join Trip",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkTeal,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              robotoText(
                "Enter the Trip name shared by the trip creator to join",
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xff666666),
              ),
              const SizedBox(height: 16),

              // Input label
              robotoText(
                "Trip name",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff333333),
              ),
              const SizedBox(height: 8),

              // Input field
              TextField(
                controller: joinTripController,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff333333),
                  letterSpacing: -0.28,
                ),
                decoration: InputDecoration(
                  hintText: "e.g. coorg_trip_26/12",
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xff999999),
                    letterSpacing: -0.28,
                  ),
                  prefixIcon: const Icon(Icons.key, color: darkTeal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: lightTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: borderColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: robotoText(
                        "Cancel",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff666666),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkTeal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final tripName = joinTripController.text.trim();

                        if (tripName.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Trip name cannot be empty",
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                          return;
                        }

                        // Close dialog before API call
                        Get.back();

                        // Call join trip API
                        final success = await joinTrip(tripName);

                        if (success) {
                          Get.snackbar(
                            "Success",
                            "Successfully joined trip!",
                            backgroundColor: lightTeal,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                          // Refresh trips list
                          await fetchTrips();
                        }
                      },
                      child: robotoText(
                        "Join Trip",
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  void onClose() {
    joinTripController.dispose();
    super.onClose();
  }
}
