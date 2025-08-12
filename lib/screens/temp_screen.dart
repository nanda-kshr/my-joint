import 'package:flutter/material.dart';

class TempScreen extends StatelessWidget {
  final String title;
  const TempScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'This is a temporary screen for $title',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
