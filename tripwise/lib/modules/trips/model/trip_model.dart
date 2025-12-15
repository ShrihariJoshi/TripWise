import 'dart:ui';

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

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  entertainment,
  shopping,
  other,
}

class Expense {
  final String id;
  final String name;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    required this.category,
    required this.date,
    this.description = '',
  });

  double get perPersonShare =>
      splitBetween.isEmpty ? 0 : amount / splitBetween.length;

  String getCategoryIcon() {
    switch (category) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.accommodation:
        return '🏨';
      case ExpenseCategory.entertainment:
        return '🎉';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.other:
        return '💰';
    }
  }

  String getCategoryName() {
    switch (category) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  Color getCategoryColor() {
    switch (category) {
      case ExpenseCategory.food:
        return const Color(0xffFF6B6B);
      case ExpenseCategory.transport:
        return const Color(0xff4ECDC4);
      case ExpenseCategory.accommodation:
        return const Color(0xffFFE66D);
      case ExpenseCategory.entertainment:
        return const Color(0xffA8E6CF);
      case ExpenseCategory.shopping:
        return const Color(0xffFFAEC9);
      case ExpenseCategory.other:
        return const Color(0xff95A5A6);
    }
  }
}

class Settlement {
  final String from;
  final String to;
  final double amount;

  Settlement({required this.from, required this.to, required this.amount});
}
