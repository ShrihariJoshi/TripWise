import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../controller/profile_controller.dart';

class EditProfileSheet extends StatelessWidget {
  const EditProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final nameController = TextEditingController(
      text: controller.fullName.value,
    );
    final emailController = TextEditingController(text: controller.email.value);
    final phoneController = TextEditingController(text: controller.phone.value);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xffDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                robotoText(
                  "Edit Profile",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkTeal,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff666666)),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form Fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name Field
                robotoText(
                  "Full Name",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your full name",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: darkTeal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                robotoText(
                  "Email",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: darkTeal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Field
                robotoText(
                  "Phone Number",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your phone number",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: darkTeal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // Validate inputs
                      if (emailController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Email and phone are required',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        return;
                      }

                      // Close the sheet
                      Get.back();

                      // Call API to update profile
                      final success = await controller.updateProfile(
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim(),
                      );

                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Profile updated successfully',
                          backgroundColor: lightTeal,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    },
                    child: robotoText(
                      "Save Changes",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
