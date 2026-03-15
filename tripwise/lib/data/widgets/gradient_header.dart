import 'package:flutter/material.dart';
import 'package:tripwise/data/config/colors.dart';

class GradientHeader extends StatelessWidget {
  final String title;

  /// ✅ optional controls
  final double height;
  final Widget? trailing;
  final Widget? leading;

  const GradientHeader({
    super.key,
    required this.title,
    this.height = 180,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 48,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkTeal, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Optional back / leading widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],

          /// Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          /// Optional menu / trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
