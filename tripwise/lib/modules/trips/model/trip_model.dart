enum TripStatus { active, upcoming, completed }

class Trip {
  final String id;
  final String tripName;
  final String createdBy;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spent;
  final int members;
  final List<String> memberNames;

  Trip({
    required this.id,
    required this.tripName,
    required this.createdBy,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.spent = 0,
    this.members = 1,
    this.memberNames = const [],
  });

  String get dateRange =>
      "${startDate.day}/${startDate.month}/${startDate.year} - "
      "${endDate.day}/${endDate.month}/${endDate.year}";

  double get progress => budget == 0 ? 0 : spent / budget;

  int get totalDays => endDate.difference(startDate).inDays + 1;

  int get currentDay {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return totalDays;
    return now.difference(startDate).inDays + 1;
  }

  TripStatus get status {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return TripStatus.completed;
    if (startDate.isAfter(now)) return TripStatus.upcoming;
    return TripStatus.active;
  }
}

class Expense {
  final String id;
  final String name;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.splitBetween = const [],
    this.description = '',
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['expense_id']?.toString() ?? '',
      name: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidBy: json['paid_by'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      splitBetween: [],
    );
  }

  double get perPersonShare =>
      splitBetween.isEmpty ? 0 : amount / splitBetween.length;
}

class Settlement {
  final String id;
  final String from;
  final String to;
  final double amount;
  final DateTime? date;

  Settlement({
    required this.from,
    required this.to,
    required this.amount,
    this.id = '',
    this.date,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['settlement_id']?.toString() ?? '',
      from: json['from_user']?.toString() ?? '',
      to: json['to_user']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}
