import 'package:flutter/material.dart';
import 'meal_details_screen.dart';
import '../models/meal.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Plans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMealTypeCard(
              context,
              'Breakfast',
              Icons.wb_sunny,
              Colors.orange,
              [
                Meal(
                  name: 'Oatmeal with Berries',
                  calories: 350,
                  protein: 12,
                  carbs: 45,
                  fat: 8,
                  fiber: 6,
                  vitamins: ['B1', 'B6', 'E'],
                ),
                Meal(
                  name: 'Greek Yogurt Parfait',
                  calories: 280,
                  protein: 15,
                  carbs: 35,
                  fat: 6,
                  fiber: 4,
                  vitamins: ['B12', 'D', 'Calcium'],
                ),
              ],
            ),
            _buildMealTypeCard(
              context,
              'Lunch',
              Icons.restaurant,
              Colors.green,
              [
                Meal(
                  name: 'Grilled Chicken Salad',
                  calories: 420,
                  protein: 35,
                  carbs: 25,
                  fat: 12,
                  fiber: 8,
                  vitamins: ['A', 'C', 'K'],
                ),
                Meal(
                  name: 'Quinoa Bowl',
                  calories: 380,
                  protein: 18,
                  carbs: 45,
                  fat: 10,
                  fiber: 7,
                  vitamins: ['B', 'E', 'Iron'],
                ),
              ],
            ),
            _buildMealTypeCard(
              context,
              'Dinner',
              Icons.nightlight_round,
              Colors.blue,
              [
                Meal(
                  name: 'Baked Salmon',
                  calories: 450,
                  protein: 40,
                  carbs: 20,
                  fat: 15,
                  fiber: 5,
                  vitamins: ['D', 'B12', 'Omega-3'],
                ),
                Meal(
                  name: 'Vegetable Stir Fry',
                  calories: 320,
                  protein: 15,
                  carbs: 40,
                  fat: 8,
                  fiber: 9,
                  vitamins: ['A', 'C', 'K'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Meal> meals,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ...meals.map((meal) => ListTile(
                title: Text(meal.name),
                subtitle: Text('${meal.calories} calories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailsScreen(meal: meal),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
} 