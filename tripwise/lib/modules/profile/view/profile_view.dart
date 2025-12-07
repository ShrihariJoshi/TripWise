import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/widgets/gradient_header.dart';
import '../controller/profile_controller.dart';
import 'package:tripwise/modules/profile/view/widgets/profile_title.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      body: Column(
        children: [
          /// ✅ BIG GRADIENT HEADER (extended)
          GradientHeader(
            title: "Profile",
            height: 230,
            trailing: const Icon(Icons.menu, color: Colors.white),
          ),

          /// Avatar + Name
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.teal,
                      child: const Text(
                        "JD",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.edit, size: 14),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      controller.fullName.value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                const SizedBox(height: 4),
                const Text("Traveler & Explorer",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          /// CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text("Personal Information",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    ProfileTile(
                      icon: Icons.person,
                      label: "Full Name",
                      value: controller.fullName.value,
                      onEdit: () =>
                          _editDialog("name", controller),
                    ),
                    ProfileTile(
                      icon: Icons.email,
                      label: "Email",
                      value: controller.email.value,
                      onEdit: () =>
                          _editDialog("email", controller),
                    ),
                    ProfileTile(
                      icon: Icons.phone,
                      label: "Phone",
                      value: controller.phone.value,
                      onEdit: () =>
                          _editDialog("phone", controller),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// --------------------------
  /// Edit Dialog
  /// --------------------------
  void _editDialog(String type, ProfileController controller) {
    final textCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Edit"),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (textCtrl.text.isNotEmpty) {
                controller.updateField(type, textCtrl.text);
              }
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
