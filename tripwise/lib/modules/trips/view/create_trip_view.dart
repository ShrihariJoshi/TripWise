import 'package:flutter/material.dart';

class CreateTripView extends StatelessWidget {
  const CreateTripView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Trip")),
      body: const Center(
        child: Text(
          "Create Trip UI goes here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
