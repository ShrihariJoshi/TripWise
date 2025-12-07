import 'package:flutter/material.dart';
import 'package:tripwise/data/widgets/gradient_header.dart';
import 'package:tripwise/data/widgets/app_drawer.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      body: Column(
        children: [
          Builder(
            builder: (context) => GradientHeader(
              title: "TripWise",
              trailing: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                "Dashboard\n(Empty for now)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
