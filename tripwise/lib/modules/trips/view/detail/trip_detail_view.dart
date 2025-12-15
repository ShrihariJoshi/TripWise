import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/trips/view/dashboard/trip_dashboard_view.dart';
import 'package:tripwise/modules/trips/view/expenses/view/expenses_view.dart';
import '../../model/trip_model.dart';
import '../itinerary/itinerary_view.dart';

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
                TripDashboardView(trip: widget.trip),
                ExpensesView(trip: widget.trip),
                ItineraryView(trip: widget.trip),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
