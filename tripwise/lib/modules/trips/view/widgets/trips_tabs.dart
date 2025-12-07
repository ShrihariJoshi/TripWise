import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/trips_controller.dart';
import '../../model/trip_model.dart';

class TripsTabs extends StatelessWidget {
  final TripsController controller;

  const TripsTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: TripStatus.values.map((status) {
            final selected = controller.activeTab.value == status;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setTab(status),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.teal.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? Colors.teal : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}
