import 'package:flutter/material.dart';
import 'exercise_details_screen.dart';
import '../models/exercise.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      Exercise(
        name: 'Knee Extension',
        description: 'Strengthens quadriceps and improves knee stability',
        duration: '10-15 minutes',
        difficulty: 'Beginner',
        steps: [
          'Sit on a chair with your back straight',
          'Extend one leg straight out in front of you',
          'Hold for 5 seconds',
          'Slowly lower your leg back down',
          'Repeat 10-15 times for each leg',
        ],
        benefits: [
          'Improves knee stability',
          'Strengthens quadriceps',
          'Reduces knee pain',
        ],
      ),
      Exercise(
        name: 'Hamstring Curl',
        description: 'Strengthens hamstrings and improves knee flexibility',
        duration: '10 minutes',
        difficulty: 'Beginner',
        steps: [
          'Stand behind a chair, holding it for support',
          'Bend one knee, bringing your heel toward your buttocks',
          'Hold for 5 seconds',
          'Slowly lower your foot back down',
          'Repeat 10-15 times for each leg',
        ],
        benefits: [
          'Strengthens hamstrings',
          'Improves knee flexibility',
          'Enhances balance',
        ],
      ),
      Exercise(
        name: 'Wall Squat',
        description: 'Builds leg strength and improves joint stability',
        duration: '15 minutes',
        difficulty: 'Intermediate',
        steps: [
          'Stand with your back against a wall',
          'Feet shoulder-width apart',
          'Slide down the wall until your knees are at 90 degrees',
          'Hold for 10-15 seconds',
          'Slide back up',
          'Repeat 10 times',
        ],
        benefits: [
          'Builds leg strength',
          'Improves joint stability',
          'Enhances balance',
        ],
      ),
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(exercise.description),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.timer,
                        exercise.duration,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.fitness_center,
                        exercise.difficulty,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailsScreen(exercise: exercise),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
} 