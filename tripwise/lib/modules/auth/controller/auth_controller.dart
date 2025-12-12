import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:tripwise/data/config/tripwise.dart';
import 'package:tripwise/data/services/cache_service.dart';

class AuthController extends GetxController {
  final _backendBaseUrl = Tripwise.baseUrl;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNoController = TextEditingController();

  RxString pageName = 'login'.obs;
  Map<String, dynamic> body = {};

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
  }

  /// Login using email + password
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password are required');
      return;
    }

    try {
      final resp = await _dio.post(
        '$_backendBaseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final token = data['access_token'];
        if (token != null) {
          // persist token to CacheService (SharedPreferences)
          try {
            await Get.find<CacheService>().saveTokensToCache(
              accessToken: token,
            );
          } catch (e) {
            // Fall back to showing success even if cache save fails
            Get.log('Failed to save token to cache: $e');
          }
          Get.snackbar('Success', 'Logged in successfully');
        } else {
          Get.snackbar('Error', 'Login succeeded but no token returned');
        }
      } else {
        Get.snackbar('Error', 'Login failed: ${resp.statusCode}');
      }
    } on DioException catch (e) {
      String message = 'Login error';
      if (e.response != null && e.response?.data != null) {
        try {
          final d = e.response?.data;
          if (d is Map && d['message'] != null) message = d['message'];
        } catch (_) {}
      }
      Get.snackbar('Error', message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// Read the stored access token from CacheService
  String? getStoredAccessToken() {
    try {
      return Get.find<CacheService>().accessToken;
    } catch (e) {
      Get.log('CacheService not available: $e');
      return null;
    }
  }

  /// Clear stored tokens (logout)
  Future<void> clearStoredTokens() async {
    try {
      await Get.find<CacheService>().clearTokens();
    } catch (e) {
      Get.log('Error clearing tokens: $e');
    }
  }

  /// Register a new user
  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNoController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      final resp = await _dio.post(
        '$_backendBaseUrl/register',
        data: {
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        Get.snackbar('Success', 'Registered successfully');
      } else {
        Get.snackbar('Error', 'Registration failed: ${resp.statusCode}');
      }
    } on DioException catch (e) {
      String message = 'Registration error';
      if (e.response != null && e.response?.data != null) {
        try {
          final d = e.response?.data;
          if (d is Map && d['message'] != null) message = d['message'];
        } catch (_) {}
      }
      Get.snackbar('Error', message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void clearForm() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneNoController.clear();
  }
}
