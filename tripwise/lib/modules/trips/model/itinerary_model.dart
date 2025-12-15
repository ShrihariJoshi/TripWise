enum EventStatus { pending, completed, missed }

class ItineraryEvent {
  final String id;
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;

  ItineraryEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.description,
  });

  String get timeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  Duration get duration => endTime.difference(startTime);

  ItineraryEvent copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
  }) {
    return ItineraryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
    );
  }
}

class DayItinerary {
  final DateTime date;
  final List<ItineraryEvent> events;

  DayItinerary({required this.date, required this.events});

  String get dateString {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  int get eventCount => events.length;
}
