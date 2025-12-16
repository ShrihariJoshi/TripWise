import 'package:get/get.dart';
import 'package:tripwise/data/services/api_service.dart';
import 'package:tripwise/modules/dashboard/model/expense_model.dart';
import 'package:tripwise/modules/profile/controller/profile_controller.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final profileController = Get.find<ProfileController>();

  var isLoadingExpenses = false.obs;
  var userExpenses = <UserExpense>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserExpenses();
  }

  Future<void> fetchUserExpenses() async {
    try {
      isLoadingExpenses.value = true;
      errorMessage.value = '';
      final username = profileController.fullName.value;

      final response = await _apiService.get(
        '/user-expenses',
        queryParameters: {'username': username},
      );

      print(response);

      if (response['trip_balances'] != null) {
        final expenseResponse = UserExpenseResponse.fromJson(response);
        userExpenses.value = expenseResponse.tripBalances;
      } else {
        errorMessage.value = 'Failed to load expenses';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.log('Error fetching user expenses: $e');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<void> refreshExpenses() async {
    await fetchUserExpenses();
  }
}
