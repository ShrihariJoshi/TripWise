import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxString fullName = 'user1'.obs;
  final email = 'john.doe@email.com'.obs;
  final phone = '+91 6361558082'.obs;

  void updateField(String type, String value) {
    if (type == 'name') fullName.value = value;
    if (type == 'email') email.value = value;
    if (type == 'phone') phone.value = value;
  }
}
