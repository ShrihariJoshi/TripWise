import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/auth/controller/auth_controller.dart';
import 'package:tripwise/modules/home/view/home_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final inputTextStyle = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    letterSpacing: -0.28,
  );

  final hintTextStyle = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
    letterSpacing: -0.28,
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.clearForm();
          },
          icon: const Icon(Icons.arrow_back),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 20),
                  Center(
                    child: robotoText(
                      controller.pageName.value == 'login'
                          ? 'Login'
                          : 'Sign up',
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: darkTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() {
                return (controller.pageName.value != 'login')
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: robotoText(
                                "Username",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Username
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffD7D7D7),
                                      width: 0.8),
                                  borderRadius: BorderRadius.circular(16)),
                              child: TextField(
                                controller: controller.usernameController,
                                style: inputTextStyle,
                                cursorHeight: 16,
                                decoration: InputDecoration(
                                  hintText: "Enter your username",
                                  border: InputBorder.none,
                                  hintStyle: hintTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Phone number
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: robotoText(
                                "Phone Number",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xffD7D7D7),
                                      width: 0.8),
                                  borderRadius: BorderRadius.circular(16)),
                              child: TextField(
                                controller: controller.phoneNoController,
                                keyboardType: TextInputType.phone,
                                style: inputTextStyle,
                                cursorHeight: 16,
                                decoration: InputDecoration(
                                  hintText: "Enter your phone number",
                                  border: InputBorder.none,
                                  hintStyle: hintTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12)
                          ])
                    : const SizedBox.shrink();
              }),
              // Email
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: robotoText(
                  "Email",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xffD7D7D7), width: 0.8),
                    borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: inputTextStyle,
                  cursorHeight: 16,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    border: InputBorder.none,
                    hintStyle: hintTextStyle,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: robotoText(
                  "Password",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xffD7D7D7), width: 0.8),
                    borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: inputTextStyle,
                  cursorHeight: 16,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    border: InputBorder.none,
                    hintStyle: hintTextStyle,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  if (controller.pageName.value == 'login') {
                    await controller.loginUser();
                  } else {
                    await controller.registerUser();
                  }
                  // Optionally navigate on success
                  // Get.to(() => HomeView());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: robotoText(
                      controller.pageName.value == "login"
                          ? "Login"
                          : "Sign up",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
