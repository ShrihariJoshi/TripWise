class UserExpense {
  final String tripName;
  final double netBalance;
  final String status; // "owes" or "owed"

  UserExpense({
    required this.tripName,
    required this.netBalance,
    required this.status,
  });

  factory UserExpense.fromJson(Map<String, dynamic> json) {
    return UserExpense(
      tripName: json['trip_name'] ?? '',
      netBalance: (json['net_balance'] ?? 0).toDouble(),
      status: json['status'] ?? 'owes',
    );
  }

  Map<String, dynamic> toJson() {
    return {'trip_name': tripName, 'net_balance': netBalance, 'status': status};
  }

  bool get isOwed => status == 'owed';
  bool get owes => status == 'owes';
}

class UserExpenseResponse {
  final String username;
  final List<UserExpense> tripBalances;

  UserExpenseResponse({required this.username, required this.tripBalances});

  factory UserExpenseResponse.fromJson(Map<String, dynamic> json) {
    return UserExpenseResponse(
      username: json['username'] ?? '',
      tripBalances:
          (json['trip_balances'] as List<dynamic>?)
              ?.map((e) => UserExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
