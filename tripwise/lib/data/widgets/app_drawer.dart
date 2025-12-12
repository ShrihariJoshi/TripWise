import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/modules/home/controller/home_controller.dart';
import 'package:tripwise/modules/profile/view/edit_profile_sheet.dart';
import 'package:tripwise/modules/settings/view/settings_view.dart';
import '../config/colors.dart';
import '../config/text_styles.dart';
import 'package:tripwise/modules/profile/controller/profile_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Enhanced Header with User Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
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
                Obx(
                  () => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profileController.fullName.value.isNotEmpty
                            ? profileController.fullName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: darkTeal,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => robotoText(
                    profileController.fullName.value,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => robotoText(
                    profileController.email.value,
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
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

          const Divider(height: 1, indent: 16, endIndent: 16),

          _DrawerItem(
            icon: Icons.group_outlined,
            label: "Manage Groups",
            onTap: () {
              Get.back();
            },
          ),

          _DrawerItem(
            icon: Icons.person_add_alt_outlined,
            label: "Requests",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: robotoText(
                "3",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onTap: () {
              Get.back();
            },
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          _DrawerItem(
            icon: Icons.edit,
            label: "Edit profile",
            onTap: () {
              Get.back();
              Get.find<HomeController>().currentIndex.value = 2;
              Get.bottomSheet(
                const EditProfileSheet(),
                isScrollControlled: true,
              );
            },
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: "Settings",
            onTap: () {
              Get.back();
              Get.to(() => const SettingsView());
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

          const Divider(height: 1),

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
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color ?? const Color(0xff333333), size: 24),
      title: robotoText(
        label,
        fontSize: 16,
        color: color ?? const Color(0xff333333),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      hoverColor: lightTeal.withOpacity(0.1),
    );
  }
}
