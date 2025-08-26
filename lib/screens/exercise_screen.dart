import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLanguage == 'en' ? 'Exercise Recommendations' : 'உடற்பயிற்சி பரிந்துரைகள்'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              _selectedLanguage == 'en' ? 'Recommended Exercises for Joint Health' : 'மூட்டு ஆரோக்கியத்திற்கு பரிந்துரைக்கப்பட்ட உடற்பயிற்சிகள்',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: Text(_selectedLanguage == 'en' ? 'Walking' : 'நடப்பது'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Gentle, low-impact daily walks' : 'மென்மையான, குறைந்த தாக்கம் கொண்ட தினசரி நடை'),
            ),
            ListTile(
              leading: const Icon(Icons.pool),
              title: Text(_selectedLanguage == 'en' ? 'Swimming' : 'நீச்சல்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Water aerobics or swimming laps' : 'தண்ணீர் உடற்பயிற்சி அல்லது நீச்சல் சுற்றுகள்'),
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: Text(_selectedLanguage == 'en' ? 'Yoga' : 'யோகா'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Gentle stretching and flexibility' : 'மென்மையான நீட்டிப்பு மற்றும் நெகிழ்வு'),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(_selectedLanguage == 'en' ? 'Strength Training' : 'வலிமை பயிற்சி'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Light weights or resistance bands' : 'இலகு எடைகள் அல்லது எதிர்ப்பு பட்டைகள்'),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bike),
              title: Text(_selectedLanguage == 'en' ? 'Cycling' : 'மிதிவண்டி ஓட்டுதல்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Stationary or outdoor cycling' : 'நிலையான அல்லது வெளிப்புற மிதிவண்டி ஓட்டுதல்'),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedLanguage == 'en'
                  ? 'Note: Always consult your doctor or physiotherapist before starting a new exercise routine.'
                  : 'குறிப்பு: புதிய உடற்பயிற்சி முறையை தொடங்கும் முன் உங்கள் மருத்துவர் அல்லது உடல்நல பயிற்சியாளரை அணுகவும்.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
