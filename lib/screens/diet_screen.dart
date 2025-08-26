import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
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
        title: Text(_selectedLanguage == 'en' ? 'Diet Recommendations' : 'உணவு பரிந்துரைகள்'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              _selectedLanguage == 'en' ? 'Foods for Joint Health' : 'மூட்டு ஆரோக்கியத்திற்கு உணவுகள்',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.waves),
              title: Text(_selectedLanguage == 'en' ? 'Fatty Fish' : 'கொழுப்பு மீன்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Salmon, Mackerel, Sardines' : 'சால்மன், மாக்கரல், சார்டின்ஸ்'),
            ),
            ListTile(
              leading: const Icon(Icons.spa),
              title: Text(_selectedLanguage == 'en' ? 'Nuts & Seeds' : 'முந்திரிகள் & விதைகள்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Walnuts, Almonds, Flaxseeds, Chia Seeds' : 'ஆக்ரோடா, பாதாம், ஆளி விதைகள், சியா விதைகள்'),
            ),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: Text(_selectedLanguage == 'en' ? 'Berries' : 'பெர்ரிகள்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Blueberries, Strawberries, Raspberries' : 'நீலப்பழம், ஸ்ட்ராபெர்ரி, ராஸ்பெர்ரி'),
            ),
            ListTile(
              leading: const Icon(Icons.eco),
              title: Text(_selectedLanguage == 'en' ? 'Leafy Greens' : 'இலைகள்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Spinach, Kale, Collard Greens' : 'கீரை, கேல், காலர்ட் கிரீன்ஸ்'),
            ),
            ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(_selectedLanguage == 'en' ? 'Olive Oil' : 'ஆலிவ் எண்ணெய்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Extra Virgin Olive Oil' : 'எக்ஸ்ட்ரா வர்ஜின் ஆலிவ் எண்ணெய்'),
            ),
            ListTile(
              leading: const Icon(Icons.grain),
              title: Text(_selectedLanguage == 'en' ? 'Whole Grains' : 'முழு தானியங்கள்'),
              subtitle: Text(_selectedLanguage == 'en' ? 'Oats, Brown Rice, Quinoa' : 'ஓட்ஸ், பிரவுன் அரிசி, கினோவா'),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedLanguage == 'en'
                  ? 'Note: Consult your doctor or dietitian for personalized advice.'
                  : 'குறிப்பு: தனிப்பட்ட ஆலோசனைக்கு உங்கள் மருத்துவர் அல்லது உணவு நிபுணரை அணுகவும்.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
