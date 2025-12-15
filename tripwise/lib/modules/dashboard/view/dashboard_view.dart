import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/data/widgets/app_drawer.dart';
import 'package:tripwise/modules/home/controller/home_controller.dart';
import 'package:tripwise/modules/profile/controller/profile_controller.dart';
import 'package:tripwise/modules/trips/controller/trips_controller.dart';
import 'package:tripwise/modules/trips/model/trip_model.dart';
import 'package:tripwise/modules/trips/view/detail/trip_detail_view.dart';
import 'package:tripwise/modules/trips/view/widgets/create_trip_sheet.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final bool isTripActive = true;

  // Sample trip expense data
  final List<Map<String, dynamic>> tripExpenses = [
    {
      'tripName': 'European Adventure',
      'netAmount': 850.00,
      'isOwed': false, // false means you owe, true means you're owed
      'isSettled': false,
      'owedTo': ['John', 'Sarah'],
      'destination': 'Paris, France',
    },
    {
      'tripName': 'Goa Beach Getaway',
      'netAmount': 1200.00,
      'isOwed': true, // you are owed
      'isSettled': false,
      'owedBy': ['Mike', 'Alex', 'Emma'],
      'destination': 'Goa, India',
    },
    {
      'tripName': 'Manali Adventure',
      'netAmount': 0.00,
      'isOwed': null,
      'isSettled': true,
      'destination': 'Manali, India',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final homeController = Get.find<HomeController>();
    final tripsController = Get.put(TripsController());

    // Get the first active trip from the controller
    final Trip? activeTrip = tripsController.trips
        .where((trip) => trip.status == TripStatus.active)
        .toList()
        .firstOrNull;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: bgColor,

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(top: 50, bottom: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, lightTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Drawer Button
                Builder(
                  builder: (scaffoldContext) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                    constraints: const BoxConstraints(),
                  ),
                ),

                // User Info Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        robotoText(
                          "Welcome back,",
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          lineHeight: 1.1,
                        ),
                        Obx(
                          () => robotoText(
                            profileController.fullName.value,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Avatar Button
                GestureDetector(
                  onTap: () {
                    homeController.currentIndex.value = 2;
                  },
                  child: Obx(
                    () => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          profileController.fullName.value.isNotEmpty
                              ? profileController.fullName.value[0]
                                    .toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: darkTeal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  robotoText(
                    "Active trip".toUpperCase(),
                    color: const Color(0xffABABAB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (activeTrip != null) {
                        Get.to(() => TripDetailView(trip: activeTrip));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 0.88),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 2),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: (activeTrip != null)
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Trip Name & Destination
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            robotoText(
                                              activeTrip.tripName,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: darkTeal,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Color(0xff666666),
                                                ),
                                                const SizedBox(width: 4),
                                                robotoText(
                                                  activeTrip.destination,
                                                  fontSize: 14,
                                                  color: const Color(
                                                    0xff666666,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: lightTeal.withAlpha(10),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: lightTeal,
                                            width: 1,
                                          ),
                                        ),
                                        child: robotoText(
                                          "Day ${activeTrip.currentDay}/${activeTrip.totalDays}",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: darkTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Dates
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF5F5F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Color(0xff666666),
                                        ),
                                        const SizedBox(width: 8),
                                        robotoText(
                                          "${activeTrip.startDate.day}/${activeTrip.startDate.month}/${activeTrip.startDate.year}",
                                          fontSize: 13,
                                          color: const Color(0xff333333),
                                        ),
                                        const SizedBox(width: 8),
                                        robotoText(
                                          "→",
                                          fontSize: 13,
                                          color: const Color(0xff999999),
                                        ),
                                        const SizedBox(width: 8),
                                        robotoText(
                                          "${activeTrip.endDate.day}/${activeTrip.endDate.month}/${activeTrip.endDate.year}",
                                          fontSize: 13,
                                          color: const Color(0xff333333),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Budget Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          robotoText(
                                            "Budget Used",
                                            fontSize: 13,
                                            color: const Color(0xff666666),
                                          ),
                                          robotoText(
                                            "₹${activeTrip.spent.toStringAsFixed(2)} / ₹${activeTrip.budget.toStringAsFixed(2)}",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff333333),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: activeTrip.progress,
                                          minHeight: 8,
                                          backgroundColor: const Color(
                                            0xffE0E0E0,
                                          ),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                activeTrip.progress > 0.8
                                                    ? Colors.red
                                                    : activeTrip.progress > 0.6
                                                    ? Colors.orange
                                                    : lightTeal,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      robotoText(
                                        "${(activeTrip.progress * 100).toStringAsFixed(1)}% used",
                                        fontSize: 11,
                                        color: const Color(0xff999999),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 40,
                              ),
                              child: Column(
                                mainAxisAlignment: .center,
                                children: [
                                  robotoText(
                                    "No active plans.\nPlan one with your friends soon!",
                                    fontSize: 18,
                                    letterSpacing: -0.36,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center,
                                    color: darkTeal,
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ).copyWith(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: lightTeal,
                                    ),
                                    child: Row(
                                      mainAxisSize: .min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Get.bottomSheet(
                                              const CreateTripSheet(),
                                              isScrollControlled: true,
                                            );
                                          },
                                        ),
                                        robotoText(
                                          "Create new trip",
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Expenses Section
                  robotoText(
                    "Expenses".toUpperCase(),
                    color: const Color(0xffABABAB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),

                  // Trip Expense List
                  ...(() {
                    final unsettled = tripExpenses
                        .where((e) => !e['isSettled'])
                        .toList();
                    final settled = tripExpenses
                        .where((e) => e['isSettled'])
                        .take(2)
                        .toList();

                    // If no unsettled expenses, show "All expenses settled" message
                    if (unsettled.isEmpty) {
                      return [
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xffE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xff4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xff4CAF50),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              robotoText(
                                "All expenses settled",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff2E7D32),
                              ),
                            ],
                          ),
                        ),
                        ...settled.map(
                          (trip) => _TripExpenseCard(
                            tripName: trip['tripName'],
                            destination: trip['destination'],
                            netAmount: trip['netAmount'],
                            isOwed: trip['isOwed'],
                            isSettled: trip['isSettled'],
                            owedTo: trip['owedTo'],
                            owedBy: trip['owedBy'],
                          ),
                        ),
                      ];
                    }

                    final displayTrips = [...unsettled, ...settled];

                    return displayTrips
                        .map(
                          (trip) => _TripExpenseCard(
                            tripName: trip['tripName'],
                            destination: trip['destination'],
                            netAmount: trip['netAmount'],
                            isOwed: trip['isOwed'],
                            isSettled: trip['isSettled'],
                            owedTo: trip['owedTo'],
                            owedBy: trip['owedBy'],
                          ),
                        )
                        .toList();
                  })(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Trip Expense Card Widget
class _TripExpenseCard extends StatelessWidget {
  final String tripName;
  final String destination;
  final double netAmount;
  final bool? isOwed; // null if settled, false if you owe, true if you're owed
  final bool isSettled;
  final List<dynamic>? owedTo;
  final List<dynamic>? owedBy;

  const _TripExpenseCard({
    required this.tripName,
    required this.destination,
    required this.netAmount,
    required this.isOwed,
    required this.isSettled,
    this.owedTo,
    this.owedBy,
  });

  @override
  Widget build(BuildContext context) {
    String peopleText = '';
    if (!isSettled) {
      if (isOwed == false && owedTo != null && owedTo!.isNotEmpty) {
        peopleText = owedTo!.length == 1
            ? 'You owe ${owedTo![0]}'
            : 'You owe ${owedTo!.join(', ')}';
      } else if (isOwed == true && owedBy != null && owedBy!.isNotEmpty) {
        peopleText = owedBy!.length == 1
            ? '${owedBy![0]} owes you'
            : '${owedBy!.join(', ')} owe you';
      }
    }

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to trip expense details
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSettled ? const Color(0xffE0E0E0) : borderColor,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSettled
                    ? const Color(0xffE3F2FD)
                    : (isOwed == true
                          ? const Color(0xffE8F5E9)
                          : const Color(0xffFFEBEE)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSettled
                    ? Icons.check_circle
                    : (isOwed == true
                          ? Icons.arrow_downward
                          : Icons.arrow_upward),
                color: isSettled
                    ? const Color(0xff2196F3)
                    : (isOwed == true ? const Color(0xff4CAF50) : Colors.red),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Trip Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  robotoText(
                    tripName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff333333),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Color(0xff888888),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: robotoText(
                          destination,
                          fontSize: 12,
                          color: const Color(0xff888888),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (!isSettled && peopleText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isOwed == true ? Icons.person : Icons.person_outline,
                          size: 13,
                          color: isOwed == true
                              ? const Color(0xff4CAF50)
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: robotoText(
                            peopleText,
                            fontSize: 12,
                            color: isOwed == true
                                ? const Color(0xff4CAF50)
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isSettled)
                  robotoText(
                    "${isOwed == true ? '+' : '-'}₹${netAmount.toStringAsFixed(2)}",
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isOwed == true
                        ? const Color(0xff4CAF50)
                        : Colors.red.shade700,
                  ),
                if (isSettled)
                  robotoText(
                    "Settled",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff2196F3),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSettled
                        ? const Color(0xffE3F2FD)
                        : (isOwed == true
                              ? const Color(0xffE8F5E9)
                              : Colors.red.withAlpha(30)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSettled
                          ? const Color(0xff2196F3)
                          : (isOwed == true
                                ? const Color(0xff4CAF50)
                                : Colors.red),
                      width: 1,
                    ),
                  ),
                  child: robotoText(
                    isSettled
                        ? "Settled"
                        : (isOwed == true ? "You get" : "You owe"),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSettled
                        ? const Color(0xff1976D2)
                        : (isOwed == true
                              ? const Color(0xff2E7D32)
                              : Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
