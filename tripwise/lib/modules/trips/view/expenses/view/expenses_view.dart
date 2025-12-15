import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/trips/model/trip_model.dart';
import 'package:tripwise/modules/trips/view/expenses/widgets/add_expense_sheet.dart';
import 'package:tripwise/modules/trips/controller/expenses_controller.dart';

class ExpensesView extends StatefulWidget {
  final Trip trip;

  const ExpensesView({super.key, required this.trip});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final Set<String> _settledDebts = {}; // Track settled debts by unique key
  late final ExpensesController _expensesController;

  @override
  void initState() {
    super.initState();
    _expensesController = Get.put(ExpensesController());
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    await _expensesController.fetchExpenses(widget.trip.tripName);
    await _expensesController.fetchSettlements(widget.trip.tripName);
  }

  String _getSettlementKey(Settlement settlement) {
    return '${settlement.id}_${settlement.from}_${settlement.to}_${settlement.amount.toStringAsFixed(2)}';
  }

  void _markAsSettled(Settlement settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: darkTeal, size: 28),
            const SizedBox(width: 12),
            robotoText(
              'Confirm Settlement',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkTeal,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            robotoText(
              'Mark this payment as settled?',
              fontSize: 16,
              color: const Color(0xff4A5568),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightTeal.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lightTeal.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  robotoText(
                    '${settlement.from} → ${settlement.to}',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff2D3748),
                  ),
                  const SizedBox(height: 4),
                  robotoText(
                    '₹${settlement.amount.toStringAsFixed(2)}',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTeal,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              side: const BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: robotoText(
              'Cancel',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xff666666),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkTeal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                _settledDebts.add(_getSettlementKey(settlement));
              });
              Navigator.pop(context);
              Get.snackbar(
                'Settlement Recorded',
                '${settlement.from} → ${settlement.to}: ₹${settlement.amount.toStringAsFixed(2)} marked as paid',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xff4DB6AC),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 3),
              );
            },
            child: robotoText(
              'Mark as Paid',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _addExpense(Expense expense) async {
    // Refresh expenses from API after adding
    await _fetchExpenses();
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddExpenseSheet(trip: widget.trip, onExpenseAdded: _addExpense),
    );
  }

  // Calculate balance for current user
  Map<String, double> _calculateBalances() {
    Map<String, double> balances = {};
    final expenses = _expensesController.expenses;

    // Initialize all members with 0 balance
    for (var member in widget.trip.memberNames) {
      balances[member] = 0.0;
    }

    // Calculate balances
    for (var expense in expenses) {
      double perPersonShare = expense.perPersonShare;

      // Payer gets credited
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      // Each person in split gets debited
      if (expense.splitBetween.isNotEmpty) {
        for (var member in expense.splitBetween) {
          balances[member] = (balances[member] ?? 0) - perPersonShare;
        }
      } else {
        // If splitBetween is empty, split equally among all members
        final sharePerMember = expense.amount / widget.trip.memberNames.length;
        for (var member in widget.trip.memberNames) {
          balances[member] = (balances[member] ?? 0) - sharePerMember;
        }
      }
    }

    return balances;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_expensesController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: darkTeal));
      }

      final expenses = _expensesController.expenses;
      final balances = _calculateBalances();
      final settlements = _expensesController.settlements;
      final currentUserBalance =
          balances['John Doe'] ?? 0.0; // Replace with actual current user

      // Sort expenses by date (most recent first)
      final sortedExpenses = List<Expense>.from(expenses)
        ..sort((a, b) => b.date.compareTo(a.date));

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Combined Balance & Settlement Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Section with Gradient Background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: currentUserBalance >= 0
                                ? [darkTeal, lightTeal]
                                : [
                                    const Color(0xffF44336),
                                    const Color(0xffd32f2f),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            robotoText(
                              currentUserBalance >= 0
                                  ? 'You are owed'
                                  : 'You owe',
                              fontSize: 16,
                              color: Colors.white.withAlpha(90),
                            ),
                            const SizedBox(height: 8),
                            robotoText(
                              '₹${currentUserBalance.abs().toStringAsFixed(2)}',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: robotoText(
                                'Total spent: ₹${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settlement Section
                      if (settlements.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              size: 20,
                              color: darkTeal,
                            ),
                            const SizedBox(width: 8),
                            robotoText(
                              'Settlement Summary',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff2D3748),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_expensesController.isLoadingSettlements.value)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: darkTeal,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          ...settlements.map((settlement) {
                            final settlementKey = _getSettlementKey(settlement);
                            final isSettled = _settledDebts.contains(
                              settlementKey,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSettled
                                    ? Colors.grey.shade50
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSettled
                                      ? Colors.grey.shade300
                                      : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSettled
                                        ? Icons.check_circle
                                        : Icons.arrow_forward,
                                    size: 18,
                                    color: isSettled
                                        ? Colors.green
                                        : const Color(0xff718096),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        robotoText(
                                          '${settlement.from} → ${settlement.to}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isSettled
                                              ? Colors.grey.shade600
                                              : const Color(0xff2D3748),
                                        ),
                                        if (isSettled)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: robotoText(
                                              'Settled',
                                              fontSize: 12,
                                              color: Colors.green,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  robotoText(
                                    '₹${settlement.amount.toStringAsFixed(2)}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSettled
                                        ? Colors.grey.shade600
                                        : darkTeal,
                                  ),
                                  if (!isSettled) ...[
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 32,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          side: const BorderSide(
                                            color: darkTeal,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _markAsSettled(settlement),
                                        child: robotoText(
                                          'Settle',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: darkTeal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showAddExpenseSheet,
                      icon: const Icon(Icons.add, size: 18),
                      label: robotoText(
                        "Add expense",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Expense History Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 20, color: darkTeal),
                      const SizedBox(width: 8),
                      robotoText(
                        'Expense History',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff2D3748),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expense List as Sliver
          sortedExpenses.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        robotoText(
                          'No expenses yet',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = sortedExpenses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Expense Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        robotoText(
                                          expense.name,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff2D3748),
                                        ),
                                        const SizedBox(height: 4),
                                        robotoText(
                                          DateFormat(
                                            'MMM d, yyyy',
                                          ).format(expense.date),
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Amount
                                  robotoText(
                                    '₹${expense.amount.toStringAsFixed(2)}',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2D3748),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: borderColor),
                              const SizedBox(height: 12),
                              // Payer and Split Info
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      robotoText(
                                        'Paid by ${expense.paidBy}',
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  // Row(
                                  //   children: [
                                  //     const Icon(
                                  //       Icons.group,
                                  //       size: 16,
                                  //       color: Colors.grey,
                                  //     ),
                                  //     const SizedBox(width: 4),
                                  //     robotoText(
                                  //       'Split ${expense.splitBetween.length} ways',
                                  //       fontSize: 13,
                                  //       color: Colors.grey,
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Current User's Share
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 8,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: isCurrentUserPayer
                              //         ? darkTeal.withAlpha(10)
                              //         : const Color(0xffFF9800).withAlpha(10),
                              //     borderRadius: BorderRadius.circular(8),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       robotoText(
                              //         isCurrentUserPayer
                              //             ? 'You get back'
                              //             : 'You owe',
                              //         fontSize: 13,
                              //         fontWeight: FontWeight.w500,
                              //         color: isCurrentUserPayer
                              //             ? darkTeal
                              //             : const Color(0xffFF9800),
                              //       ),
                              //       robotoText(
                              //         '₹${currentUserShare.toStringAsFixed(2)}',
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.bold,
                              //         color: isCurrentUserPayer
                              //             ? darkTeal
                              //             : const Color(0xffFF9800),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: sortedExpenses.length),
                  ),
                ),
        ],
      );
    });
  }
}
