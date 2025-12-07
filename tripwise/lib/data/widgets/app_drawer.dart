import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              "TripWise",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          _DrawerItem(
            icon: Icons.history,
            label: "Recent Activity",
            onTap: () {
              Get.back();
              // TODO: Navigate later
            },
          ),

          _DrawerItem(
            icon: Icons.group,
            label: "Manage Friends",
            onTap: () {
              Get.back();
            },
          ),

          _DrawerItem(
            icon: Icons.mail_outline,
            label: "Invitations",
            onTap: () {
              Get.back();
            },
          ),

          _DrawerItem(
            icon: Icons.help_outline,
            label: "Help & FAQ",
            onTap: () {
              Get.back();
            },
          ),

          const Spacer(),

          const Divider(),

          _DrawerItem(
            icon: Icons.logout,
            label: "Logout",
            color: Colors.red,
            onTap: () {
              Get.back();
              // TODO: clear auth + redirect
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ------------------------------
/// Drawer Item
/// ------------------------------
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
