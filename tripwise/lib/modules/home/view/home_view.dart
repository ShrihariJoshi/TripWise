import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/modules/home/controller/home_controller.dart';
import 'package:tripwise/modules/dashboard/view/dashboard_view.dart';
import 'package:tripwise/modules/trips/view/trips_view.dart';
import 'package:tripwise/modules/expenses/view/expenses_view.dart';
import 'package:tripwise/modules/profile/view/profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    /// ✅ Each page handles its OWN layout & GradientHeader
    final pages = [
      const DashboardView(), // Gradient: "TripWise"
      TripsView(),           // Gradient: "My Trips"
      const ExpensesView(),  // Gradient: "My Expenses"
      const ProfileView(),   // Gradient: "Profile"
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: bgColor,

        /// ✅ Switch between pages
        body: pages[controller.currentIndex.value],

        /// ✅ Bottom navigation only
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              )
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: darkTeal,
            unselectedItemColor: Colors.grey,
            currentIndex: controller.currentIndex.value,
            onTap: (index) =>
                controller.currentIndex.value = index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.place),
                label: "Trips",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments),
                label: "Expenses",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
