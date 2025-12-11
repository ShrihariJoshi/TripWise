import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../controller/trips_controller.dart';

class CreateTripSheet extends StatefulWidget {
  const CreateTripSheet({super.key});

  @override
  State<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends State<CreateTripSheet> {
  final tripNameCtrl = TextEditingController();
  final destinationCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripsController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xffDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                robotoText(
                  "Create New Trip",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkTeal,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff666666)),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form Fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Name Field
                robotoText(
                  "Trip Name",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tripNameCtrl,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter trip name",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(Icons.trip_origin, color: darkTeal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Destination Field
                robotoText(
                  "Destination",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: destinationCtrl,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter destination",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(Icons.place, color: darkTeal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Budget Field
                robotoText(
                  "Budget",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff333333),
                    letterSpacing: -0.28,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter budget amount",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff999999),
                      letterSpacing: -0.28,
                    ),
                    prefixIcon: const Icon(Icons.payments, color: darkTeal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lightTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date Fields
                robotoText(
                  "Trip Duration",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: "Start Date",
                        date: startDate,
                        onPick: (d) => setState(() => startDate = d),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateButton(
                        label: "End Date",
                        date: endDate,
                        onPick: (d) => setState(() => endDate = d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Create Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: controller.isCreating.value
                          ? null
                          : () {
                              if (tripNameCtrl.text.isEmpty ||
                                  destinationCtrl.text.isEmpty ||
                                  budgetCtrl.text.isEmpty ||
                                  startDate == null ||
                                  endDate == null) {
                                Get.snackbar(
                                  "Incomplete",
                                  "Please fill all fields",
                                  backgroundColor: Colors.red.shade100,
                                  colorText: Colors.red.shade900,
                                  snackPosition: SnackPosition.TOP,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                                return;
                              }

                              if (endDate!.isBefore(startDate!)) {
                                Get.snackbar(
                                  "Invalid Date",
                                  "End date must be on or after start date",
                                  backgroundColor: Colors.red.shade100,
                                  colorText: Colors.red.shade900,
                                  snackPosition: SnackPosition.TOP,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                                return;
                              }

                              controller.createTrip(
                                tripName: tripNameCtrl.text,
                                destination: destinationCtrl.text,
                                startDate: startDate!,
                                endDate: endDate!,
                                budget: double.tryParse(budgetCtrl.text) ?? 0,
                              );

                              Navigator.pop(context);
                            },
                      child: controller.isCreating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : robotoText(
                              "Create Trip",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          initialDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      icon: const Icon(Icons.calendar_today, size: 18, color: darkTeal),
      label: Text(
        date == null ? label : "${date!.day}/${date!.month}/${date!.year}",
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: date == null
              ? const Color(0xff999999)
              : const Color(0xff333333),
          letterSpacing: -0.28,
        ),
      ),
    );
  }
}
