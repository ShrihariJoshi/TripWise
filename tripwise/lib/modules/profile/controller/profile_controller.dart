import 'package:get/get.dart';

class ProfileController extends GetxController {
  var fullName = 'John Doe'.obs;
  var email = 'john.doe@email.com'.obs;
  var phone = '+1 234 567 8900'.obs;

  void updateField(String type, String value) {
    if (type == 'name') fullName.value = value;
    if (type == 'email') email.value = value;
    if (type == 'phone') phone.value = value;
  }
}
