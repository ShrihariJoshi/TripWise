import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/modules/trips/model/trip_model.dart';
import 'package:tripwise/modules/trips/controller/expenses_controller.dart';

class AddExpenseSheet extends StatefulWidget {
  final Trip trip;
  final Function(Expense) onExpenseAdded;

  const AddExpenseSheet({
    super.key,
    required this.trip,
    required this.onExpenseAdded,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _expensesController = Get.put(ExpensesController());

  String _paidBy = '';
  DateTime _date = DateTime.now();
  List<String> _selectedMembers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Set default payer to current user
    _paidBy = widget.trip.memberNames.isNotEmpty
        ? widget.trip.memberNames[0]
        : 'You';
    // Select all members by default
    _selectedMembers = List.from(widget.trip.memberNames);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.trip.startDate,
      lastDate: widget.trip.endDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkTeal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkTeal,
                textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _showMemberSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        robotoText(
                          'Split Between',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2D3748),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              if (_selectedMembers.length ==
                                  widget.trip.memberNames.length) {
                                _selectedMembers.clear();
                              } else {
                                _selectedMembers = List.from(
                                  widget.trip.memberNames,
                                );
                              }
                            });
                            setState(() {});
                          },
                          child: robotoText(
                            _selectedMembers.length ==
                                    widget.trip.memberNames.length
                                ? 'Deselect All'
                                : 'Select All',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Member list
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.trip.memberNames.length,
                      itemBuilder: (context, index) {
                        final member = widget.trip.memberNames[index];
                        final isSelected = _selectedMembers.contains(member);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                _selectedMembers.add(member);
                              } else {
                                _selectedMembers.remove(member);
                              }
                            });
                            setState(() {});
                          },
                          title: robotoText(
                            member,
                            fontSize: 16,
                            color: const Color(0xff2D3748),
                          ),
                          activeColor: darkTeal,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  // Done button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_selectedMembers.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please select at least one member',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          Navigator.pop(context);
                        },
                        child: robotoText(
                          'Done (${_selectedMembers.length} selected)',
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
          },
        );
      },
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one member to split with',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final expense = await _expensesController.addExpense(
        tripName: widget.trip.tripName,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        paidBy: _paidBy,
        date: _date,
        splitBetween: _selectedMembers,
      );

      if (expense != null) {
        widget.onExpenseAdded(expense);
        Get.back();
        Get.snackbar(
          'Success',
          'Expense added successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: lightTeal,
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                robotoText(
                  'Add Expense',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2D3748),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Expense Name
                  robotoText(
                    'Expense Name',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff4A5568),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff2D3748),
                      letterSpacing: -0.28,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Dinner, Taxi, Hotel',
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.grey,
                        letterSpacing: -0.28,
                      ),
                      prefixIcon: const Icon(
                        Icons.receipt_long,
                        color: darkTeal,
                      ),
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
                        borderSide: const BorderSide(
                          color: lightTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter expense name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  robotoText(
                    'Amount (₹)',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff4A5568),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xff2D3748),
                      letterSpacing: -0.28,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.grey,
                        letterSpacing: -0.28,
                      ),
                      prefixIcon: const Icon(
                        Icons.currency_rupee,
                        color: darkTeal,
                      ),
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
                        borderSide: const BorderSide(
                          color: lightTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Paid By
                  robotoText(
                    'Paid By',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff4A5568),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: bgColor,
                    value: _paidBy,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: darkTeal),
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
                        borderSide: const BorderSide(
                          color: lightTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    items: widget.trip.memberNames.map((member) {
                      return DropdownMenuItem(
                        value: member,
                        child: robotoText(
                          member,
                          fontSize: 16,
                          color: const Color(0xff2D3748),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _paidBy = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Split Between
                  robotoText(
                    'Split Between',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff4A5568),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showMemberSelectionSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group, color: darkTeal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: robotoText(
                              _selectedMembers.isEmpty
                                  ? 'Select members'
                                  : '${_selectedMembers.length} member(s) selected',
                              fontSize: 16,
                              color: _selectedMembers.isEmpty
                                  ? Colors.grey
                                  : const Color(0xff2D3748),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  robotoText(
                    'Date',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff4A5568),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: darkTeal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: robotoText(
                              DateFormat('dd/MM/yyyy').format(_date),
                              fontSize: 16,
                              color: const Color(0xff2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: robotoText(
                      'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff4A5568),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveExpense,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : robotoText(
                            'Save Expense',
                            fontSize: 16,
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
  }
}
