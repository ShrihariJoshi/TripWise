import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import '../create_trip_view.dart';

class TripsActions extends StatelessWidget {
  const TripsActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add,
              label: "Create Trip",
              onTap: () => Get.to(() => const CreateTripView()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.group_add,
              label: "Join Trip",
              onTap: () {
                Get.snackbar("Join Trip", "Join trip coming soon");
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: lightTeal.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: darkTeal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: darkTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
