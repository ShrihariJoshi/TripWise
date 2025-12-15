import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/trips/model/trip_model.dart';

class ExpensesView extends StatelessWidget {
  final Trip trip;

  const ExpensesView({super.key, required this.trip});

  // Mock data - replace with actual data from backend
  List<Expense> get mockExpenses => [
    Expense(
      id: '1',
      name: 'Dinner at Local Restaurant',
      description: 'Traditional cuisine',
      amount: 120.00,
      paidBy: 'John Doe',
      splitBetween: trip.memberNames,
      category: ExpenseCategory.food,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Expense(
      id: '2',
      name: 'Taxi to Hotel',
      description: 'From airport',
      amount: 45.00,
      paidBy: 'Jane Smith',
      splitBetween: trip.memberNames,
      category: ExpenseCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Expense(
      id: '3',
      name: 'Hotel Booking',
      description: '3 nights',
      amount: 450.00,
      paidBy: 'Mike Wilson',
      splitBetween: trip.memberNames,
      category: ExpenseCategory.accommodation,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Expense(
      id: '4',
      name: 'Museum Tickets',
      description: 'Group entry',
      amount: 80.00,
      paidBy: 'John Doe',
      splitBetween: trip.memberNames,
      category: ExpenseCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Expense(
      id: '5',
      name: 'Souvenirs',
      description: 'Local crafts',
      amount: 60.00,
      paidBy: 'Jane Smith',
      splitBetween: trip.memberNames,
      category: ExpenseCategory.shopping,
      date: DateTime.now(),
    ),
  ];

  // Calculate balance for current user
  Map<String, double> _calculateBalances() {
    Map<String, double> balances = {};

    // Initialize all members with 0 balance
    for (var member in trip.memberNames) {
      balances[member] = 0.0;
    }

    // Calculate balances
    for (var expense in mockExpenses) {
      double perPersonShare = expense.perPersonShare;

      // Payer gets credited
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      // Each person in split gets debited
      for (var member in expense.splitBetween) {
        balances[member] = (balances[member] ?? 0) - perPersonShare;
      }
    }

    return balances;
  }

  List<Settlement> _calculateSettlements(Map<String, double> balances) {
    List<Settlement> settlements = [];

    // Separate creditors (people who should receive money) and debtors (people who owe money)
    List<MapEntry<String, double>> creditors = [];
    List<MapEntry<String, double>> debtors = [];

    balances.forEach((member, balance) {
      if (balance > 0.01) {
        creditors.add(MapEntry(member, balance));
      } else if (balance < -0.01) {
        debtors.add(MapEntry(member, -balance));
      }
    });

    // Sort for optimal settlement
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    // Calculate settlements
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      double amount = debtors[i].value < creditors[j].value
          ? debtors[i].value
          : creditors[j].value;

      settlements.add(
        Settlement(from: debtors[i].key, to: creditors[j].key, amount: amount),
      );

      debtors[i] = MapEntry(debtors[i].key, debtors[i].value - amount);
      creditors[j] = MapEntry(creditors[j].key, creditors[j].value - amount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    final settlements = _calculateSettlements(balances);
    final currentUserBalance =
        balances['John Doe'] ?? 0.0; // Replace with actual current user

    // Sort expenses by date (most recent first)
    final sortedExpenses = List<Expense>.from(mockExpenses)
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
                              'Total spent: ₹${mockExpenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
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
                      ...settlements.map(
                        (settlement) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Color(0xff718096),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: robotoText(
                                  '${settlement.from} pays ${settlement.to}',
                                  fontSize: 14,
                                  color: const Color(0xff4A5568),
                                ),
                              ),
                              robotoText(
                                '₹${settlement.amount.toStringAsFixed(2)}',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkTeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
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
                    final isCurrentUserPayer = expense.paidBy == 'John Doe';
                    final currentUserShare = expense.perPersonShare;

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
                                // Category Icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: expense.getCategoryColor().withAlpha(
                                      20,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      expense.getCategoryIcon(),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                      Row(
                                        children: [
                                          robotoText(
                                            expense.getCategoryName(),
                                            fontSize: 12,
                                            color: expense.getCategoryColor(),
                                          ),
                                          const SizedBox(width: 8),
                                          robotoText(
                                            '•',
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          robotoText(
                                            DateFormat(
                                              'MMM d, h:mm a',
                                            ).format(expense.date),
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ],
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
                            if (expense.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              robotoText(
                                expense.description,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: borderColor),
                            const SizedBox(height: 12),
                            // Payer and Split Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.group,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    robotoText(
                                      'Split ${expense.splitBetween.length} ways',
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Current User's Share
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUserPayer
                                    ? darkTeal.withAlpha(10)
                                    : const Color(0xffFF9800).withAlpha(10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  robotoText(
                                    isCurrentUserPayer
                                        ? 'You get back'
                                        : 'You owe',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isCurrentUserPayer
                                        ? darkTeal
                                        : const Color(0xffFF9800),
                                  ),
                                  robotoText(
                                    '₹${currentUserShare.toStringAsFixed(2)}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUserPayer
                                        ? darkTeal
                                        : const Color(0xffFF9800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: sortedExpenses.length),
                ),
              ),
      ],
    );
  }
}
