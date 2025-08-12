import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            Text(
              'Recommended Exercises for Joint Health',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.directions_walk),
              title: Text('Walking'),
              subtitle: Text('Gentle, low-impact daily walks'),
            ),
            ListTile(
              leading: Icon(Icons.pool),
              title: Text('Swimming'),
              subtitle: Text('Water aerobics or swimming laps'),
            ),
            ListTile(
              leading: Icon(Icons.self_improvement),
              title: Text('Yoga'),
              subtitle: Text('Gentle stretching and flexibility'),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Strength Training'),
              subtitle: Text('Light weights or resistance bands'),
            ),
            ListTile(
              leading: Icon(Icons.directions_bike),
              title: Text('Cycling'),
              subtitle: Text('Stationary or outdoor cycling'),
            ),
            SizedBox(height: 24),
            Text(
              'Note: Always consult your doctor or physiotherapist before starting a new exercise routine.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
