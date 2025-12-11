import 'package:flutter/material.dart';
import 'package:tripwise/data/config/colors.dart';
import 'package:tripwise/data/config/text_styles.dart';
import 'package:tripwise/data/widgets/gradient_header.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ).copyWith(top: 50, bottom: 16),
          width: double.infinity,
          decoration: const BoxDecoration(color: lightTeal),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              robotoText(
                "My Expenses",
                fontSize: 26,
                fontWeight: .bold,
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: lightTeal),
                onPressed: () => {},
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "Expenses\n(Coming soon)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
