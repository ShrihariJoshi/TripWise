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

  factory ItineraryEvent.fromJson(
    Map<String, dynamic> json,
    DateTime tripStartDate,
  ) {
    // Parse day_number to calculate the actual date
    final dayNumber = json['day_number'] as int;
    final eventDate = tripStartDate.add(Duration(days: dayNumber - 1));

    // Parse time strings (format: "HH:MM:SS")
    final startTimeParts = (json['start_time'] as String).split(':');
    final endTimeParts = (json['end_time'] as String).split(':');

    final startTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
      startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
    );

    final endTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
      endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
    );

    return ItineraryEvent(
      id: '${json['day_number']}_${json['start_time']}_${json['title']}',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      startTime: startTime,
      endTime: endTime,
      description: json['description']?.toString().isEmpty ?? true
          ? null
          : json['description']?.toString(),
    );
  }

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
