import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/home/controller/home_controller.dart';
import 'package:tripwise/modules/profile/view/edit_profile_sheet.dart';
import 'package:tripwise/modules/profile/view/profile_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                robotoText(
                  "Settings",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          /// Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "Account",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff888888),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    onTap: () {
                      Get.back();
                      
                      Future.delayed(const Duration(milliseconds: 300));
                      Get.bottomSheet(
                        const EditProfileSheet(),
                        isScrollControlled: true,
                      );
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.security_outlined,
                    title: "Privacy & Security",
                    subtitle: "Manage your privacy settings",
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    subtitle: "Configure notification preferences",
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),

                  const SizedBox(height: 24),

                  // App Preferences Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "App Preferences",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff888888),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: "Language",
                    subtitle: "English (US)",
                    onTap: () {
                      // TODO: Navigate to language settings
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.currency_rupee,
                    title: "Currency",
                    subtitle: "Indian Rupee (₹)",
                    onTap: () {
                      // TODO: Navigate to currency settings
                    },
                  ),

                  _SettingsSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    subtitle: "Enable dark theme",
                    value: false,
                    onChanged: (value) {
                      // TODO: Toggle dark mode
                    },
                  ),

                  const SizedBox(height: 24),

                  // Data & Storage Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "Data & Storage",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff888888),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.cloud_outlined,
                    title: "Backup & Sync",
                    subtitle: "Manage your data backup",
                    onTap: () {
                      // TODO: Navigate to backup settings
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.storage_outlined,
                    title: "Storage",
                    subtitle: "Manage app storage",
                    onTap: () {
                      // TODO: Navigate to storage settings
                    },
                  ),

                  const SizedBox(height: 24),

                  // Support Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "Support",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff888888),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: "Help & FAQ",
                    subtitle: "Get help and answers",
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.feedback_outlined,
                    title: "Send Feedback",
                    subtitle: "Share your thoughts with us",
                    onTap: () {
                      // TODO: Navigate to feedback
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: "About",
                    subtitle: "Version 1.0.0",
                    onTap: () {
                      // TODO: Show about dialog
                      _showAboutDialog(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Danger Zone
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: robotoText(
                      "Danger Zone",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.delete_outline,
                    title: "Delete Account",
                    subtitle: "Permanently delete your account",
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.card_travel, size: 48, color: darkTeal),
              ),
              const SizedBox(height: 16),
              robotoText(
                "TripWise",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkTeal,
              ),
              const SizedBox(height: 8),
              robotoText(
                "Version 1.0.0",
                fontSize: 14,
                color: const Color(0xff666666),
              ),
              const SizedBox(height: 16),
              robotoText(
                "Trip planning and expense tracking made easier",
                fontSize: 14,
                color: const Color(0xff888888),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: robotoText(
                    "Close",
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  Icons.warning_outlined,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              robotoText(
                "Delete Account?",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 12),
              robotoText(
                "This action cannot be undone. All your data will be permanently deleted.",
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: borderColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        // TODO: Delete account logic
                        Get.snackbar(
                          "Account Deleted",
                          "Your account has been deleted",
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: robotoText(
                        "Delete",
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
  }
}

/// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? darkTeal).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 22, color: iconColor ?? darkTeal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    robotoText(
                      title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xff333333),
                    ),
                    const SizedBox(height: 2),
                    robotoText(
                      subtitle,
                      fontSize: 13,
                      color: const Color(0xff888888),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings Switch Tile Widget
class _SettingsSwitchTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends State<_SettingsSwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: darkTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, size: 22, color: darkTeal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  robotoText(
                    widget.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff333333),
                  ),
                  const SizedBox(height: 2),
                  robotoText(
                    widget.subtitle,
                    fontSize: 13,
                    color: const Color(0xff888888),
                  ),
                ],
              ),
            ),
            Switch(
              value: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                widget.onChanged(value);
              },
              activeColor: darkTeal,
            ),
          ],
        ),
      ),
    );
  }
}
