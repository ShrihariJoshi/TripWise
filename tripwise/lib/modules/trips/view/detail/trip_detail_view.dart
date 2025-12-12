import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../model/trip_model.dart';
import '../itinerary/itinerary_view.dart';
import '../settings/trip_settings_view.dart';

class TripDetailView extends StatefulWidget {
  final Trip trip;

  const TripDetailView({super.key, required this.trip});

  @override
  State<TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<TripDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(top: 60, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, lightTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: robotoText(
                        widget.trip.tripName,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    robotoText(
                      widget.trip.destination,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    robotoText(
                      widget.trip.dateRange,
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: darkTeal,
              unselectedLabelColor: const Color(0xff888888),
              indicatorColor: darkTeal,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Expenses'),
                Tab(text: 'Itinerary'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DashboardTab(trip: widget.trip),
                _ExpensesTab(trip: widget.trip),
                ItineraryView(trip: widget.trip),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Trip trip;

  const _DashboardTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget Overview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                robotoText(
                  "Budget Overview",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTeal,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        robotoText(
                          "Total Budget",
                          fontSize: 13,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 4),
                        robotoText(
                          "₹${trip.budget.toStringAsFixed(2)}",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff333333),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        robotoText(
                          "Spent",
                          fontSize: 13,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 4),
                        robotoText(
                          "₹${trip.spent.toStringAsFixed(2)}",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: trip.progress > 0.8 ? Colors.red : lightTeal,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: trip.progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xffE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trip.progress > 0.8
                          ? Colors.red
                          : trip.progress > 0.6
                          ? Colors.orange
                          : lightTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    robotoText(
                      "${(trip.progress * 100).toStringAsFixed(1)}% used",
                      fontSize: 12,
                      color: const Color(0xff888888),
                    ),
                    robotoText(
                      "₹${(trip.budget - trip.spent).toStringAsFixed(2)} remaining",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff666666),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trip Status
          robotoText(
            "Trip Status",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xff888888),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(trip.status),
                    color: _getStatusColor(trip.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    robotoText(
                      _getStatusText(trip.status),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff333333),
                    ),
                    const SizedBox(height: 2),
                    robotoText(
                      _getStatusDescription(trip.status),
                      fontSize: 13,
                      color: const Color(0xff888888),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Members Section
          robotoText(
            "Trip Members",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xff888888),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: trip.memberNames.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: robotoText(
                        "No members added yet",
                        fontSize: 14,
                        color: const Color(0xff888888),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: trip.memberNames.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: borderColor),
                    itemBuilder: (context, index) {
                      final memberName = trip.memberNames[index];
                      final isCreator = memberName == trip.createdBy;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: lightTeal.withOpacity(0.2),
                          child: robotoText(
                            memberName[0].toUpperCase(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkTeal,
                          ),
                        ),
                        title: robotoText(
                          memberName,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff333333),
                        ),
                        subtitle: isCreator
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: robotoText(
                                  "Trip Creator",
                                  fontSize: 12,
                                  color: darkTeal,
                                ),
                              )
                            : null,
                        trailing: isCreator
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: darkTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: robotoText(
                                  "Admin",
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: darkTeal,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Settings
          robotoText(
            "Settings",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xff888888),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Get.to(() => TripSettingsView(trip: trip));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: darkTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        robotoText(
                          "Trip Settings",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff333333),
                        ),
                        const SizedBox(height: 2),
                        robotoText(
                          "Manage trip preferences",
                          fontSize: 13,
                          color: const Color(0xff888888),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xffBBBBBB),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return const Color(0xff4CAF50);
      case TripStatus.upcoming:
        return const Color(0xff2196F3);
      case TripStatus.completed:
        return const Color(0xff9E9E9E);
    }
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return Icons.flight_takeoff;
      case TripStatus.upcoming:
        return Icons.schedule;
      case TripStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return "Active Trip";
      case TripStatus.upcoming:
        return "Upcoming Trip";
      case TripStatus.completed:
        return "Completed Trip";
    }
  }

  String _getStatusDescription(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return "Trip is currently ongoing";
      case TripStatus.upcoming:
        return "Trip hasn't started yet";
      case TripStatus.completed:
        return "Trip has been completed";
    }
  }
}

class _ExpensesTab extends StatelessWidget {
  final Trip trip;

  const _ExpensesTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Color(0xffCCCCCC)),
          const SizedBox(height: 16),
          robotoText(
            "Expenses feature coming soon",
            fontSize: 16,
            color: const Color(0xff888888),
          ),
        ],
      ),
    );
  }
}
