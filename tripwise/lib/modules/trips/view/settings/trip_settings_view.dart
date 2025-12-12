import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import '../../model/trip_model.dart';

class TripSettingsView extends StatefulWidget {
  final Trip trip;

  const TripSettingsView({super.key, required this.trip});

  @override
  State<TripSettingsView> createState() => _TripSettingsViewState();
}

class _TripSettingsViewState extends State<TripSettingsView> {
  late TextEditingController _tripNameController;
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(text: widget.trip.tripName);
    _destinationController = TextEditingController(
      text: widget.trip.destination,
    );
    _budgetController = TextEditingController(
      text: widget.trip.budget.toStringAsFixed(0),
    );
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(top: 60, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [darkTeal, lightTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: robotoText(
                        "Trip Settings",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                robotoText(
                  "Manage your trip details",
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Details Section
                  robotoText(
                    "Trip Details",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff888888),
                  ),
                  const SizedBox(height: 12),

                  // Trip Name Field
                  _buildLabel("Trip Name"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _tripNameController,
                    hint: "Enter trip name",
                    icon: Icons.travel_explore,
                  ),
                  const SizedBox(height: 20),

                  // Destination Field
                  _buildLabel("Destination"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _destinationController,
                    hint: "Enter destination",
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 20),

                  // Budget Field
                  _buildLabel("Budget (₹)"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _budgetController,
                    hint: "Enter budget amount",
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Date Range Section
                  robotoText(
                    "Date Range",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff888888),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Start Date"),
                            const SizedBox(height: 8),
                            _buildDatePicker(
                              date: _startDate,
                              onTap: () => _selectStartDate(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("End Date"),
                            const SizedBox(height: 8),
                            _buildDatePicker(
                              date: _endDate,
                              onTap: () => _selectEndDate(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Danger Zone Section
                  robotoText(
                    "Danger Zone",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _showDeleteConfirmation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                robotoText(
                                  "Delete Trip",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 2),
                                robotoText(
                                  "Permanently delete this trip",
                                  fontSize: 13,
                                  color: const Color(0xff888888),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(top: 8, bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: robotoText(
                  "Save Changes",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return robotoText(
      text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xff666666),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            fontSize: 14,
            letterSpacing: -0.3,
            color: const Color(0xffAAAAAA),
          ),
          prefixIcon: Icon(icon, color: darkTeal, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: GoogleFonts.roboto(
          fontSize: 14,
          letterSpacing: -0.3,
          color: const Color(0xff333333),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: darkTeal),
            const SizedBox(width: 12),
            robotoText(
              "${date.day}/${date.month}/${date.year}",
              fontSize: 14,
              color: const Color(0xff333333),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: _endDate,
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
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveChanges() {
    // Validation
    if (_tripNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a trip name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_destinationController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a destination',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final budget = double.tryParse(_budgetController.text.trim());
    if (budget == null || budget <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid budget amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      Get.snackbar(
        'Error',
        'End date must be after start date',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Update trip in backend/database
    // For now, just show success message
    Get.back();
    Get.snackbar(
      'Success',
      'Trip details updated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              robotoText(
                'Delete Trip?',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff333333),
              ),
              const SizedBox(height: 12),
              robotoText(
                'This action cannot be undone. All trip data, expenses, and itinerary will be permanently deleted.',
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
                        // TODO: Delete trip from backend/database
                        Get.back(); // Close dialog
                        Get.back(); // Close settings
                        Get.back(); // Close trip detail
                        Get.snackbar(
                          'Success',
                          'Trip deleted successfully',
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
}
