import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/auth/controller/auth_controller.dart';
import 'package:tripwise/modules/auth/view/auth_view.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        backgroundColor: bgColor,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffD7D7D7),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, 4),
                    spreadRadius: 4,
                    blurRadius: 32,
                  )
                ],
                color: bgColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/file.svg',
                      height: 100,
                      width: 100,
                      color: darkTeal,
                    ),
                    robotoText(
                      'TripWise',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: darkTeal,
                    )
                  ],
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    controller.pageName.value = 'signup';
                    Get.to(() => const AuthView());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: lightTeal,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 12),
                        robotoText("Register/Sign up",
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    controller.pageName.value = 'login';
                    Get.to(() => const AuthView());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: lightTeal,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.login),
                        const SizedBox(width: 12),
                        robotoText("Login",
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
