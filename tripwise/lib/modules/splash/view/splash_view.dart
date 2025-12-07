import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/auth/controller/auth_controller.dart';
import 'package:tripwise/modules/auth/view/login_choice_screen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    Get.put(AuthController());
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.forward();
    // Navigate to home screen after 3s
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Get.to(() => const LoginChoiceScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/TripWiseLogo.png'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: darkTeal,
                      borderRadius: BorderRadius.circular(24),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: robotoText(
                  "Welcome to TripWise!\nTrip Planning and Expense Tracking made easier",
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ));
  }
}
