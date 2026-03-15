import 'package:get/get.dart';
import 'package:tripwise/data/services/api_service.dart';

class ProfileController extends GetxController {
  final api = Get.find<ApiService>();

  RxString fullName = 'user1'.obs;
  final email = 'john.doe@email.com'.obs;
  final phone = '6361558082'.obs;

  void updateField(String type, String value) {
    if (type == 'name') fullName.value = value;
    if (type == 'email') email.value = value;
    if (type == 'phone') phone.value = value;
  }

  /// Update profile via API
  Future<bool> updateProfile({
    required String email,
    required String phone,
  }) async {
    try {
      final body = {
        'username': fullName.value,
        'new_email': email,
        'new_phone': phone,
      };

      final response = await api.patch('/update_profile', body: body);

      if (response['message'] != null || response['status'] == 'success') {
        // Update local state
        this.email.value = email;
        this.phone.value = phone;
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }
}
