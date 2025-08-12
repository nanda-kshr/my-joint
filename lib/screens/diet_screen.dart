import 'package:flutter/material.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            Text(
              'Foods for Joint Health',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.waves),
              title: Text('Fatty Fish'),
              subtitle: Text('Salmon, Mackerel, Sardines'),
            ),
            ListTile(
              leading: Icon(Icons.spa),
              title: Text('Nuts & Seeds'),
              subtitle: Text('Walnuts, Almonds, Flaxseeds, Chia Seeds'),
            ),
            ListTile(
              leading: Icon(Icons.local_florist),
              title: Text('Berries'),
              subtitle: Text('Blueberries, Strawberries, Raspberries'),
            ),
            ListTile(
              leading: Icon(Icons.eco),
              title: Text('Leafy Greens'),
              subtitle: Text('Spinach, Kale, Collard Greens'),
            ),
            ListTile(
              leading: Icon(Icons.local_drink),
              title: Text('Olive Oil'),
              subtitle: Text('Extra Virgin Olive Oil'),
            ),
            ListTile(
              leading: Icon(Icons.grain),
              title: Text('Whole Grains'),
              subtitle: Text('Oats, Brown Rice, Quinoa'),
            ),
             SizedBox(height: 24),
             Text(
              'Note: Consult your doctor or dietitian for personalized advice.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
