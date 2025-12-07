import 'package:flutter/material.dart';
import 'package:tripwise/data/widgets/gradient_header.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientHeader(title: "My Expenses"),
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
