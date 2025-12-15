import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../model/trip_model.dart';
import '../../model/itinerary_model.dart';

class ItineraryView extends StatefulWidget {
  final Trip trip;

  const ItineraryView({super.key, required this.trip});

  @override
  State<ItineraryView> createState() => _ItineraryViewState();
}

class _ItineraryViewState extends State<ItineraryView> {
  late List<DayItinerary> itinerary;

  @override
  void initState() {
    super.initState();
    itinerary = _getSampleItinerary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Content
          Expanded(
            child: itinerary.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: const Color(0xffCCCCCC),
                        ),
                        const SizedBox(height: 16),
                        robotoText(
                          "No itinerary planned yet",
                          fontSize: 16,
                          color: const Color(0xff888888),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddEditEventSheet(),
                          child: robotoText(
                            "Add Events",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTeal,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Itinerary Header
                        robotoText(
                          "Schedule",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff888888),
                        ),
                        const SizedBox(height: 16),

                        // Itinerary Days
                        ...List.generate(
                          itinerary.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _DayItineraryCard(
                              dayItinerary: itinerary[index],
                              dayNumber: index + 1,
                              onEdit: (event) => _editEvent(event),
                              onDelete: (eventId) => _deleteEvent(eventId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditEventSheet(),
        backgroundColor: darkTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _editEvent(ItineraryEvent event) {
    _showAddEditEventSheet(existingEvent: event);
  }

  void _showAddEditEventSheet({ItineraryEvent? existingEvent}) {
    final isEditing = existingEvent != null;
    final titleController = TextEditingController(
      text: existingEvent?.title ?? '',
    );
    final locationController = TextEditingController(
      text: existingEvent?.location ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingEvent?.description ?? '',
    );

    DateTime selectedDate = existingEvent?.startTime ?? widget.trip.startDate;
    TimeOfDay startTime = existingEvent != null
        ? TimeOfDay(
            hour: existingEvent.startTime.hour,
            minute: existingEvent.startTime.minute,
          )
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = existingEvent != null
        ? TimeOfDay(
            hour: existingEvent.endTime.hour,
            minute: existingEvent.endTime.minute,
          )
        : const TimeOfDay(hour: 10, minute: 0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      robotoText(
                        isEditing ? "Edit Event" : "Add Event",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff333333),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, color: borderColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        robotoText(
                          "Event Title",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: "E.g., Beach Lunch",
                            hintStyle: GoogleFonts.roboto(
                              letterSpacing: -0.3,
                              fontSize: 14,
                              color: Color(0xffAAAAAA),
                            ),
                            filled: true,
                            fillColor: const Color(0xffF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            letterSpacing: -0.3,
                            color: Color(0xff333333),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Location Field
                        robotoText(
                          "Location",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: locationController,
                          decoration: InputDecoration(
                            hintText: "E.g., Baga Beach",
                            hintStyle: GoogleFonts.roboto(
                              letterSpacing: -0.3,
                              fontSize: 14,
                              color: Color(0xffAAAAAA),
                            ),
                            filled: true,
                            fillColor: const Color(0xffF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            letterSpacing: -0.3,
                            color: Color(0xff333333),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date Picker
                        robotoText(
                          "Date",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: widget.trip.startDate,
                              lastDate: widget.trip.endDate,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: darkTeal,
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xff333333),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setSheetState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: darkTeal,
                                ),
                                const SizedBox(width: 12),
                                robotoText(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                  fontSize: 14,
                                  color: const Color(0xff333333),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Time Pickers
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  robotoText(
                                    "Start Time",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff666666),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: startTime,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: darkTeal,
                                                    onPrimary: Colors.white,
                                                    onSurface: Color(
                                                      0xff333333,
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setSheetState(() {
                                          startTime = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF5F5F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 18,
                                            color: darkTeal,
                                          ),
                                          const SizedBox(width: 8),
                                          robotoText(
                                            startTime.format(context),
                                            fontSize: 14,
                                            color: const Color(0xff333333),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  robotoText(
                                    "End Time",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff666666),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: endTime,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: darkTeal,
                                                    onPrimary: Colors.white,
                                                    onSurface: Color(
                                                      0xff333333,
                                                    ),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setSheetState(() {
                                          endTime = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF5F5F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 18,
                                            color: darkTeal,
                                          ),
                                          const SizedBox(width: 8),
                                          robotoText(
                                            endTime.format(context),
                                            fontSize: 14,
                                            color: const Color(0xff333333),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        robotoText(
                          "Description (Optional)",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff666666),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Add notes about this event...",
                            hintStyle: GoogleFonts.roboto(
                              letterSpacing: -0.3,
                              fontSize: 14,
                              color: const Color(0xffAAAAAA),
                            ),
                            filled: true,
                            fillColor: const Color(0xffF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            letterSpacing: -0.3,
                            color: Color(0xff333333),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: robotoText(
                            'Cancel',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff666666),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty ||
                                locationController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please fill in title and location',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final startDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              startTime.hour,
                              startTime.minute,
                            );
                            final endDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              endTime.hour,
                              endTime.minute,
                            );

                            if (endDateTime.isBefore(startDateTime)) {
                              Get.snackbar(
                                'Error',
                                'End time must be after start time',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            setState(() {
                              if (isEditing) {
                                // Update existing event
                                for (var day in itinerary) {
                                  final eventIndex = day.events.indexWhere(
                                    (e) => e.id == existingEvent.id,
                                  );
                                  if (eventIndex != -1) {
                                    day.events[eventIndex] = existingEvent
                                        .copyWith(
                                          title: titleController.text.trim(),
                                          location: locationController.text
                                              .trim(),
                                          startTime: startDateTime,
                                          endTime: endDateTime,
                                          description:
                                              descriptionController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : descriptionController.text
                                                    .trim(),
                                        );
                                    break;
                                  }
                                }
                              } else {
                                // Add new event
                                final newEvent = ItineraryEvent(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: titleController.text.trim(),
                                  location: locationController.text.trim(),
                                  startTime: startDateTime,
                                  endTime: endDateTime,
                                  description:
                                      descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                                );

                                // Find or create day itinerary
                                final dayIndex = itinerary.indexWhere(
                                  (day) =>
                                      day.date.year == selectedDate.year &&
                                      day.date.month == selectedDate.month &&
                                      day.date.day == selectedDate.day,
                                );

                                if (dayIndex != -1) {
                                  itinerary[dayIndex].events.add(newEvent);
                                  // Sort events by start time
                                  itinerary[dayIndex].events.sort(
                                    (a, b) =>
                                        a.startTime.compareTo(b.startTime),
                                  );
                                } else {
                                  itinerary.add(
                                    DayItinerary(
                                      date: selectedDate,
                                      events: [newEvent],
                                    ),
                                  );
                                  // Sort days by date
                                  itinerary.sort(
                                    (a, b) => a.date.compareTo(b.date),
                                  );
                                }
                              }
                            });

                            Get.back();
                            Get.snackbar(
                              'Success',
                              isEditing
                                  ? 'Event updated successfully'
                                  : 'Event added successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: robotoText(
                            isEditing ? 'Update Event' : 'Add Event',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  void _deleteEvent(String eventId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              robotoText(
                'Delete Event',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff333333),
              ),
              const SizedBox(height: 12),
              robotoText(
                'Are you sure you want to delete this event?',
                fontSize: 14,
                color: const Color(0xff666666),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: robotoText(
                        'Cancel',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff666666),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          for (var day in itinerary) {
                            day.events.removeWhere((e) => e.id == eventId);
                          }
                        });
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Event deleted successfully',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: robotoText(
                        'Delete',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DayItinerary> _getSampleItinerary() {
    // Sample data for demonstration
    final startDate = widget.trip.startDate;

    return [
      DayItinerary(
        date: startDate,
        events: [
          ItineraryEvent(
            id: '1',
            title: 'Airport Pickup',
            location: 'Goa International Airport',
            startTime: startDate.copyWith(hour: 10, minute: 0),
            endTime: startDate.copyWith(hour: 11, minute: 0),
            description:
                'Meet at arrival gate. Driver will hold a sign with your name.',
          ),
          ItineraryEvent(
            id: '2',
            title: 'Check-in at Hotel',
            location: 'Taj Fort Aguada Resort & Spa',
            startTime: startDate.copyWith(hour: 12, minute: 0),
            endTime: startDate.copyWith(hour: 13, minute: 0),
          ),
          ItineraryEvent(
            id: '3',
            title: 'Lunch at Beach Shack',
            location: 'Baga Beach',
            startTime: startDate.copyWith(hour: 14, minute: 0),
            endTime: startDate.copyWith(hour: 16, minute: 0),
            description: 'Try the seafood platter and fresh coconut water.',
          ),
          ItineraryEvent(
            id: '4',
            title: 'Sunset at Chapora Fort',
            location: 'Chapora Fort, Vagator',
            startTime: startDate.copyWith(hour: 17, minute: 30),
            endTime: startDate.copyWith(hour: 19, minute: 0),
            description:
                'Famous from Dil Chahta Hai. Great views of the coastline.',
          ),
        ],
      ),
      DayItinerary(
        date: startDate.add(const Duration(days: 1)),
        events: [
          ItineraryEvent(
            id: '5',
            title: 'Breakfast',
            location: 'Hotel Restaurant',
            startTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 8, minute: 0),
            endTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 9, minute: 0),
          ),
          ItineraryEvent(
            id: '6',
            title: 'Water Sports',
            location: 'Calangute Beach',
            startTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 10, minute: 0),
            endTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 13, minute: 0),
            description: 'Parasailing, jet skiing, and banana boat rides.',
          ),
          ItineraryEvent(
            id: '7',
            title: 'Old Goa Heritage Tour',
            location: 'Basilica of Bom Jesus',
            startTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 15, minute: 0),
            endTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 18, minute: 0),
            description: 'Visit UNESCO World Heritage churches and cathedrals.',
          ),
          ItineraryEvent(
            id: '8',
            title: 'Dinner Cruise',
            location: 'Mandovi River',
            startTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 19, minute: 30),
            endTime: startDate
                .add(const Duration(days: 1))
                .copyWith(hour: 22, minute: 0),
            description: 'Evening cruise with live music and buffet dinner.',
          ),
        ],
      ),
      DayItinerary(
        date: startDate.add(const Duration(days: 2)),
        events: [
          ItineraryEvent(
            id: '9',
            title: 'Dudhsagar Waterfall Trek',
            location: 'Dudhsagar Falls',
            startTime: startDate
                .add(const Duration(days: 2))
                .copyWith(hour: 7, minute: 0),
            endTime: startDate
                .add(const Duration(days: 2))
                .copyWith(hour: 14, minute: 0),
            description:
                'Full day trek to one of India\'s tallest waterfalls. Pack lunch included.',
          ),
          ItineraryEvent(
            id: '10',
            title: 'Spice Plantation Visit',
            location: 'Sahakari Spice Farm',
            startTime: startDate
                .add(const Duration(days: 2))
                .copyWith(hour: 15, minute: 30),
            endTime: startDate
                .add(const Duration(days: 2))
                .copyWith(hour: 17, minute: 30),
            description:
                'Guided tour of organic spice plantation with traditional Goan lunch.',
          ),
        ],
      ),
    ];
  }
}

class _DayItineraryCard extends StatelessWidget {
  final DayItinerary dayItinerary;
  final int dayNumber;
  final Function(ItineraryEvent) onEdit;
  final Function(String) onDelete;

  const _DayItineraryCard({
    required this.dayItinerary,
    required this.dayNumber,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: darkTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: robotoText(
                "Day $dayNumber",
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            robotoText(
              dayItinerary.dateString,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xff333333),
            ),
            const Spacer(),
            robotoText(
              "${dayItinerary.eventCount} events",
              fontSize: 13,
              color: const Color(0xff888888),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Events List
        ...dayItinerary.events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == dayItinerary.events.length - 1;

          return _EventTile(
            event: event,
            isLast: isLast,
            onEdit: () => onEdit(event),
            onDelete: () => onDelete(event.id),
          );
        }).toList(),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final ItineraryEvent event;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventTile({
    required this.event,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: lightTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: darkTeal, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: borderColor)),
            ],
          ),
          const SizedBox(width: 16),

          // Event Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge and Actions Row
                    Row(
                      children: [
                        // Time
                        Icon(Icons.access_time, size: 16, color: darkTeal),
                        const SizedBox(width: 6),
                        robotoText(
                          event.timeRange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkTeal,
                        ),
                        const Spacer(),
                        // Action Buttons
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: bgColor,

                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: darkTeal,
                                  ),
                                  const SizedBox(width: 12),
                                  robotoText(
                                    'Edit Event',
                                    fontSize: 14,
                                    color: const Color(0xff333333),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  robotoText(
                                    'Delete Event',
                                    fontSize: 14,
                                    color: const Color(0xff333333),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    robotoText(
                      event.title,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff333333),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xff888888),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: robotoText(
                            event.location,
                            fontSize: 14,
                            color: const Color(0xff666666),
                          ),
                        ),
                      ],
                    ),

                    // Description (if available)
                    if (event.description != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.description!,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            color: Color(0xff666666),
                            height: 1.4,
                            letterSpacing: -0.28,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
