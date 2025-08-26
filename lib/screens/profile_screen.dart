import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final isEn = _selectedLanguage == 'en';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Profile' : 'சுயவிவரம்'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isEn ? 'Personal Information' : 'தனிப்பட்ட தகவல்கள்',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isEn ? 'Age' : 'வயது',
              '45 years',
              Icons.calendar_today,
            ),
            _buildInfoCard(
              isEn ? 'Gender' : 'பாலினம்',
              isEn ? 'Male' : 'ஆண்',
              Icons.person,
            ),
            _buildInfoCard(
              isEn ? 'Phone' : 'தொலைபேசி',
              '+1 234 567 8900',
              Icons.phone,
            ),
            _buildInfoCard(
              isEn ? 'Address' : 'முகவரி',
              '123 Health Street, Medical City',
              Icons.location_on,
            ),
            const SizedBox(height: 32),
            Text(
              isEn ? 'Medical Information' : 'மருத்துவத் தகவல்கள்',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              isEn ? 'Blood Type' : 'இரத்த வகை',
              'O+',
              Icons.bloodtype,
            ),
            _buildInfoCard(
              isEn ? 'Allergies' : 'ஆலர்ஜீஸ்',
              isEn ? 'None' : 'இல்லை',
              Icons.warning,
            ),
            _buildInfoCard(
              isEn ? 'Conditions' : 'நிலைமைகள்',
              isEn ? 'Joint Pain, Arthritis' : 'மூட்டு வலிப்பு, ஒட்டுக்குழாய் அழற்சி',
              Icons.medical_services,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement edit profile
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEn ? 'Edit Profile' : 'சுயவிவரத்தை திருத்து'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}