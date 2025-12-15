import 'package:get/get.dart';
import 'package:tripwise/data/services/api_service.dart';
import 'package:tripwise/modules/trips/model/trip_model.dart';

class ExpensesController extends GetxController {
  final api = Get.find<ApiService>();

  final isLoading = false.obs;
  final isLoadingSettlements = false.obs;
  final expenses = <Expense>[].obs;
  final settlements = <Settlement>[].obs;

  /// Add expense to backend
  Future<Expense?> addExpense({
    required String tripName,
    required String name,
    required double amount,
    required String paidBy,
    required DateTime date,
    required List<String> splitBetween,
  }) async {
    try {
      isLoading.value = true;

      // Calculate shares for each member
      final perPersonShare = amount / splitBetween.length;
      final shares = <String, double>{};
      for (var member in splitBetween) {
        shares[member] = perPersonShare;
      }

      final body = {
        'trip_name': tripName,
        'amount': amount,
        'paid_by': paidBy,
        'date': date.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
        'shares': shares,
      };

      final response = await api.post('/expense', body: body);

      // Create Expense object from response
      final expense = Expense(
        id:
            response['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        paidBy: paidBy,
        splitBetween: splitBetween,
        date: date,
      );

      expenses.add(expense);
      return expense;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add expense: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch expenses for a trip
  Future<void> fetchExpenses(String tripName) async {
    try {
      isLoading.value = true;
      final response = await api.get(
        '/trip-expense-history',
        queryParameters: {'trip_name': tripName},
      );

      if (response.statusCode == 200 && response.data != null) {
        final expensesList = response.data['expenses'] as List<dynamic>?;
        if (expensesList != null) {
          expenses.value = expensesList
              .map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Failed to fetch expenses: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch expenses: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch settlements for a trip
  Future<void> fetchSettlements(String tripName) async {
    try {
      isLoadingSettlements.value = true;
      final response = await api.get(
        '/splits',
        queryParameters: {'trip_name': tripName},
      );

      if (response.statusCode == 200 && response.data != null) {
        final settlementsList = response.data['settlements'] as List<dynamic>?;
        if (settlementsList != null) {
          settlements.value = settlementsList
              .map((e) => Settlement.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Failed to fetch settlements: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch settlements: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingSettlements.value = false;
    }
  }
}
