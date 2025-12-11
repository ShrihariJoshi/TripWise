import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final pages = [
      DashboardView(),
      TripsView(),
      // ExpensesView(),
      ProfileView(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: bgColor,

        body: pages[controller.currentIndex.value],

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              selectedLabelStyle: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.24,
              ),
              unselectedLabelStyle: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.24,
              ),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: darkTeal,
              unselectedItemColor: Colors.grey,
              currentIndex: controller.currentIndex.value,
              onTap: (index) {
                controller.currentIndex.value = index;
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.airplanemode_active),
                  label: "Trips",
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.payments),
                //   label: "Expenses"
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
