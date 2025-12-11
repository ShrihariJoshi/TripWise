import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../controller/trips_controller.dart';
import '../../model/trip_model.dart';

class TripsTabs extends StatelessWidget {
  final TripsController controller;

  const TripsTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Obx(
        () => Row(
          children: TripStatus.values.map((status) {
            final selected = controller.activeTab.value == status;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setTab(status),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? darkTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: robotoText(
                      status.name[0].toUpperCase() + status.name.substring(1),
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xff666666),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
