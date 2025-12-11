import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/data/widgets/app_drawer.dart';
import 'package:tripwise/modules/home/controller/home_controller.dart';
import 'package:tripwise/modules/profile/controller/profile_controller.dart';
import 'package:tripwise/modules/trips/view/widgets/create_trip_sheet.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final bool isTripActive = true;

  // Sample data - replace with actual data from controller
  final String tripName = "European Adventure";
  final String destination = "Paris, France";
  final String startDate = "Dec 15, 2025";
  final String endDate = "Dec 22, 2025";
  final int currentDay = 3;
  final int totalDays = 7;
  final double budgetUsed = 1250.50;
  final double totalBudget = 3000.00;

  // Sample expense groups data
  final List<Map<String, dynamic>> expenseGroups = [
    {
      'name': 'Dinner at Le Bistro',
      'amount': 450.00,
      'isSettled': false,
      'participants': 4,
      'paidBy': 'You',
      'date': 'Dec 13, 2025',
    },
    {
      'name': 'Hotel Booking',
      'amount': 2500.00,
      'isSettled': false,
      'participants': 2,
      'paidBy': 'John',
      'date': 'Dec 12, 2025',
    },
    {
      'name': 'Museum Tickets',
      'amount': 180.00,
      'isSettled': true,
      'participants': 4,
      'paidBy': 'Sarah',
      'date': 'Dec 11, 2025',
    },
    {
      'name': 'Taxi Ride',
      'amount': 75.00,
      'isSettled': true,
      'participants': 3,
      'paidBy': 'Mike',
      'date': 'Dec 10, 2025',
    },
    {
      'name': 'Lunch',
      'amount': 320.00,
      'isSettled': true,
      'participants': 4,
      'paidBy': 'You',
      'date': 'Dec 9, 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final homeController = Get.find<HomeController>();

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
                      // TODO: Navigate to trip details
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
                      child: (isTripActive)
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
                                              tripName,
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
                                                  destination,
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
                                          "Day $currentDay/$totalDays",
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
                                          startDate,
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
                                          endDate,
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
                                            "₹${budgetUsed.toStringAsFixed(2)} / ₹${totalBudget.toStringAsFixed(2)}",
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
                                          value: budgetUsed / totalBudget,
                                          minHeight: 8,
                                          backgroundColor: const Color(
                                            0xffE0E0E0,
                                          ),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                budgetUsed / totalBudget > 0.8
                                                    ? Colors.red
                                                    : budgetUsed / totalBudget >
                                                          0.6
                                                    ? Colors.orange
                                                    : lightTeal,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      robotoText(
                                        "${((budgetUsed / totalBudget) * 100).toStringAsFixed(1)}% used",
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

                  // Expense Groups List
                  ...(() {
                    final unsettled = expenseGroups
                        .where((e) => !e['isSettled'])
                        .toList();
                    final settled = expenseGroups
                        .where((e) => e['isSettled'])
                        .take(2)
                        .toList();

                    // If no unsettled groups, show "All expenses settled" message
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
                          (group) => _ExpenseGroupCard(
                            name: group['name'],
                            amount: group['amount'],
                            isSettled: group['isSettled'],
                            participants: group['participants'],
                            paidBy: group['paidBy'],
                            date: group['date'],
                          ),
                        ),
                      ];
                    }

                    final displayGroups = [...unsettled, ...settled];

                    return displayGroups
                        .map(
                          (group) => _ExpenseGroupCard(
                            name: group['name'],
                            amount: group['amount'],
                            isSettled: group['isSettled'],
                            participants: group['participants'],
                            paidBy: group['paidBy'],
                            date: group['date'],
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

/// Expense Group Card Widget
class _ExpenseGroupCard extends StatelessWidget {
  final String name;
  final double amount;
  final bool isSettled;
  final int participants;
  final String paidBy;
  final String date;

  const _ExpenseGroupCard({
    required this.name,
    required this.amount,
    required this.isSettled,
    required this.participants,
    required this.paidBy,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to expense group details
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSettled
                    ? const Color(0xffE8F5E9)
                    : lightTeal.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSettled ? Icons.check_circle : Icons.pending,
                color: isSettled ? const Color(0xff4CAF50) : darkTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Expense Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: robotoText(
                          name,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff333333),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      robotoText(
                        "₹${amount.toStringAsFixed(2)}",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSettled ? const Color(0xff666666) : darkTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Color(0xff888888),
                      ),
                      const SizedBox(width: 4),
                      robotoText(
                        "$participants participants",
                        fontSize: 12,
                        color: const Color(0xff888888),
                      ),
                      const SizedBox(width: 12),
                      robotoText(
                        "•",
                        fontSize: 12,
                        color: const Color(0xff888888),
                      ),
                      const SizedBox(width: 12),
                      robotoText(
                        "Paid by $paidBy",
                        fontSize: 12,
                        color: const Color(0xff888888),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  robotoText(
                    date,
                    fontSize: 11,
                    color: const Color(0xff999999),
                  ),
                ],
              ),
            ),

            // Status Badge
            if (!isSettled)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: robotoText(
                  "Unsettled",
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
