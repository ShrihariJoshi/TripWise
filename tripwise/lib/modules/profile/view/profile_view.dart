import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/settings/view/settings_view.dart';
import '../controller/profile_controller.dart';
import 'package:tripwise/modules/profile/view/widgets/profile_title.dart';
import 'package:tripwise/modules/profile/view/edit_profile_sheet.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          /// Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ).copyWith(top: 64, bottom: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, lightTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: robotoText(
                "Profile",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          /// Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 32),
                  // Personal Information Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "Personal Information",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ).copyWith(top: 32, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(
                      () => Column(
                        children: [
                          // Avatar
                          Obx(
                            () => Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: darkTeal,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  controller.fullName.value.isNotEmpty
                                      ? controller.fullName.value[0]
                                            .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(
                            () => robotoText(
                              controller.fullName.value,
                              fontSize: 24,
                              lineHeight: 1.1,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff333333),
                            ),
                          ),
                          robotoText(
                            "Traveler & Explorer",
                            fontSize: 14,
                            color: const Color(0xff888888),
                          ),
                          const SizedBox(height: 20),
                          ProfileTile(
                            icon: Icons.person_outline,
                            label: "Full Name",
                            value: controller.fullName.value,
                          ),
                          ProfileTile(
                            icon: Icons.email_outlined,
                            label: "Email",
                            value: controller.email.value,
                          ),
                          ProfileTile(
                            icon: Icons.phone_outlined,
                            label: "Phone",
                            value: controller.phone.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2, indent: 20, endIndent: 20),
                  const SizedBox(height: 12),
                  // Edit profile Tile
                  _ActionTile(
                    icon: Icons.edit,
                    label: "Edit profile",
                    onTap: () {
                      Get.bottomSheet(
                        const EditProfileSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  //Settings tile
                  _ActionTile(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                    onTap: () {
                      Get.to(() => const SettingsView());
                    },
                  ),
                  const SizedBox(height: 12),

                  // Help & Support Tile
                  _ActionTile(
                    icon: Icons.help_outline,
                    label: "Help & Support",
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: bgColor,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    size: 48,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                robotoText(
                                  "Logout",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 12),
                                robotoText(
                                  "Are you sure you want to logout?",
                                  fontSize: 14,
                                  color: const Color(0xff666666),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          side: const BorderSide(
                                            color: borderColor,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => Get.back(),
                                        child: robotoText(
                                          "Cancel",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff666666),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade400,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Get.back();
                                          // TODO: Clear auth and redirect to login
                                          Get.snackbar(
                                            "Logged Out",
                                            "You have been logged out successfully",
                                            backgroundColor: lightTeal,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                            margin: const EdgeInsets.all(16),
                                            borderRadius: 12,
                                          );
                                        },
                                        child: robotoText(
                                          "Logout",
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.red),
                            const SizedBox(width: 4),
                            robotoText(
                              "Logout",
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Logout Tile
                  // _ActionTile(
                  //   icon: Icons.logout,
                  //   label: "Logout",
                  //   color: Colors.red,
                  //   onTap: () {
                  //     // TODO: Logout logic
                  //     Get.defaultDialog(
                  //       title: "Logout",
                  //       middleText: "Are you sure you want to logout?",
                  //       textConfirm: "Yes",
                  //       textCancel: "No",
                  //       confirmTextColor: Colors.white,
                  //       onConfirm: () {
                  //         Get.back();
                  //         // TODO: Clear auth and redirect
                  //       },
                  //     );
                  //   },
                  // ),
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

/// Action Tile Widget
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color ?? const Color(0xff333333)),
              const SizedBox(width: 16),
              Expanded(
                child: robotoText(
                  label,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? const Color(0xff333333),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color ?? const Color(0xff999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
