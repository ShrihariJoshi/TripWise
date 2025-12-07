import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/trips_controller.dart';

class CreateTripSheet extends StatefulWidget {
  const CreateTripSheet({super.key});

  @override
  State<CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends State<CreateTripSheet> {
  final destinationCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripsController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Create New Trip",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: destinationCtrl,
            decoration: const InputDecoration(
              labelText: "Destination",
              prefixIcon: Icon(Icons.place, color: Colors.teal),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: budgetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Budget",
              prefixIcon: Icon(Icons.payments, color: Colors.teal),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          /// ✅ ONLY THE BUTTON IS REACTIVE
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isCreating.value
                    ? null
                    : () {
                        if (destinationCtrl.text.isEmpty ||
                            budgetCtrl.text.isEmpty ||
                            startDate == null ||
                            endDate == null) {
                          Get.snackbar(
                            "Incomplete",
                            "Please fill all fields",
                            backgroundColor: Colors.red.shade100,
                          );
                          return;
                        }

                        controller.createTrip(
                          destination: destinationCtrl.text,
                          startDate: startDate!,
                          endDate: endDate!,
                          budget:
                              double.tryParse(budgetCtrl.text) ?? 0,
                        );

                        Get.back(); // ✅ closes sheet immediately
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isCreating.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text("Create Trip"),
              ),
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
      icon: const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
      label: Text(
        date == null ? label : "${date!.day}/${date!.month}/${date!.year}",
      ),
    );
  }
}
