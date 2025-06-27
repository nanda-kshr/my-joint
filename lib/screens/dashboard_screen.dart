import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'diet_screen.dart';
import 'assessment_screen.dart';
import 'consult_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  'Exercise',
                  Icons.fitness_center,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExerciseScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Diet Plans',
                  Icons.restaurant_menu,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Assessment',
                  Icons.assessment,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AssessmentScreen()),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Consult',
                  Icons.video_call,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConsultScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityCard(
              'Last Exercise',
              '30 minutes ago',
              Icons.fitness_center,
            ),
            _buildActivityCard(
              'Last Assessment',
              '2 hours ago',
              Icons.assessment,
            ),
            _buildActivityCard(
              'Last Meal',
              '1 hour ago',
              Icons.restaurant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
} 