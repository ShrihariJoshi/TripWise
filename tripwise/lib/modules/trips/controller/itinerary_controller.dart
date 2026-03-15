import 'package:get/get.dart';
import 'package:tripwise/data/services/api_service.dart';
import 'package:tripwise/modules/trips/model/itinerary_model.dart';

class ItineraryController extends GetxController {
  final api = Get.find<ApiService>();

  final isLoading = false.obs;
  final itinerary = <DayItinerary>[].obs;

  /// Fetch itinerary for a trip
  Future<void> fetchItinerary(String tripName, DateTime tripStartDate) async {
    try {
      isLoading.value = true;
      final response = await api.get(
        '/itineary-details',
        queryParameters: {'trip_name': tripName},
      );

      if (response['itinerary_items'] != null) {
        final items = response['itinerary_items'] as List<dynamic>;

        // Group events by day number
        Map<int, List<ItineraryEvent>> dayGroups = {};

        for (var item in items) {
          final dayNumber = item['day_number'] as int;
          final event = ItineraryEvent.fromJson(item, tripStartDate);

          if (!dayGroups.containsKey(dayNumber)) {
            dayGroups[dayNumber] = [];
          }
          dayGroups[dayNumber]!.add(event);
        }

        // Convert to DayItinerary list
        final dayItineraries = <DayItinerary>[];
        final sortedDays = dayGroups.keys.toList()..sort();

        for (var dayNumber in sortedDays) {
          final events = dayGroups[dayNumber]!;
          // Sort events by start time
          events.sort((a, b) => a.startTime.compareTo(b.startTime));

          // Calculate the date for this day
          final dayDate = tripStartDate.add(Duration(days: dayNumber - 1));

          dayItineraries.add(DayItinerary(date: dayDate, events: events));
        }

        itinerary.value = dayItineraries;
      }
    } catch (e) {
      print('Failed to fetch itinerary: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch itinerary: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new itinerary event
  Future<bool> addEvent({
    required String tripName,
    required DateTime tripStartDate,
    required int dayNumber,
    required String title,
    required String description,
    required String location,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final body = {
        'trip_name': tripName,
        'day_number': dayNumber,
        'title': title,
        'description': description,
        'location': location,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response = await api.post('/iternary-dashboard', body: body);

      if (response['message'] != null) {
        // Refresh itinerary after successful addition
        await fetchItinerary(tripName, tripStartDate);
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add event: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to add event: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
  }

  /// Update an existing event (local only for now)
  void updateEvent(ItineraryEvent updatedEvent) {
    for (var day in itinerary) {
      final eventIndex = day.events.indexWhere((e) => e.id == updatedEvent.id);
      if (eventIndex != -1) {
        day.events[eventIndex] = updatedEvent;
        day.events.sort((a, b) => a.startTime.compareTo(b.startTime));
        itinerary.refresh();
        break;
      }
    }
  }

  /// Delete an event (local only for now)
  void deleteEvent(String eventId) {
    for (var day in itinerary) {
      day.events.removeWhere((e) => e.id == eventId);
    }
    itinerary.refresh();
  }
}
