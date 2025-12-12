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

  TripStatus get status {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return TripStatus.completed;
    if (startDate.isAfter(now)) return TripStatus.upcoming;
    return TripStatus.active;
  }
}
