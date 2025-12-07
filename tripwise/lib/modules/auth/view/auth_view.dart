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
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffD7D7D7)),
            borderRadius: BorderRadius.circular(24),
            color: bgColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 32,
                spreadRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/file.svg',
                    height: 90,
                    color: darkTeal,
                  ),
                  const SizedBox(width: 20),
                  robotoText(
                    controller.pageName.value == 'login'
                        ? 'Login'
                        : 'Sign up',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: darkTeal,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SIGNUP ONLY FIELDS
              Obx(() {
                if (controller.pageName.value == 'login') {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Username"),
                    _inputBox(
                      controller: controller.usernameController,
                      hint: "Enter your username",
                    ),
                    const SizedBox(height: 12),

                    _label("Phone Number"),
                    _inputBox(
                      controller: controller.phoneNoController,
                      hint: "Enter your phone number",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),

              /// EMAIL
              _label("Email"),
              _inputBox(
                controller: controller.emailController,
                hint: "Enter your email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              /// PASSWORD
              _label("Password"),
              _inputBox(
                controller: controller.passwordController,
                hint: "Enter your password",
                obscure: true,
              ),

              const SizedBox(height: 36),

              /// SUBMIT BUTTON
              GestureDetector(
                onTap: () async {
                  if (controller.pageName.value == 'login') {
                    await controller.loginUser();
                  } else {
                    await controller.registerUser();
                  }

                  /// ✅ UI FLOW: Auth → Home
                  Get.offAll(() => const HomeView());
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: robotoText(
                    controller.pageName.value == 'login'
                        ? "Login"
                        : "Sign up",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// SMALL HELPERS (keeps UI clean)
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: robotoText(
        text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD7D7D7), width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        cursorHeight: 16,
        style: inputTextStyle,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: hintTextStyle,
        ),
      ),
    );
  }
}
