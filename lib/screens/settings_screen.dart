import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'en'; // 'en' or 'ta'
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

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            'Enable Notifications',
            'Receive updates about your health and appointments',
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            'Dark Mode',
            'Switch between light and dark theme',
            _darkModeEnabled,
            (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          _buildDropdownTile(
            _selectedLanguage == 'en' ? 'Language' : 'மொழி',
            _selectedLanguage == 'en' ? 'Select your preferred language' : 'உங்கள் விருப்பமான மொழியை தேர்ந்தெடுக்கவும்',
            _selectedLanguage,
            [
              'en',
              'ta',
            ],
            (value) {
              if (value != null) _setLanguage(value);
            },
            labels: {
              'en': 'English',
              'ta': 'தமிழ்',
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          _buildActionTile(
            'Change Password',
            'Update your account password',
            Icons.lock,
            () {
              // TODO: Implement change password
            },
          ),
          _buildActionTile(
            'Privacy Settings',
            'Manage your privacy preferences',
            Icons.privacy_tip,
            () {
              // TODO: Implement privacy settings
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildInfoTile(
            'App Version',
            '1.0.0',
            Icons.info,
          ),
          _buildActionTile(
            'Terms of Service',
            'Read our terms and conditions',
            Icons.description,
            () {
              // TODO: Show terms of service
            },
          ),
          _buildActionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.policy,
            () {
              // TODO: Show privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    {Map<String, String>? labels}
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(labels != null ? labels[item] ?? item : item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
} 